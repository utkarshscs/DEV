/*
@Author : MAANTIC
@CreatedDate : 8th August 2022
@Description : Opportunity Product Object Trigger Helper use to calculate Total Sales Price..
*/

public with sharing class OpportunityLineItemTriggerHelper {
    
    public static void calculateTotalSalesPrice(Set<Id> opptyIdSet, List<OpportunityLineItem> recordList, Set<Id> recordProductList){
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Map<Id, Product2> mapProduct;
        
        if(opptyIdSet != null && !opptyIdSet.isEmpty()){
            mapOpportunity = new Map<Id, Opportunity>([SELECT Id, Commission__c, Margin__c, G_A__c FROM Opportunity WHERE Id IN:opptyIdSet]);
            mapProduct = new Map<ID, Product2>( [Select Id,Revenue_Type__c from Product2 WHERE Id IN:recordProductList] );
        }
        
        for(OpportunityLineItem record : recordList){
            Boolean revenueTypeCheck = false;
            Decimal discount = record.Discount != null ? record.Discount : 0.00;
            if(mapProduct.containsKey(record.Product2Id)){
                revenueTypeCheck = mapProduct.get(record.Product2Id).Revenue_Type__c == 'R - Reimbursable/Travel' ? true : false ;
            }
            if(revenueTypeCheck){
                record.Total_Sales_Price__c = ((record.Quantity * record.UnitPrice)-((record.Quantity * record.UnitPrice) * (discount/100)));
            }
            else{
                //Decimal discount = record.Discount != null ? record.Discount : 0.00;
                Decimal margin = mapOpportunity.get(record.OpportunityId).Margin__c != null ? mapOpportunity.get(record.OpportunityId).Margin__c : 0.00;
                Decimal commission = mapOpportunity.get(record.OpportunityId).Commission__c != null ? mapOpportunity.get(record.OpportunityId).Commission__c : 0.00;
                Decimal ga = mapOpportunity.get(record.OpportunityId).G_A__c != null ? mapOpportunity.get(record.OpportunityId).G_A__c : 0.00;
                
                record.Total_Sales_Price__c = ((record.Quantity * record.UnitPrice) + ((record.Quantity * record.UnitPrice) * (margin/100)) + ((record.Quantity * record.UnitPrice) * (commission/100)) + ((record.Quantity * record.UnitPrice) * (ga/100))) - ((record.Quantity * record.UnitPrice) * (discount/100));
            }       
        }
    }
}