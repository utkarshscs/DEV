/*
    Description : Test Class for SCS_OpportunityLineItemTrigger, SCS_OppLineItemTrHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 27th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_OppLineItemTrHandler_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        Id oppChRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].BillingCountry= 'United States';
        insert accList;        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
        proList[0].name = 'SQF';
        insert proList; 

        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppRT_Id,Date.Today(),1);
        oppList[0].CloseDate = Date.Today().addYears(1);
        //oppList[0].Programc__c = proList[0].Id;
        insert oppList; 
        System.debug('OPPLIST' +  oppList);
        	
        List<Opportunity> oppListCh = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppChRT_Id,Date.Today(),1);
        
        oppListCh[0].Bundle_Opportunity__c	= oppList[0].id;
        System.debug('OPPLIST' +  oppListCh[0].Bundle_Opportunity__c);
        
        insert oppListCh;
        //oppListCh[0].Bundle_Opportunity__c	= oppList[0].id;
        System.debug('OPPLIST rectypeid' +  oppList[0].recordtypeId);
        System.debug('OPPLIST Bundle_Opportunity__c' +  oppListCh[0].Bundle_Opportunity__c);
        //update oppListCh;
        
        PriceBook2 stan = SCS_TestDataFactory.getStandardPriceBook();
		update stan;
        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        insert prodListDummy;

        List<PricebookEntry> pbeList = SCS_TestDataFactory.createPriceBookEntry(stan.Id,prodListDummy[0].Id);
        insert pbeList;

        List<OpportunityLineItem> oliList = SCS_TestDataFactory.createOpportunityLI(oppListCh[0].Id, pbeList[0].Id, 1);
        //insert oliList;
        
        List<OpportunityLineItem> oliListBD = SCS_TestDataFactory.createOpportunityLI(oppListCh[0].Id, pbeList[0].Id, 1);
        insert oliListBD;

    }
   
    /*
        Method to check trigger handler scenario
        Refrenced - MockHttpResponseGenerator class to provide fake response for callout
        Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
    */
    static testMethod void triggerHandlerTest(){


        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
            
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

                List<OpportunityLineItem> oliList = [SELECT Id, Description, External_Record_Id__c FROM OpportunityLineItem WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                oliList[0].Description = 'Desc';
                update oliList[0];

            Test.stopTest();

            //deleting the product to cover trigger delete
            delete oliList;
        }

    }

}