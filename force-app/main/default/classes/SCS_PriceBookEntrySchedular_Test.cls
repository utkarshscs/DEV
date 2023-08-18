/*
    Description : Test Class for SCS_PriceBookEntrySchedular
    Author      : Utkarsh Goswami(Maantic)
    Date        : 26th September, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_PriceBookEntrySchedular_Test {
    
    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        PriceBook2 stan = SCS_TestDataFactory.getStandardPriceBook();

        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        insert prodListDummy;

        List<PricebookEntry> pbeList = SCS_TestDataFactory.createPriceBookEntry(stan.Id,prodListDummy[0].Id);
        insert pbeList;

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

                SCS_PriceBookEntrySchedular sch = new SCS_PriceBookEntrySchedular();

                String sch1 = '0 0 2 * * ?'; 
                System.schedule('Test Schedule',sch1,sch);

                sch.execute(null);
                        
            Test.stopTest();


            List<PricebookEntry> pb = [SELECT Id, unitprice, External_Record_Id__c FROM PricebookEntry WHERE CreatedDate = Today LIMIT 1];
                
            System.assertEquals('external-Id', pb[0].External_Record_Id__c);

            //deleting the product to cover trigger delete
            delete pb;
        }

    }

}