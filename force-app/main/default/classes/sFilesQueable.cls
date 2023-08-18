public class sFilesQueable implements Queueable{
    
    List<ContentDocumentLink> contentDocList;
    
    public sFilesQueable (List<ContentDocumentLink> triggeredcontentDocLinkList){
        contentDocList = triggeredcontentDocLinkList;
    }
    
    public void execute(QueueableContext context){
        //Opportunity
        Set<Id> contentDocOppIdSet = new Set<Id>();
        Map<Id, String> mapOppty = new Map<Id, String>();
        Map<Id, Id> mapContentDocOpptyId = new Map<Id, Id>();
        Map<Id, Id> mapContentOpptyId = new Map<Id, Id>();
        //Project
        Set<Id> contentDocProjectIdSet = new Set<Id>();
        Map<Id, String> mapProject = new Map<Id, String>();
        Map<Id, Id> mapContentDocProjectId = new Map<Id, Id>();
        Map<Id, Id> mapContentProjectId = new Map<Id, Id>();
        //Opportunity Certificate
        Set<Id> contentDocOppCertIdSet = new Set<Id>();
        Map<Id, String> mapOppCert = new Map<Id, String>();
        Map<Id, Id> mapContentDocOpptyCertId = new Map<Id, Id>();
        Map<Id, Id> mapContentOpptyCertId = new Map<Id, Id>();
        //Account
        Set<Id> contentDocAccIdSet = new Set<Id>();
        Map<Id, String> mapAccount = new Map<Id, String>();
        Map<Id, Id> mapContentDocAccId = new Map<Id, Id>();
        Map<Id, Id> mapContentAccId = new Map<Id, Id>();
        
        if(contentDocList != null && !contentDocList.isEmpty()){
            for(ContentDocumentLink cdl : contentDocList){
                String strObjPrefix = String.valueOf(cdl.LinkedEntityId).substring(0, 3);
                if(strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix()) {
                    //Opportunity
                    contentDocOppIdSet.add(cdl.ContentDocumentId);
                    if(!mapContentOpptyId.containsKey(cdl.LinkedEntityId)){
                        mapContentOpptyId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                    if(!mapContentDocOpptyId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocOpptyId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }else if(strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix()){
                    //Project
                    contentDocProjectIdSet.add(cdl.ContentDocumentId);
                    if(!mapContentProjectId.containsKey(cdl.LinkedEntityId)){
                        mapContentProjectId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                    if(!mapContentDocProjectId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocProjectId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
                else if(strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()){
                    //Opportunity Certificate
                    contentDocOppCertIdSet.add(cdl.ContentDocumentId);
                    if(!mapContentOpptyCertId.containsKey(cdl.LinkedEntityId)){
                        mapContentOpptyCertId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                    if(!mapContentDocOpptyCertId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocOpptyCertId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
                else if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix()){
                    //Account
                    contentDocAccIdSet.add(cdl.ContentDocumentId);
                    if(!mapContentAccId.containsKey(cdl.LinkedEntityId)){
                        mapContentAccId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                    if(!mapContentDocAccId.containsKey(cdl.ContentDocumentId)){
                        mapContentDocAccId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
            }
        }
        //Opportunity
        List<ContentVersion> conVerListOpp = [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocOppIdSet];
        if(mapContentOpptyId != null && !mapContentOpptyId.isEmpty()){
            for(Opportunity opp : [SELECT Id, fileforcem1__Sharepoint_Folder_Id__c, Name FROM Opportunity WHERE Id IN:mapContentOpptyId.keySet()]){
                if(!mapOppty.containsKey(mapContentOpptyId.get(opp.Id))){
                    mapOppty.put(mapContentOpptyId.get(opp.Id), opp.fileforcem1__Sharepoint_Folder_Id__c);
                }
            }
        }
        //Project
        List<ContentVersion> conVerListProject = [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocProjectIdSet];
        if(mapContentProjectId != null && !mapContentProjectId.isEmpty()){
            for(inspire1__Project__c pro : [SELECT Id, SharePoint_Folder_Id__c, Name FROM inspire1__Project__c WHERE Id IN:mapContentProjectId.keySet()]){
                if(!mapProject.containsKey(mapContentProjectId.get(pro.Id))){
                    mapProject.put(mapContentProjectId.get(pro.Id), pro.SharePoint_Folder_Id__c);
                }
            }
        }
        
        //Opportunity Certificate
        List<ContentVersion> conVerListOppCert = [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocOppCertIdSet];
        System.debug('conVerListOppCert-9- '+conVerListOppCert);
        if(mapContentOpptyCertId != null && !mapContentOpptyCertId.isEmpty()){
            for(Opportunity_Certificate__c oppCert : [SELECT Id, SharePoint_Folder_Id__c, Name FROM Opportunity_Certificate__c WHERE Id IN:mapContentOpptyCertId.keySet()]){
                if(!mapOppCert.containsKey(mapContentOpptyCertId.get(oppCert.Id))){
                    mapOppCert.put(mapContentOpptyCertId.get(oppCert.Id), oppCert.SharePoint_Folder_Id__c);
                }
            }
        }
        
        //Account
        List<ContentVersion> conVerListAcc = [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocAccIdSet];
        System.debug('conVerListAcc-9- '+conVerListAcc);
        if(mapContentAccId != null && !mapContentAccId.isEmpty()){
            for(Account acc : [SELECT Id, SharePoint_Folder_Id__c, Name FROM Account WHERE Id IN:mapContentAccId.keySet()]){
                if(!mapAccount.containsKey(mapContentAccId.get(acc.Id))){
                    mapAccount.put(mapContentAccId.get(acc.Id), acc.SharePoint_Folder_Id__c);
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
        
        //Opportunity
        if(conVerListOpp != null && !conVerListOpp.isEmpty()){
            for(ContentVersion conVer : conVerListOpp){
                String title = conVer.Title.removeEnd('.pdf');
                String fileName = '';
                fileName = title + '.' + conVer.FileExtension;
                Map<string,string> fields = new Map<string,string>();
                fields.put('SalesforceId',mapContentDocOpptyId.get(conVer.ContentDocumentId));
                //fields.put('ContentVersionId',conVer.Id);
                try{
                    if(!Test.isRunningTest()){apiClient.uploadLargeFile(mapOppty.get(conVer.ContentDocumentId), fileName,conVer.Id,mapContentDocOpptyId.get(conVer.ContentDocumentId),fields,false,true);}
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage()); integrationLogs.add(log);}
            }
        }
        
        //Project
        if(conVerListProject != null && !conVerListProject.isEmpty()){
            for(ContentVersion conVer : conVerListProject){
                String fileName = '';
                fileName = conVer.Title + '.' + conVer.FileExtension;
                Map<string,string> fields = new Map<string,string>();
                fields.put('SalesforceId',mapContentDocProjectId.get(conVer.ContentDocumentId));
                try{
                    if(!Test.isRunningTest()){apiClient.uploadLargeFile(mapProject.get(conVer.ContentDocumentId), fileName,conVer.Id,mapContentDocProjectId.get(conVer.ContentDocumentId),fields,false,true);}
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);}
            }
        }
        
        //Opportunity Certificate
        if(conVerListOppCert != null && !conVerListOppCert.isEmpty()){
            for(ContentVersion conVer : conVerListOppCert){
                String title = conVer.Title.removeEnd('.pdf');
                String fileName = '';
                fileName = title + '.' + conVer.FileExtension;
                Map<string,string> fields = new Map<string,string>();
                fields.put('SalesforceId',mapContentDocOpptyCertId.get(conVer.ContentDocumentId));
                try{
                    if(!Test.isRunningTest()){apiClient.uploadLargeFile(mapOppCert.get(conVer.ContentDocumentId), fileName,conVer.Id,mapContentDocOpptyCertId.get(conVer.ContentDocumentId),fields,false,true);}
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);
                }
            }
        }
        
        //Account
        if(conVerListAcc != null && !conVerListAcc.isEmpty()){
            for(ContentVersion conVer : conVerListAcc){
                String fileName = '';
                fileName = conVer.Title + '.' + conVer.FileExtension;
                Map<string,string> fields = new Map<string,string>();
                fields.put('SalesforceId',mapContentDocAccId.get(conVer.ContentDocumentId));
                try{
                    if(!Test.isRunningTest()){apiClient.uploadLargeFile(mapAccount.get(conVer.ContentDocumentId), fileName,conVer.Id,mapContentDocAccId.get(conVer.ContentDocumentId),fields,false,true);}
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);
                }
            }
        }
        
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
    }
}