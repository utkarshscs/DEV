/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Credit Memo Object Trigger.
*/

trigger SCS_CreditMemoTrigger on fw1__Credit_Memo__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_CreditMemoTriggerHandler(), 'Credit_MemoSync_Trigger');
}