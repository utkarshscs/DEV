/*
    Description :   Custom Invoice Trigger
    Date        :   15th Dec, 2022
    Author      :   Utkarsh G (Maantic)
*/

trigger Invoice_Trigger on fw1__Invoice__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) { 
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new Invoice_TriggerHandler(), 'Invoice_Trigger'); 
}