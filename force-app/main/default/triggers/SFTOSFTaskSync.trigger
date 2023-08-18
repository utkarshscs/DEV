/*
@Author : MAANTIC
@CreatedDate : 26th April 2023
@Description : This trigger is created to dettach sync trigger from task trigger.

*/
/****************************** OLD ORG CODE *****************************************************/

trigger SFTOSFTaskSync on Task (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SFTOSFTaskSyncHandler(), 'Task_Sync_Trigger');
    
}