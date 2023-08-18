/*
@Author : MAANTIC
@CreatedDate : 20th JULY 2022
@Description : Contact Object Trigger.
*/
trigger SCS_ContactTrigger on Contact(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_ContactTriggerHandler(), 'ContactSync_Trigger'); 
    
}