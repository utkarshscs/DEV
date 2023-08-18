/*
    Description :   Custom Invoice Trigger
    Date        :   15th Dec, 2022
    Author      :   Utkarsh G (Maantic)
*/
trigger InvoiceLineItemTrigger on fw1__Invoice_Line__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        InvoiceLineItemTriggerHandler.beforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        InvoiceLineItemTriggerHandler.preventUpdatingInvoiceLine(Trigger.oldMap,Trigger.newMap);
    }  
}