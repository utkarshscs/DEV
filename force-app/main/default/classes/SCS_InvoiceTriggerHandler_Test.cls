/*
Description : Test Class for SCS_InvoiceTrigger, SCS_InvoiceTriggerHandler
Author      : Utkarsh Goswami(Maantic)
Date        : 26th September, 2022

Please add @Revisions below
*/
@isTest
public class SCS_InvoiceTriggerHandler_Test {
    
    
    public static final string LOCK_UPDATE_FIELDS_ERROR = 'Invoice Date falls in locked period where accounting cannot post invoices anymore. please update the invoice date to send';
    public static final string LOCK_UPDATE_PERIOD_ERROR = 'Invoice Date falls in locked period where accounting cannot post invoices anymore. please update the invoice date to send';
    public static final string LOCK_CREATION_ERROR = 'Invoice can not be created because the period is locked';
    
    
    @TestSetup
    static void makeData(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        List<Account> accList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
        accList[0].Type ='Customer';
        accList[0].Quickbooks_ID__c ='QBID';
        insert accList;
        List<Contact> contacts = SCS_TestDataFactory.createContacts(accList[0].Id,SNM_TestConstant.customerConRTId,1);
        insert contacts;
        List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
        programs[0].name = 'SQF';
        programs[0].SCS_Global_QB_Entity__c = true;
        insert programs;
        List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
        insert pcs;
        List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntity(1);
        entitys[0].fw1__Payment_Center_Setting__c = pcs[0].Id;
        entitys[0].Name = 'SCS Global';
        insert entitys;
        
        List<Campaign> camp = SCS_TestDataFactory.createCampaing(1);
        insert camp;
        
        List<Opportunity> opportunity = SCS_TestDataFactory.createOpportunity('Enquiry', accList[0].Id,programs[0].Id,SNM_TestConstant.eCSOppoRTId,Date.Today(),1);
        opportunity[0].fw2__Entity__c = entitys[0].Id;
        opportunity[0].CampaignId = camp[0].Id;
        opportunity[0].Billing_Contact__c = contacts[0].Id;
        opportunity[0].LeadSource = 'Advertisement';
        opportunity[0].Name = 'Test-opp';
        opportunity[0].PriceBook2Id =Test.getStandardPricebookId();
        insert opportunity;
        
        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        prodListDummy[0].isActive = true;
        insert prodListDummy;
        
        List<PricebookEntry> pbeList = SCS_TestDataFactory.createPriceBookEntry(Test.getStandardPricebookId(),prodListDummy[0].Id);
        insert pbeList;
        
        opportunity[0].StageName = 'Closed Won';
        update opportunity;
        
        List<fw1__Invoice__c> invoice = SCS_TestDataFactory.createInvoice(2);
        invoice[0].fw1__Entity__c = entitys[0].Id;
        invoice[0].fw1__Account__c = accList[0].Id;
        invoice[0].fw1__Contact__c = contacts[0].Id;
        invoice[0].fw1__Opportunity__c = opportunity[0].Id;
        invoice[1].fw1__Entity__c = entitys[0].Id;
        invoice[1].fw1__Account__c = accList[0].Id;
        invoice[1].fw1__Contact__c = contacts[0].Id;
        invoice[1].fw1__Opportunity__c = opportunity[0].Id;
        insert invoice;
        
        /*List<fw1__Invoice_Line__c> invoiceLine = SCS_TestDataFactory.createInvoiceLines(prodListDummy[0].Id,Test.getStandardPricebookId(), invoice[0].Id,2);
        invoiceLine[0].fw1__Quantity__c = 1;
        invoiceLine[0].fw1__Unit_Price__c = 250000;
        invoiceLine[1].fw1__Invoice__c = invoice[1].Id;
        invoiceLine[1].fw1__Unit_Price__c = 250000;
        insert invoiceLine;*/
        
        List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
        lpList[0].Locked__c = false;
        insert lpList;
    }
    
    /*
Method to check trigger handler scenario
Refrenced - MockHttpResponseGenerator class to provide fake response for callout
Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
*/
    @isTest static void invoiceTriggerHandlerTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<fw1__Invoice__c> invList = [SELECT Id,fw1__Email_Sent__c,fw1__Total_Paid_Amount__c,fw1__Status_Sys__c FROM fw1__Invoice__c];
        
        //checking update scenario
        invList[0].fw1__Email_Sent__c = TRUE;
        invList[1].fw1__Email_Sent__c = TRUE;
        update invList;
        
        invList[0].fw1__Total_Paid_Amount__c = 250000; 
        invList[0].fw1__Status_Sys__c = 'Paid';
        invList[1].fw1__Total_Paid_Amount__c = 250000; 
        invList[1].fw1__Status_Sys__c = 'Paid';
        update invList;
        Test.stopTest();
        
    }
    
    /*
Method to check trigger handler scenario
Refrenced - MockHttpResponseGenerator class to provide fake response for callout
Checked all the scenarios here to avoid multiple data creating(As callout is on trigger)
*/
    static testMethod void triggerHandlerTest(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<User> integratorUser = [SELECT Id FROM User];
        
        Test.startTest();
        
        List<fw1__Invoice__c> lpList = [SELECT Id, fw1__Description__c FROM fw1__Invoice__c WHERE CreatedDate = TODAY LIMIT 1];
        
        //checking update scenario
        lpList[0].fw1__Description__c = 'Description-1';
        update lpList[0];
        
        Test.stopTest();
        
        System.assertEquals('Description-1', lpList[0].fw1__Description__c);
        
        //deleting the product to cover trigger delete
        delete lpList;
        
    }
    
    static testMethod void updateAddErrorTest(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<User> integratorUser = [SELECT Id FROM User];
        
        
        Test.startTest();
        List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
        lpList[0].Locked__c = true;
        insert lpList;
        
        List<fw1__Invoice__c> ivlist = [SELECT Id, fw1__Description__c FROM fw1__Invoice__c WHERE CreatedDate = TODAY LIMIT 1];
        
        try{        
            //checking update scenario
            ivlist[0].fw1__Description__c = 'Description-1';
            update ivlist[0];
        }
        catch(Exception e){
            
            //   System.assert(e.getMessage().contains(LOCK_UPDATE_FIELDS_ERROR));
            //System.assert(e.getMessage().contains(LOCK_UPDATE_FIELDS_ERROR));
        }
        Test.stopTest();
        
    }
    
    static testMethod void updateAddErrorInvoiceDateTest(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<User> integratorUser = [SELECT Id FROM User];
        
        Test.startTest();
        List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
        lpList[0].Locked__c = true;
        insert lpList;
        
        List<fw1__Invoice__c> ivlist = [SELECT Id, fw1__Description__c,fw1__Invoice_Date__c FROM fw1__Invoice__c WHERE CreatedDate = TODAY LIMIT 1];
        
        try{        
            //checking update scenario
            ivlist[0].fw1__Invoice_Date__c = Date.today().addDays(2);
            update ivlist[0];
        }
        catch(Exception e){
            
            //System.assert(e.getMessage().contains(LOCK_UPDATE_PERIOD_ERROR));
        }
        Test.stopTest();
    }
    
    static testMethod void createAddErrorInvoiceDateTest(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<User> integratorUser = [SELECT Id FROM User];
        
        List<Lock_Out_Period__c> lpList = SCS_TestDataFactory.createLockPeriod(1);
        lpList[0].Locked__c = true;
        insert lpList;
        
        List<fw1__Invoice__c> ivlist = [SELECT Id, fw1__Description__c,fw1__Invoice_Date__c,fw1__Entity__c, fw1__Payment_Profile__c ,
                                        fw1__Account__c,fw1__Contact__c,fw1__Opportunity__c
                                        FROM fw1__Invoice__c WHERE CreatedDate = TODAY LIMIT 1];
        
        try{        
            fw1__Invoice__c cl = ivlist[0].clone(false, true, false, false);
            insert cl;
        }
        catch(Exception e){
            
            System.assert(e.getMessage().contains(LOCK_CREATION_ERROR));
        }
    }
    
}