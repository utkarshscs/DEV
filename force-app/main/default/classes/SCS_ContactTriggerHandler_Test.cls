/*
    Description : Test Class for SCS_LeadTrigger, SCS_LeadTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
public class SCS_ContactTriggerHandler_Test {
    
    @TestSetup
    static void makeData(){

        Id accountRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id contactRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        insert integratorUser[0];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Permissions'];

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = integratorUser[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        System.runAs(integratorUser[0]){

            List<Account> accList = SCS_TestDataFactory.createAccounts(accountRT_Id, 1);
            insert accList;
            List<Contact> contactList = SCS_TestDataFactory.createContacts(accList[0].Id, contactRT_Id, 3);
            contactList[0].Company_Name__c = 'Individual_Test';
            contactList[1].Company_Name__c = 'Test';
            insert contactList;
        
        }

    }
   
    /*
        Method to check trigger handler scenario
        Refrenced - MockHttpResponseGenerator class to provide fake response for callout
        Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
    */
    static testMethod void triggerHandlerTest(){


        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        integratorUser[0].username = 'webintwithbypass@gmail123.com';
        insert integratorUser[0];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Permissions'];

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = integratorUser[0].Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        System.runAs(integratorUser[0]){
            
            Test.startTest();

                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
                
                List<Contact> pb = [SELECT Id, Name, External_Record_Id__c FROM Contact WHERE CreatedDate = Today LIMIT 1];
        
                //checking update scenario
                pb[0].LastName = 'Test-PriceBook';
                update pb[0];

            Test.stopTest();

            //System.assertEquals('external-Id', pb[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete pb;
        }

    }

}