/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Invoice Line Object Trigger Handler.
*/
public with sharing class Invoice_TriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList){
        InvoiceTriggerHandler.preventCreatingInvoice((List<fw1__Invoice__c>) newList);
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        // calculates total amounts
        Invoice_TriggerHelper.calculateTotalAmount((List<fw1__Invoice__c>) newList, null);
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
        InvoiceTriggerHandler.preventUpdatingInvoice((Map<Id, fw1__Invoice__c>) oldMap,(Map<Id, fw1__Invoice__c>) newMap);
    }
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        // calculates total amounts
        Invoice_TriggerHelper.calculateTotalAmount((List<fw1__Invoice__c>) newList, (Map<Id, fw1__Invoice__c>)oldMap);
        // create OpportunityLineItems 
        Invoice_TriggerHelper.addOpportunityLineItem((List<fw1__Invoice__c>) newList, (Map<Id, fw1__Invoice__c>)oldMap);
        //update initial or final amount on opportunity...
        //SCS_InvoiceTriggerHelper.fireEventToupdateInitialOrFinalAmount((List<fw1__Invoice__c>) newList,(Map<Id,fw1__Invoice__c>) oldMap);
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        InvoiceTriggerHandler.beforeDelete((List<fw1__Invoice__c>) oldList);
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {}
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {}   
}