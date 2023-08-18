/*
@Author : MAANTIC
@CreatedDate : 16th JUN 2022
@Description : Opportunity Object Trigger Handler.

Modification history

Date: 08/03/2022
Added by pass logic for CVENT INTEGRATION USER

*/
/****************************** NEW ORG CODE *****************************************************/
public with sharing class SCS_OpportunityTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<sObject> newList) {
        //Create goal...
        FnA_GoalAutomation.createUserAndProgramGoal((List<Opportunity>)newList);
        SCS_OpportunityTriggerHelper.updateProgramListInsertOrUpdate((List<Opportunity>)newList,null);
    }
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        //Call trigger helper to created standard covered for the opportunity...
        SCS_OpportunityTriggerHelper.createStandardCovered((List<Opportunity>)newList);  
        //Call trigger helper method to create Opportunity folder on SharePoint...
        SCS_OpportunityTriggerHelper.sFilesCreateOpportunityFolder((List<Opportunity>)newList, null);  
    }
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        //Call project comment trigger helper to create contact and stakeholder... 
        FnA_GoalAutomation.updateUserAndProgramGoal((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap);
        SCS_OpportunityTriggerHelper.updateProgramListInsertOrUpdate((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap);
        //SCS_OpportunityTriggerHelper.requireReasonForChangeValidation((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap); //Case:00001499
    }
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) { 
        SCS_OpportunityTriggerHelper.sFilesCreateOpportunityFolder((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap);
        //Call this method to add and remove line item from bundle opportunity...
        FnA_LineItemHelper.addChildLineItemOnBundleOpportunity((List<Opportunity>)newList,oldMap);
        SCS_OpportunityTriggerHelper.updateBundledOpptyAmount((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap);
        SCS_OpportunityTriggerHelper.updateChildOpportuityStage((Map<Id,Opportunity>)newMap,(Map<Id,Opportunity>)oldMap);
        //SCS_ActualFinishDateAutomation.updateActualFinishDateOnProjectTask((List<Opportunity>)newList,(Map<Id,Opportunity>)oldMap);
    }
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        //Subtract opportunity amount from goal...
        FnA_GoalAutomation.subtractGoalAmountOnDelete((List<Opportunity>)oldList);
    }
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {  
    }
    
}