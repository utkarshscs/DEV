/*
    Description : Test Class for SCS_ProductTrigger, SCS_ProductTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_ProductTrigger_Test {
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        insert prodListDummy;

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
                List<Product2> prodListDummy = [SELECT Id, ProductCode, External_Record_Id__c FROM Product2 WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                prodListDummy[0].ProductCode = 'PRDTST';
                update prodListDummy[0];

            Test.stopTest();

            System.assertEquals('external-Id', prodListDummy[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete prodListDummy;
        }

    }

}