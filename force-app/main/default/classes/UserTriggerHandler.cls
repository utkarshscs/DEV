/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : User Object Trigger handler.
*/

public with sharing class UserTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList) {
    }
    //Call after insert...
    public void afterInsert(List<User> newList , Map<Id, sObject> newMap) {
        //Stop the recursion...
        if( UserTriggerHelper.isRecursive){
            UserTriggerHelper.isRecursive = false;
            //Call user trigger helper to add user into public group.
            UserTriggerHelper.addUserInPublicGroup(newList,null);
        }
        
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        //Stop the recursion...
        if(UserTriggerHelper.isRecursive){
            UserTriggerHelper.isRecursive = false;
            //Call user trigger helper to add user into public group.
            UserTriggerHelper.addUserInPublicGroup((List<User>)newList,( Map<Id, User>)oldMap);
        }  
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