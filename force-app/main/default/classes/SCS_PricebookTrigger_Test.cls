/*
    Description : Test Class for SCS_PricebookTrigger, SCS_PricebookTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_PricebookTrigger_Test {
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'test';
        pb2.IsActive = true;
        
        insert pb2;

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
                
                List<PriceBook2> pb = [SELECT Id, Name, External_Record_Id__c FROM PriceBook2 WHERE CreatedDate = Today LIMIT 1];
        
                //checking update scenario
                pb[0].Name = 'Test-PriceBook';
                update pb[0];

            Test.stopTest();

            System.assertEquals('external-Id', pb[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete pb;
        }

    }

}