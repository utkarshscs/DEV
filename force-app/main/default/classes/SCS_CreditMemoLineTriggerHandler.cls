/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Credit Memo Line Object Trigger Handler.
*/

public with sharing class SCS_CreditMemoLineTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<fw1__Credit_Memo_Line__c>...
        List<fw1__Credit_Memo_Line__c> recordList = (List<fw1__Credit_Memo_Line__c>) newList;
        for(fw1__Credit_Memo_Line__c record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       } 
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<fw1__Credit_Memo_Line__c>...
        List<fw1__Credit_Memo_Line__c> recordList = (List<fw1__Credit_Memo_Line__c>) newList;
        //Filter record list...
        List<fw1__Credit_Memo_Line__c> filterRecordList = new List<fw1__Credit_Memo_Line__c>();
        //Loop each record...
        for(fw1__Credit_Memo_Line__c record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_inv_line_Id__c)){
                //Add filter record into list...
                filterRecordList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterRecordList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterRecordList),'fw1__Credit_Memo_Line__c','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<fw1__Credit_Memo_Line__c>...
        List<fw1__Credit_Memo_Line__c> recordList = (List<fw1__Credit_Memo_Line__c>) newList;
        //Filter record list...
        List<fw1__Credit_Memo_Line__c> filterRecordList = new List<fw1__Credit_Memo_Line__c>();
        //Loop each record...
        for(fw1__Credit_Memo_Line__c record : recordList){
            //Get old record...
            //fw1__Credit_Memo_Line__c oldRecord = (fw1__Credit_Memo_Line__c)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_inv_line_Id__c) && String.isNotBlank(record.External_Credit_Memo_Id__c)){
                //Add filter record into list...
                filterRecordList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterRecordList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterRecordList),'fw1__Credit_Memo_Line__c','PATCH','');
        }
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