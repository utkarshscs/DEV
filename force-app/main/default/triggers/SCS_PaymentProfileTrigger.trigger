/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Payment Profile Object Trigger.
*/

trigger SCS_PaymentProfileTrigger on fw1__PaymentProfile__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_PaymentProfileTrHandler(), 'Payment_ProfileSync_Trigger');
}