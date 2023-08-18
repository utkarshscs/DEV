/*
    Description : Test Class for SCS_Batch_Before15DaysInteLogDel
    Author      : Maantic
    Date        : September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_Batch_Before15DaysInteLogDel_Test {

    @TestSetup
    static void prepareData(){
        
        Integration_Log__c intLg = new Integration_Log__c(Error_Code__c = 'Batch_Test');
        insert intLg;

    }
    /*
        Test Method to test batch class
        Batch Class deletes Data created before Last Month.
    */
    static testMethod void batchTest(){
       
        Test.startTest();

            SCS_Batch_Before15DaysInteLogDel cleanIntegartionLog= new SCS_Batch_Before15DaysInteLogDel();
            Id jobid= Database.executeBatch(cleanIntegartionLog);

        Test.stopTest();

        List<Integration_Log__c> intList = [SELECT Id from Integration_Log__c];

        system.assertEquals(0, intList.size());
    }
}