/*
@Author : MAANTIC
@CreatedDate : 16th Sept 2022
@Description : Account Object Trigger.
*/

trigger SFTOSFAccountSync on Account(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SFTOSFAccountSyncHandler(), 'AccountSync_Trigger'); 
}