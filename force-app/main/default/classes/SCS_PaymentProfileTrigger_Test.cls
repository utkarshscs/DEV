/*
@Author : MAANTIC
@CreatedDate : SEP 2022
@Description : This test class for SCS_PaymentProfileTrigger trigger.
*/


@isTest
public class SCS_PaymentProfileTrigger_Test {
    static Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    //Setup data...
    @testSetup static void setup() {
        
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser() ){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Create Account record...
            List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
            accList[0].BillingCountry= 'United States';
            insert accList;
            //Create payment center setting...
            List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1); 
            insert pcs;
            //Create Entity record...
            List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntitys(pcs[0].Id,1);
            insert entitys;
            //Create payment profile...
            List<fw1__PaymentProfile__c> paymentProfile = SCS_TestDataFactory.createPaymentProfiles(accList[0].Id,entitys[0].Id,1);
            paymentProfile[0].Name = 'PProfile';
            insert paymentProfile;
            
        }
         
    }
    
    @isTest static void testPaymentProfile() {
        Test.startTest();
        
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Get record ...
            List<fw1__PaymentProfile__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM fw1__PaymentProfile__c  WHERE Name = 'PProfile'];
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