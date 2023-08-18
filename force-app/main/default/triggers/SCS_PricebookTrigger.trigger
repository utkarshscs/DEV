/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : PriceBook Object Trigger.
*/


trigger SCS_PricebookTrigger on Pricebook2 (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_PricebookTriggerHandler(), 'PricebookSync_Trigger');
}