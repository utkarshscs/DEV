/**************************************************** FnA ORG CODE ***************************************************************** 
* Class  Name       : FnA_LineItemHelper
* Division          : Food and Agriculture
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-311
* Functionality     : This helper use in OpportunityLineItemTriggerHandler to create update and delete line item in bundle opportunity.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        25-11-2022                          Initial version 
* Umesh Kumar                        07-11-2022                          Add and removed line item on bundle opportunity chnages..
************************************************************************************************************************************/




public with sharing class FnA_LineItemHelper {
    //Create opportunity line item in bundle opportunity...
    public static void addLineItemOnBundleOppo(List<OpportunityLineItem> newList){
        List<OpportunityLineItem> newOpportunityLineItemList = new List<OpportunityLineItem>();
        Map<String,String> pbEntryMap = new Map<String,String>();
        Set<String> productId = new  Set<String>();
        Set<String> opptyIdSet = new  Set<String>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        //Query standard price book id...
        List<Pricebook2> stdList =[SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        for(OpportunityLineItem record : newList) {
            if(String.isNotBlank(record.Product2Id)) {
                productId.add(record.Product2Id);
            }
            //Added by Sohit
            opptyIdSet.add(record.OpportunityId);
        }
        //Added by Sohit
        if(!opptyIdSet.isEmpty()){
            mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Programc__c FROM Opportunity WHERE Id IN: opptyIdSet]);
        }
        if(! stdList.isEmpty() && ! productId.isEmpty()) {
            //Query price book entry based on product and standard price book...
            for(PricebookEntry pbookEntry : [SELECT Id,Product2Id,Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =:stdList[0].Id AND Product2Id IN : productId AND IsActive = TRUE]){
                pbEntryMap.put(pbookEntry.Product2Id,pbookEntry.Id);
            }
            if(! pbEntryMap.isEmpty()){
                //loop each new line item and add new line item in list for bundle opportunity...
                for(OpportunityLineItem record : newList) {
                    if(String.isNotBlank(record.Bundled_OpportunityId__c) && pbEntryMap.containsKey(record.Product2Id)){
                        //clone each opportunity line item...
                        OpportunityLineItem oppoLine = record.clone(false, true, false, false);
                        oppoLine.OpportunityId = record.Bundled_OpportunityId__c;
                        oppoLine.Child_Opportunity_Product__c = record.Id;
                        oppoLine.PricebookEntryId = pbEntryMap.get(record.Product2Id);
                        oppoLine.TotalPrice = null;
                        //Added by Sohit
                        if(mapOpportunity.containsKey(record.OpportunityId) && mapOpportunity.get(record.OpportunityId).Programc__c != null){
                            oppoLine.Program__c = mapOpportunity.get(record.OpportunityId).Programc__c;
                        }
                        newOpportunityLineItemList.add(oppoLine); 
                    }  
                }
            }
            //Insert bundle opportunity line item...
            if(!newOpportunityLineItemList.isEmpty()){
                insert newOpportunityLineItemList;
            }
        }
    }
    //Update bundle opportunity line item...
    public static void updateLineItemOnBundleOppo(List<OpportunityLineItem> newList, Map<Id,Sobject> oldMap){
        List<OpportunityLineItem> updatedLineItemList = new List<OpportunityLineItem>();
        Map<String,String> lineItemMap = new Map<String,String>();
        //Query bundle opportunity line item based on old map id...
        for(OpportunityLineItem bundleLineItem :[SELECT Id,Child_Opportunity_Product__c,Name FROM OpportunityLineItem WHERE Child_Opportunity_Product__c IN : oldMap.keySet()]){
            lineItemMap.put(bundleLineItem.Child_Opportunity_Product__c,bundleLineItem.Id);
        }
        if(! lineItemMap.isEmpty()){
            //Add updated line item in list...
            for(OpportunityLineItem record : newList){
                OpportunityLineItem oldRecord = (OpportunityLineItem) oldMap.get(record.Id);
                if(lineItemMap.containsKey(record.Id) && (record.UnitPrice != oldRecord.UnitPrice || record.Quantity != oldRecord.Quantity || record.Discount != oldRecord.Discount || record.Description__c != oldRecord.Description__c || record.Description != oldRecord.Description || record.Discount_Amount__c != oldRecord.Discount_Amount__c)){
                    updatedLineItemList.add(new OpportunityLineItem(Id = lineItemMap.get(record.Id),
                    UnitPrice = record.UnitPrice,
                    Quantity = record.Quantity,
                    Discount = record.Discount,
                    Description__c = record.Description__c,
                    Description = record.Description,
                    Discount_Amount__c = record.Discount_Amount__c                                               
                    ));
                }
            }
            //update bundle opportunity line item...
            if(! updatedLineItemList.isEmpty()){
                update updatedLineItemList;
            }
        }
        
    }
    //Delete bundle opportunity line itrm...
    public static void deleteLineItemOnBundleOppo(Map<Id,Sobject> oldMap){
        //Query bundle opportunity line item
        List<OpportunityLineItem> lineItemRecords = [SELECT Id FROM OpportunityLineItem WHERE Child_Opportunity_Product__c IN :oldMap.keySet()];
        //Dete bundle opportunity line item...
        if(! lineItemRecords.isEmpty()){
            delete lineItemRecords; 
        }     
    }
    //Add and removed line item from bundle opportunity...
    public static void addChildLineItemOnBundleOpportunity(List<Opportunity> newList,Map<Id,Sobject> oldMap){
        Set<String> newOppIds = new Set<String>();
        Set<String> oldOppIds = new Set<String>();
        Set<String> bundleOppIds = new Set<String>();
        //Check bundle is change on each record... 
        for(Opportunity record :newList){
            Opportunity oldRecord = (Opportunity) oldMap.get(record.Id);
            if(record.Bundle_Opportunity__c != oldRecord.Bundle_Opportunity__c){
                if(record.HasOpportunityLineItem && String.isNotBlank(record.Bundle_Opportunity__c)){
                    newOppIds.add(record.Id);
                }
                if(oldRecord.HasOpportunityLineItem && String.isNotBlank(oldRecord.Bundle_Opportunity__c)){
                    bundleOppIds.add(oldRecord.Bundle_Opportunity__c);
                    oldOppIds.add(oldRecord.Id);
                }  
            }
        }
        //add line item in bundle opportunity...
        if(! newOppIds.isEmpty()){
            List<OpportunityLineItem> oppoLineItem =[SELECT Id,Name,ServiceDate,Product2Id,Bundled_OpportunityId__c,UnitPrice,Quantity,Discount,Discount_Amount__c,Description__c,Description, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN : newOppIds];
            addLineItemOnBundleOppo(oppoLineItem);
        }
        //removed line item from bundle opportunity...
        if(! oldOppIds.isEmpty()){
            Map<Id,OpportunityLineItem> oldOppoLineItem = new Map<Id,OpportunityLineItem>([SELECT Id,Name FROM OpportunityLineItem WHERE OpportunityId IN : oldOppIds]);
            if(! oldOppoLineItem.isEmpty() && ! bundleOppIds.isEmpty()){
                List<OpportunityLineItem> lineItemRecords = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN : bundleOppIds AND Child_Opportunity_Product__c IN :oldOppoLineItem.keySet()];
                //Dete bundle opportunity line item...
                if(! lineItemRecords.isEmpty()){
                    delete lineItemRecords; 
                } 
            }
        }
    }
    
}