/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : Project Comment Object Trigger handler.
*/
public with sharing class ProjectCommentTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Project_Comments__c> newList) {
        //Stop the recursion...
        if(ProjectCommentTriggerHelper.isRecursive){
            ProjectCommentTriggerHelper.isRecursive = false;
            //Call project comment trigger helper to create contact and stakeholder... 
            ProjectCommentTriggerHelper.createStakeholderAndContact(newList); 
        }
    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
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