/*
@Author : MAANTIC
@CreatedDate : 19th JULY 2022
@Description : Account Object Trigger.
*/

trigger SCS_AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_AccountTriggerHandler(), 'Account_Trigger'); 
}