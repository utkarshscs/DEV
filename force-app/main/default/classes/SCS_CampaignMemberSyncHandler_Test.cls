/*
    Description : Test Class for SCS_CampaignMemberTrigger, SCS_CampaignMemberSyncHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 26th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_CampaignMemberSyncHandler_Test {
    
    
    @TestSetup
    static void makeData(){
        
        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id conRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        insert accList;
        
        List<Contact> conList = SCS_TestDataFactory.createContacts(accList[0].Id,conRT_Id,1);
        insert conList;
        
        List<Campaign> campList = SCS_TestDataFactory.createCampaing(2);
        insert campList;

        List<CampaignMember> campMemList = SCS_TestDataFactory.createCampaingMember(1, String.valueOf(campList[0].Id), conList[0].Id);
        insert campMemList;

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
                List<CampaignMember> campMemList = [SELECT Id, Status, External_Record_Id__c FROM CampaignMember WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                campMemList[0].Status = 'Sent';
                update campMemList[0];

            Test.stopTest();

            System.assertEquals('external-Id', campMemList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete campMemList;
        }

    }

}