/*
    Description : Test Class for SCS_EntityTrigger, SCS_EntityTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 26th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_EntityTriggerHandler_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<fw1__Entity__c> entList = SCS_TestDataFactory.createEntity(1);
        insert entList;

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
                List<fw1__Entity__c> entList = [SELECT Id, Name, External_Record_Id__c FROM fw1__Entity__c WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                entList[0].Name = 'Test';
                update entList[0];

            Test.stopTest();

            System.assertEquals('external-Id', entList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete entList;
        }

    }

}