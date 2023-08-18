/************************************************************************************************************************************************
Apex Class Name : sFilesBatchAccountSCFolder
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchAccountSCFolderTest
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
//Query for all account
//String query = 'SELECT Id, Name, SC_SharePoint_Folder_Id__c, SC_SharePoint_Folder_URL__c, SCOpportunityFolderSharePointId__c, SCOpportunityFolderSharePointURL__c, AllProjectSCSharePointFolderId__c, AllProjectSCSharePointFolderURL__c, AllOCSCSharePointFolderId__c, AllOCSCSharePointFolderURL__c FROM Account WHERE Id IN(SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName IN:opptyRTList AND fileforcem1__Sharepoint_Folder_Id__c = null AND HasFile__c = True) AND RecordType.DeveloperName IN:accountRTList';
**************************************************************************************************************************************************/
global class sFilesBatchAccountSCFolder implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    
    global database.querylocator start(database.batchableContext bc){
        List<String> accountRTList = Label.Account_RecordType.contains(',')?Label.Account_RecordType.split(',') : new List<String>{Label.Account_RecordType};
            List<String> userList = Label.UserListForSOQL.contains(',')?Label.UserListForSOQL.split(',') : new List<String>{Label.UserListForSOQL};
                List<String> opptyRTList = Label.Opportunity_RecordType.contains(',')?Label.Opportunity_RecordType.split(',') : new List<String>{Label.Opportunity_RecordType};
                    
                    List<String> yearList = Label.YearList.contains(',')?Label.YearList.split(',') : new List<String>{Label.YearList};
                        String query;
        if(!Test.isRunningTest()){
            query = Label.Create_Folder_Batch_Query;
        }else{
            query = 'SELECT Id, Name, SS_SharePoint_Folder_Id__c, SS_SharePoint_Folder_URL__c, SSOpportunityFolderSharePointId__c, SSOpportunityFolderSharePointURL__c, AllProjectSSSharePointFolderId__c, AllProjectSSSharePointFolderURL__c, AllOCSSSharePointFolderId__c, AllOCSSSharePointFolderURL__c FROM Account WHERE Id IN(SELECT AccountId FROM Opportunity WHERE fileforcem1__Sharepoint_Folder_Id__c = null) LIMIT 1';
        }
        System.debug('query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<Account> accList){
        
        List<Account> accListToUpdate = new List<Account>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        fileforcem1.SharePointFileInfo acctFolder;
        fileforcem1.SharePointFileInfo scAllOpptyFolder;
        fileforcem1.SharePointFileInfo scAllPrjFolder;
        fileforcem1.SharePointFileInfo scAllOCFolder;
        
        Map<string,string> fields = new Map<string,string>();
        
        for(Account acc : accList){
            String accName = '';
            accName = acc.Name;
            accName = accName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
            accName = accName.removeEnd('_');
            System.debug('accName ======> '+accName);
            try{
                //Creating account folder
                acctFolder = createFolder(Label.Account_Root_FolderId_SC, accName, null);
                acc.SC_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                acc.SC_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                //Creating all opportunity folder
                scAllOpptyFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                acc.SCOpportunityFolderSharePointId__c = scAllOpptyFolder != null ? scAllOpptyFolder.Id : null;
                acc.SCOpportunityFolderSharePointURL__c = scAllOpptyFolder != null ? scAllOpptyFolder.OpenUrl : null;
                //Creating all projects folder
                scAllPrjFolder = createFolder(acctFolder.Id, Label.All_Projects_SharePoint_FolderName, null);
                acc.AllProjectSCSharePointFolderId__c = scAllPrjFolder != null ? scAllPrjFolder.Id : null;
                acc.AllProjectSCSharePointFolderURL__c = scAllPrjFolder != null ? scAllPrjFolder.OpenUrl : null;
                //Creating all oc's folder
                scAllOCFolder = createFolder(acctFolder.Id, Label.All_OppCert_SharePoint_FolderName, null);
                acc.AllOCSCSharePointFolderId__c = scAllOCFolder != null ? scAllOCFolder.Id : null;
                acc.AllOCSCSharePointFolderURL__c = scAllOCFolder != null ? scAllOCFolder.OpenUrl : null;
                
                fields = new Map<string,string>();
                fields.put('SalesforceId',acc.Id);
                if(acctFolder != null && fields != null){
                    createFolder(acctFolder.Id, '',fields);
                }
                accListToUpdate.add(acc);
            }
            catch (Exception e){
                Integration_Log__c log = new Integration_Log__c(Account__c = acc.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                integrationLogs.add(log);
            }
        }
        
        if(accListToUpdate != null && !accListToUpdate.isEmpty()){
            List<Database.SaveResult> dsrs = Database.Update(accListToUpdate, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    
                    Integration_Log__c log = new Integration_Log__c(Account__c = accListToUpdate[index].Id, Integration_Status__c = 'DML Exception', Error_Message__c = errMsg);
                    integrationLogs.add(log);
                }
                index++;
            }
        }
        
        //Capturing Exception logs
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
    }
    
    public static fileforcem1.SharePointFileInfo createFolder(String rootFolderId, String folderName, Map<string,string> fields){
        fileforcem1.SharePointFileInfo folder;
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Account' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        if(!Test.isRunningTest()){
            if(fields == null && String.isNotBlank(rootFolderId) && String.isNotBlank(folderName)){
                folder = apiClient.createFolder(rootFolderId, folderName);
            }
            else{
                folder = apiClient.updateCustomFields(rootFolderId,fields);
            }
        }
        else{
            String jsonString1 = '{"ApiActionStatus":null,"CreatedBy":null, "CreatedDateTime":null, "CustomFields":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":null, "FormattedLastModified":null, "Id":"01ZEWS4T24FTSQMPOYZND3Z4VEGORXFNLU", "Index":null, "ModifiedBy":null, "Name":"007AAbb", "NameWithoutExt":"007AAbb", "NextLink":null, "OpenUrl":"https://scsglobalservices.sharepoint.com/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "ParentId":"01ZEWS4T7GSH5FJ4YC7NDIRHROT7HKKVF7", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FQA", "RootLevel":null, "SalesforceId":null, "SecurityFields":null, "SharepointGuid":null, "SharepointListId":null, "Size":"0 bytes", "Type":"Folder", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "items":null}';
            folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
        }
        return folder;
    }
    
    global void finish(database.batchableContext bc){
        
    }
    
    
}