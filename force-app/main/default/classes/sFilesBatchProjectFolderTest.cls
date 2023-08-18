/************************************************************************************************************************************************
Apex Class Name : sFilesBatchProjectFolderTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesBatchProjectFolder' apex class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	10/07/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesBatchProjectFolderTest {
    @testSetup 
    static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id consOpRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        Id prjRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Food_and_Agriculture').getRecordTypeId();
        Id prjStandardRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id prjConsultingRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            accountList[0].Payment_Terms__c = 'Net 30';
            accountList[0].SharePoint_Folder_Id__c = 'DFDV345533234324234';
            accountList[0].AllProjectSGSSharePointFolderId__c = 'JHM7876867888GH';
            accountList[0].SS_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            accountList[0].AllProjectSSSharePointFolderId__c = 'JHM7876867888GH';
            accountList[0].SC_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            accountList[0].AllProjectSCSharePointFolderId__c = 'JHM7876867888GH';
            insert accountList;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(3);
            proList[0].name = 'SQF';
            proList[0].Entity__c = 'ECS';
            proList[1].name = 'Materiality Assessments';
            proList[1].Entity__c = 'SCS Consulting';
            proList[2].name = 'RSB';
            proList[2].Entity__c = 'SCS Standard';
            insert proList; 

            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;

            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry', accountList[0].Id, proList[0].Id, oppRTId ,Date.newInstance(2025,1,5), 3);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].IsConverted__c = True;
            oppList[1].Type = 'New Business';
            oppList[1].TotalAmount__c = 1000;
            oppList[1].CampaignId  = campaign[0].Id;
            oppList[1].IsConverted__c = True;
            oppList[1].RecordTypeId = oppSCSStandrdRTId;
            oppList[1].Programc__c = proList[2].Id;
            oppList[2].Type = 'New Business';
            oppList[2].TotalAmount__c = 1000;
            oppList[2].CampaignId  = campaign[0].Id;
            oppList[2].IsConverted__c = True;
            oppList[2].RecordTypeId = consOpRTId;
            oppList[2].Programc__c = proList[1].Id;
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id, 9);
            projects[1].inspire1__Opportunity1__c = null;
            projects[1].RecordTypeId = prjRTId;
            projects[2].inspire1__Opportunity1__c = null;
            projects[2].inspire1__Account__c = null;
            projects[2].RecordTypeId = prjRTId;
            projects[3].RecordTypeId = prjStandardRTId;
            projects[3].inspire1__Opportunity1__c = oppList[1].Id;
            projects[4].RecordTypeId = prjConsultingRTId;
            projects[4].inspire1__Opportunity1__c = oppList[2].Id;
            projects[5].RecordTypeId = prjConsultingRTId;
            projects[5].inspire1__Opportunity1__c = null;
            projects[6].RecordTypeId = prjStandardRTId;
            projects[6].inspire1__Opportunity1__c = null;
            projects[7].inspire1__Opportunity1__c = null;
            projects[7].inspire1__Account__c = null;
            projects[7].RecordTypeId = prjStandardRTId;
            projects[8].inspire1__Opportunity1__c = null;
            projects[8].inspire1__Account__c = null;
            projects[8].RecordTypeId = prjConsultingRTId;
            insert projects;
        }
    }
    
    @isTest 
    static void testOpportunity() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testOpportunityStandard() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null AND RecordType.DeveloperName = 'SCS_Standard' AND inspire1__Opportunity1__r.RecordType.DeveloperName='SCS_Standard'];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testOpportunityConsulting() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null AND RecordType.DeveloperName = 'SCS_Consulting' AND inspire1__Opportunity1__r.RecordType.DeveloperName='SCS_Consulting'];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testAccount() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testAccountStandard() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Standard'];
        System.debug('projects--122-'+projects);
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testAccountConsulting() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Consulting'];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testProjectSGS() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testProjectSS() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Standard'];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
    
    @isTest 
    static void testProjectSC() {
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Consulting'];
        sFilesBatchProjectFolder batch = new sFilesBatchProjectFolder();
        Database.executeBatch(batch);
    }
}