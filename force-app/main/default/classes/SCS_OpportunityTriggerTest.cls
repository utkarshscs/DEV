/*
@Author : MAANTIC
@CreatedDate : 27th SEP 2022
@Description : This test class for SCS_OpportunityTrigger trigger.
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class SCS_OpportunityTriggerTest {
    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id programGoalId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock()); 
            //Create record...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
            proList[0].name = 'SQF';
            proList[0].SCS_Global_QB_Entity__c = true;
            proList[1].name = 'BRCGS';
            proList[1].SCS_Global_QB_Entity__c = true;
            insert proList; 
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            standards[0].Language__c = 'English';
            insert standards;
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            List<Goal__c> goalList = SCS_TestDataFactory.createGoalRecord(programGoalId,proList[0].id,'Q1','2025',1);  
            insert goalList;
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,null, bundelOppRTId ,Date.newInstance(2025,1,5),3);
            oppList[0].Name = 'New Business-';
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].RecordTypeId = oppRTId;
            oppList[0].Programc__c = proList[0].Id;
            oppList[0].Language__c = 'English';
            oppList[0].NextStep ='ECS';
            oppList[1].Type = 'New Business';
            oppList[1].TotalAmount__c = 1000;
            oppList[1].CampaignId = campaign[0].Id;
            oppList[1].NextStep ='BUNDLE';
            oppList[2].Type = 'New Business';
            oppList[2].TotalAmount__c = 1000;
            oppList[2].CampaignId = campaign[0].Id;
            oppList[2].NextStep ='BUNDLE';
            insert oppList;
        }
        
    }
    
    @isTest static void testOpportunityGoal() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock()); 
            //Get Campaign ...
            List<User> ownr = SCS_TestDataFactory.createUser('Sales User',1);
            ownr[0].Username='scssu.testoppogoal@gmail.com';
            insert ownr;
            List<Opportunity> recordList =[SELECT Id,Type,TotalAmount__c,Program_Goal__c FROM Opportunity WHERE NextStep ='ECS'];
            recordList[0].Type ='Existing Business';
            recordList[0].TotalAmount__c = 2000;
            recordList[0].Program_Goal__c = null;
            update recordList;
            List<Opportunity> recordList1 =[SELECT Id,User_Goal__c FROM Opportunity WHERE NextStep ='ECS'];
            recordList1[0].User_Goal__c = null;
            update recordList1;
            List<Program__c> program =[SELECT Id,Name FROM Program__c WHERE name = 'BRCGS'];
            List<Opportunity> recordList2 =[SELECT Id,User_Goal__c,Program_Goal__c FROM Opportunity WHERE NextStep ='ECS'];
            recordList2[0].User_Goal__c = null;
            recordList2[0].Program_Goal__c = null;
            update recordList2;
            List<Opportunity> recordList3 =[SELECT Id,StageName FROM Opportunity WHERE NextStep ='ECS'];
            recordList3[0].StageName = 'Closed Won';
            update recordList3;
            List<Opportunity> recordList4 =[SELECT Id,Programc__c FROM Opportunity WHERE NextStep ='ECS'];
            recordList4[0].Programc__c = program[0].Id;
            update recordList4;
            List<Opportunity> recordList5 =[SELECT Id,OwnerId FROM Opportunity WHERE NextStep ='ECS'];
            recordList5[0].OwnerId = ownr[0].Id;
            update recordList5;
            List<Opportunity> recordList6 =[SELECT Id,Type FROM Opportunity WHERE NextStep ='ECS'];
            recordList6[0].Type ='New Business';
            update recordList6;
            List<Opportunity> recordList7 =[SELECT Id,StageName FROM Opportunity WHERE NextStep ='ECS'];
            recordList7[0].StageName = 'Closed Won';
            update recordList7;
            List<Opportunity> bundleList =[SELECT Id,Name,StageName,Bundle_Opportunity__c,Record_Type_Name__c FROM Opportunity WHERE NextStep ='BUNDLE'];
            //system.debug('bundleList :'+bundleList);
            bundleList[0].Bundle_Opportunity__c = bundleList[1].Id;
            update bundleList;
            //Delete record to cover delete event in trigger...
            delete recordList;
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