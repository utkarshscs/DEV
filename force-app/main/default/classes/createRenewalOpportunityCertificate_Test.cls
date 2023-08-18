/***************
Class: createRenewalOpportunityCertificate_Test
Description : Test class for createRenewalOpportunityCertificate
Author: Amitava Dutta
*******************/
@isTest
public class createRenewalOpportunityCertificate_Test {

    @TestSetup
    static void makeData(){
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id accRTS_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CustomerSite').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        Id oppChRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        

        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].name = 'cust_acc';
        accList[0].BillingCountry= 'United States';
        insert accList;   
        
        List<Account> accListS = SCS_TestDataFactory.createAccounts(accRTS_Id,1);
        accListS[0].BillingCountry= 'United Kingdom';
        accListS[0].ParentId = accList[0].id;
        
        insert accListS;  
        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
        proList[0].name = 'SQF';
        insert proList; 

        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppRT_Id,Date.Today(),1);
        oppList[0].CloseDate = Date.Today().addYears(1);
        //oppList[0].Programc__c = proList[0].Id;
        insert oppList; 
        System.debug('OPPLIST' +  oppList);
        	
        List<Opportunity> oppListCh = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,null,oppChRT_Id,Date.Today(),1);
        
        oppListCh[0].previous_opportunity__c = oppList[0].id;
        //System.debug('OPPLIST' +  oppListCh[0].Bundle_Opportunity__c);
        
        insert oppListCh;
        
        List<Certificate__c> certList = SCS_TestDataFactory.createCertificate(1);
        insert certList;
        
        List<Opportunity_certificate__c> opcerlist = SCS_TestDataFactory.createOppsCertificate(certList[0], oppList);
        insert opcerlist;

        List<CertifiedProducts__c> certProdList = SCS_TestDataFactory.createOppCertifiedProds(opcerlist[0].Id, 1);
        insert certProdList;

        List<Species__c> specList = SCS_TestDataFactory.createSpecies(1);
        insert specList;

        List<Certified_Species__c> certSpecList = SCS_TestDataFactory.createCertifiedSpecies(certProdList[0].Id,specList[0].Id,1);
        insert certSpecList;

        List<Certified_volume__c> certVolSpecList = SCS_TestDataFactory.createCertifiedVolume(opcerlist[0].Id,1);
        insert certVolSpecList;
        
        List<Certified_Sites__c> cstlist = SCS_TestDataFactory.createCertifiedSites(opcerlist);
        cstlist[0].CustomerSite__c = accListS[0].Id;
        cstList[0].Account__c = accList[0].id;
        insert cstlist;
        

    }
    static testMethod void createRenewalOpportunityCertificate()
    {
       test.startTest();
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
       Opportunity opm = [select id,name,previous_opportunity__c from opportunity where previous_opportunity__c !=null limit 1 ] ;
       List<String> opids = new List<string>(); opids.add(opm.id);
       createRenewalOpportunityCertificate.createRenewalOpportunityCertificateAndCertifiedSites(opids);
        
        
       test.stopTest(); 
    }
}