public with sharing class SCS_ContentDocumentLinkTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {}
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Call trigger helper to created standard covered for the opportunity...
        SCS_ContentDocumentLinkTriggerHelper.uploadFileInSharePoint((List<ContentDocumentLink>)newList);
        //SCS_ContentDocumentLinkTriggerHelper.updateContentVersion((List<ContentDocumentLink>)newList);
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
       
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
}