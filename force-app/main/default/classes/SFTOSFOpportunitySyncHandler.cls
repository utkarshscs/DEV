/*
@Author : MAANTIC
@CreatedDate : 16th JUN 2022
@Description : Opportunity Object Trigger Handler.

*/
/****************************** NEW ORG CODE *****************************************************/
public with sharing class SFTOSFOpportunitySyncHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Opportunity> newList) {
        //Convert List<Sobject> into List<Opportunity>...
        List<Opportunity> recordList = (List<Opportunity>) newList;
        for(Opportunity record : recordList){
               if(record.isClone()){
                 record.External_Record_Id__c = null;
               }
            }  
    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        //Convert List<Sobject> into List<Opportunity>...
        List<Opportunity> recordList = (List<Opportunity>) newList;
        //User to store record type name...
        String recordTypeName;
        //Filter record list...
        List<Opportunity> opportunityList = new List<Opportunity>();
        //Loop each record...
        for(Opportunity record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.LastModifiedById != System.Label.SCS_CVENT_USER_Id && String.isNotBlank(record.External_Account_Id__c) && String.isBlank(record.DMS_Project_ID__c)){
                //Assign record type name...
                recordTypeName = record.Record_Type_Name__c;
                //Add filter record into list...
                opportunityList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !opportunityList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(opportunityList),'Opportunity','PATCH',recordTypeName);
        }
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        //Convert List<Sobject> into List<Opportunity>...
        List<Opportunity> recordList = (List<Opportunity>) newList;
        //Filter record list...
        List<Opportunity> opportunityList = new List<Opportunity>();
        //User to store record type name...
        String recordTypeName;
        //Loop each record...
        for(Opportunity record : recordList){
            //Get old record...
            Opportunity oldOpportunity = (Opportunity)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.LastModifiedById != System.Label.SCS_CVENT_USER_Id && String.isNotBlank(record.External_Account_Id__c) && String.isBlank(record.DMS_Project_ID__c)){
                //Assign record type name...
                recordTypeName = record.Record_Type_Name__c;
                //Add filter record into list...
                opportunityList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !opportunityList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(opportunityList),'Opportunity','PATCH',recordTypeName);
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