/*
    Description : Test Class for SCS_LeadTrigger, SCS_LeadTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_LeadTriggerHandler_Test {
    
    @TestSetup
    static void makeData(){

        Id leadRT_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SCS_Global_Services').getRecordTypeId();
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Lead> ldList = SCS_TestDataFactory.createLead(1, 'New', leadRT_Id);
        insert ldList;

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
                
                List<Lead> pb = [SELECT Id, Name, External_Record_Id__c FROM Lead WHERE CreatedDate = Today LIMIT 1];
        
                //checking update scenario
                pb[0].LastName = 'Test-PriceBook';
                update pb[0];

            Test.stopTest();

            System.assertEquals('external-Id', pb[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete pb;
        }

    }

}