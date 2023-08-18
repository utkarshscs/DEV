/*
    Description : Test Class for SCS_ProgramTrigger, SCS_ProgramTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_ProgramTrigger_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Program__c> programList = SCS_TestDataFactory.createPrograms(1);
        insert programList;

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
                List<Program__c> programList = [SELECT Id, Name, External_Record_Id__c FROM Program__c WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                programList[0].Name = 'SQF';
                update programList[0];

            Test.stopTest();

            System.assertEquals('external-Id', programList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete programList;
        }

    }

}