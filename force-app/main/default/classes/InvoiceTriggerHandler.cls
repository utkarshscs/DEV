/*
    Description :   Handler class for Invoice Trigger
                    Entire logic is taken from old org.
    Date        :   15th Dec, 2022
    Author      :   Utkarsh G (Maantic)

*/
public class InvoiceTriggerHandler {
 
    public static final string ACCOUNTING_LOCKOUT_PS = 'Accounting_Lockout_Periods';
    public static final string LOCK_CREATION_ERROR = 'Invoice can not be created because the period is locked';
    public static final string LOCK_UPDATE_FIELDS_ERROR = 'Current Invoice can not be updated because the field is locked';
    public static final string LOCK_UPDATE_PERIOD_ERROR = 'Current Invoice can not be updated because the period is locked';

    
    public static void beforeDelete(List<fw1__Invoice__c> oldInvoices){
        
        for(fw1__Invoice__c invoiceToDelete : oldInvoices){
            if(invoiceToDelete.fw1__Status__c != null){
                invoiceToDelete.addError('You cannot delete an Invoice record if it has already been sent. If you need to submit a change, please create a Credit Memo.');
            }
        }

    }
    
    /**
         * Prevent users from updating invoices that meet the criteria for the lock out period.
         * If the invoice date falls in lock period and user is trying to update any field present
           in Lock_Out_Invoice_Fields add validation to restrict the update
         * Called from Invoice_Trigger
         * Params : oldMap and new Map
    */
    public static void preventUpdatingInvoice(Map<Id,fw1__Invoice__c> oldInvoices,Map<Id,fw1__Invoice__c> newInvoices){
        
        //Skip if it's an admin
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        for(PermissionSetAssignment psa : lstcurrentUserPerSet){
            if(ACCOUNTING_LOCKOUT_PS.equals(psa.PermissionSet.Name)) {
                return;
            }                
        }

        //Get Dates of Invoice
        List<Date> currentDates = new List<Date>();
        for(fw1__Invoice__c currentInvoice: newInvoices.values()){  
            currentDates.add(currentInvoice.fw1__Invoice_Date__c);
        }
        currentDates.sort();
        Date lockOutDate = currentDates.get(0);

        List<Lock_Out_Period__c> lockOutPeriods = [SELECT Id, Start_Date__c, End_Date__c FROM Lock_Out_Period__c WHERE Locked__c = true AND End_Date__c >= :lockOutDate AND Start_Date__c <=: lockOutDate ORDER BY Start_Date__c ASC LIMIT 1];
        
        if( lockOutPeriods.isEmpty() ) {
            return;
        }

        Date lockOutEndDate = lockOutPeriods.get(0).End_Date__c;
        Date lockOutStartDate = lockOutPeriods.get(0).Start_Date__c;

        String lockedFieldsString = Label.Lock_Out_Invoice_Fields;
        List<String> lockedFields = lockedFieldsString.split(';');

        for(fw1__Invoice__c currentInvoice: newInvoices.values()){ 
            fw1__Invoice__c oldInvoice = oldInvoices.get(currentInvoice.Id);            
            Date invoiceDate = currentInvoice.fw1__Invoice_Date__c;

            if( invoiceDate > lockOutEndDate || invoiceDate < lockOutStartDate ) {
                continue;
            }

            if( oldInvoice.fw1__Invoice_Date__c != invoiceDate ){
                currentInvoice.addError(LOCK_UPDATE_PERIOD_ERROR);
                continue;
            }
            
            for( String lockedField : lockedFields ) {
                if( currentInvoice.get(lockedField) != oldInvoice.get(lockedField) ) {
                    currentInvoice.addError(LOCK_UPDATE_FIELDS_ERROR);
                    continue;
                }
            }
        }
    }

    /**
         * Prevent users from Creating invoices that meet the criteria for the lock out period.
         * Called from Invoice_Trigger
         * Params : List newInvoices
    */
    public static void preventCreatingInvoice(List<fw1__Invoice__c> newInvoices){
        Date currentDate = Date.today();
        List<Lock_Out_Period__c> lockOutPeriods = [SELECT Id, Start_Date__c, End_Date__c FROM Lock_Out_Period__c WHERE Locked__c = true AND End_Date__c >=:currentDate AND Start_Date__c<=:currentDate ORDER BY Start_Date__c ASC LIMIT 1];
        if( lockOutPeriods.isEmpty() ){
            return;
        }   
        Date lockOutEndDate = lockOutPeriods.get(0).End_Date__c;                 
        Date lockOutStartDate = lockOutPeriods.get(0).Start_Date__c;
        for( fw1__Invoice__c currentInvoice: newInvoices ){                
            if(currentInvoice.fw1__Invoice_Date__c <= lockOutEndDate && currentInvoice.fw1__Invoice_Date__c >= lockOutStartDate){
                currentInvoice.addError(LOCK_CREATION_ERROR);
            }       
        }
    }
}