/*
@Author : MAANTIC
@CreatedDate : 21th JULY 2022
@Description : Lead Object Trigger.
*/

trigger SCS_LeadTrigger on Lead (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_LeadTriggerHandler(), 'LeadSync_Trigger'); 
}