/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Invoice Object Trigger.
*/

trigger SCS_InvoiceTrigger on fw1__Invoice__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_InvoiceTriggerHandler(), 'InvoiceSync_Trigger');
}