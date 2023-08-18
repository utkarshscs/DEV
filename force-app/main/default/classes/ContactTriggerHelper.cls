/**
        Description    :   Handler for Contact Trigger
        Date           :   21st March, 2023
        Author         :   Utkarsh G (Maantic)
        Test Class     :   ContactTriggerHandlerTest
 */
public without sharing class ContactTriggerHelper implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        ContactTriggerHandler.beforeInsert((List<Contact>)newList); 
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {

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