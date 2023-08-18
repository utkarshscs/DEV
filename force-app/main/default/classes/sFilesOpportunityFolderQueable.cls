/************************************************************************************************************************************************
Apex Class Name : sFilesOpportunityFolderQueable
Version         : 1.0
Created Date    : 
Function        : This class is used to create Opportunity folder on SharePoint.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	21/10/2022                            Initial version
**************************************************************************************************************************************************/
public class sFilesOpportunityFolderQueable implements Queueable, Database.AllowsCallouts{
    
    Set<Id> opptyIdSet;
    
    public sFilesOpportunityFolderQueable (Set<Id> triggeredOpptyIdSet){
        opptyIdSet = triggeredOpptyIdSet;
    }
    
    public void execute(QueueableContext context){
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        
        List<String> accountRTList = Label.Account_RecordType.contains(',')?Label.Account_RecordType.split(',') : new List<String>{Label.Account_RecordType};
            
            List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
                List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                    List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                                
        if(opptyIdSet != null && !opptyIdSet.isEmpty()){
            for(Opportunity opp : [Select Id, Name, RecordType.DeveloperName, AccountId,fileforcem1__Sharepoint_Folder_Id__c, SharePoint_Folder_URL__c, Account.OpportunityFolderSharePointId__c, Account.SCOpportunityFolderSharePointId__c, Account.SGSOpportunityFolderSharePointId__c, Account.SSOpportunityFolderSharePointId__c FROM Opportunity WHERE id IN:opptyIdSet AND Account.RecordType.DeveloperName IN:accountRTList]){
                fileforcem1.SharePointFileInfo opptyFolder;
                Map<string,string> fields = new Map<string,string>();
                String oppName = '';
                oppName = opp.Name;
                oppName = oppName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
                oppName = oppName.removeEnd('_');
                System.debug('oppName ======> '+oppName);
                try{
                    if(sgsOpptyRTList.contains(String.valueOf(opp.RecordType.DeveloperName)) && String.isNotBlank(opp.Account.SGSOpportunityFolderSharePointId__c)){
                        opptyFolder = createFolder(opp.Account.SGSOpportunityFolderSharePointId__c, oppName, null);
                    }
                    else if(scOpptyRTList.contains(String.valueOf(opp.RecordType.DeveloperName)) && String.isNotBlank(opp.Account.SCOpportunityFolderSharePointId__c)){
                        opptyFolder = createFolder(opp.Account.SCOpportunityFolderSharePointId__c, oppName, null);
                    }
                    else if(ssOpptyRTList.contains(String.valueOf(opp.RecordType.DeveloperName)) && String.isNotBlank(opp.Account.SSOpportunityFolderSharePointId__c)){
                        opptyFolder = createFolder(opp.Account.SSOpportunityFolderSharePointId__c, oppName, null);
                    }
                    
                    fields.put('SalesforceId',opp.Id);
                    if(opptyFolder != null && fields != null){
                        createFolder(opptyFolder.Id, '' ,fields);
                    }
                    
                    opp.fileforcem1__Sharepoint_Folder_Id__c = opptyFolder != null ? opptyFolder.Id : null;
                    opp.SharePoint_Folder_URL__c = opptyFolder != null ? opptyFolder.OpenUrl : null;
                    opptyListToUpdate.add(opp);
                }
                catch (Exception e){
                    Integration_Log__c log = new Integration_Log__c(Opportunity__c = opp.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                    integrationLogs.add(log);
                }
            }	
        }
        
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
        
        if(opptyListToUpdate != null && !opptyListToUpdate.isEmpty()){
            //update opptyListToUpdate;
            
            List<Database.SaveResult> dsrs = Database.Update(opptyListToUpdate, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    
                    Integration_Log__c log = new Integration_Log__c(Opportunity__c = opptyListToUpdate[index].Id, Integration_Status__c = 'DML Exception', Error_Message__c = errMsg);
                    integrationLogs.add(log);
                }
                index++;
            }
        }
    }
    
    Public static fileforcem1.SharePointFileInfo createFolder(String rootFolderId, String folderName, Map<string,string> fields){
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
    
}