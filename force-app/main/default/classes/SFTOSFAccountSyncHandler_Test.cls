/*
    Description : Test Class for SFTOSFAccountSync, SFTOSFAccountSyncHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 27th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SFTOSFAccountSyncHandler_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].BillingCountry= 'United States';
        insert accList;

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

                List<Account> acList = [SELECT Id, Name, External_Record_Id__c FROM Account LIMIT 1];
        
                //checking update scenario
                acList[0].Name = 'Test2';
                update acList;

            Test.stopTest();

           // System.assertEquals('external-Id', acList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            //delete acList;
        }

    }

}