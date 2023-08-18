/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_ProjectTaskTriggerHandler
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1330
* Functionality     : This is SCS_ProjectTaskTrigger helper class.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        11-04-2023                          Initial version 
************************************************************************************************************************************/
public with sharing class SCS_ProjectTaskTriggerHandler implements ITriggerHandler{
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList){
       //SCS_ActualFinishDateAutomation.assignActualFinishDateOnProjectTask( (List<inspire1__Project_Tasks__c>) newList);
    }
    
    //Call after insert...
    public void afterInsert( List<sObject> newList , Map<Id, sObject> newMap ){
            SCS_ProjectTaskTriggerHelper.updateIsParentField( newList ); 
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap){
          SCS_COIAutomation.checkCOI((List<inspire1__Project_Tasks__c>) newList,(Map<Id,inspire1__Project_Tasks__c>) oldMap);   
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap){ 
        SCS_ProjectTaskTriggerHelper.updateIsParentField( newList ); 
        SCS_ProjectTaskTriggerHelper.updateProjectTask((List<inspire1__Project_Tasks__c>)newList ,(Map<Id,inspire1__Project_Tasks__c>)oldMap);     
    }
    
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap){
        SCS_ProjectTaskTriggerHelper.parentTaskDelete((List<inspire1__Project_Tasks__c>)oldList);
    }
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap){    
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap){  
        
    }  
}