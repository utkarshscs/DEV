/*
@Author : MAANTIC
@CreatedDate : 30 November 2022
@Description : Opportunity Object Trigger Handler.
Date: 30/11/2022
Created By: Sohit Tripathi
*/
public with sharing class OpportunityCertificateTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList) {
        FSC_AAFCalculation.culationAAFOnCreation((List<Opportunity_Certificate__c>)newList);
    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        //Call trigger helper method to create Opportunity folder on SharePoint...
        OpportunityCertificateTriggerHelper.sFilesCreateOpportunityCertFolder((List<Opportunity_Certificate__c>)newList, null);  
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        FSC_AAFCalculation.culationAAFOnUpdate((List<Opportunity_Certificate__c>)newList,(Map<Id,Opportunity_Certificate__c>)oldMap);
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) { 
        OpportunityCertificateTriggerHelper.sFilesCreateOpportunityCertFolder((List<Opportunity_Certificate__c>)newList,(Map<Id,Opportunity_Certificate__c>)oldMap); 
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