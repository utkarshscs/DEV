@isTest
public class SCSGlobal_CreateCertificateHelper_Test 
{
    
    @testSetup static void setup() 
    {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id naturalResourcesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Natural_Resources').getRecordTypeId();
        Id accRTS_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CustomerSite').getRecordTypeId();
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        Id oppChRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        //Create record...
        List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
		accountList[0].name = 'United PIPES';       
        accountList[0].BillingCountry= 'United States';
        insert accountList;
        
        List<Account> accListS = SCS_TestDataFactory.createAccounts(accRTS_Id,1);
        accListS[0].BillingCountry= 'United Kingdom';
        accListS[0].ParentId = accountList[0].id;
        insert accListS; 
        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
        proList[0].name = 'SQF';
        proList[1].name = 'IRMA';
        insert proList; 
        
        List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,proList[0].Id,naturalResourcesId ,Date.newInstance(2025,1,5),1);
        oppList[0].Type = 'New Business';
        oppList[0].TotalAmount__c = 1000;
        insert oppList;
        List<Certificate__c> certList =new List<Certificate__c>();
    	List<Opportunity_certificate__c> opcerlist = new List<Opportunity_certificate__c>();
        
        certList = SCS_TestDataFactory.createCertificate(1);
        insert certList;
        
        opcerlist = SCS_TestDataFactory.createOppsCertificate(certList[0], oppList);
        insert opcerlist;
        
        
        
    }
    
    public static testmethod void getCertificateFromOpportunityTest()
    {
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        System.runAs(integratorUser[0]){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            List<Opportunity> opptylist=[SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
           
            List<Certificate__c> ctlist = [select id from certificate__c limit 1];
            List<Opportunity_Certificate__c> oclist = new List<Opportunity_Certificate__C>();
            oclist = [Select id, certificate__C from Opportunity_Certificate__c limit 1];
            Certificate__c cc = [select id from certificate__c where id=:ctlist[0].id];
            Opportunity_Certificate__c opc = [Select certificate__c from Opportunity_Certificate__c where id=:oclist[0].id];
            
            System.debug('cc:' + cc);
            SCSGlobal_CreateCertificateHelper.getCertificateFromOpportunity(10,1,opptylist[0].Id);
            SCSGlobal_CreateCertificateHelper.getFieldsListFromFieldSet('SQF');
            //createCertificateAndOC(Certificate__c cert, Opportunity_Certificate__c oppCert, String existingCertId)
			Certificate__c cert = new Certificate__c();
            Opportunity_Certificate__c oppCert = new Opportunity_Certificate__c();
            SCSGlobal_CreateCertificateHelper.createCertificateAndOC(cert, oppCert, cc.id);
            Test.stopTest();
        }
    }
    
    public static testmethod void getCertificateFromOpportunityTest2()
    {
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        System.runAs(integratorUser[0]){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            List<Opportunity> opptylist=[SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
           
            List<Certificate__c> ctlist = [select id from certificate__c limit 1];
            List<Opportunity_Certificate__c> oclist = new List<Opportunity_Certificate__C>();
            oclist = [Select id, certificate__C from Opportunity_Certificate__c limit 1];
            Certificate__c cc = [select id from certificate__c where id=:ctlist[0].id];
            Opportunity_Certificate__c opc = [Select certificate__c from Opportunity_Certificate__c where id=:oclist[0].id];
            
            System.debug('cc:' + cc);
            SCSGlobal_CreateCertificateHelper.getCertificateFromOpportunity(10,1,opptylist[0].Id);
            SCSGlobal_CreateCertificateHelper.getFieldsListFromFieldSet('SQF');
            SCSGlobal_CreateCertificateHelper.getCertificateFieldsfromFieldSet('SQF');
            //createCertificateAndOC(Certificate__c cert, Opportunity_Certificate__c oppCert, String existingCertId)
			//Certificate__c cert = new Certificate__c();
            Opportunity_Certificate__c oppCert = new Opportunity_Certificate__c();
            SCSGlobal_CreateCertificateHelper.createCertificateAndOC(cc, oppCert, cc.id);
             SCSGlobal_CreateCertificateHelper.checkProjectExist(opptylist[0].Id);
            Test.stopTest();
        }
    }
}