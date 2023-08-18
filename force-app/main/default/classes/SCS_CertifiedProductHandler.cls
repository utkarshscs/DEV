/*
@Author : MAANTIC
@CreatedDate : 17th AUG 2023
@Description : CertifiedProducts__c Object Trigger.
*/

/****************************** NEW ORG CODE *****************************************************/
public with sharing class SCS_CertifiedProductHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList) {
        
    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        SCS_CertifiedProductHelper.addProductClaim((List<CertifiedProducts__c>)newList,null);
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        SCS_CertifiedProductHelper.addProductClaim((List<CertifiedProducts__c>)newList,(Map<Id, CertifiedProducts__c>) oldMap);
    }
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        SCS_CertifiedProductHelper.addProductClaim((List<CertifiedProducts__c>)oldList,null);  
    }
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {  
    }
    
}