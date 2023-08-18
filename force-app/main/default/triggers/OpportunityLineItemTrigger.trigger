/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : OpportunityLineItem Object Trigger.
*/

trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
     
    //Call Trigger Dispatcher...
     TriggerDispatcher.run(new OpportunityLineItemTriggerHandler(), 'OpportunityLineItemTrigger');

}