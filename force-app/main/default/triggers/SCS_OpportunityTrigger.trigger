/*
@Author : MAANTIC
@CreatedDate : 16th JUN 2022
@Description : Opportunity Object Trigger.
*/

trigger SCS_OpportunityTrigger on Opportunity(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    System.debug(' !!!! SCS_OpportunityTrigger Trigger Entry');
    TriggerDispatcher.run(new SCS_OpportunityTriggerHandler(), 'Opportunity_Trigger'); 
    System.debug(' !!!! SCS_OpportunityTrigger Trigger Exit');
}