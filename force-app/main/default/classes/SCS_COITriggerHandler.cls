/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_COITriggerHandler
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1312
* Functionality     : This class use in SCS_COITrigger trigger.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        20-06-2023                          Initial version 
************************************************************************************************************************************/
public with sharing class SCS_COITriggerHandler implements ITriggerHandler{
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList){
        SCS_COIAutomationFromCOI.preventDuplicate((List<Conflict_of_Interest__c>) newList);
    }
    
    //Call after insert...
    public void afterInsert( List<sObject> newList , Map<Id, sObject> newMap ){ 
        SCS_COIAutomationFromCOI.checkCOI((List<Conflict_of_Interest__c>) newList,null);
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap){
        SCS_COIAutomationFromCOI.preventDuplicate((List<Conflict_of_Interest__c>) newList);
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap){
        SCS_COIAutomationFromCOI.checkCOI((List<Conflict_of_Interest__c>) newList,(Map<Id,Conflict_of_Interest__c>) oldMap);
    }
    
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap){
    }
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap){    
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap){  
        
    }  
}