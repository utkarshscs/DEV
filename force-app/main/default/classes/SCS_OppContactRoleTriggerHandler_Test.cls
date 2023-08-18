/*
    Description : Test Class for SCS_OppContactRoleTrigger, SCS_OppContactRoleTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 5th Dec, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_OppContactRoleTriggerHandler_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id contactRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].BillingCountry= 'United States';
        insert accList;
        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
        proList[0].name = 'SQF';
        insert proList; 

        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,proList[0].Id,oppRT_Id,Date.Today(),1);
        oppList[0].CloseDate = Date.Today().addYears(1);
        oppList[0].Programc__c = proList[0].Id;
        insert oppList; 

        List<Contact> contactList = SCS_TestDataFactory.createContacts(accList[0].Id, contactRT_Id, 1);
        contactList[0].Company_Name__c = 'Individual_Test';
        insert contactList;

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

                List<Contact> con = [SELECT Id FROM Contact WHERE CreatedDate = TODAY LIMIT 1];
                List<Opportunity> op = [SELECT Id FROM Opportunity WHERE CreatedDate = TODAY LIMIT 1];
        
                OpportunityContactRole opR = new OpportunityContactRole();
                opR.OpportunityId = op[0].Id;
                opR.ContactId = con[0].Id;
                opR.Role = 'Other';

                insert opR;

                opR.Is_Active__c = TRUE;

                update oPR;


            Test.stopTest();

            List<OpportunityContactRole> opRLIST = [SELECT Id,External_Record_Id__c FROM OpportunityContactRole WHERE CreatedDate = TODAY LIMIT 1];

            System.assertEquals('external-Id', opRLIST[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete opRLIST;
        }

    }

}