/*
    Description : Test Class for LeadTriggerGeneric, LeadGenericTrigger
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class LeadGenericTriggerHelper_Test {

    @TestSetup
    static void makeData(){

        Id leadRT_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SCS_Global_Services').getRecordTypeId();
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Campaign> campList = SCS_TestDataFactory.createCampaing(1);
        insert campList;

        List<Program__c> programList = SCS_TestDataFactory.createPrograms(5);
        insert programList;

        List<Lead> ldList = SCS_TestDataFactory.createLead(1, 'New', leadRT_Id);
        for(Lead ln:ldList)
        {
            ln.LeadSource = 'Website';
        	ln.Recent_Campaign__c = campList[0].Id;
        	ln.program__c = programList[0].Id;
            
        }
        //ldList[2].LeadSource = 'Other';
        System.debug('*************MAIN LEAD' + ldList);
        insert ldList;
        //System.debug('*************' + ldList[0]);
        
    }

    /*
        Method to check trigger handler scenario
        Refrenced - MockHttpResponseGenerator class to provide fake response for callout
        Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
    */
    static testMethod void triggerHandlerTest(){

        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        String prevEmail = '';
        System.runAs(integratorUser[0]){
            
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
                
                List<Lead> pb = [SELECT Id, Name,Email,program__c,External_Record_Id__c,leadsource FROM Lead WHERE CreatedDate = Today LIMIT 1];
                List<Program__c> prog = [SELECT Id,  External_Record_Id__c FROM Program__c WHERE CreatedDate = Today LIMIT 2];
        
                //checking update scenario
                pb[0].LeadSource = 'Website';
                pb[0].Program__c = prog[1].Id;
               

                prevEmail = pb[0].Email;

                update pb;

            Test.stopTest();

            //System.assertEquals(prevEmail, pb[0].Email);

            //deleting the product to cover trigger delete
            //delete pb;
        }

    }
    
}