/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : User Trigger.
*/
trigger userTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new UserTriggerHandler(), 'User_Trigger');   
}