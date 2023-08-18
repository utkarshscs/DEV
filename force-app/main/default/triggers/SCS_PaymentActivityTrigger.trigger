/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Payment Activity Object Trigger.
*/

trigger SCS_PaymentActivityTrigger on fw1__Payment_Activity__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_PaymentActivityTrHandler(), 'Payment_ActivitySync_Trigger');
}