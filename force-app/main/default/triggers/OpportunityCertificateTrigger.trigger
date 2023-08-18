/*
@Author : MAANTIC
@CreatedDate : 30th November 2022
@Description : Opportunity Certificate Object Trigger.
*/
trigger OpportunityCertificateTrigger on Opportunity_Certificate__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    System.debug(' !!!! OpportunityCertificateTrigger Trigger Entry');
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new OpportunityCertificateTriggerHandler(), 'OpportunityCertificate_Trigger'); 
    System.debug(' !!!! OpportunityCertificateTrigger Trigger Exit'); 
}