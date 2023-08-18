/*
    Description : Test Class for SCS_CertificateTrigger, SCS_CertificateTrHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 23nd September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_CertificateTrigger_Test {
    
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<Certificate__c> certList = SCS_TestDataFactory.createCertificate(1);
        insert certList;

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
                List<Certificate__c> certList = [SELECT Id, Name, External_Record_Id__c FROM Certificate__c WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                certList[0].ValidFrom__c = Date.Today().addDays(10);
                update certList[0];

            Test.stopTest();

            System.assertEquals('external-Id', certList[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete certList;
        }

    }

}