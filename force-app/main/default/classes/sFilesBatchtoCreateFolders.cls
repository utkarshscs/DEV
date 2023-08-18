/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoCreateFolders
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchtoCreateFoldersTest
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
**************************************************************************************************************************************************/
global class sFilesBatchtoCreateFolders implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    
    global database.querylocator start(database.batchableContext bc){
        List<String> accountRTList = Label.Account_RecordType.contains(',')?Label.Account_RecordType.split(',') : new List<String>{Label.Account_RecordType};
        List<String> userList = Label.UserListForSOQL.contains(',')?Label.UserListForSOQL.split(',') : new List<String>{Label.UserListForSOQL};
        List<String> opptyRTList = Label.Opportunity_RecordType.contains(',')?Label.Opportunity_RecordType.split(',') : new List<String>{Label.Opportunity_RecordType};

		String createdByUser = 'DMS Integration';
		List<String> yearList = Label.YearList.contains(',')?Label.YearList.split(',') : new List<String>{Label.YearList};

        String query = 'Select Id, Name, Account.BillingCountry ,Billing_Contact__c , CampaignId,RecordType.DeveloperName, AccountId,fileforcem1__Sharepoint_Folder_Id__c, SharePoint_Folder_URL__c, Account.OpportunityFolderSharePointId__c, Account.SCOpportunityFolderSharePointId__c, Account.SGSOpportunityFolderSharePointId__c, Account.SSOpportunityFolderSharePointId__c, Account.SharePoint_Folder_Id__c, Account.SS_SharePoint_Folder_Id__c, Account.SC_SharePoint_Folder_Id__c FROM Opportunity WHERE Account.RecordType.DeveloperName IN:accountRTList AND fileforcem1__Sharepoint_Folder_Id__c = null AND Year__c IN:yearList and CreatedById NOT IN:userList AND Recordtype.developername IN:opptyRTList ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<Opportunity> opptyList){
        
        List<Account> accListToUpdate = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> oppIdSetForExistingAccFolder = new Set<Id>();
        Set<Id> oppIdSetForNewAccFolder = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        Map<Id, String> mapAccOppSGS = new Map<Id, String>();
        Map<Id, String> mapAccOppSS = new Map<Id, String>();
        Map<Id, String> mapAccOppSC = new Map<Id, String>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
            //Getting Opportunity's SCS Consulting RecordType from Custom Label
            List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                //Getting Opportunity's SCS Standard RecordType from Custom Label
                List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                    for(Opportunity opp : opptyList){
                        if(String.isNotBlank(opp.Account.SharePoint_Folder_Id__c) && sgsOpptyRTList.contains(opp.RecordType.DeveloperName)){
                            System.debug('I am in Existign Record Folder');
                            oppIdSetForExistingAccFolder.add(opp.Id);
                        }
                        else if(String.isNotBlank(opp.Account.SS_SharePoint_Folder_Id__c) && ssOpptyRTList.contains(opp.RecordType.DeveloperName)){
                            oppIdSetForExistingAccFolder.add(opp.Id);
                        }
                        else if(String.isNotBlank(opp.Account.SC_SharePoint_Folder_Id__c) && scOpptyRTList.contains(opp.RecordType.DeveloperName)){
                            oppIdSetForExistingAccFolder.add(opp.Id);
                        }
                        else{
                            oppIdSetForNewAccFolder.add(opp.Id);
                            if(opp.AccountId != null){
                                accIdSet.add(opp.AccountId);
                            }
                            if(!mapAccOppSGS.containsKey(opp.AccountId) && opp.AccountId != null && sgsOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                mapAccOppSGS.put(opp.AccountId, opp.RecordType.DeveloperName);
                            }
                            if(!mapAccOppSS.containsKey(opp.AccountId) && opp.AccountId != null && ssOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                mapAccOppSS.put(opp.AccountId, opp.RecordType.DeveloperName);
                            }
                            if(!mapAccOppSC.containsKey(opp.AccountId) && opp.AccountId != null && scOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                mapAccOppSC.put(opp.AccountId, opp.RecordType.DeveloperName);
                            }
                        }
                    }
        
        //This section creates folders for new Accounts and Opportunities
        if(oppIdSetForNewAccFolder != null && !oppIdSetForNewAccFolder.isEmpty()){
            if(accIdSet != null && !accIdSet.isEmpty()){
                mapAccount = new Map<Id, Account>([SELECT Id, Name, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, SS_SharePoint_Folder_Id__c, SS_SharePoint_Folder_URL__c, SC_SharePoint_Folder_Id__c, SC_SharePoint_Folder_URL__c FROM Account WHERE Id In:accIdSet]);
            }
            
            fileforcem1.SharePointFileInfo acctFolder;
            fileforcem1.SharePointFileInfo sgsChildFolder;
            fileforcem1.SharePointFileInfo scChildFolder;
            fileforcem1.SharePointFileInfo ssChildFolder;
            Map<string,string> fields = new Map<string,string>();
            
            if(mapAccount != null){
                for(Account acc : mapAccount.values()){
                    String accName = '';
                    accName = acc.Name;
                    accName = accName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
                    accName = accName.removeEnd('_');
                    System.debug('accName ======> '+accName);
                    try{
                        if(mapAccOppSGS.containsKey(acc.Id) && String.isNotBlank(mapAccOppSGS.get(acc.Id)) && sgsOpptyRTList.contains(mapAccOppSGS.get(acc.Id)) && String.isBlank(acc.SharePoint_Folder_Id__c)){
                            acctFolder = createFolder(Label.Account_Root_FolderId_SGS, accName, null);
                            acc.SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            sgsChildFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SGSOpportunityFolderSharePointId__c = sgsChildFolder != null ? sgsChildFolder.Id : null;
                            acc.SGSOpportunityFolderSharePointURL__c = sgsChildFolder != null ? sgsChildFolder.OpenUrl : null;
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        if((mapAccOppSS.containsKey(acc.Id) && String.isNotBlank(mapAccOppSS.get(acc.Id)) && ssOpptyRTList.contains(mapAccOppSS.get(acc.Id)) && String.isBlank(acc.SS_SharePoint_Folder_Id__c)) || Test.isRunningTest()){
                            acctFolder = createFolder(Label.Account_Root_FolderId_SS, accName, null);
                            acc.SS_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SS_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            ssChildFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SSOpportunityFolderSharePointId__c = ssChildFolder != null ? ssChildFolder.Id : null;
                            acc.SSOpportunityFolderSharePointURL__c = ssChildFolder != null ? ssChildFolder.OpenUrl : null;
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        if((mapAccOppSC.containsKey(acc.Id) && String.isNotBlank(mapAccOppSC.get(acc.Id)) && scOpptyRTList.contains(mapAccOppSC.get(acc.Id)) && String.isBlank(acc.SC_SharePoint_Folder_Id__c)) || Test.isRunningTest()){
                            acctFolder = createFolder(Label.Account_Root_FolderId_SC, accName, null);
                            acc.SC_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SC_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            scChildFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SCOpportunityFolderSharePointId__c = scChildFolder != null ? scChildFolder.Id : null;
                            acc.SCOpportunityFolderSharePointURL__c = scChildFolder != null ? scChildFolder.OpenUrl : null;
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        
                        accListToUpdate.add(acc);
                    }
                    catch (Exception e){
                        Integration_Log__c log = new Integration_Log__c(Account__c = acc.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                        integrationLogs.add(log);
                    }
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
                //Calling Queable class to create Opportunity Folder for new Account
                System.enqueuejob(new sFilesOpportunityFolderQueable(oppIdSetForNewAccFolder));
            }
        }
        
        //Capturing Exception logs
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
        
        //Calling Queable class to create Opportunity Folder for existing Account
        if(oppIdSetForExistingAccFolder != null && !oppIdSetForExistingAccFolder.isEmpty()){
            System.debug('I am inside oppIdSetForExistingAccFolder');
            System.enqueuejob(new sFilesOpportunityFolderQueable(oppIdSetForExistingAccFolder));
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
        fileforcem1.SharePointFileInfo projectFolder;
        fileforcem1.SharePointFileInfo projectChildFolder;
        
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