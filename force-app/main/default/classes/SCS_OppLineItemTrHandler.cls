/*
@Author : MAANTIC
@CreatedDate : 1st AUGUST 2022
@Description : OpportunityLineItem Object Trigger Handler.
*/
/****************************** New ORG CODE *****************************************************/

public with sharing class SCS_OppLineItemTrHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        for(OpportunityLineItem record : recordList){
               if(record.isClone()){
	             record.External_Record_Id__c = null;
	           }
            }    
    }
    
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        //Filter record list...
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        //Looping each record...
        for(OpportunityLineItem record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_WO_Lines_Id__c)){
                //Add filter record into list...
                opportunityLineItemList.add(record); 
                system.debug('pbe'+record.PricebookEntryId);
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !opportunityLineItemList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(opportunityLineItemList),'OpportunityLineItem','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {        
    }
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        //Filter record list...
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        //Looping each record...
        for(OpportunityLineItem record : recordList){
            //Get old record...
            //OpportunityLineItem oldProduct = (OpportunityLineItem)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_WO_Lines_Id__c)){
                //Add filter record into list...
                opportunityLineItemList.add(record); 
                system.debug('pbe'+record.PricebookEntryId);
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !opportunityLineItemList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(opportunityLineItemList),'OpportunityLineItem','PATCH','');
        }
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) oldList;
        //Filter record list...
        String externalRecordId='';
        //Looping each record...
        for(OpportunityLineItem record : recordList){
            //Check last modified user not equal to web integrater user...
            if(UserInfo.getUserId() != System.Label.Web_Integrator && record.External_Record_Id__c != null){
                externalRecordId = externalRecordId + record.External_Record_Id__c+','; 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && externalRecordId !=''){
            SCS_DeleteRecord.sFToSFConnectorDeletion(externalRecordId,'DELETE');
        }
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
    
    
}