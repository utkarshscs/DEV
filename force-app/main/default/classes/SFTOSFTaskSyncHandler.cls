/*
@Author           : MAANTIC
@CreatedDate      : 26th April 2023
@Created By       : Sohit Tripathi
@LastModified By  : Sohit Tripathi
@LastModified Date: 26th April 2023
@Description      : Task Object Sync Trigger Handler. 
*/
/****************************** NEW ORG CODE *****************************************************/


public with sharing class SFTOSFTaskSyncHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        //Set of contact ids...
        Set<String> whoIds = new Set<String> ();
        //Set of Opportunity ids...
        Set<String> oppoIds = new Set<String> ();
        for(Task record : recordList){
            //Add contact id into set...
            if(!String.isBlank(record.WhoId) && String.valueOf(record.WhoId).startsWith('003')) {
                whoIds.add(record.WhoId);
            }
            //Add opportunity id into set...
            if(!String.isBlank(record.WhatId) && String.valueOf(record.WhatId).startsWith('006')) {
                oppoIds.add(record.WhatId);
            }
            //blank out external id if record is clone...
            if(record.isClone()){
                record.External_Record_Id__c = null;
            }
        }
        //Assign external Opportunity Id...
        if(!oppoIds.isEmpty()){
            Map<Id,Opportunity> oppoMap = new Map<ID,Opportunity>([SELECT Id,External_Record_Id__c FROM Opportunity WHERE Id IN : oppoIds]);
            for(Task record : recordList){
                if(String.isNotBlank(record.WhatId) && oppoMap.containsKey(record.WhatId)) {
                    record.External_What_Id__c = oppoMap.get(record.WhatId).External_Record_Id__c;
                }
            }
            
        }
        //Assign external Contact Id...
        if(! whoIds.isEmpty()){
            Map<Id,Contact> whoIdMap = new Map<Id,Contact>([SELECT Id,External_Record_Id__c FROM Contact WHERE Id IN : whoIds]);
            for(Task record : recordList){
                if(String.isNotBlank(record.WhoId) && whoIdMap.containsKey(record.WhoId)){
                    record.External_Who_Id__c = whoIdMap.get(record.WhoId).External_Record_Id__c;
                }
            }
        }
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        //Filter record list...
        List<Task> filterList = new List<Task>();
        //Loop each record...
        for(Task record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator && !String.isBlank(record.WhatId) && String.valueOf(record.WhatId).startsWith('006')){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Task','PATCH','');
        }
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        //Set of contact ids...
        Set<String> whoIds = new Set<String> ();
        //Set of Opportunity ids...
        Set<String> oppoIds = new Set<String> ();
        for(Task record : recordList){
            //Add contact id into set...
            if(!String.isBlank(record.WhoId) && String.valueOf(record.WhoId).startsWith('003')) {
                whoIds.add(record.WhoId);
            }
            //Add opportunity id into set...
            if(!String.isBlank(record.WhatId) && String.valueOf(record.WhatId).startsWith('006')) {
                oppoIds.add(record.WhatId);
            }
        }
        //Assign external Opportunity Id...
        if(!oppoIds.isEmpty()){
            Map<Id,Opportunity> oppoMap = new Map<ID,Opportunity>([SELECT Id,External_Record_Id__c FROM Opportunity WHERE Id IN : oppoIds]);
            for(Task record : recordList){
                if(String.isNotBlank(record.WhatId) && oppoMap.containsKey(record.WhatId)) {
                    record.External_What_Id__c = oppoMap.get(record.WhatId).External_Record_Id__c;
                }
            }
            
        }
        //Assign external Contact Id...
        if(! whoIds.isEmpty()){
            Map<Id,Contact> whoIdMap = new Map<Id,Contact>([SELECT Id,External_Record_Id__c FROM Contact WHERE Id IN : whoIds]);
            for(Task record : recordList){
                if(String.isNotBlank(record.WhoId) && whoIdMap.containsKey(record.WhoId)){
                    record.External_Who_Id__c = whoIdMap.get(record.WhoId).External_Record_Id__c;
                }
            }
        }
    }
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        //Filter record list...
        List<Task> filterList = new List<Task>();
        //Loop each record...
        for(Task record : recordList){
            //Check last modified user is not equal to web integrator user...
            if(record.LastModifiedById != System.Label.Web_Integrator && !String.isBlank(record.WhatId) && String.valueOf(record.WhatId).startsWith('006')){
                //Add filter record into list..
                filterList.add(record); 
            }
        }
        //Call SF connector to sync data from old org to new org...
        if(!System.isFuture() && !filterList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterList),'Task','PATCH','');
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