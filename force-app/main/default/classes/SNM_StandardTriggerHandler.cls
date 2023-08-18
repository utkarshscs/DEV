/**************************************************** NEW ORG CODE ***************************************************************** 
* Class  Name       : SNM_StandardTriggerHandler
* Related Class Name: SCS_SFToSFConnector
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-37
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-37
* Functionality     : This trigger use to sync standard to standard object from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        31-10-2022                          Initial version 
************************************************************************************************************************************/



public with sharing class SNM_StandardTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Standard__c>...
        List<Standard__c> recordList = (List<Standard__c>) newList;
        for(Standard__c record : recordList){
            if(record.isClone()){
                record.External_Record_Id__c = null;
            }
        }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Standard__c>...
        List<Standard__c> recordList = (List<Standard__c>) newList;
        //Filter record list...
        List<Standard__c> filterList = new List<Standard__c>();
        //Loop each record...
        for(Standard__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Standards__c','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Standard__c>...
        List<Standard__c> recordList = (List<Standard__c>) newList;
        //Filter record list...
        List<Standard__c> filterList = new List<Standard__c>();
        //Loop each record...
        for(Standard__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Standards__c','PATCH','');
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