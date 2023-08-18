/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_InvoiceTriggerHelper
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1315
* Functionality     : This helper use in SCS_InvoiceTriggerHandler class to update initial and final invoice amount on opportunity.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        13-04-2023                          Initial version 
* Umesh Kumar                        13-04-2023                          Update initial and final invoice amount on opportunity when status is sent or paid.
************************************************************************************************************************************/

public with sharing class SCS_InvoiceTriggerHelper {
    //call from trigger handler when invoice record is update...
    public static void fireEventToupdateInitialOrFinalAmount(List<fw1__Invoice__c> newTrigger,Map<Id,fw1__Invoice__c> oldMap){
        List<Invoice_Event__e> invoiceIds = new List<Invoice_Event__e>();
        for(fw1__Invoice__c record : newTrigger){
            if(record.fw1__Opportunity__c != null && record.fw1__Status__c != oldMap.get(record.Id).fw1__Status__c && ( record.fw1__Status__c == 'Sent' || record.fw1__Status__c == 'Paid')){
                invoiceIds.add(new Invoice_Event__e(Invoice_Id__c = record.Id));
            }
        }
        if(! invoiceIds.isEmpty()){
            EventBus.publish(invoiceIds);
            system.debug('Fire Event');
        }
    }
    
    public static void updateAmountAndDate(Set<Id> opportunitySet,List<fw1__Invoice__c> newInvoiceList){
        //if opportunity set in not empty...
        if(! opportunitySet.isEmpty() && ! newInvoiceList.isEmpty()){
            //Query the all invoice related opportunity using opportunity set...
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id,Initial_Invoice_Number__c,Initial_Invoice_Amount__c,Initial_Invoice_Paid_Amount__c,Final_Invoice_Number__c,Final_Invoice_Amount__c,Final_Invoice_Paid_Amount__c,Invoice_Type__c,Initial_Invoice_Send_Date__c,Final_Invoice_Send_Date__c,Initial_Invoice_Payment_Date__c,Final_Invoice_Payment_Date__c FROM Opportunity WHERE Id IN :opportunitySet]);
            for(fw1__Invoice__c invRecord : newInvoiceList){
                if(invRecord.fw1__Opportunity__c != null){
                    Opportunity oppRecord = opportunityMap.containsKey(invRecord.fw1__Opportunity__c) ? opportunityMap.get(invRecord.fw1__Opportunity__c) : null;
                    if(oppRecord !=null){
                        //if invoice sent to customer...
                        if(invRecord.fw1__Status__c == 'Sent'){
                            //if initial invoice sent to customer then add initial invoice amount on opportunity...
                            if(oppRecord.Initial_Invoice_Number__c == null){
                                oppRecord.Initial_Invoice_Number__c = invRecord.Name;
                                oppRecord.Initial_Invoice_Amount__c = invRecord.fw1__Total_Invoice_Amount__c;
                                oppRecord.Initial_Invoice_Send_Date__c = System.now();
                                oppRecord.Invoice_Type__c = 'Initial';
                                //if final invoice sent to customer then add final invoice amount on opportunity...
                            } else if(oppRecord.Initial_Invoice_Number__c!=null && ! oppRecord.Initial_Invoice_Number__c.contains(invRecord.Name)){
                                oppRecord.Final_Invoice_Number__c = oppRecord.Final_Invoice_Number__c != null ? oppRecord.Final_Invoice_Number__c+','+invRecord.Name : invRecord.Name;
                                oppRecord.Final_Invoice_Amount__c =  oppRecord.Final_Invoice_Amount__c != null ? oppRecord.Final_Invoice_Amount__c + invRecord.fw1__Total_Invoice_Amount__c : invRecord.fw1__Total_Invoice_Amount__c;
                                oppRecord.Final_Invoice_Send_Date__c = System.now();
                                oppRecord.Invoice_Type__c = 'Final';
                            }
                            //if invoice paid by customer...
                        } else if(invRecord.fw1__Status__c == 'Paid'){
                            //if initial invoice paid by customer then add initial invoice amount on opportunity...
                            if(oppRecord.Initial_Invoice_Number__c != null && oppRecord.Initial_Invoice_Number__c.contains(invRecord.Name)){
                                oppRecord.Initial_Invoice_Paid_Amount__c =  invRecord.fw1__Total_Paid_Amount__c;
                                oppRecord.Initial_Invoice_Payment_Date__c = System.now();
                                //if final invoice paid by customer then add final invoice amount on opportunity...
                            } else if(oppRecord.Final_Invoice_Number__c != null && oppRecord.Final_Invoice_Number__c.contains(invRecord.Name) && oppRecord.Invoice_Type__c == 'Final'){
                                oppRecord.Final_Invoice_Paid_Amount__c =  oppRecord.Final_Invoice_Paid_Amount__c != null ? oppRecord.Final_Invoice_Paid_Amount__c + invRecord.fw1__Total_Paid_Amount__c : invRecord.fw1__Total_Paid_Amount__c;
                                oppRecord.Final_Invoice_Payment_Date__c = System.now();
                            }
                        }
                        opportunityMap.put(oppRecord.Id,oppRecord);
                    } 
                }
            }
            //update opportunity with initial amount or final amount...
            if(! opportunityMap.isEmpty()){
                update opportunityMap.values();
            } 
        }
    }
}