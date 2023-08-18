/*
@Author : MAANTIC
@CreatedDate : 3rd April 2023
@Description : This test class for AddChildOpportunityLWCController lightning web component.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class AddChildOpportunityLWCController_Test {
    
    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id programGoalId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            //Create record...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
            proList[0].name = 'SQF';
            proList[0].SCS_Global_QB_Entity__c = true;
            proList[1].name = 'BRCGS';
            proList[1].SCS_Global_QB_Entity__c = true;
            insert proList; 
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            standards[0].Language__c = 'English';
            insert standards;
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,null, bundelOppRTId ,Date.newInstance(2025,1,5),3);
            oppList[0].Name = 'New Business-';
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].RecordTypeId = oppRTId;
            oppList[0].Programc__c = proList[0].Id;
            oppList[0].Language__c = 'English';
            oppList[0].NextStep ='ECS';
            oppList[1].Type = 'New Business';
            oppList[1].TotalAmount__c = 1000;
            oppList[1].CampaignId = campaign[0].Id;
            oppList[1].NextStep ='BUNDLE';
            oppList[2].Type = 'New Business';
            oppList[2].TotalAmount__c = 1000;
            oppList[2].CampaignId = campaign[0].Id;
            oppList[2].NextStep ='BUNDLE';
            insert oppList;
            
            oppList[0].Bundle_Opportunity__c = oppList[1].Id;
            update oppList[0];

            
            PriceBook2 stan = SCS_TestDataFactory.getStandardPriceBook();
            update stan;
            List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
            insert prodListDummy;
            
            List<PricebookEntry> pbeList = SCS_TestDataFactory.createPriceBookEntry(stan.Id,prodListDummy[0].Id);
            insert pbeList;
            
            List<OpportunityLineItem> oliList = SCS_TestDataFactory.createOpportunityLI(oppList[0].Id, pbeList[0].Id, 1);
            insert oliList;
            
            List<Scope__c> scopeList = SCS_TestDataFactory.createScope(1);
            scopeList[0].Description__c = 'Testing My Desc';
            scopeList[0].opportunity__c = oppList[1].Id;
            scopeList[0].Program__c = proList[0].Id;
            scopeList[0].RecordTypeId = SCS_ConstantRTypeReference.scope_opportunityRTId;
            insert scopeList;
            
            List<Standard_Covered__c> standardList = SCS_TestDataFactory.createStandardCovered(oppList[1].Id, standards[0].Id, 1);
            insert standardList;
        }
    }
    
    @isTest static void testBundleOpportunity() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> recordList =[SELECT Id,StageName FROM Opportunity WHERE NextStep ='ECS'];
            List<Opportunity> bundleList =[SELECT Id,Name,StageName,Bundle_Opportunity__c,Record_Type_Name__c FROM Opportunity WHERE NextStep ='BUNDLE'];
            List<OpportunityLineItem> oliList = [SELECT Id, Description, External_Record_Id__c FROM OpportunityLineItem];
            List<Product2> productList = [SELECT Id FROM Product2];
            List<Program__c> programList = [SELECT Id, Name FROM Program__c];
            List<Scope__c> scopeList = [Select Id, Description__c from Scope__c];
            List<Standard_Covered__c> standardList = [Select Id from Standard_Covered__c];
            String oppList = JSON.serialize(recordList);
            String oliList2 = JSON.serialize(oliList);
            String scopeList2 = JSON.serialize(scopeList);
            String standardList2 = JSON.serialize(standardList);
                        
            AddChildOpportunityLWCController.getAllOpptyWithOlis(bundleList[0].Id);
            AddChildOpportunityLWCController.upsertOpptyList(oppList, oliList2, scopeList2, standardList2);
            AddChildOpportunityLWCController.getPricebookEntry(productList[0].Id);
            AddChildOpportunityLWCController.getPricebookAndRecordType(programList[0].Name);
            AddChildOpportunityLWCController.deleteOpportunity(recordList[0].Id);
        }
    }
    
    @isTest static void testBundleOpportunity2() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<OpportunityLineItem> oliList = [SELECT Id, Description, External_Record_Id__c FROM OpportunityLineItem];
            
            AddChildOpportunityLWCController.deleteOpportunity(oliList[0].Id);
        }
    }
    
    @isTest static void testBundleOpportunity3() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Scope__c> scopeList = [Select Id, Description__c from Scope__c];
            
            AddChildOpportunityLWCController.deleteOpportunity(scopeList[0].Id);
        }
    }
    
    @isTest static void testBundleOpportunity4() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Standard_Covered__c> standardList = [Select Id from Standard_Covered__c];
            
            AddChildOpportunityLWCController.deleteOpportunity(standardList[0].Id);
        }
    }
    
}