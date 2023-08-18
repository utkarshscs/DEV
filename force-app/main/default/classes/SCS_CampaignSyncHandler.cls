/*
@Author : MAANTIC
@CreatedDate : 5th Sept 2022
@Description : Campaign Object Trigger Handler use for data sync only.
*/
/****************************** New ORG CODE *****************************************************/

public with sharing class SCS_CampaignSyncHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Campaign>...
        List<Campaign> recordList = (List<Campaign>) newList;
        for(Campaign record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Campaign>...
        List<Campaign> recordList = (List<Campaign>) newList;
        //Filter record list...
        List<Campaign> campaignList = new List<Campaign>();
        //Loop each record...
        for(Campaign record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                campaignList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !campaignList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(campaignList),'Campaign','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Campaign>...
        List<Campaign> recordList = (List<Campaign>) newList;
        //Filter record list...
        List<Campaign> campaignList = new List<Campaign>();
        //Loop each record...
        for(Campaign record : recordList){
            //Get old record...
            Campaign oldRecord = (Campaign)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldRecord.External_Record_Id__c){
                //Add filter record into list...
                campaignList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !campaignList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(campaignList),'Campaign','PATCH','');
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