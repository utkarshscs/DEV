public with sharing class SCS_CertifiedProductHelper {
    
    //call from certified trigger handler on insert or update...
    public static void addProductClaim(List<CertifiedProducts__c> newList,Map<Id,CertifiedProducts__c> oldMap){
        Set<String> ocIdSet = new Set<String>();
        Map<String,Set<String>> catMap = new Map<String,Set<String>> ();
        List<Opportunity_Certificate__c> updatedList = new List<Opportunity_Certificate__c> ();
        for(CertifiedProducts__c record :newList) {
            if(oldMap == null || (oldMap != null && record.Output_Category__c != oldMap.get(record.Id).Output_Category__c)){
                ocIdSet.add(record.OpportunityCertificate__c);    
            }
        }
        if(! ocIdSet.isEmpty()) {
            for(CertifiedProducts__c cp:[SELECT Id,Output_Category__c,OpportunityCertificate__c FROM CertifiedProducts__c WHERE OpportunityCertificate__c IN : ocIdSet] ){
                String catStr = cp.Output_Category__c;
                if(String.isNotBlank(catStr)) {
                    if(catStr.contains(';')) {
                        for(String str : catStr.split(';')) {
                            if (!catMap.containsKey(cp.OpportunityCertificate__c)) {
                                catMap.put(cp.OpportunityCertificate__c, new Set<String>());
                            }
                            catMap.get(cp.OpportunityCertificate__c).add(str);   
                        }
                    } else {
                        if (!catMap.containsKey(cp.OpportunityCertificate__c)) {
                            catMap.put(cp.OpportunityCertificate__c, new Set<String>());
                        }
                        catMap.get(cp.OpportunityCertificate__c).add(catStr);   
                    }
                } else {
                    if (!catMap.containsKey(cp.OpportunityCertificate__c)) {
                        catMap.put(cp.OpportunityCertificate__c, new Set<String>());
                    }
                    catMap.get(cp.OpportunityCertificate__c).add(catStr); 
                } 
            } 
        }
        
        if(! catMap.isEmpty()) {
            for(String key : catMap.keySet()){
                updatedList.add(new Opportunity_Certificate__c(Id = key,Product_Claims__c = String.join(new Set <String> (catMap.get(key)), ';')));
            } 
        }
        if(! updatedList.isEmpty()){
            update updatedList;
        }
    }
    
}