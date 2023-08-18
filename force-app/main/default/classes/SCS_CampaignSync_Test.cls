/*
    Description : Test Class for SCS_CampaignSync, SCS_CampaignSyncHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 26th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_CampaignSync_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Campaign> campList = SCS_TestDataFactory.createCampaing(1);
        insert campList;

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
                List<Campaign> campList = [SELECT Id, Name, External_Record_Id__c FROM Campaign WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                campList[0].Name = 'Test';
                update campList[0];

            Test.stopTest();

            System.assertEquals('external-Id', campList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete campList;
        }

    }

}