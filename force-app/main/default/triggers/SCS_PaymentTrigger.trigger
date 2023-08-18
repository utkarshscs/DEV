/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Payment Object Trigger.
*/

trigger SCS_PaymentTrigger on fw1__Payment__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    System.debug(' !!!! SCS_PaymentTrigger Trigger Entry');
    TriggerDispatcher.run(new SCS_PaymentTriggerHandler(), 'PaymentSync_Trigger');
    System.debug(' !!!! SCS_PaymentTrigger Trigger Exit');
}