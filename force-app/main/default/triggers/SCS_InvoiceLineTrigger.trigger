/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Invoice Line Object Trigger.
*/

trigger SCS_InvoiceLineTrigger on fw1__Invoice_Line__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_InvoiceLineTriggerHandler(), 'Invoice_LineSync_Trigger');
}