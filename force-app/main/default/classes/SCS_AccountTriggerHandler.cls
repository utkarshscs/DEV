/*
@Author : MAANTIC
@CreatedDate : 16th Sept 2022
@Description : Account Trigger Handler.
*/
/****************************** NEW ORG CODE *****************************************************/
public with sharing class SCS_AccountTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {}
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Call trigger helper to created standard covered for the opportunity...
        //SCS_AccountTriggerHelper.sFilesCreateAccountFolder((List<Account>)newList, null);  
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //SCS_AccountTriggerHelper.sFilesCreateAccountFolder((List<Account>)newList,(Map<Id,Account>) oldMap);
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
    
        AccountTriggerHandler.preventDeleteAccount(Trigger.old);
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
}