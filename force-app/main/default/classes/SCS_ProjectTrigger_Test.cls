@isTest
public class SCS_ProjectTrigger_Test {
    @testSetup 
    static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
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
            oppList[6].RecordTypeId = oppSCSStandrdRTId;
            oppList[6].NextStep ='BUNDLE';
            oppList[6].Programc__c = proList[0].Id;
            oppList[6].Engagement_Type__c ='Initial';
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
            List<Goal__c> goalList = SCS_TestDataFactory.createGoalRecord(goalRTId,proList[1].id,'Q1','2025',1);  
            insert goalList;
            
             //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id, 1);
            insert projects;
        }
        
    }
    
    
    
    @isTest 
    static void testOpportunitysFiles() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> opptyIdSet = new Set<Id>();
            Set<Id> prjIdSet = new Set<Id>();
            List<Account> accList =[SELECT Id, Name FROM Account];
            List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
            List<Opportunity> opptyList = new List<Opportunity>();
            
            for(Account acc : accList){
                accIdSet.add(acc.Id);
            }
            
            for(Opportunity opp : recordList){
                opp.fileforcem1__Sharepoint_Folder_Id__c = '13221314213123123';
                opptyIdSet.add(opp.Id);
                opptyList.add(opp);
            }
            update opptyList;
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            System.assertEquals(11,recordList.size(),'External Record should not be blank');
            
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
            delete projects;
        }
        Test.stopTest();  
    }
    
}