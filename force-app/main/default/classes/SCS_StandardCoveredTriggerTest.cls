/*
@Author : MAANTIC
@CreatedDate : 21st June 2023
@Description : This test class for SCS_StandardCoveredTrigger trigger.
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class SCS_StandardCoveredTriggerTest {

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
            standards[0].Title__c = 'Test';
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
            insert oppList;
            List<Standard_Covered__c> stndrdCoveredList = SCS_TestDataFactory.createStandardCovered(oppList[0].Id, standards[0].Id, 1);
            insert stndrdCoveredList;
        }
    }
    
    @isTest static void testOpportunityGoal() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Standard_Covered__c> stndrdCoveredList =[SELECT Id, Title__c, Opportunity__c FROM Standard_Covered__c];
            update stndrdCoveredList;
            delete stndrdCoveredList;
        }
        Test.stopTest();  
    }
}