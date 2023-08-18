/************************************************************************************************************************************************
Apex Class Name : sFilesBatchProjectFolder
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchProjectFolderTest
Description     : This batch class is used to create project folder on sharepoint
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          17/05/2023                            Initial version
**************************************************************************************************************************************************/
global class sFilesBatchProjectFolder implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    
    global database.querylocator start(database.batchableContext bc){
        String query;
        if(!Test.isRunningTest()){
            query = Label.Create_Folder_Batch_Query;
        }else{
            query = 'SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, inspire1__Account__c, inspire1__Opportunity1__c, inspire1__Opportunity1__r.RecordType.DeveloperName, inspire1__Opportunity1__r.Account.SGSOpportunityFolderSharePointId__c, inspire1__Opportunity1__r.Account.SCOpportunityFolderSharePointId__c, inspire1__Opportunity1__r.Account.SSOpportunityFolderSharePointId__c, inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c, inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c, inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c, inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c, inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c, inspire1__Account__r.AllProjectSCSharePointFolderId__c, inspire1__Account__r.AllProjectSGSSharePointFolderId__c, inspire1__Account__r.AllProjectSICSharePointFolderId__c, inspire1__Account__r.AllProjectSSSharePointFolderId__c, inspire1__Opportunity1__r.Account.SC_SharePoint_Folder_Id__c,inspire1__Opportunity1__r.Account.SS_SharePoint_Folder_Id__c, inspire1__Opportunity1__r.Account.SIC_SharePoint_Folder_Id__c, inspire1__Account__r.SharePoint_Folder_Id__c, inspire1__Account__r.SC_SharePoint_Folder_Id__c, inspire1__Account__r.SS_SharePoint_Folder_Id__c, inspire1__Account__r.SIC_SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c = null AND inspire1__Template__c = false';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<inspire1__Project__c> projectList){
        
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Account> accountList = new List<Account>();
        List<inspire1__Project__c> prjListToUpdate = new List<inspire1__Project__c>();        
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        //Getting Opportunity's SCS Global Services Entity from Custom Label
        List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
            //Getting Opportunity's SCS Consulting Entity from Custom Label
            List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                //Getting Opportunity's SCS Standard Entity from Custom Label
                List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                    //Getting Opportunity's SCS Ivory Coast Entity from Custom Label
                    List<String> sicOpptyRTList = Label.Opportunity_RT_SCS_Ivory_Coast.contains(',')?Label.Opportunity_RT_SCS_Ivory_Coast.split(',') : new List<String>{Label.Opportunity_RT_SCS_Ivory_Coast};
                        
                        for(inspire1__Project__c prj : projectList){
                            fileforcem1.SharePointFileInfo allPrjFolder;
                            fileforcem1.SharePointFileInfo prjFolder;
                            Map<string,string> fields = new Map<string,string>();
                            String prjName = '';
                            prjName = prj.Name;
                            prjName = prjName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
                            prjName = prjName.removeEnd('_');
                            
                            try{
                                if(prj.inspire1__Opportunity1__c != null){
                                    if(sgsOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(scOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SC_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(ssOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SS_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(sicOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SIC_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;prjListToUpdate.add(prj);
                                        }
                                    }
                                }
                                else if(prj.inspire1__Opportunity1__c == null && prj.inspire1__Account__c != null){
                                    if(sgsOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Account__r.AllProjectSGSSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSGSSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(scOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SC_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Account__r.AllProjectSCSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSCSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(ssOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SS_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Account__r.AllProjectSSSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSSSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                            prjListToUpdate.add(prj);
                                        }
                                    }
                                    else if(sicOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SIC_SharePoint_Folder_Id__c)){
                                        if(prj.inspire1__Account__r.AllProjectSICSharePointFolderId__c != null){
                                            prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSICSharePointFolderId__c, prjName, null);    
                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;prjListToUpdate.add(prj);
                                        }
                                    }
                                }
                                else if(prj.inspire1__Opportunity1__c == null && prj.inspire1__Account__c == null){
                                    if(sgsOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                        prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SGS, prjName, null);    
                                        prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                        prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                        prjListToUpdate.add(prj);
                                    }
                                    else if(scOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                        prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SC, prjName, null);    
                                        prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                        prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                        prjListToUpdate.add(prj);
                                    }
                                    else if(ssOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                        prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SS, prjName, null);    
                                        prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                        prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                        prjListToUpdate.add(prj);
                                    }
                                    else if(sicOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                        prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SIC, prjName, null);    
                                        prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;prjListToUpdate.add(prj);
                                    }
                                }
                                
                                fields.put('SalesforceId',prj.Id);
                                if(prjFolder != null && fields != null){
                                    createFolder(prjFolder.Id, '' ,fields);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Project__c = prj.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                integrationLogs.add(log);
                            }
                        }
        
        if(prjListToUpdate != null && !prjListToUpdate.isEmpty()){
            List<Database.SaveResult> dsrs = Database.Update(prjListToUpdate, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    
                    Integration_Log__c log = new Integration_Log__c(Project__c = prjListToUpdate[index].Id, Integration_Status__c = 'DML Exception', Error_Message__c = errMsg);
                    integrationLogs.add(log);
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