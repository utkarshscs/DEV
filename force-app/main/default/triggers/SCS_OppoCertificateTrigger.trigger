/*
@Author : MAANTIC
@CreatedDate : 6th Oct 2022
@Description : Opportunity Certificate Object Trigger.
*/


trigger SCS_OppoCertificateTrigger on Opportunity_Certificate__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_OppoCertificateTriggerHandler(), 'Opportunity_Certificate_Sync_Trigger');
    
}