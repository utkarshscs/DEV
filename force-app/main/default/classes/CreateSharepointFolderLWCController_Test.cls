/*
@Author : MAANTIC
@CreatedDate : 14th April 2023
@Description : This test class for CreateSharepointFolderLWCController lightning web component.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class CreateSharepointFolderLWCController_Test {

    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id programGoalId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
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
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,null, bundelOppRTId ,Date.newInstance(2025,1,5),3);
            oppList[0].Name = 'New Business-';
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].RecordTypeId = oppRTId;
            oppList[0].Programc__c = proList[0].Id;
            oppList[0].Language__c = 'English';
            oppList[0].NextStep ='ECS';
            insert oppList;
            
             //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id, 1);
            insert projects;
            
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
    
    @isTest static void testCreateSharepointFolderOppty() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> recordList =[SELECT Id,Name,External_Record_Id__c FROM Opportunity];
            CreateSharepointFolderLWCController.checkParentFolder(recordList[0].Id);
        }
    }
    
    @isTest static void testCreateSharepointFolderOC() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity_Certificate__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM Opportunity_Certificate__c];
            CreateSharepointFolderLWCController.checkParentFolder(recordList[0].Id);
        }
    }
    
    @isTest static void testCreateSharepointFolderProject() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c];
            CreateSharepointFolderLWCController.checkParentFolder(projects[0].Id);
        }
    }
}