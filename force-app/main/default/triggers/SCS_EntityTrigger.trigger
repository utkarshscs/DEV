/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Entity Object Trigger.
*/

trigger SCS_EntityTrigger on fw1__Entity__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_EntityTriggerHandler(), 'EntitySync_Trigger');
}