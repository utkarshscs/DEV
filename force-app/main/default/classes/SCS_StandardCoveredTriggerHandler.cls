/**************************************************** NEW ORG CODE ***************************************************************** 
* Apex Class Name   : SCS_StandardCoveredTriggerHandler
* Related Class Name: SCS_StandardCoveredTriggerHelper
* Version           : 1.0
* Description     	: Standard Covered Object Trigger Handler
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Sohit Tripathi                    21-06-2023                          Initial version 
************************************************************************************************************************************/
public with sharing class SCS_StandardCoveredTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Call trigger helper to update all standard covered title on Opportunity...
        SCS_StandardCoveredTriggerHelper.updateTitleonOppty((List<Standard_Covered__c>)newList);  
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        SCS_StandardCoveredTriggerHelper.updateTitleonOppty((List<Standard_Covered__c>)oldList);  
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
}