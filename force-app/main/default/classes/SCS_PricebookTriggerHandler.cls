/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : Price Book Trigger Handler.
*/
/****************************** New ORG CODE *****************************************************/


public with sharing class SCS_PricebookTriggerHandler implements ITriggerHandler  {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Pricebook2>...
        List<Pricebook2> recordList = (List<Pricebook2>) newList;
        for(Pricebook2 record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       }  
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Pricebook2>...
        List<Pricebook2> recordList = (List<Pricebook2>) newList;
        //Filter record list...
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        //Looping each record...
        for(Pricebook2 record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list...
                pricebookList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !pricebookList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(pricebookList),'Pricebook2','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Pricebook2>...
        List<Pricebook2> recordList = (List<Pricebook2>) newList;
        //Filter record list...
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        //Looping each record...
        for(Pricebook2 record : recordList){
            //Get old record...
            Pricebook2 oldRecord = (Pricebook2)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldRecord.External_Record_Id__c){
                //Add filter record into list...
                pricebookList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !pricebookList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(pricebookList),'Pricebook2','PATCH','');
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