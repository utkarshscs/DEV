/*
@Author : MAANTIC
@CreatedDate : 1st AUG 2022
@Description : Lead Trigger Handler.

*** Modification history ----

Add clauses under before update trigger for Lead to ensure whether same Lead is being synched from Hubspot for new program 
if yes then create new duplicate lead in system for same details.

*/
/****************************** New ORG CODE *****************************************************/
public with sharing class SCS_LeadTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Lead>...
        List<Lead> recordList = (List<Lead>) newList;
            for(Lead record : recordList){
               if(record.isClone()){
                 record.External_Record_Id__c = null;
               }
            }
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Lead>...
        List<Lead> recordList = (List<Lead>) newList;
        //Filter record list...
        List<Lead> leadList = new List<Lead>();
        //Looping each record...
        for(Lead record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                leadList.add(record); 
            }
        }
        
        
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !leadList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(leadList),'Lead','PATCH','');
        }
        
        
        
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
       
        
        
    }
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Lead>...
        List<Lead> recordList = (List<Lead>) newList;
        //Filter record list...
        List<Lead> leadList = new List<Lead>();
        //Converted Lead list
        List<Lead> newLeadList = new List<Lead>();
        
        //Looping each record...
        for(Lead record : recordList){
            //Get old record...
            Lead oldRecord = (Lead)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldRecord.External_Record_Id__c){
                //Add filter record into list...
                leadList.add(record); 
            }
            
           
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !leadList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(leadList),'Lead','PATCH','');
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