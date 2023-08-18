/*
    Description : Test Class for InvoiceLineItemTrigger, InvoiceLineItemTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 20th Dec, 2022

    Please add @Revisions below
*/
@isTest
public with sharing class SCS_InvoiceLine_Trigger_Test {

    public static final string LOCK_UPDATE_FIELDS_ERROR = 'Current Invoice Lines can not be updated because the field is locked';
    public static final string LOCK_UPDATE_PERIOD_ERROR = 'Current Invoice can not be updated because the period is locked';
    public static final string LOCK_CREATION_ERROR = 'Invoice Line can not be created because the period is locked';
    
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

      //  List<MPM4_BASE__Milestone1_Program__c> programs = SCS_TestDataFactory.createMilPrograms(1);
      //  insert programs;

        List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
        programs[0].name = 'SQF';
        insert programs;

        List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
        insert pcs;

        List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntity(1);
        entitys[0].fw1__Payment_Center_Setting__c = pcs[0].Id;
        insert entitys;

        List<Campaign> camp = SCS_TestDataFactory.createCampaing(1);
        insert camp;

        List<Opportunity> opportunity = SCS_TestDataFactory.createOpportunity('Negotiation', accList[0].Id,programs[0].Id,oppRT_Id,Date.Today(),1);
        opportunity[0].fw2__Entity__c = entitys[0].Id;
        opportunity[0].CampaignId = camp[0].Id;
        insert opportunity;

        List<fw1__PaymentProfile__c> paymentProfile = SCS_TestDataFactory.createPaymentProfiles(accList[0].Id,entitys[0].Id,1);
        insert paymentProfile;

        List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
        lpList[0].Locked__c = false;
        insert lpList;


        List<fw1__Invoice__c> invoice = SCS_TestDataFactory.createInvoice(1);
        invoice[0].fw1__Entity__c = entitys[0].Id;
        invoice[0].fw1__Payment_Profile__c = paymentProfile[0].Id;
      ////  invoice[0].Quickbooks_ID__c = 'QUICKBOOKID';
        invoice[0].fw1__Account__c = accList[0].Id;
        invoice[0].fw1__Contact__c = contacts[0].Id;
        invoice[0].fw1__Opportunity__c = opportunity[0].Id;
        invoice[0].fw1__Description__c = 'DEscp';
        insert invoice;

        List<fw1__Invoice_Line__c> invoiceLine = SCS_TestDataFactory.createInvoiceLines(null, null, invoice[0].Id, 2);
        invoiceLine[0].fw1__Quantity__c = 5;
        invoiceLine[0].fw1__Unit_Price__c = 250000;   
        invoiceLine[0].fw1__Invoice__c = invoice[0].Id;
        insert invoiceLine;

    }
   
    /*
        Method to check trigger handler scenario
        Refrenced - MockHttpResponseGenerator class to provide fake response for callout
        Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
    */
    static testMethod void triggerHandlerTest(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());

        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
            
            Test.startTest();

                List<fw1__Invoice_Line__c> lpList = [SELECT Id, fw1__Item_Description__c FROM fw1__Invoice_Line__c WHERE CreatedDate = TODAY LIMIT 1];
        
                //checking update scenario
                lpList[0].fw1__Item_Description__c = 'Description-1';
                update lpList[0];

            Test.stopTest();

            System.assertEquals('Description-1', lpList[0].fw1__Item_Description__c);

            //deleting the product to cover trigger delete
            delete lpList;
        }

    }

    static testMethod void updateAddErrorTest(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
        
            Test.startTest();
                List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
                lpList[0].Locked__c = true;
                insert lpList;

                List<fw1__Invoice_Line__c> ivlist = [SELECT Id, fw1__Item_Description__c FROM fw1__Invoice_Line__c WHERE CreatedDate = TODAY LIMIT 1];

                try{        
                    //checking update scenario
                    ivlist[0].fw1__Item_Description__c = 'Description-1';
                    update ivlist[0];
                }
                catch(Exception e){
                    
                    //System.assert(e.getMessage().contains(LOCK_UPDATE_FIELDS_ERROR));
                }
            Test.stopTest();
        }

    }
/*
    static testMethod void updateAddErrorInvoiceDateTest(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
        
            Test.startTest();
                List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
                lpList[0].Locked__c = true;
                insert lpList;

                List<fw1__Invoice_Line__c> ivlist = [SELECT Id, fw1__Description__c,fw1__Invoice_Date__c FROM fw1__Invoice_Line__c WHERE CreatedDate = TODAY LIMIT 1];

                try{        
                    //checking update scenario
                    ivlist[0].fw1__Invoice_Date__c = Date.today().addDays(2);
                    update ivlist[0];
                }
                catch(Exception e){
                    
                    System.assert(e.getMessage().contains(LOCK_UPDATE_PERIOD_ERROR));
                }
            Test.stopTest();
        }
    }
*/
    static testMethod void createAddErrorInvoiceDateTest(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
        
            
            List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
            lpList[0].Locked__c = true;
            insert lpList;

            List<fw1__Invoice_Line__c> ivlist = [SELECT Id, fw1__Quantity__c,fw1__Unit_Price__c,fw1__Invoice__c
                                                FROM fw1__Invoice_Line__c WHERE CreatedDate = TODAY LIMIT 1];

            try{        
                fw1__Invoice_Line__c cl = ivlist[0].clone(false, true, false, false);
                insert cl;
            }
            catch(Exception e){
                
                System.assert(e.getMessage().contains(LOCK_CREATION_ERROR));
            }
        }

    }
}