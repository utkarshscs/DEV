/*
@Author         : MAANTIC
@CreatedDate    : 21st November 2022
@Description    : Opportunity Contact Role Trigger Handler
                  To sync the data between the new and old orgs.
@Jira           : https://scsglobalservices.atlassian.net/browse/SF20FA-236           

*/
/****************************** New ORG CODE *****************************************************/

public with sharing class SCS_OppContactRoleTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {

        //Convert List<Sobject> into List<OpportunityContactRole>...
        List<OpportunityContactRole> recordList = (List<OpportunityContactRole>) newList;

        for(OpportunityContactRole record : recordList){
            if(record.isClone()){
	           record.External_Record_Id__c = null;
	        }
       }  
    }

    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {

        System.debug('Oppcontactrole ' + newList);
        //Convert List<Sobject> into List<OpportunityContactRole>...
        List<OpportunityContactRole> recordList = (List<OpportunityContactRole>) newList;
        System.debug('recordList ' + recordList);
        //Filter record list...
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        //Loop each record...
        for(OpportunityContactRole record : recordList){
            System.debug('Inside for ' + record);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                System.debug('Inside IFF ' + record);
                //Add filter record into list...
                oppContactRoleList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !oppContactRoleList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(oppContactRoleList),'OpportunityContactRole','POST','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}

    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<OpportunityContactRole>...
        List<OpportunityContactRole> recordList = (List<OpportunityContactRole>) newList;
        //Filter record list...
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        //Loop each record...
        for(OpportunityContactRole record : recordList){
            //Get old record...
            OpportunityContactRole oldProduct = (OpportunityContactRole)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && record.External_Record_Id__c == oldProduct.External_Record_Id__c){
                //Add filter record into list...
                oppContactRoleList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !oppContactRoleList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(oppContactRoleList),'OpportunityContactRole','PATCH','');
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