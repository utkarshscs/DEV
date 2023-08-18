/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : Invoice Object Trigger Handler.

@Revision    : Utkarsh G - 29 Nov, 2022 - Updated the logic addOpportunityLineItem
*/
public without sharing class SCS_InvoiceTriggerHandler implements ITriggerHandler {
    static final String INVOICE_SENT = 'Sent';
    static final String INVOICE_PAID = 'Paid';
    static final String INVOICE_PARTIAL = 'Partial';
    static final String INVOICE_OVERDUE = 'Overdue';
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<fw1__Invoice__c>...
        List<fw1__Invoice__c> recordList = (List<fw1__Invoice__c>) newList;
        for(fw1__Invoice__c record : recordList){
            if(record.isClone()){
               record.External_Record_Id__c = null;
            }
       } 
        
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<fw1__Invoice__c>...
        List<fw1__Invoice__c> recordList = (List<fw1__Invoice__c>) newList;
        //Filter record list...
        List<fw1__Invoice__c> filterRecordList = new List<fw1__Invoice__c>();
        //Loop each record...
        for(fw1__Invoice__c record : recordList){
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_inv_Id__c)){
                //Add filter record into list...
                filterRecordList.add(record); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterRecordList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterRecordList),'fw1__Invoice__c','PATCH','');
        }
        
        // calculates total amounts
        calculateTotalAmount(recordList, null);
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Convert List<Sobject> into List<fw1__Invoice__c>...
        List<fw1__Invoice__c> recordList = (List<fw1__Invoice__c>) newList;
        //Filter record list...
        List<fw1__Invoice__c> filterRecordList = new List<fw1__Invoice__c>();
        //Loop each record...
        List<Sync_Invoice_Line_Item__e > invoicelineItemEvent = new List<Sync_Invoice_Line_Item__e >();
        for(fw1__Invoice__c record : recordList){
            //Get old record...
            fw1__Invoice__c oldRecord = (fw1__Invoice__c)oldMap.get(record.Id);
            //Check last modified user not equal to web integrater user...
            if(record.LastModifiedById != System.Label.Web_Integrator && String.isBlank(record.DMS_inv_Id__c)){
                //Add filter record into list...
                filterRecordList.add(record); 
            }
            if(String.isNotBlank(record.External_Record_Id__c) && String.isBlank(oldRecord.External_Record_Id__c) ){
                invoicelineItemEvent.add(new Sync_Invoice_Line_Item__e(Invoice_Id__c = record.Id));
                
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !filterRecordList.isEmpty()){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(filterRecordList),'fw1__Invoice__c','PATCH','');
        }
        
        // calculates total amounts
        calculateTotalAmount(recordList, (Map<Id, fw1__Invoice__c>)oldMap);
        if(invoicelineItemEvent.size()>0){
            EventBus.publish(invoicelineItemEvent);
        }
        // create OpportunityLineItems 
        addOpportunityLineItem(recordList, (Map<Id, fw1__Invoice__c>)oldMap);
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
    /* Method used to calculate SUM of Total Invoice Amount and Total Paid Amount on Opportunity
     * parms: new list of Invoices, old map of invoices
     * //SF-273
    */
    public void calculateTotalAmount(List<fw1__Invoice__c> newList, Map<Id, fw1__Invoice__c> oldMap){
        Set<id> oppIds = new Set<id>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        Set<String> invStatus = new Set<String>{INVOICE_SENT, INVOICE_PAID, INVOICE_PARTIAL, INVOICE_OVERDUE};
            
        for(fw1__Invoice__c invoice : newList){system.debug('@@@ ' +  invoice.fw1__Status__c);
            fw1__Invoice__c oldInv = oldMap != null ? oldMap.get(invoice.Id) : null;
            if(invoice.fw1__Opportunity__c != null && invStatus.contains(invoice.fw1__Status__c) &&
               (oldInv == null || oldInv.fw1__Status__c != invoice.fw1__Status__c || oldInv.fw1__Total_Paid_Amount__c != invoice.fw1__Total_Paid_Amount__c))
            {
                oppIds.add(invoice.fw1__Opportunity__c);
            }
        }system.debug('@@@ Opp ' +oppIds);
        List<Opportunity> oppList = [SELECT Id, fw1__Total_Invoice_Amount__c, fw1__Total_Paid_Amount__c, 
                               (SELECT Id, fw1__Total_Invoice_Amount__c, fw1__Total_Paid_Amount__c, fw1__Status__c FROM  fw1__Invoices__r
                               WHERE fw1__Status__c IN: invStatus) 
                               FROM Opportunity WHERE Id IN : oppIds];
        for(Opportunity opp : oppList){
            opp.fw1__Total_Invoice_Amount__c = 0;
            opp.fw1__Total_Paid_Amount__c = 0;
            for(fw1__Invoice__c invoice : opp.fw1__Invoices__r){system.debug('@@@ ' + invoice.fw1__Status__c);             
                fw1__Invoice__c oldInv = oldMap != null ? oldMap.get(invoice.Id) : null;
                if(invoice.fw1__Total_Invoice_Amount__c != null && invStatus.contains(invoice.fw1__Status__c))
                {
                    // If Overdue then check if previous status was SENT. For other staus, Total Invoice should be calculated
                    if(!INVOICE_OVERDUE.equalsIgnoreCase(invoice.fw1__Status__c) || (oldInv != null && INVOICE_SENT.equalsIgnoreCase(oldInv.fw1__Status__c) && 
                                                                                     INVOICE_OVERDUE.equalsIgnoreCase(invoice.fw1__Status__c)))
                       {
                    		opp.fw1__Total_Invoice_Amount__c = opp.fw1__Total_Invoice_Amount__c + invoice.fw1__Total_Invoice_Amount__c;
                       }
                }
                if(invoice.fw1__Total_Paid_Amount__c != null && (INVOICE_PAID.equalsIgnoreCase(invoice.fw1__Status__c) || INVOICE_PARTIAL.equalsIgnoreCase(invoice.fw1__Status__c)))
                {
                    opp.fw1__Total_Paid_Amount__c = opp.fw1__Total_Paid_Amount__c + invoice.fw1__Total_Paid_Amount__c;
                }
            }
            lstOppToUpdate.add(opp);
        }system.debug('@@@ ' + lstOppToUpdate);
        update lstOppToUpdate;
    }

    /*
        Author    :     Farhan
        Date      :     28 Nov, 2022
        Description :    Called from Invoice Trigger
                          When invoice item is SENT any new product added to invoice line
                          will migrate to OLI
        Params    :    New list and old Map
        
        @Revision    : Utkarsh G - 29 Nov, 2022 - Updated the logic to add the oli    
    
    */
    public void addOpportunityLineItem(List<fw1__Invoice__c> newList, Map<Id, fw1__Invoice__c> oldMap){
        
        Set<Id> invoiceIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        OpportunityLineItem oli;

        List<OpportunityLineItem> newOLIRecords = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        
        for(fw1__Invoice__c inv : newList){
            if(inv.SCS_Email_Sent__c == false && inv.fw1__Status__c == INVOICE_SENT && oldMap.get(inv.Id).fw1__Status__c != inv.fw1__Status__c){
                invoiceIdSet.add(inv.Id);
                oppIdSet.add(inv.fw1__Opportunity__c);
            }  
        }
        
        System.debug('invoice list ' + invoiceIdSet);
        System.debug('oppIdSet ' + oppIdSet);
        
        List<OpportunityLineItem> oppLineItemList = [Select Id, Product2Id, Quantity, Invoice_Quantity__c, UnitPrice
                                                     From OpportunityLineItem where OpportunityId IN: oppIdSet];
        
        for(OpportunityLineItem lineItem : oppLineItemList){
           productIdSet.add(lineItem.Product2Id);
        }
        
        System.debug('productIdSet ' + productIdSet.size()); 
        System.debug('productIdSet ' + productIdSet); 
        
        List<fw1__Invoice_Line__c> invoiceLineItemList = [Select Id,Name,fw1__Invoice__c, fw1__Product2__c, fw1__Invoice__r.fw1__Opportunity__c,
                                                          fw1__Quantity__c, fw1__Taxable__c, fw1__Item_Description__c, fw1__Amount__c,
                                                          fw1__Unit_Price__c, fw1__Discount_Amount__c, fw1__Discount_Percentage__c,fw2__Opportunity_Product__c
                                                          From fw1__Invoice_Line__c Where fw1__Invoice__c IN : invoiceIdSet];
       
       System.debug('fw1__Invoice_Line__c ' + invoiceLineItemList.size());                                                  
        
        for(fw1__Invoice_Line__c inv : invoiceLineItemList){
        
            if(!productIdSet.contains(inv.fw1__Product2__c) || String.isBlank(inv.fw2__Opportunity_Product__c)){
                
                oli = new OpportunityLineItem();
                
                oli.Product2Id = inv.fw1__Product2__c;
                oli.OpportunityId = inv.fw1__Invoice__r.fw1__Opportunity__c;
                oli.UnitPrice = inv.fw1__Unit_Price__c;
                oli.Quantity = inv.fw1__Quantity__c;
                oli.Invoice_Quantity__c = inv.fw1__Quantity__c;
                
                newOLIRecords.add(oli);
                
            }      
        }
        
        System.debug('newOLIRecords ' + newOLIRecords);

        if(newOLIRecords.size() > 0) 
            insert newOLIRecords;

    }    
}