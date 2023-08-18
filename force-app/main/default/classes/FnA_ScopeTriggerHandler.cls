/**************************************************** NEW ORG CODE ***************************************************************** 
* Trigger Name      : FnA_ScopeTriggerHandler
* Related Class Name: SCS_SFToSFConnector
* Division          : Food and agriculture
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-136
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-136
* Functionality     : This trigger use to sync scope into client activity and opportunity client activity from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        15-12-2022                          Initial version 
************************************************************************************************************************************/



public with sharing class FnA_ScopeTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Scope__c>...
        List<Scope__c> recordList = (List<Scope__c>) newList;
        for(Scope__c record : recordList){
            //If record is clone then blank out the external record id...
            if(record.isClone()){
                record.External_Record_Id__c = null;
            }
        }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Scope__c>...
        List<Scope__c> recordList = (List<Scope__c>) newList;
        //Filter record list...
        List<Scope__c> filterList = new List<Scope__c>();
        String objectName = '';
        //Loop each record...
        for(Scope__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
                //Check current record type is equal to Sub Scope...
                if(record.RecordTypeId == SCS_ConstantRTypeReference.scope_SubScopeRTId) {
                    objectName = 'Client_Activity__c';
                    //Check current record type is equal to opportunity...
                } else if(record.RecordTypeId == SCS_ConstantRTypeReference.scope_opportunityRTId && String.isNotBlank(record.Sub_Scope__c)){
                    objectName = 'OpportunityClientActivity__c';
                }
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty() && objectName != ''){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),objectName,'PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Scope__c>...
        List<Scope__c> recordList = (List<Scope__c>) newList;
        //Filter record list...
        List<Scope__c> filterList = new List<Scope__c>();
        String objectName = '';
        //Loop each record...
        for(Scope__c record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator){
                //Add filter record into list..
                filterList.add(record); 
                //Check current record type is equal to Sub Scope...
                if(record.RecordTypeId == SCS_ConstantRTypeReference.scope_SubScopeRTId) {
                    objectName = 'Client_Activity__c';
                    //Check current record type is equal to opportunity...
                } else if(record.RecordTypeId == SCS_ConstantRTypeReference.scope_opportunityRTId && String.isNotBlank(record.Sub_Scope__c)){
                    objectName = 'OpportunityClientActivity__c';
                }
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty() && objectName != ''){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),objectName,'PATCH','');
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