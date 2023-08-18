/*
@Author : MAANTIC
@CreatedDate : 19th Oct 2022
@Description : Task trigger test.
*/
/****************************** NEW ORG CODE *****************************************************/

@isTest
public class SCS_TaskTrigger_Test {
    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        List<User> users = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        users[0].Username = 'salesuser@scsuser.com';
        insert users;
        
        System.runAs(users[0]){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock()); 
            //Create Account record...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            //Create Program record...
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
            proList[0].name = 'SQF';
            insert proList;
            //Create Campaign record... 
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            //Create Contact record...
            List<Contact> conList = SCS_TestDataFactory.createContacts(accountList[0].Id,conRTId,1);
            insert conList;
            //Create Opportunity record...
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,proList[0].Id,oppRTId ,Date.today(),1);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id, 1);
            insert projects;
            
            //Create task...
            Task tsk = new Task ();
            tsk.Subject = 'OppoTask';
            tsk.WhoId = conList[0].Id;
            tsk.WhatId = oppList[0].Id;
            tsk.Priority = 'Normal';
            tsk.Status = 'Open';
            insert tsk;
            
            Task tsk2 = new Task ();
            tsk2.Subject = 'OppoTask2';
            tsk2.WhoId = conList[0].Id;
            tsk2.WhatId = projects[0].Id;
            tsk2.Priority = 'Normal';
            tsk2.Status = 'Open';
            insert tsk2;
            
            Task tsk3 = new Task ();
            tsk3.Subject = 'OppoTask3';
            tsk3.WhoId = conList[0].Id;
            tsk3.WhatId = accountList[0].Id;
            tsk3.Priority = 'Normal';
            tsk3.Status = 'Open';
            insert tsk3;
        }
        
    }
    
    @isTest static void testTask() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock());
            //Get Campaign ...
            List<Task> recordList =[SELECT Id,External_Record_Id__c FROM Task  WHERE Subject ='OppoTask'];
            //Update campaign records...
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
    
    @isTest static void testTask2() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock());
            //Get Campaign ...
            List<Task> recordList =[SELECT Id,External_Record_Id__c FROM Task  WHERE Subject ='OppoTask2'];
            update recordList;
        }
        Test.stopTest();  
    }
    
    @isTest static void testTask3() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock());
            //Get Campaign ...
            List<Task> recordList =[SELECT Id,External_Record_Id__c FROM Task  WHERE Subject ='OppoTask3'];
            update recordList;
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