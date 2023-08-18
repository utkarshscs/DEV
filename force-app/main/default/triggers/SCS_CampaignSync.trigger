/*
@Author : MAANTIC
@CreatedDate : 5th Sept 2022
@Description : Campaign Object Trigger use for data sync only.
*/

trigger SCS_CampaignSync on Campaign (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_CampaignSyncHandler(), 'CampaignSync_Trigger');
    
}