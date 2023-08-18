/*
@Author : MAANTIC
@CreatedDate : 6th Sept 2022
@Description : Campaign Member Object Trigger use for data sync only.
*/
/****************************** NEW ORG CODE *****************************************************/
trigger SCS_CampaignMemberSync on CampaignMember (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_CampaignMemberSyncHandler(), 'CampaignMemberSync_Trigger');
    
}