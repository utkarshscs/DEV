trigger SCS_InvoiceEvent on Invoice_Event__e (after insert) {
 //Get the trigger active information from custom meta data by trigger name
    Boolean isActive = Trigger_Setting__mdt.getInstance('SCS_InvoiceEvent').Is_Active__c;
    if(isActive){    
        Set<String> invoiceIdSet = new Set<String>();
        for(Invoice_Event__e eventRecord :trigger.new){
            invoiceIdSet.add(eventRecord.Invoice_Id__c);
        }
        if(!invoiceIdSet.isEmpty()){
            List<fw1__Invoice__c>   invoiceList = new List<fw1__Invoice__c> ();
            Set<Id> oppIdSet= new Set<Id>();
            List<Opportunity>   oppoList = new List<Opportunity> ();
            for(fw1__Invoice__c record : [SELECT Id,Name,fw1__Opportunity__c,Invoice_Type__c,fw1__Status__c,fw1__Total_Paid_Amount__c,fw1__Total_Invoice_Amount__c FROM fw1__Invoice__c WHERE Id IN :invoiceIdSet]){
                invoiceList.add(record);
                oppIdSet.add(record.fw1__Opportunity__c);
            }
            if(! invoiceList.isEmpty() && ! oppIdSet.isEmpty()){
                //call apex class method to update amount...
                SCS_InvoiceTriggerHelper.updateAmountAndDate(oppIdSet,invoiceList);
            }
        }
    }
}