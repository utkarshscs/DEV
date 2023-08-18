/*
Description :   Handler class for InvoiceLine Trigger
Entire logic is taken from old org.
Date        :   15th Dec, 2022
Author      :   Utkarsh G (Maantic)
*/
public class InvoiceLineItemTriggerHandler {
    
    
    public static final string ACCOUNTING_LOCKOUT_PS = 'Accounting_Lockout_Periods';
    public static final string LOCK_UPDATE_FIELDS_ERROR = 'Current Invoice Lines can not be updated because the field is locked';
    public static final string LOCK_CREATION_ERROR = 'Invoice Line can not be created because the period is locked';
    
    public static void beforeInsert(List<fw1__Invoice_Line__c> newInvoiceLineItems){        
        Set<Id> invoiceIds = new Set<Id>();
        for(fw1__Invoice_Line__c invoiceLineItem : newInvoiceLineItems){            
            invoiceIds.add(invoiceLineItem.fw1__Invoice__c);
        }
        
        Map<fw1__Invoice_Line__c,fw1__Invoice__c> invoiceLineInvoiceMap = new Map<fw1__Invoice_Line__c,fw1__Invoice__c>();
        List<fw1__Invoice__c> parentInvoices = [SELECT Id, Language__c, fw1__Invoice_Date__c FROM fw1__Invoice__c WHERE Id IN :invoiceIds];
        for(fw1__Invoice__c invoice : parentInvoices){            
            for(fw1__Invoice_Line__c invoiceLine: newInvoiceLineItems){
                if(invoiceLine.fw1__Invoice__c == invoice.Id){
                    invoiceLineInvoiceMap.put(invoiceLine,invoice);
                }                
            }            
        }  
        /*
//Prevent creation of a new Invoice Line when the Invoice has a Lockout Period
for(fw1__Invoice_Line__c invoiceLineItem : newInvoiceLineItems){
fw1__Invoice__c currentParentInvoice = invoiceLineInvoiceMap.get(invoiceLineItem);
preventCreatingInvoiceLine(invoiceLineItem, currentParentInvoice);
}*/
        
        preventCreatingInvoiceLine(newInvoiceLineItems, invoiceLineInvoiceMap);
    }
    
    /**
* Prevent users from updating invoices lines that meet the criteria for the lock out period.
* If the invoice date falls in lock period and user is trying to update any field present
in Lock_Out_Invoice_Fields add validation to restrict the update
* Called from InvoiceLineTrigger
* Params : oldMap and new Map
*/
    public static void preventUpdatingInvoiceLine(Map<Id,fw1__Invoice_Line__c> oldInvoiceLineItems,Map<Id,fw1__Invoice_Line__c> newInvoiceLineItems){      
        
        Set<Id> invoiceIds = new Set<Id>();
        Boolean isPayment = false;
        
        for(fw1__Invoice_Line__c currentInvoiceLine: newInvoiceLineItems.values()){
            invoiceIds.add(currentInvoiceLine.fw1__Invoice__c);
            
            fw1__Invoice_Line__c oldInvoiceLine = oldInvoiceLineItems.get(currentInvoiceLine.Id);
            if(currentInvoiceLine.fw1__Paid_Amount__c != null && oldInvoiceLine.fw1__Paid_Amount__c != currentInvoiceLine.fw1__Paid_Amount__c){
                isPayment = true;
            }
        }      
        
        Map<Id,fw1__Invoice__c> invoiceLineInvoiceMap = new Map<Id,fw1__Invoice__c>();        
        List<fw1__Invoice__c> parentInvoices = [SELECT Id,fw1__Invoice_Date__c FROM fw1__Invoice__c WHERE Id IN :invoiceIds];
        for(fw1__Invoice__c invoice : parentInvoices){            
            for(fw1__Invoice_Line__c invoiceLine: newInvoiceLineItems.values()){
                if(invoiceLine.fw1__Invoice__c == invoice.Id){
                    invoiceLineInvoiceMap.put(invoiceLine.Id,invoice);                    
                }                
            }            
        }  
        
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment psa : lstcurrentUserPerSet){
            if(ACCOUNTING_LOCKOUT_PS.equals(psa.PermissionSet.Name)){ //'Lock_Out_Period_Accounting_Administrator'
                return;
            }                
        }
        //Get Dates of Invoice
        List<Date> currentDates = new List<Date>();
        for(fw1__Invoice__c currentInvoice: invoiceLineInvoiceMap.values()){  
            currentDates.add(currentInvoice.fw1__Invoice_Date__c);
        }
        currentDates.sort();        
        Date lockOutDate = currentDates.get(0);
        
        List<Lock_Out_Period__c> lockOutPeriods = [SELECT Id, Start_Date__c, End_Date__c FROM Lock_Out_Period__c WHERE Locked__c = true AND End_Date__c >=:lockOutDate AND Start_Date__c<=:lockOutDate ORDER BY Start_Date__c ASC];
        
        if(lockOutPeriods.isEmpty() ) {
            return;
        }
        
        Date lockOutEndDate = lockOutPeriods.get(0).End_Date__c;
        Date lockOutStartDate = lockOutPeriods.get(0).Start_Date__c;
        
        String lockedFieldsString = Label.Lock_Out_Invoice_Line_Fields;
        List<String> lockedFields = lockedFieldsString.split(';');
        
        if(isPayment == false){
            for(fw1__Invoice_Line__c currentInvoiceLine: newInvoiceLineItems.values()){                                      
                fw1__Invoice__c currentInvoice = invoiceLineInvoiceMap.get(currentInvoiceLine.Id);
                Date invoiceDate = currentInvoice.fw1__Invoice_Date__c;
                
                if(currentInvoice == null && currentInvoice.fw1__Invoice_Date__c == null){
                    return;
                }
                /*  if(invoiceDate <= lockOutEndDate){
currentInvoiceLine.addError('Current Invoice Line can not be updated because the period is locked');
//continue;
}*/
                if( invoiceDate > lockOutEndDate || invoiceDate < lockOutStartDate ) {
                    continue;
                }
                
                for( String lockedField : lockedFields ) {
                    if( currentInvoiceLine.get(lockedField) != oldInvoiceLineItems.get(currentInvoiceLine.Id).get(lockedField) ) {
                        System.debug('string: '+lockedField);
                        currentInvoiceLine.addError(LOCK_UPDATE_FIELDS_ERROR);
                        continue;
                    }
                }
            }            
        }        
    }
    
    /**
* Prevent users from creating invoices that meet the criteria for the lock out period.      *  
* @author Ennube Solutions
*/
    //--merge to Minnow
    public static void preventCreatingInvoiceLine(List<fw1__Invoice_Line__c> newInvoiceLineItems, Map<fw1__Invoice_Line__c,fw1__Invoice__c> invoiceLineInvoiceMap){ // Merge with Partial                        
        Date currentDate = Date.today();
        List<Lock_Out_Period__c> lockOutPeriods = [SELECT Id, Start_Date__c, End_Date__c FROM Lock_Out_Period__c WHERE Locked__c = true AND End_Date__c >=:currentDate AND Start_Date__c<=:currentDate ORDER BY Start_Date__c ASC LIMIT 1];
        if( lockOutPeriods.isEmpty() ) {
            return;
        }
        Date lockOutEndDate = lockOutPeriods.get(0).End_Date__c;                 
        Date lockOutStartDate = lockOutPeriods.get(0).Start_Date__c;
        //Prevent creation of a new Invoice Line when the Invoice has a Lockout Period
        for(fw1__Invoice_Line__c invoiceLineItem : newInvoiceLineItems){
            fw1__Invoice__c currentParentInvoice = invoiceLineInvoiceMap.get(invoiceLineItem);
            if(currentParentInvoice.fw1__Invoice_Date__c<=lockOutEndDate && currentParentInvoice.fw1__Invoice_Date__c>=lockOutStartDate){
                invoiceLineItem.addError(LOCK_CREATION_ERROR);
            } 
            
        }   
    }
}