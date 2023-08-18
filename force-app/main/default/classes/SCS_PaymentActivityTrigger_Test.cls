/*
@Author : MAANTIC
@CreatedDate : 26th SEP 2022
@Description : This test class for SCS_PaymentActivityTrigger trigger.
*/

@isTest
public class SCS_PaymentActivityTrigger_Test {
    static Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    static Id conRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    static Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
    //Setup data...
    @testSetup static void setup() {
        
        //Create web integrator user...
        Id profileId = [SELECT Id from Profile WHERE name = 'Sales User'].Id;
        List<User> userList = SCS_TestDataFactory.createUsers(profileId, 1);
        userList[0].Username ='salesuser@scsuser.com';
        insert userList;
        
        System.runAs( userList[0] ){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Create Account record...
            List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
            accList[0].BillingCountry= 'United States';
            insert accList;
            //Create contact...
            List<Contact> contacts = SCS_TestDataFactory.createContacts(accList[0].Id,conRT_Id,1);
            insert contacts;
            //Create program...
            List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
            programs[0].name='SQF';
            insert programs;
            //Create payment center setting...
            List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
            insert pcs;
            //Create Entity record...
            List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntitys(pcs[0].Id,1);
            insert entitys;
            //Create opportunity...
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,programs[0].Id,oppRT_Id,Date.Today(),1);
            //oppList[0].name = 'SCS_TestOpportunity';
            //oppList[0].TotalAmount__c = 1000;
            //oppList[0].Type = 'New Business';
            insert oppList; 
            //Create payments...
            List<fw1__Payment__c> payment = SCS_TestDataFactory.createPayment(1);
            insert payment;
            //Create payment profile...
            List<fw1__PaymentProfile__c> paymentProfile = SCS_TestDataFactory.createPaymentProfiles(accList[0].Id,entitys[0].Id,1);
            insert paymentProfile;
            //Create invoice...
            List<fw1__Invoice__c> invoice = SCS_TestDataFactory.createInvoice(1);
            invoice[0].fw1__Account__c = accList[0].id;
            invoice[0].fw1__Entity__c = entitys[0].Id;
            invoice[0].fw1__Payment_Profile__c = paymentProfile[0].Id;
            insert invoice;
            //Create payment Activity...
            List<fw1__Payment_Activity__c> pActivity = SCS_TestDataFactory.createPaymentActivitys(payment[0].Id,invoice[0].Id,1);
            pActivity[0].Name = 'PAYMENTACTIVITY';
            insert pActivity;
        }
        
    }
    
    @isTest static void testPaymentActivity() {
        Test.startTest();
        
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){ 
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Get records ...
            List<fw1__Payment_Activity__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM fw1__Payment_Activity__c WHERE Name = 'PAYMENTACTIVITY'];
            //Update records...
            update recordList;
            //Verify the response...
            //System.assertEquals('SCSTESTId',recordList[0].External_Record_Id__c,'External Record should not be blank');
            //Delete record to cover delete event in trigger...
            Database.Delete(recordList,false);
            //Un-Delete record to cover delete event in trigger...
            undelete recordList;
        }
        Test.stopTest();  
    } 
    
}