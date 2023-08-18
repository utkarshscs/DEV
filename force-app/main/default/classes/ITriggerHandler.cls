/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : Trigger Handler Interface
*/
public interface ITriggerHandler { 
    
    //Implements in before insert trigger handler.
    void beforeInsert(List<sObject> newList);
    //Implements in after insert trigger handler
    void afterInsert(List<sObject> newList, Map<Id, sObject> newMap);
    //Implements in before update trigger handler
    void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap);
    //Implements in after update trigger handler
    void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap);
    //Implements in before delete trigger handler
    void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap);
    //Implements in after delete trigger handler
    void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap);
    //Implements in after undelete trigger handler
    void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap);
}