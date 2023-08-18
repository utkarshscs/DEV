/*
    Description : Test Class for SCS_EntityTrigger, SCS_EntityTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 26th September, 2022

    Please add @Revisions below
*/
@isTest
public class SCS_PaymentTriggerHandler_Test {
 
    @TestSetup
    static void makeData(){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
            Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
            Id contactRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

            List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
            insert accList;
            
            List<Contact> contacts = SCS_TestDataFactory.createContacts(accList[0].Id,contactRT_Id,1);
            insert contacts;

            List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
            programs[0].name = 'SQF';
            programs[0].SCS_Global_QB_Entity__c = true;
            insert programs;

            List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
            insert pcs;

            List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntity(1);
            entitys[0].fw1__Payment_Center_Setting__c = pcs[0].Id;
            insert entitys;
        
        	List<Campaign> campList = SCS_TestDataFactory.createCampaing(1);
			insert campList;        

            List<Opportunity> opportunity = SCS_TestDataFactory.createOpportunity('Closed Won', accList[0].Id,programs[0].Id,oppRT_Id,Date.Today(),1);
            opportunity[0].fw2__Entity__c = entitys[0].Id;
        	opportunity[0].CampaignId = campList[0].Id;
        	opportunity[0].Billing_Contact__c = contacts[0].Id;
            insert opportunity;

            List<fw1__Payment__c> paymentList = SCS_TestDataFactory.createPayment(1);
            paymentList[0].Name = 'PMT';
            paymentList[0].fw1__Opportunity__c = opportunity[0].Id;
            insert paymentList;
    }
   
    /*
        Method to check trigger handler scenario
        Refrenced - MockHttpResponseGenerator class to provide fake response for callout
        Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
    */
    @isTest
    static void triggerHandlerTest(){
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        System.runAs(integratorUser[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
                List<fw1__Payment__c> paymentList = [SELECT Id, Name,External_Record_Id__c  FROM fw1__Payment__c WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                paymentList[0].Name = 'Test';
                update paymentList[0];

            Test.stopTest();

            System.assertEquals('external-Id', paymentList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete paymentList;
        }

    }

}