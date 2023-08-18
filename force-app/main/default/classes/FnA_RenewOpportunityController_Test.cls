/***************
Class: FnA_RenewOpportunityController_Test
Description : Test class for FnA_RenewOpportunityController
Author: Amitava Dutta
*******************/
@isTest
public with sharing class FnA_RenewOpportunityController_Test {
    
    @TestSetup
    static void makeData(){        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());        
        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        Id oppChRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();        
        Id scope_Id = Schema.SObjectType.Scope__c.getRecordTypeInfosByDeveloperName().get('Sub_Scope').getRecordTypeId();      
        
        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].BillingCountry= 'United States';
        insert accList;        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
        proList[0].name = 'SQF';
        insert proList;         
        
        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppRT_Id,Date.Today(),1);
        oppList[0].CloseDate = Date.Today().addYears(1); 
        insert oppList;            
        
        
        List<Opportunity> oppListCh = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppChRT_Id,Date.Today(),1);        
        oppListCh[0].Bundle_Opportunity__c	= oppList[0].id;
        
        insert oppListCh;        
        
        List<Scope__c> scopeList = SCS_TestDataFactory.createScope(1);
        scopeList[0].RecordTypeId = scope_Id;
        scopeList[0].Opportunity__c = oppListCh[0].Id;
        scopeList[0].Program__c = proList[0].Id;      
        insert scopeList;
        
        List<Site_Covered__c> siteCoveredList = SCS_TestDataFactory.createSiteCovered(oppListCh[0].Id, 1);
        insert siteCoveredList;
        
        List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id, 1);
        insert standards;
        
        List<Standard_Covered__c> standardCovered = SCS_TestDataFactory.createStandardCovered(oppListCh[0].Id,standards[0].Id, 1);
        insert standardCovered;
        
        PriceBook2 stan = SCS_TestDataFactory.getStandardPriceBook();
        update stan;
        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        insert prodListDummy;
        
        List<PricebookEntry> pbeList = SCS_TestDataFactory.createPriceBookEntry(stan.Id,prodListDummy[0].Id);
        insert pbeList;
        
        List<OpportunityLineItem> oliList = SCS_TestDataFactory.createOpportunityLI(oppListCh[0].Id, pbeList[0].Id, 1);
        insert oliList;
        
        List<OpportunityLineItem> oliListBD = SCS_TestDataFactory.createOpportunityLI(oppListCh[0].Id, pbeList[0].Id, 1);
        insert oliListBD;
        
        List<OpportunityTeamMember> oppTeamMemberList = SCS_TestDataFactory.createOppTeamMembers(oppListCh[0].Id, 1);
        insert oppTeamMemberList;        
        
    }
    
    //test method
    static  testMethod void getOpportunityListTest()
    {
        Test.startTest();
        Opportunity opBundle = [Select Id from Opportunity where Bundle_Opportunity__c != null limit 1];        
        FnA_RenewOpportunityController.getOpportunityList(opBundle.Id);
        Test.stopTest();
    }
    
    //test method
    static  testMethod void createOpRenewalBundle()
    {
        Test.startTest();
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            Opportunity opNewBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                       Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                       Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                       Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                       Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c 
                                       from Opportunity where Bundle_Opportunity__c = null limit 1];
            
            Opportunity opBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                    Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                    Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                    Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                    Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c from Opportunity 
                                    where Bundle_Opportunity__c != null limit 1]; 
            
            List<String> oppidlist = new List<String>(); oppidlist.add(opBundle.Id);
            List<String> relatedopplist = new List<String>();
            relatedopplist.add('Site_Covered');
            relatedopplist.add('Standard_Covered');
            relatedopplist.add('OpportunityTeam');
            relatedopplist.add('ContactRole');
            relatedopplist.add('Opportunity_Certificates');           
            
            FnA_RenewOpportunityController.createBundleOpportunity(oppidlist, opBundle.id, relatedopplist, opNewBundle.clone(false, true, false, false));
        }
        Test.stopTest();
    }
    
    //test method
    static  testMethod void createOpRenewalBundle2()
    {
        Test.startTest();
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            Opportunity opNewBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                       Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                       Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                       Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                       Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c 
                                       from Opportunity where Bundle_Opportunity__c = null limit 1];
            
            Opportunity opBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                    Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                    Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                    Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                    Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c from Opportunity 
                                    where Bundle_Opportunity__c != null limit 1];            
            
            List<String> oppidlist = new List<String>(); oppidlist.add(opBundle.Id);
            List<String> relatedopplist = new List<String>();
            relatedopplist.add('Site_Covered');
            relatedopplist.add('Standard_Covered');
            relatedopplist.add('OpportunityTeam');
            relatedopplist.add('ContactRole');
            relatedopplist.add('Opportunity_Certificates');	
            FnA_RenewOpportunityController.createBundleOpportunity(oppidlist, opNewBundle.id, relatedopplist, opNewBundle.clone(false, true, false, false));
            
        }
        Test.stopTest();
    }   
    
    //test method
    static  testMethod void createOpRenewalBundle3()
    {
        Test.startTest();
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        
        System.runAs(integratorUser[0]){
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            Opportunity opNewBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                       Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                       Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                       Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                       Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c 
                                       from Opportunity where Bundle_Opportunity__c = null limit 1];
            
            Opportunity opBundle = [Select Name,Engagement_Type__c,CloseDate,StageName,Type,AccountId,
                                    Billing_Contact__c,Bill_To_Company__c,Show_Discount__c,Include_Cover_Page__c,Payment_Term__c,RecordTypeId,Programc__c,
                                    Entity__c,fw2__Entity__c,Program_List__c,Bill_To_Address__c,LeadSource,Lead_Source_Details__c,Application_Status__c,
                                    Web_Traffic_Source__c,Language__c,NextStep,Description,Notes__c,Target_Audit_Date__c,Payment_Terms_Approval__c,Requested_Payment_Term__c,
                                    Project_Start_Date__c,SCS_Probability__c,Closed_Lost_Date__c,Loss_Reason__c from Opportunity 
                                    where Bundle_Opportunity__c != null limit 1];            
            
            List<String> oppidlist = new List<String>(); oppidlist.add(opBundle.Id);
            List<String> relatedopplist = new List<String>();            
            relatedopplist.add('ContactRole');
            relatedopplist.add('Products');
            relatedopplist.add('Opportunity_Certificates');	
            
            Id conRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
            List<Contact> conList = SCS_TestDataFactory.createContacts(opBundle.AccountId, conRT_Id,1);
            insert conList;
            
            List<OpportunityContactRole> oppConRoleList = SCS_TestDataFactory.createOppContactRoles(opBundle.Id, conList[0].Id, 1);
            insert oppConRoleList;
            
            List<Opportunity_Certificate__c> oppCertList = SCS_TestDataFactory.createOppCertificates(opBundle.Id, 1);
            oppCertList[0].Date_of_Audit__c = Date.today().addMonths(-1);
            insert oppCertList;
            
            List<Certified_Sites__c> oppCertSiteList = SCS_TestDataFactory.createCertifiedSites(oppCertList);
            insert oppCertSiteList;
            
            List<CertifiedProducts__c> oppCertProdList = SCS_TestDataFactory.createOppCertifiedProds(oppCertList[0].Id, 1);
            insert oppCertProdList;

            List<Species__c> specList = SCS_TestDataFactory.createSpecies(1);
            insert specList;

            List<Certified_Species__c> certSpecList = SCS_TestDataFactory.createCertifiedSpecies(oppCertProdList[0].Id,specList[0].Id,1);
            insert certSpecList;

            List<Certified_volume__c> certVolSpecList = SCS_TestDataFactory.createCertifiedVolume(oppCertList[0].Id,1);
            insert certVolSpecList;
            
            FnA_RenewOpportunityController.createBundleOpportunity(oppidlist, opNewBundle.id, relatedopplist, opNewBundle.clone(false, true, false, false));
            
        }
        Test.stopTest();
    }
}