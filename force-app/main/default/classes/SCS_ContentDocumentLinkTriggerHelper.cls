public with sharing class SCS_ContentDocumentLinkTriggerHelper {
    
    //This method uploads the file in sharepoint folder
    public static void uploadFileInSharePoint(List<ContentDocumentLink> newList){
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        for(ContentDocumentLink contentDocLink : newList) {
            String strObjPrefix = String.valueOf(contentDocLink.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix() || strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix() || strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix() || strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()) {
                System.debug('strObjPrefix-9- '+strObjPrefix);
                contentDocList.add(contentDocLink);
            }
        }
        
        if(contentDocList != null && !contentDocList.isEmpty()){
            System.enqueuejob(new sFilesQueable(contentDocList));
        }
    }
    
    //This method update the content version of the file when file is sent from Email Message
    /*public static void updateContentVersion(List<ContentDocumentLink> newList){
        List<ContentVersion> conVerListToUpdate = new List<ContentVersion>();
        Set<Id> contentDocIdSet = new Set<Id>();
        for(ContentDocumentLink contentDocLink : newList) {
            String strObjPrefix = String.valueOf(contentDocLink.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == EmailMessage.sObjectType.getDescribe().getKeyPrefix()){
                contentDocIdSet.add(contentDocLink.ContentDocumentId);
            }
        }
        
        if(!contentDocIdSet.isEmpty()){
            for(ContentVersion conVer : [SELECT Id, Title, FileExtension, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN:contentDocIdSet]){
                conVer.Sent__c = true;
                conVerListToUpdate.add(conVer);
            }
        }
        
        if(!conVerListToUpdate.isEmpty()){
            update conVerListToUpdate;
        }
    }*/

}