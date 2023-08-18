/*
@Author : MAANTIC
@CreatedDate : 8th AUGUST 2022
@Description : OpportunityLineItem Object Trigger.
*/

public with sharing class OpportunityLineItemTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        
        //Looping each record...
        for(OpportunityLineItem record : recordList){
            opptyIdSet.add(record.OpportunityId);
            productIdSet.add(record.Product2Id);
        }
        
        if(opptyIdSet != null && !opptyIdSet.isEmpty()){
            //OpportunityLineItemTriggerHelper.calculateTotalSalesPrice(opptyIdSet, recordList, productIdSet); 
        }
        
    }
    
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        FnA_LineItemHelper.addLineItemOnBundleOppo(recordList);
    }
    
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
        //Convert List<Sobject> into List<OpportunityLineItem>...
        List<OpportunityLineItem> recordList = (List<OpportunityLineItem>) newList;
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        
        for(OpportunityLineItem record : recordList){
            //Get old record...
            OpportunityLineItem oldProduct = (OpportunityLineItem)oldMap.get(record.Id);
            if(record.Discount != oldProduct.Discount || record.Quantity != oldProduct.Quantity || record.UnitPrice != oldProduct.UnitPrice){
                opptyIdSet.add(record.OpportunityId);
                productIdSet.add(record.Product2Id);
            }
        }
        
        if(opptyIdSet != null && !opptyIdSet.isEmpty()){
            //OpportunityLineItemTriggerHelper.calculateTotalSalesPrice(opptyIdSet, recordList, productIdSet); 
        }
        
    }
    
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        List<OpportunityLineItem> newRecordList = (List<OpportunityLineItem>) newList;
        FnA_LineItemHelper.updateLineItemOnBundleOppo(newRecordList, oldMap); 
    }
    
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        FnA_LineItemHelper.deleteLineItemOnBundleOppo(oldMap);
    }
    
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
       
    }
    
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
    }
    

}