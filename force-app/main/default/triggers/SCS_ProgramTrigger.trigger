/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : Program Object Trigger.
*/
/****************************** NEW ORG CODE *****************************************************/
trigger SCS_ProgramTrigger on Program__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_ProgramTriggerHandler(), 'ProgramSync_Trigger');
    
}