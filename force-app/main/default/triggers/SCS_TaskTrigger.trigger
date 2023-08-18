/*
@Author : MAANTIC
@CreatedDate : 14th Oct 2022
@Description : Task Object Trigger.
*/
/****************************** OLD ORG CODE *****************************************************/

trigger SCS_TaskTrigger on Task (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    System.debug(' !!!! SCS_TaskTrigger Trigger Entry');
    TriggerDispatcher.run(new SCS_TaskTriggerHandler(), 'Task_Trigger');
    System.debug(' !!!! SCS_TaskTrigger Trigger Exit');
    
}