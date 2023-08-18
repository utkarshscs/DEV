/************************************************************************************************************************************************
Apex Class Name : sFilesBatchAccountSSFolderTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesBatchAccountSSFolder' apex class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesBatchAccountSSFolderTest{
    @testSetup 
    static void setup() {
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id goalRTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        id contRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        id consOpRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            accountList[0].Payment_Terms__c = 'Net 30';
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
            
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry', accountList[0].Id, proList[0].Id, oppRTId ,Date.newInstance(2023,1,5), 3);
            oppList[1].Type = 'New Business';
            oppList[1].TotalAmount__c = 1000;
            oppList[1].CampaignId  = campaign[0].Id;
            oppList[1].IsConverted__c = True;
            oppList[1].RecordTypeId = oppSCSStandrdRTId;
            oppList[1].Programc__c = proList[2].Id;
            insert oppList;
        }
    }
    
   @isTest 
    static void testOpptySCSStandard() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c, RecordType.DeveloperName from Opportunity WHERE RecordType.DeveloperName = 'SCS_Standard'];
            System.debug('oppList-Standard--'+oppList);
            sFilesBatchAccountSSFolder batch = new sFilesBatchAccountSSFolder();
            Database.executeBatch(batch);
        }
        Test.stopTest();
    }
   
}