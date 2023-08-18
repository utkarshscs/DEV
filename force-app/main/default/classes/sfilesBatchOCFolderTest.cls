/************************************************************************************************************************************************
Apex Class Name : sfilesBatchOCFolderTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sfilesBatchOCFolder' apex class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	10/07/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sfilesBatchOCFolderTest {
    
    @testSetup 
    static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id consOpRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        Id prjRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id prjStandardRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id prjConsultingRTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,2);
            accountList[0].BillingCountry= 'United States';
            accountList[0].Payment_Terms__c = 'Net 30';
            accountList[0].SharePoint_Folder_Id__c = 'DFDV345533234324234';
            accountList[0].AllOCSGSSharePointFolderId__c = 'JHM7876867888GH';
            accountList[0].SS_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            accountList[0].AllOCSSSharePointFolderId__c = 'JHM7876867888GH';
            accountList[0].SC_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            accountList[0].AllOCSCSharePointFolderId__c = 'JHM7876867888GH';
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
            
            List<Certificate__c> certList =new List<Certificate__c>();
            List<Opportunity_certificate__c> opcerlist = new List<Opportunity_certificate__c>();
            certList = SCS_TestDataFactory.createCertificate(1);
            insert certList;
            
            opcerlist = SCS_TestDataFactory.createOppsCertificate(certList[0], oppList);
            insert opcerlist;
        }
    }
    
    @isTest 
    static void testOpptySCSGlobalServices() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'ECS'];
            sfilesBatchOCFolder batch = new sfilesBatchOCFolder();
            Database.executeBatch(batch);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testOpptySCSStandard() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'SCS_Standard'];
            sfilesBatchOCFolder batch = new sfilesBatchOCFolder();
            Database.executeBatch(batch);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testOpptySCSConsulting() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'SCS_Consulting'];
            sfilesBatchOCFolder batch = new sfilesBatchOCFolder();
            Database.executeBatch(batch);
        }
        Test.stopTest();
    }
}