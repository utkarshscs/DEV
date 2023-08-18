/*
@Author : MAANTIC
@CreatedDate : 2nd AUGUST 2022
@Description : Program Object Trigger Handler.
*/
/****************************** NEW ORG CODE *****************************************************/


public with sharing class SCS_ProgramTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
         //Convert List<Sobject> into List<Program__c>...
        List<Program__c> recordList = (List<Program__c>) newList;
        for(Program__c record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       }  
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Program__c>...
        List<Program__c> recordList = (List<Program__c>) newList;
        //Filter record list...
        List<Program__c> programList = new List<Program__c>();
        //Looping each record...
        for(Program__c record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                programList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !programList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(programList),'MPM4_BASE__Milestone1_Program__c','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Program__c>...
        List<Program__c> recordList = (List<Program__c>) newList;
        //Filter record list...
        List<Program__c> programList = new List<Program__c>();
        //Looping each record...
        for(Program__c record : recordList){
            //Get old record...
            Program__c oldRecord = (Program__c)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldRecord.External_Record_Id__c){
                //Add filter record into list... 
                programList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !programList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(programList),'MPM4_BASE__Milestone1_Program__c','PATCH','');
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