/*
@Author : MAANTIC
@CreatedDate : 1st AUGUST 2022
@Description : OpportunityLineItem Object Trigger.
*/

trigger SCS_OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
     //Call Trigger Dispatcher...
     TriggerDispatcher.run(new SCS_OppLineItemTrHandler(), 'OpportunityLineItemSync_Trigger');

}