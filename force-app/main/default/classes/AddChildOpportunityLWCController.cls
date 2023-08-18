/*
@Author : MAANTIC
@CreatedDate : 26th Feb 2023
@Description : This class is used to create child opportunity and line items under bundle opportunity.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/
public without sharing class AddChildOpportunityLWCController {
    
    @AuraEnabled(cacheable=true)
    public static WrapperClass getPricebookAndRecordType(String programName){
        List<Pricebook2> pricebookList = [SELECT Id, Name, Program__c, Program__r.Reporting_Division__c FROM Pricebook2 WHERE Program__r.Name =:programName AND IsActive = true];
        List<Pricebook2> allpricebookList = [SELECT Id, Name, Program__c, Program__r.Reporting_Division__c FROM Pricebook2 WHERE IsActive = true];
        Program__c prg = [SELECT Id, Name, Reporting_Division__c, Division__c FROM Program__c WHERE Name =:programName LIMIT 1];
        
        if(pricebookList != null && !pricebookList.isEmpty()){
            WrapperClass wrap = new WrapperClass();
            wrap.prg = prg != null ? prg : null;
            wrap.pricebookList = pricebookList;
            wrap.opp = null;
            wrap.pricebookName = null;
            return wrap;
        }
        else{
            WrapperClass wrap = new WrapperClass();
            wrap.prg = prg != null ? prg : null;
            wrap.pricebookList = allpricebookList;
            wrap.opp = null;
            wrap.pricebookName = null;
            return wrap;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static PriceBookEntry getPricebookEntry(String product2Id){
        return [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =:product2Id LIMIT 1];
    }    
    
    @AuraEnabled(cacheable=true)
    public static List<WrapperClass> getAllOpptyWithOlis(String bundleOpptyId){
        List<Map<String ,Object>> oppMapList  = new  List<Map<String ,Object>>();
        Set<String> programNameSet = new Set<String>();
        List<WrapperClass> wrapperList = new List<WrapperClass>();
        Map<String, List<Pricebook2>> mapProgramPricebook = new Map<String, List<Pricebook2>>();
        Map<Id, List<Scope__c>> mapPrgScope = new Map<Id, List<Scope__c>>();
        List<Opportunity> oppList = [SELECT Id, TotalAmount__c, RecordTypeId, LeadSource, Target_Audit_Date__c, Pricebook2Id, Pricebook2.Name, AccountId, Name, Program_List__c, Engagement_Type__c, StageName, CloseDate, Type, HasOpportunityLineItem, Bundle_Opportunity__c, Language__c, Programc__c,
                                     (SELECT Id, Name, Quantity, Discount, Discount_Amount__c, TotalPrice, UnitPrice, Product2Id, Description FROM OpportunityLineItems ORDER BY CreatedDate ASC),
                                     (SELECT Id, name, Title__c, Description__c, Opportunity__c, Program__c, Sub_Scope__c, Sub_Scope__r.Name FROM Scope__r Where Sub_Scope__c != null),
                                     (SELECT Id, Standard__c, Opportunity__c, Program__c, Name FROM Standard_Covered__r)
                                     FROM Opportunity where Bundle_Opportunity__c =:bundleOpptyId ORDER BY CreatedDate ASC];
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                programNameSet.add(opp.Program_List__c);
            }
        }
        
        List<Pricebook2> pricebookList = [SELECT Id, Name, Program__c, Program__r.Name, Program__r.Reporting_Division__c FROM Pricebook2 WHERE Program__r.Name IN:programNameSet AND IsActive = true];
        List<Pricebook2> allpricebookList = [SELECT Id, Name, Program__c, Program__r.Name, Program__r.Reporting_Division__c FROM Pricebook2 WHERE IsActive = true];
                
        if(!pricebookList.isEmpty()){
            for(Pricebook2 pb : pricebookList){
                if(!mapProgramPricebook.containsKey(pb.Program__r.Name)){
                    mapProgramPricebook.put(pb.Program__r.Name, new List<Pricebook2>{pb});
                }
                else{
                    mapProgramPricebook.get(pb.Program__r.Name).add(pb);
                }
            }
        }
        
        if(!programNameSet.isEmpty()){
            String subScopeRecType = Label.SubScopeRecordType;
            for(Scope__c sc : [SELECT Id, Name, Title__c, Description__c, Sub_Scope__c,Program__c FROM Scope__c WHERE RecordType.DeveloperName=:subScopeRecType AND Program__r.Name =:programNameSet]){
                if(!mapPrgScope.containsKey(sc.Program__c)){
                    mapPrgScope.put(sc.Program__c, new List<Scope__c>{sc});
                }
                else{
                    mapPrgScope.get(sc.Program__c).add(sc);
                }
            }
        }
        
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                WrapperClass wrap = new WrapperClass();
                wrap.prg = null;
                if(mapProgramPricebook.containsKey(opp.Program_List__c) && !mapProgramPricebook.get(opp.Program_List__c).isEmpty()){
                    wrap.pricebookList = mapProgramPricebook.get(opp.Program_List__c);
                    wrap.pricebookName = opp.Pricebook2.Name;
                }
                else{
                    wrap.pricebookList = allpricebookList;
                    wrap.pricebookName = '';
                }
                wrap.opp = opp;
                if(mapPrgScope.containsKey(opp.Programc__c) && !mapPrgScope.get(opp.Programc__c).isEmpty()){
                    wrap.subScopeList = mapPrgScope.get(opp.Programc__c);
                }
                wrap.hasSubScope = opp.Scope__r.size() > 0 ? true : false;
                wrap.hasStandardCovered = opp.Standard_Covered__r.size() > 0 ? true : false;
                wrapperList.add(wrap);
            }
        }
        return wrapperList;
    }
    
    public class WrapperClass{
        @AuraEnabled
        public Program__c prg{get;set;}
        @AuraEnabled
        public List<Pricebook2> pricebookList{get;set;}
        @AuraEnabled
        public Opportunity opp{get;set;}
        @AuraEnabled
        public String pricebookName{get;set;}
        @AuraEnabled
        public List<Scope__c> subScopeList{get;set;}
        @AuraEnabled
        public Boolean hasSubScope{get;set;}
        @AuraEnabled
        public Boolean hasStandardCovered{get;set;}
    }
    
    @AuraEnabled(Cacheable=false)
    public static void upsertOpptyList(String opptyList, String oliList, String subScopeList, String standardList){
        System.debug('subScopeList--'+subScopeList);
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();
        List<Opportunity> opptyListToInsert = new List<Opportunity>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLItemList = new List<OpportunityLineItem>();
        List<Scope__c> scopeList = new List<Scope__c>();
        List<Standard_Covered__c> stanCoveredList = new List<Standard_Covered__c>();
        
        if(String.isNotBlank(opptyList)){
            opportunityList = (List<Opportunity>) JSON.deserialize(opptyList, List<Opportunity>.class);
        }
        if(String.isNotBlank(oliList)){
            opportunityLItemList = (List<OpportunityLineItem>) JSON.deserialize(oliList, List<OpportunityLineItem>.class);
        }
        if(String.isNotBlank(subScopeList)){
            scopeList = (List<Scope__c>) JSON.deserialize(subScopeList, List<Scope__c>.class);
        }
        if(String.isNotBlank(standardList)){
            stanCoveredList = (List<Standard_Covered__c>) JSON.deserialize(standardList, List<Standard_Covered__c>.class);
        }
        
        try{
            if(opportunityList != null && !opportunityList.isEmpty()){
                upsert opportunityList;
            }
            
            if(opportunityLItemList != null && !opportunityLItemList.isEmpty()){
                upsert opportunityLItemList;
            }
            
            if(scopeList != null && !scopeList.isEmpty()){
                upsert scopeList;
            }
            
            if(stanCoveredList != null && !stanCoveredList.isEmpty()){
                upsert stanCoveredList;
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable=false)
    public static void deleteOpportunity(String recordId){
        try{
            if(recordId.startsWith('006')){
                //Delete [SELECT Id FROM Opportunity WHERE Id=:recordId];
                Opportunity opp = new Opportunity(Id = recordId, StageName = 'Closed Lost', 
                                                  Loss_Reason__c = 'Removed from Bundle Opportunity', 
                                                  Bundle_Opportunity__c = null,
                                                  CampaignId = Label.lblDefaultHSCampaign);
                update opp;
            }
            else if(recordId.startsWith('00k')){
                Delete [SELECT Id FROM OpportunityLineItem WHERE Id=:recordId];
            }
            else if(recordId.startsWith('a26')){
                Delete [SELECT Id FROM Scope__c WHERE Id=:recordId];
            }
            else{
                Delete [SELECT Id FROM Standard_Covered__c WHERE Id=:recordId];
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}