/************************************************************************************************************************************************
Apex Class Name : sFilesBatchQueabletoUploadFiles
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchtoUploadFilesTest
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
**************************************************************************************************************************************************/
public class sFilesBatchQueabletoUploadFiles implements Queueable{
    
    List<ContentDocumentLink> conDocLinkList;
    List<Opportunity> opptyList;
    List<Account> accountList;
    List<Opportunity_Certificate__c> ocList;
    List<inspire1__Project__c> prjList;
    
    //Account
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    //Opportunity
    Map<Id, Opportunity> mapOppty = new Map<Id, Opportunity>();
    //Opportunity Certificate
    Map<Id, Opportunity_Certificate__c> mapOpptyCertificate = new Map<Id, Opportunity_Certificate__c>();
    //Project
    Map<Id, inspire1__Project__c> mapProject = new Map<Id, inspire1__Project__c>();
    Set<Id> contentDocIdSet = new Set<Id>();
    Map<Id, Id> mapContentDocProjectId = new Map<Id, Id>();
    Map<Id, Id> mapContentDocOpptyId = new Map<Id, Id>();
    Map<Id, Id> mapContentDocAccId = new Map<Id, Id>();
    Map<Id, Id> mapContentDocOpptyCertId = new Map<Id, Id>();
    
    public sFilesBatchQueabletoUploadFiles (List<ContentDocumentLink> contentDocLinkList, List<SObject> sObjList){
        conDocLinkList = contentDocLinkList;
        String strObjPrefix = String.valueOf(sObjList[0].Id).substring(0, 3);
        //Account
        if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix()){
            accountList = sObjList;
        }
        //Opportunity
        else if(strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix()){
            opptyList = sObjList;
        }
        //Opportunity Certificate
        else if(strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()){
            ocList = sObjList;
        }
        //Project
        else if(strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix()){
            prjList = sObjList;
        }
    }
    
    public void execute(QueueableContext context){
        
        //Map of Account
        if(accountList != null && !accountList.isEmpty()){
            for(Account acc : accountList){
                if(!mapAccount.containsKey(acc.Id)){
                    mapAccount.put(acc.Id, acc);
                }
            }
        }
        
        //Map of Opportunity
        if(opptyList != null && !opptyList.isEmpty()){
            for(Opportunity opp : opptyList){
                if(!mapOppty.containsKey(opp.Id)){
                    mapOppty.put(opp.Id, opp);
                }
            }
        }
        
        //Map of Opportunity Certificate
        if(ocList != null && !ocList.isEmpty()){
            for(Opportunity_Certificate__c oc : ocList){
                if(!mapOpptyCertificate.containsKey(oc.Id)){
                    mapOpptyCertificate.put(oc.Id, oc);
                }
            }
        }
        
        //Map of Project
        if(prjList != null && !prjList.isEmpty()){
            for(inspire1__Project__c prj : prjList){
                if(!mapProject.containsKey(prj.Id)){
                    mapProject.put(prj.Id, prj);
                }
            }
        }
        
        if(!conDocLinkList.isEmpty()){
            for(ContentDocumentLink cdl : conDocLinkList){
                contentDocIdSet.add(cdl.ContentDocumentId);
                
                String strObjPrefix = String.valueOf(cdl.LinkedEntityId).substring(0, 3);
                if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix()) {
                    if(!mapContentDocAccId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocAccId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
                else if(strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix()) {
                    if(!mapContentDocOpptyId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocOpptyId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
                else if(strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()) {
                    if(!mapContentDocOpptyCertId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocOpptyCertId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }		
                }
                else if(strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix()) {
                    if(!mapContentDocProjectId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocProjectId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }		
                }
            }
        }
        
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Initial_Folder_Structure__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Opportunity' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        
        if(!contentDocIdSet.isEmpty()){
            for(ContentVersion conVer : [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocIdSet]){
                String fileName = '';
                fileName = conVer.Title + '.' + conVer.FileExtension;
                Map<string,string> fields = new Map<string,string>();
                String strObjPrefix = '';
                if(mapContentDocAccId.containsKey(conVer.ContentDocumentId) && mapContentDocAccId.get(conVer.ContentDocumentId) != null){
                    strObjPrefix = String.valueOf(String.valueOf(mapContentDocAccId.get(conVer.ContentDocumentId)).substring(0, 3));
                    if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix()){
                        if(mapAccount.containsKey(mapContentDocAccId.get(conVer.ContentDocumentId)) && mapAccount.get(mapContentDocAccId.get(conVer.ContentDocumentId)) != null){
                            //fields.put('SalesforceId', mapAccount.get(mapContentDocAccId.get(conVer.ContentDocumentId)).Id);
                            fields.put('SalesforceId', conVer.ContentDocumentId);
                            
                            try{
                                if(!Test.isRunningTest()){
                                    apiClient.uploadLargeFile(mapAccount.get(mapContentDocAccId.get(conVer.ContentDocumentId)).SharePoint_Folder_Id__c, conVer.Title, conVer.Id, mapAccount.get(mapContentDocAccId.get(conVer.ContentDocumentId)).Id, fields, false, true);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                integrationLogs.add(log);
                            }
                        }
                    }
                }
                else if(mapContentDocOpptyId.containsKey(conVer.ContentDocumentId) && mapContentDocOpptyId.get(conVer.ContentDocumentId) != null){
                    strObjPrefix = String.valueOf(String.valueOf(mapContentDocOpptyId.get(conVer.ContentDocumentId)).substring(0, 3));
                    if(strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix()){
                        if(mapOppty.containsKey(mapContentDocOpptyId.get(conVer.ContentDocumentId)) && mapOppty.get(mapContentDocOpptyId.get(conVer.ContentDocumentId)) != null){
                            //fields.put('SalesforceId', mapOppty.get(mapContentDocOpptyId.get(conVer.ContentDocumentId)).Id);
                            fields.put('SalesforceId', conVer.ContentDocumentId);
                            try{
                                if(!Test.isRunningTest()){
                                    apiClient.uploadLargeFile(mapOppty.get(mapContentDocOpptyId.get(conVer.ContentDocumentId)).fileforcem1__Sharepoint_Folder_Id__c, conVer.Title, conVer.Id, mapOppty.get(mapContentDocOpptyId.get(conVer.ContentDocumentId)).Id, fields, false, true);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                integrationLogs.add(log);
                            }
                        }
                    }
                }
                else if(mapContentDocOpptyCertId.containsKey(conVer.ContentDocumentId) && mapContentDocOpptyCertId.get(conVer.ContentDocumentId) != null){
                    strObjPrefix = String.valueOf(String.valueOf(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)).substring(0, 3));
                    if(strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()){
                        if(mapOpptyCertificate.containsKey(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)) && mapOpptyCertificate.get(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)) != null){
                            //fields.put('SalesforceId', mapOpptyCertificate.get(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)).Id);
                            fields.put('SalesforceId', conVer.ContentDocumentId);
                            try{
                                if(!Test.isRunningTest()){
                                    apiClient.uploadLargeFile(mapOpptyCertificate.get(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)).SharePoint_Folder_Id__c, conVer.Title, conVer.Id, mapOpptyCertificate.get(mapContentDocOpptyCertId.get(conVer.ContentDocumentId)).Id, fields, false, true);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                integrationLogs.add(log);
                            }
                        }
                    }
                }
                else if(mapContentDocProjectId.containsKey(conVer.ContentDocumentId) && mapContentDocProjectId.get(conVer.ContentDocumentId) != null){
                    strObjPrefix = String.valueOf(String.valueOf(mapContentDocProjectId.get(conVer.ContentDocumentId)).substring(0, 3));
                    if(strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix()){
                        if(mapProject.containsKey(mapContentDocProjectId.get(conVer.ContentDocumentId)) && mapProject.get(mapContentDocProjectId.get(conVer.ContentDocumentId)) != null){
                            //fields.put('SalesforceId', mapProject.get(mapContentDocProjectId.get(conVer.ContentDocumentId)).Id);
                            fields.put('SalesforceId', conVer.ContentDocumentId);
                            try{
                                if(!Test.isRunningTest()){
                                    apiClient.uploadLargeFile(mapProject.get(mapContentDocProjectId.get(conVer.ContentDocumentId)).SharePoint_Folder_Id__c, conVer.Title, conVer.Id, mapProject.get(mapContentDocProjectId.get(conVer.ContentDocumentId)).Id, fields, false, true);
                                }
                            }
                            catch (Exception e){
                                Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                integrationLogs.add(log);
                            }
                        }
                    }
                }
            }
        }
        
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
    }
    
}