/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoUploadFilesTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesBatchtoUploadFiles' and 'sFilesBatchQueabletoUploadFiles' apex class.
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesBatchtoUploadFilesTest {
    @testSetup 
    static void setup(){
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
        Id goalRTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        Id contRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id consOpRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Consulting').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            accountList[0].SharePoint_Folder_Id__c = '255222XDF';
            accountList[0].Payment_Terms__c = 'Net 30';
            insert accountList;
            
            List<Contact> blcont = SCS_TestDataFactory.createContacts(accountList[0].id, contRecTypeId, 1);
            insert blcont;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
            proList[0].name = 'SQF';
            proList[0].Entity__c = 'ECS';
            proList[1].name = 'RSB';
            proList[1].Entity__c = 'SCS Standard';
            insert proList; 
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            insert standards;
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            List<fw1__Entity__c> entList=SCS_TestDataFactory.createEntity(1);
            insert entList;
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry', accountList[0].Id, proList[0].Id, oppRTId ,Date.newInstance(2023,1,5), 3);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].IsConverted__c = True;
            oppList[0].fileforcem1__Sharepoint_Folder_Id__c = 'ZE232134213132131SD5';
            insert oppList;
            SYstem.debug('oppList 92-- '+oppList);
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[1].Id, 2);
            projects[1].inspire1__Opportunity1__c = oppList[0].Id;
            projects[1].SharePoint_Folder_Id__c = 'ZGHY87578587484477HJ';
            insert projects;
            
            List<Certificate__c> certList =new List<Certificate__c>();
            List<Opportunity_certificate__c> opcerlist = new List<Opportunity_certificate__c>();
            certList = SCS_TestDataFactory.createCertificate(1);
            insert certList;
            
            opcerlist = SCS_TestDataFactory.createOppsCertificate(certList[0], oppList);
            opcerlist[0].SharePoint_Folder_Id__c = 'ZGHY87578587484477HJ';
            insert opcerlist;
        }
    }
    
    @isTest 
    static void testAccount() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accList =[SELECT Id, Name FROM Account WHERE SharePoint_Folder_Id__c != null];
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ];
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id].ContentDocumentId;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = accList[0].id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
            
            sFilesBatchtoUploadFiles obj = new sFilesBatchtoUploadFiles();
            obj.objectName = 'Account';
            DataBase.executeBatch(obj); 
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testOpportunity() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity> recordListST = [SELECT Id,Name,StageName,RecordTypeId,Type FROM Opportunity];
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ];
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id].ContentDocumentId;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordListST[0].id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
            
            sFilesBatchtoUploadFiles obj = new sFilesBatchtoUploadFiles();
            obj.objectName = 'Opportunity';
            DataBase.executeBatch(obj);
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testProject() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c != null];
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ];
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id].ContentDocumentId;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = projects[0].id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
            
            sFilesBatchtoUploadFiles obj = new sFilesBatchtoUploadFiles();
            obj.objectName = 'Project';
            DataBase.executeBatch(obj);
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testOpportunityCertificate() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Opportunity_certificate__c> recordListST = [SELECT Id, Name FROM Opportunity_certificate__c WHERE SharePoint_Folder_Id__c != null];
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ];
            Id conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id].ContentDocumentId;
            
            //Create ContentDocumentLink Record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordListST[0].id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
            
            sFilesBatchtoUploadFiles obj = new sFilesBatchtoUploadFiles();
            obj.objectName = 'Opportunity Certificate';
            DataBase.executeBatch(obj);
        }
        Test.stopTest();  
    }
}