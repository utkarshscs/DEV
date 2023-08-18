/*
    Description : Test Class for SFTOSFOpportunitySync, SFTOSFOpportunitySyncHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 27th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SFTOSFOpportunitySyncHandler_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].BillingCountry= 'United States';
        insert accList;

        List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
        proList[0].name = 'SQF';
        insert proList;

        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,proList[0].Id,oppRT_Id,Date.Today(),1);
        insert oppList;

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

                List<Opportunity> opList = [SELECT Id, Name, External_Record_Id__c FROM Opportunity WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                opList[0].Name = 'Test2';
                update opList;

            Test.stopTest();

          //  System.assertEquals('external-Id', opList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete opList;
        }

    }

}