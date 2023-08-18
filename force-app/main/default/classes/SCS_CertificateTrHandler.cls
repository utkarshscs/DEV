/*
@Author : MAANTIC
@CreatedDate : 1st AUGUST 2022
@Description : Certificate__c Object Trigger Handler.
*/
/****************************** New ORG CODE *****************************************************/

public with sharing class SCS_CertificateTrHandler  implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Certificate__c>...
        List<Certificate__c> recordList = (List<Certificate__c>) newList;
        for(Certificate__c record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       } 
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Certificate__c>...
        List<Certificate__c> recordList = (List<Certificate__c>) newList;
        //Add filter record into list...
        List<Certificate__c> certificateList = new List<Certificate__c>();
        //Looping each record...
        for(Certificate__c record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                certificateList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !certificateList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(certificateList),'Certificate__c','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Certificate__c>...
        List<Certificate__c> recordList = (List<Certificate__c>) newList;
        //Add filter record into list...
        List<Certificate__c> certificateList = new List<Certificate__c>();
        //Looping each record...
        for(Certificate__c record : recordList){
            //Get old record...
            Certificate__c oldCertificate = (Certificate__c)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldCertificate.External_Record_Id__c){
                certificateList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !certificateList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(certificateList),'Certificate__c','PATCH','');
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