/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoDeleteFilesTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesBatchtoDeleteFiles' batch class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	20/01/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesBatchtoDeleteFilesTest {
    @testSetup 
    static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id goalRTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
            proList[0].name = 'SQF';
            proList[1].name = 'IRMA';
            insert proList; 
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            insert standards;
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,proList[0].Id,oppRTId ,Date.newInstance(2025,1,5),11);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].fileforcem1__Sharepoint_Folder_Id__c = '01ZEWS4T2G6ZAUZOQQMVCZ637H3RG7DGO6';
            oppList[1].Type = 'New Business';
            oppList[1].TotalAmount__c = 1000;
            oppList[1].CampaignId = campaign[0].Id;
            oppList[2].Type = 'New Business';
            oppList[2].TotalAmount__c = 1000;
            oppList[2].CampaignId = campaign[0].Id;
            oppList[3].Type = 'Existing Business';
            oppList[3].TotalAmount__c = 1000;
            oppList[3].CampaignId = campaign[0].Id;
            oppList[4].Type = 'Existing Business';
            oppList[4].TotalAmount__c = 1000;
            oppList[4].CampaignId = campaign[0].Id;
            oppList[5].Type = 'Existing Business';
            oppList[5].TotalAmount__c = 1000;
            oppList[5].CampaignId = campaign[0].Id;
            oppList[6].Type = 'New Business';
            oppList[6].TotalAmount__c = 1000;
            oppList[6].CampaignId = campaign[0].Id;
            oppList[6].RecordTypeId = bundelOppRTId;
            oppList[6].NextStep ='BUNDLE';
            oppList[7].Type = 'New Business';
            oppList[7].TotalAmount__c = 1000;
            oppList[7].RecordTypeId = bundelOppRTId;
            oppList[7].CampaignId = campaign[0].Id;
            oppList[7].NextStep ='BUNDLE';
            oppList[8].TotalAmount__c = 1000;
            oppList[8].Type = 'Existing Business';
            oppList[8].CampaignId = campaign[0].Id;
            oppList[9].TotalAmount__c = 1000;
            oppList[9].Type = 'Existing Business';
            oppList[9].StageName = 'Closed Won';
            oppList[9].CampaignId = campaign[0].Id;
            oppList[10].TotalAmount__c = 1000;
            oppList[10].Type = 'Existing Business';
            oppList[10].StageName = 'Closed Lost';
            oppList[10].CampaignId = campaign[0].Id;
            insert oppList;
            
        }
        
    }
    
    @isTest 
    static void testOpportunityGoal() {
        List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
        Datetime testingday = Datetime.now().addMonths(-1);
        Test.setCreatedDate(recordList[0].id, testingday); 
        
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> updatedOpp = new List<Opportunity> ();
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordList[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            sFilesBatchtoDeleteFiles obj = new sFilesBatchtoDeleteFiles();
            DataBase.executeBatch(obj); 
            
            sFilesBatchtoDeleteFiles sh1 = new sFilesBatchtoDeleteFiles();
            String sch = '0 0 2 * * ?'; 
            system.schedule('Test Batch', sch, sh1); 
        }
        Test.stopTest();  
    }
    
    
}