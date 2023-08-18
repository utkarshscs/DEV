/*
@Author : MAANTIC
@CreatedDate : 6th OCT 2022
@Description : This test class for SCS_OppoCertificateTrigger trigger.
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class SCS_OppoCertificateTrigger_Test {
    //Setup data...
    @testSetup static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        List<User> userList = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        userList[0].Username ='salesuser@scsuser.com';
        insert userList;
        System.runAs(userList[0]){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock()); 
            //Create Account...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            //Create Program...
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
            proList[0].name = 'SQF';
            insert proList;
            //Create campaign record...
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            //Create Opportunity...
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,proList[0].Id,oppRTId ,Date.today(),1);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            insert oppList; 
            //Create Certificate...
            List<Certificate__c> certificate = SCS_TestDataFactory.createCertificate(1);
            certificate[0].Account__c = accountList[0].Id;
            insert certificate;
            //Create Opportunity Certificate...
            Opportunity_Certificate__c oppoCertificate = new Opportunity_Certificate__c();
            oppoCertificate.Account__c = accountList[0].Id;
            oppoCertificate.Certificate__c = certificate[0].Id;
            oppoCertificate.Opportunity__c = oppList[0].Id;
            oppoCertificate.Customer__c = accountList[0].Id;
            insert oppoCertificate;  
        }
        
    }
    
    @isTest static void testOpportunityCertificate() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock());
            //Get Record ...
            List<Opportunity_Certificate__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM Opportunity_Certificate__c];
            //Update  records...
            update recordList;
            //Verify the response...
            System.assertEquals('SCSTESTId',recordList[0].External_Record_Id__c,'External Record should not be blank');
            //Delete record to cover delete event in trigger...
            Database.Delete(recordList,false);
            //Un-Delete record to cover delete event in trigger...
            undelete recordList;
        }
        Test.stopTest();  
    }
    
    
    public class SCS_DataSyncMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"id":"SCSTESTId","success":true,"errors":[],"created":true}');
            response.setStatusCode(201);
            return response; 
        }
    }
    
}