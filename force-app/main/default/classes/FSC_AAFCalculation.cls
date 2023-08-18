public with sharing class FSC_AAFCalculation {
    
    //Calculate AAF on OC creation...
    public static void culationAAFOnCreation(List<Opportunity_Certificate__c> newList) {
        Map <String,FSC_AAF_Table__mdt> cmdMap = getCMDRecord();
        for(Opportunity_Certificate__c record : newList ){
            Decimal  revenue;
            if(record.FSC_Certificate_Type__c == 'Project Certificate') {
                record.FPT_Processor__c = null;
                record.FPT_Trader__c = null;
                record.Revenue_Processor__c = null;
                record.Revenue_Trader__c = null;
                record.FPT__c = null;
                record.Total_Revenue__c = null;
                revenue = record.Project_Cost__c;
            } else if(record.FSC_Certificate_Type__c == 'Group Certificate') {
                record.FPT__c = null;
                record.Total_Revenue__c = null;
                record.Project_Cost__c = null;
                revenue = record.Company_Type__c.contains('Manufacturer') ? record.FPT_Processor_Calculated__c : record.FPT_Trader_Calculated__c;
            } else {
                record.FPT_Processor__c = null;
                record.FPT_Trader__c = null;
                record.Revenue_Processor__c = null;
                record.Revenue_Trader__c = null;
                record.Project_Cost__c = null;
                revenue = record.FPT_Calculated__c;
            }
            //String aafClass = record.Company_Type__c.contains('Manufacturer') ? record.Processor_AAF_Class__c : record.Trader_AAF_Class__c;
            String aafClass = String.isBlank(record.Processor_AAF_Class__c) ? record.Trader_AAF_Class__c: record.Processor_AAF_Class__c;
            Decimal aaf;
            if(cmdMap.containsKey(aafClass) ) {
                FSC_AAF_Table__mdt cmdRecord = cmdMap.get(aafClass);
                Decimal excessTurnover  =  revenue - cmdRecord.Minimum_Turnover__c;
                Decimal baseFee = record.Company_Type__c.contains('Manufacturer') ? cmdRecord.Processor_Base_USD__c : cmdRecord.Trader_Base_USD__c;
                Decimal variableFee = record.Company_Type__c.contains('Manufacturer') ? cmdRecord.Processor_Variable_USD__c : cmdRecord.Trader_Variable_USD__c;
                aaf = baseFee +((excessTurnover/cmdRecord.Fixed_Number__c) *variableFee);   
            } 
            record.Annual_Administration_Fee_AAF__c = revenue == null ? null:aaf;
        }
    }
    
    //Calculate AAF on OC updation...
    public static void culationAAFOnUpdate(List<Opportunity_Certificate__c> newList,Map<Id,Opportunity_Certificate__c> oldMap) {
        List<Opportunity_Certificate__c> modifiedList = new List<Opportunity_Certificate__c> ();
        for(Opportunity_Certificate__c record : newList ) {
            Opportunity_Certificate__c oldRecord = oldMap.get(record.Id); 
            if(record.Project_Cost__c != oldRecord.Project_Cost__c || record.FPT_Calculated__c != oldRecord.FPT_Calculated__c ||
               record.FPT_Processor_Calculated__c != oldRecord.FPT_Processor_Calculated__c || record.FPT_Trader_Calculated__c != oldRecord.FPT_Trader_Calculated__c ||
               record.FSC_Certificate_Type__c != oldRecord.FSC_Certificate_Type__c) {
                   modifiedList.add(record); 
               }
        }
        if(! modifiedList.isEmpty()) {
            culationAAFOnCreation(modifiedList); 
        }
    }
    
    //Get Fields record from custom meta data...
    public static Map <String,FSC_AAF_Table__mdt> getCMDRecord() {
        Map <String,FSC_AAF_Table__mdt> cmdMap = new Map <String,FSC_AAF_Table__mdt>();
        for (FSC_AAF_Table__mdt record : [SELECT MasterLabel,Minimum_Turnover__c,Maximum_Turnover__c,Processor_Base_USD__c,Processor_Variable_USD__c,Trader_Base_USD__c,Trader_Variable_USD__c,Fixed_Number__c FROM FSC_AAF_Table__mdt]) {
            cmdMap.put(record.MasterLabel,record); 
        }
        return cmdMap;
    }
    
}