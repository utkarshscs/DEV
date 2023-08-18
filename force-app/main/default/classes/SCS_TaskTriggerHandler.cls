/*
@Author           : MAANTIC
@CreatedDate      : 18th Oct 2022
@Created By       : Kumar Umesh
@LastModified By  : Kumar Umesh
@LastModified Date: 18th Oct 2022
@Description      : Task Object Trigger Handler. 
*/
/****************************** NEW ORG CODE *****************************************************/


public with sharing class SCS_TaskTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        setAccountOnTask(recordList, null);
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
        //Convert List<Sobject> into List<Task>...
        List<Task> recordList = (List<Task>) newList;
        setAccountOnTask(recordList, (Map<Id, Task>)oldMap);
    }
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
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
    
    /*
Description : This method Identifies object under WhatId and set's Account on task
Params      : List of new task , map of old Task
*/    
    public static void setAccountOnTask(List<Task> newList, Map<Id, Task> oldMap){                    
        Schema.SObjectType accObj = Schema.Account.getSObjectType();
        Schema.SObjectType oppObj = Schema.Opportunity.getSObjectType();
        Schema.SObjectType invoiceObj = Schema.fw1__Invoice__c.getSObjectType();
        Schema.SObjectType paymentObj = Schema.fw1__Payment__c.getSObjectType();
        Schema.SObjectType projectObj = Schema.inspire1__Project__c.getSObjectType();
        
        Set<String> oppIds = new Set<String> ();
        Set<String> projectIds = new Set<String> ();
        Set<String> invoiceIds = new Set<String> ();
        Set<String> paymentIds = new Set<String> ();
        
        for(Task record : newList){
            if(String.isNotBlank(record.WhatId) && (oldMap == null || oldMap.get(record.Id).WhatId != record.WhatId)){
                Schema.SObjectType objType = record.WhatId.getsobjecttype();
                if(objType == projectObj){
                    projectIds.add(record.WhatId);
                } else if(objType == accObj){
                    record.Account__c = record.WhatId;
                } else if(objType == oppObj){
                    oppIds.add(record.WhatId);
                } else if(objType == invoiceObj){
                    invoiceIds.add(record.WhatId);
                } else if(objType == paymentObj){
                    paymentIds.add( record.WhatId);
                }
            } 
        }
        Map<String, String> objAccMap = new Map<String, String>();
        if(!projectIds.isEmpty()){
            for(inspire1__Project__c proj : [SELECT inspire1__Account__c FROM inspire1__Project__c 
                                             WHERE Id IN :projectIds AND inspire1__Account__c != null])
            {
                objAccMap.put(proj.Id, proj.inspire1__Account__c);
            }
        }        
        if(!oppIds.isEmpty()){
            for(Opportunity opp : [SELECT AccountId FROM Opportunity
                                   WHERE Id IN :oppIds AND AccountId != null])
            {
                objAccMap.put(opp.Id, opp.AccountId);
            }
        }
        if(!invoiceIds.isEmpty()){
            for(fw1__Invoice__c inv : [SELECT fw1__Account__c FROM fw1__Invoice__c 
                                       WHERE Id IN :invoiceIds AND fw1__Account__c != null])
            {
                objAccMap.put(inv.Id, inv.fw1__Account__c);
            }
        }
        if(!paymentIds.isEmpty()){
            for(fw1__Payment__c pay : [SELECT fw1__Account__c FROM fw1__Payment__c 
                                       WHERE Id IN :paymentIds AND fw1__Account__c != null])
            {
                objAccMap.put(pay.Id, pay.fw1__Account__c);
            }
        }
        if(!objAccMap.isEmpty()){
            for(Task record : newList){   
                if(objAccMap.containsKey(record.WhatId)){
                    record.Account__c = objAccMap.get(record.WhatId);
                }
            }
        }
    }
}