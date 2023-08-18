/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : Product Object Trigger.
*/


trigger SCS_ProductTrigger on Product2 (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_ProductTriggerHandler(), 'ProductSync_Trigger');
    
}