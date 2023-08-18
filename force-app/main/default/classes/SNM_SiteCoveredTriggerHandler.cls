/**************************************************** NEW ORG CODE ****************************************************************************************************************
* Apex Class Name   : SNM_SiteCoveredTriggerHandler
* Related Class Name: SCS_SFToSFConnector
* Division          : Sales and marketing
* Version           : 1.0
* Total Function    : 7
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-37
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-37
* Functionality     : This handler use in SNM_SiteCoveredTrigger trigger to sync site covered into opportunity sites object from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        21-10-2022                          Initial version 
*************************************************************************************************************************************************************************************/


public with sharing class SNM_SiteCoveredTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Site_Covered__c>...
        List<Site_Covered__c> recordList = (List<Site_Covered__c>) newList;
        for(Site_Covered__c record : recordList){
            //If record is clone then blank out external record id...
            if(record.isClone()){
                record.External_Record_Id__c = null;
            }
        }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Site_Covered__c>...
        List<Site_Covered__c> recordList = (List<Site_Covered__c>) newList;
        //Filter record list...
        List<Site_Covered__c> filterList = new List<Site_Covered__c>();
        //Loop each record...
        for(Site_Covered__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Opportunity_Site__c','PATCH','');
        }
    }
    
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Site_Covered__c>...
        List<Site_Covered__c> recordList = (List<Site_Covered__c>) newList;
        //Filter record list...
        List<Site_Covered__c> filterList = new List<Site_Covered__c>();
        //Loop each record...
        for(Site_Covered__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Opportunity_Site__c','PATCH','');
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