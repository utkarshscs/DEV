/*
@Author : MAANTIC
@CreatedDate : 6th OCT 2022
@Description : Opportunity Certificate Object Trigger Handler.
*/
/****************************** New ORG CODE *****************************************************/

public with sharing class SCS_OppoCertificateTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Opportunity_Certificate__c>...
        List<Opportunity_Certificate__c> recordList = (List<Opportunity_Certificate__c>) newList;
        for(Opportunity_Certificate__c record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Opportunity_Certificate__c>...
        List<Opportunity_Certificate__c> recordList = (List<Opportunity_Certificate__c>) newList;
        //Filter record list...
        List<Opportunity_Certificate__c> filterList = new List<Opportunity_Certificate__c>();
        //Loop each record...
        for(Opportunity_Certificate__c record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                filterList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Opportunity_Certificate__c','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Opportunity_Certificate__c>...
        List<Opportunity_Certificate__c> recordList = (List<Opportunity_Certificate__c>) newList;
        //Filter record list...
        List<Opportunity_Certificate__c> filterList = new List<Opportunity_Certificate__c>();
        //Loop each record...
        for(Opportunity_Certificate__c record : recordList){
            
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                filterList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Opportunity_Certificate__c','PATCH','');
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