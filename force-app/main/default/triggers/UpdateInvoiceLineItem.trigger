trigger UpdateInvoiceLineItem on Sync_Invoice_Line_Item__e (after insert) {

    
    System.debug(' !!!! UpdateInvoiceLineItem Trigger Entry');
    //Get the trigger active information from custom meta data by trigger name
    Boolean isActive = Trigger_Setting__mdt.getInstance('FnA_PlatFormEventTrigger').Is_Active__c;
    if(isActive){
        Set<String> invoiceId = new Set<String>();
        for(Sync_Invoice_Line_Item__e eventRecord :trigger.new){
            invoiceId.add(eventRecord.Invoice_Id__c);
        }
        
        if(!invoiceId.isEmpty()){
            List<fw1__Invoice_Line__c>   lineItemRecords = new List<fw1__Invoice_Line__c>();
            for(fw1__Invoice_Line__c record :[SELECT Id,Name,fw1__Product2__r.Name FROM fw1__Invoice_Line__c WHERE fw1__Product2__c != null AND fw1__Invoice__c IN :invoiceId]){
                lineItemRecords.add( new fw1__Invoice_Line__c( Id = record.Id,Name = record.fw1__Product2__r.Name));
            }
            if(! lineItemRecords.isEmpty()){
                update lineItemRecords; 
            } 
        }
        System.debug(' !!!! UpdateInvoiceLineItem Trigger Exit'); 
    }
}