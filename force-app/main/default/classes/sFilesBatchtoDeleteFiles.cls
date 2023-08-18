/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoDeleteFiles
Version         : 1.0
Created Date    : 
Function        : This class is used to delete files from Opportunity.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	21/10/2022                            Initial version
**************************************************************************************************************************************************/
global class sFilesBatchtoDeleteFiles implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful, schedulable{
    
    global void execute(SchedulableContext sc){
        sFilesBatchtoDeleteFiles batch = new sFilesBatchtoDeleteFiles();
        Database.executeBatch(batch, 100);
    }
    
    global database.querylocator start(database.batchableContext bc){
        String query = '';
        Date today = System.today();
        Datetime Date15th = datetime.newinstance(today.year(), (today.month()), 15);
        String stringDate = string.valueof(Date15th);
        List<String> res = stringDate.split(' ');
        stringDate = res[0]+'T00:00:00Z';
        if(today > Date15th) {
            query = 'Select Id, Name, AccountId,fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHere fileforcem1__Sharepoint_Folder_Id__c != null AND CreatedDate < '+stringDate;
        }
        else {
            query = 'Select Id, Name, AccountId,fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHere fileforcem1__Sharepoint_Folder_Id__c != null AND CreatedDate < THIS_MONTH';
        }
        system.debug(query);
        return Database.getQueryLocator(query);
        //return Database.getQueryLocator([Select Id, Name, AccountId,fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHere fileforcem1__Sharepoint_Folder_Id__c != null AND CreatedDate = LAST_N_DAYS:4]);
    }
    
    global void execute(database.batchableContext bc, List<Opportunity> opptyList){
        System.debug('opptyList-- '+opptyList);
        List<fileforcem1.SharePointFileInfo> sharePointFileInfoList = new List<fileforcem1.SharePointFileInfo>();
        List<String> fileNameList = new List<String>();
        List <ContentDocument> listFiles = new List<ContentDocument>();
        List <ContentDocument> listFilesToDelete = new List<ContentDocument>();
        Set<Id> opptyIdSet = new Set<Id>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Initial_Folder_Structure__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Account' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        for(Opportunity opp : opptyList){
            List<fileforcem1.SharePointFileInfo> opptyFilesInfo = new List<fileforcem1.SharePointFileInfo>();
            opptyIdSet.add(opp.Id);
            try{
                if(!Test.isRunningTest()){
                    opptyFilesInfo = apiClient.getFolderContents(opp.fileforcem1__Sharepoint_Folder_Id__c, false);
                }
                else{
                    String dummyString = '[{"ApiActionStatus":null,"CreatedBy":null, "CreatedDateTime":null, "CustomFields":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":null, "FormattedLastModified":null, "Id":"01ZEWS4T24FTSQMPOYZND3Z4VEGORXFNLU", "Index":null, "ModifiedBy":null, "Name":"007AAbb", "NameWithoutExt":"007AAbb", "NextLink":null, "OpenUrl":"https://scsglobalservices.sharepoint.com/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "ParentId":"01ZEWS4T7GSH5FJ4YC7NDIRHROT7HKKVF7", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FQA", "RootLevel":null, "SalesforceId":null, "SecurityFields":null, "SharepointGuid":null, "SharepointListId":null, "Size":"0 bytes", "Type":"Folder", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "items":null}]';
                    opptyFilesInfo = (List<fileforcem1.SharePointFileInfo>)JSON.deserialize(dummyString, List<fileforcem1.SharePointFileInfo>.class);
                }
                sharePointFileInfoList.addAll(opptyFilesInfo);
            }
            catch (Exception e){
                Integration_Log__c log = new Integration_Log__c(Opportunity__c = opp.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
           		integrationLogs.add(log);
            }
        }
        
        //Create log...
        if(!integrationLogs.isEmpty()){
            Database.insert(integrationLogs,false);
        }
        
        for(fileforcem1.SharePointFileInfo sInfo : sharePointFileInfoList){
            fileNameList.add(sInfo.NameWithoutExt);
        }
        
        if(fileNameList != null && !fileNameList.isEmpty()){
            for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocument.Title IN:fileNameList AND LinkedEntityId IN:opptyIdSet]){
                listFilesToDelete.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }
        }
        
        if(listFilesToDelete.size() > 0) {
            Delete listFilesToDelete;
        }
        
    }
    
    global void finish(database.batchableContext bc){
        
    }
    
    
}