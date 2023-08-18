/************************************************************************************************************************************************
Apex Class Name : sfilesBatchOCFolder
Version         : 1.0
Created Date    : 
Test Class      : sfilesBatchOCFolderTest
Description     : This batch class is used to create opportunity certificate folder on sharepoint
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          18/05/2023                            Initial version
**************************************************************************************************************************************************/
global class sfilesBatchOCFolder implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    
    global database.querylocator start(database.batchableContext bc){
        String query;
        if(!Test.isRunningTest()){
            query = Label.Create_Folder_Batch_Query;
        }else{
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, Opportunity__c, Opportunity__r.RecordType.DeveloperName, Opportunity__r.fileforcem1__Sharepoint_Folder_Id__c, Opportunity__r.Account.AllOCSCSharePointFolderId__c, Opportunity__r.Account.AllOCSGSSharePointFolderId__c, Opportunity__r.Account.AllOCSICSharePointFolderId__c, Opportunity__r.Account.AllOCSSSharePointFolderId__c, Opportunity__r.Account.SharePoint_Folder_Id__c, Opportunity__r.Account.SC_SharePoint_Folder_Id__c, Opportunity__r.Account.SS_SharePoint_Folder_Id__c, Opportunity__r.Account.SIC_SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE SharePoint_Folder_Id__c = null';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<Opportunity_Certificate__c> ocList){
        
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Account> accountList = new List<Account>();
        List<Opportunity_Certificate__c> opptyCertList = new List<Opportunity_Certificate__c>();
        
        //Getting Opportunity's SCS Global Services Entity from Custom Label
        List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
            //Getting Opportunity's SCS Consulting Entity from Custom Label
            List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                //Getting Opportunity's SCS Standard Entity from Custom Label
                List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                    //Getting Opportunity's SCS Ivory Coast Entity from Custom Label
                    List<String> sicOpptyRTList = Label.Opportunity_RT_SCS_Ivory_Coast.contains(',')?Label.Opportunity_RT_SCS_Ivory_Coast.split(',') : new List<String>{Label.Opportunity_RT_SCS_Ivory_Coast};
                        
                        for(Opportunity_Certificate__c oppCert : ocList){
                            fileforcem1.SharePointFileInfo oppCertFolder;
                            fileforcem1.SharePointFileInfo oppCertChildFolder;
                            Map<string,string> fields = new Map<string,string>();
                            try{
                                if(sgsOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SharePoint_Folder_Id__c)){
                                    if(oppCert.Opportunity__r.Account.AllOCSGSSharePointFolderId__c != null){
                                        oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSGSSharePointFolderId__c, oppCert.Name, null);
                                        oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                        oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                        opptyCertList.add(oppCert);
                                    }
                                }
                                else if(scOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SC_SharePoint_Folder_Id__c)){
                                    if(oppCert.Opportunity__r.Account.AllOCSCSharePointFolderId__c != null){
                                        oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSCSharePointFolderId__c, oppCert.Name, null);
                                        oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                        oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                        opptyCertList.add(oppCert);
                                    }
                                }
                                else if(ssOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SS_SharePoint_Folder_Id__c)){
                                    if(oppCert.Opportunity__r.Account.AllOCSSSharePointFolderId__c != null){
                                        oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSSSharePointFolderId__c, oppCert.Name, null);
                                        oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                        oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                        opptyCertList.add(oppCert);
                                    }
                                }
                                else if(sicOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SIC_SharePoint_Folder_Id__c)){
                                    if(oppCert.Opportunity__r.Account.AllOCSICSharePointFolderId__c != null){
                                        oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSICSharePointFolderId__c, oppCert.Name, null);
                                        oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;opptyCertList.add(oppCert);
                                    }
                                }
                                
                                fields.put('SalesforceId',oppCert.Id);
                                if(oppCert != null && fields != null){
                                    createFolder(oppCertChildFolder.Id, '' ,fields);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Opportunity_Certificate__c = oppCert.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);
                            }
                        }
        
        if(opptyCertList != null && !opptyCertList.isEmpty()){
            update opptyCertList;  
        }
        
        if(opptyCertList != null && !opptyCertList.isEmpty()){
            List<Database.SaveResult> dsrs = Database.Update(opptyCertList, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    
                    Integration_Log__c log = new Integration_Log__c(Opportunity_Certificate__c = opptyCertList[index].Id, Integration_Status__c = 'DML Exception', Error_Message__c = errMsg);integrationLogs.add(log);
                }
                index++;
            }
        }
        
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