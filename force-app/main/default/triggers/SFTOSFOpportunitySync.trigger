/*
@Author : MAANTIC
@CreatedDate : 16th JUN 2022
@Description : Opportunity Object Trigger.
*/

trigger SFTOSFOpportunitySync on Opportunity(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SFTOSFOpportunitySyncHandler(), 'OpportunitySync_Trigger'); 
}