/*
@Author : MAANTIC
@CreatedDate : 7th April, 2023
@Description : CAP Trigger Handler

*/
/****************************** NEW ORG CODE *****************************************************/
public class SCS_CorrectiveActionPlanTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList) {

        
        SCS_CorrectiveActionPlanTriggerHelper.beforeCall(null, null, (List<Corrective_Action_Plan__c>)newList);

    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {

    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

        SCS_CorrectiveActionPlanTriggerHelper.beforeCall((Map<Id,Corrective_Action_Plan__c>)oldMap, (Map<Id,Corrective_Action_Plan__c>)newMap, null);

    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) { 
    }
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {

    }
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {  
    }
}