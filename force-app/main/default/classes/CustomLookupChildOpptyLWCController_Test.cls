/*
@Author : MAANTIC
@CreatedDate : 3rd April 2023
@Description : This class covers the CustomLookupChildOpptyLWCController apex class.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class CustomLookupChildOpptyLWCController_Test {
    
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
            insert oppList;
            PriceBook2 stan = SCS_TestDataFactory.getStandardPriceBook();
            update stan;
            List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
            insert prodListDummy;
        }
    }
    
    @isTest static void testCustomLookup() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> recordList =[SELECT Id,StageName FROM Opportunity WHERE NextStep ='ECS'];
            List<Opportunity> bundleList =[SELECT Id,Name,StageName,Bundle_Opportunity__c,Record_Type_Name__c FROM Opportunity WHERE NextStep ='BUNDLE'];
            List<OpportunityLineItem> oliList = [SELECT Id, Description, External_Record_Id__c FROM OpportunityLineItem WHERE CreatedDate = TODAY LIMIT 1];
            List<Product2> productList = [SELECT Id FROM Product2];
            List<Pricebook2> pricebookList = [SELECT Id, Name FROM Pricebook2];
            String oppList = JSON.serialize(recordList);
            String oliList2 = JSON.serialize(oliList);
            
            CustomLookupChildOpptyLWCController.searchLookupData('pro', 'pricebookentry', pricebookList[0].Id);
            CustomLookupChildOpptyLWCController.searchDefaultRecord(productList[0].Id, 'pricebookentry');
        }
    }
    
    @isTest static void testCustomLookup2() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> recordList =[SELECT Id,StageName FROM Opportunity WHERE NextStep ='ECS'];
            List<Opportunity> bundleList =[SELECT Id,Name,StageName,Bundle_Opportunity__c,Record_Type_Name__c FROM Opportunity WHERE NextStep ='BUNDLE'];
            List<OpportunityLineItem> oliList = [SELECT Id, Description, External_Record_Id__c FROM OpportunityLineItem WHERE CreatedDate = TODAY LIMIT 1];
            List<Product2> productList = [SELECT Id FROM Product2];
            List<Pricebook2> pricebookList = [SELECT Id, Name FROM Pricebook2];
            String oppList = JSON.serialize(recordList);
            String oliList2 = JSON.serialize(oliList);
            
            CustomLookupChildOpptyLWCController.searchLookupData('', 'pricebookentry', pricebookList[0].Id);
            //CustomLookupChildOpptyLWCController.searchDefaultRecord(productList[0].Id, 'pricebookentry');
        }
    }

}