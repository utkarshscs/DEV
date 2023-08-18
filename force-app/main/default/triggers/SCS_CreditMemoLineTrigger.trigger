/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Credit Memo Line Object Trigger.
*/

trigger SCS_CreditMemoLineTrigger on fw1__Credit_Memo_Line__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    System.debug(' !!!! SCS_CreditMemoLineTrigger Trigger Entry');
    TriggerDispatcher.run(new SCS_CreditMemoLineTriggerHandler(), 'Credit_Memo_LineSync_Trigger');
    System.debug(' !!!! SCS_CreditMemoLineTrigger Trigger Exit');
}