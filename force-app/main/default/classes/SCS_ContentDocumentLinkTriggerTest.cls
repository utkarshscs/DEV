/*
@Author : MAANTIC
@CreatedDate : 28th SEP 2022
@Description : This test class is for ContentDocumentLinkTrigger trigger.
*/
/****************************** New ORG CODE *****************************************************/

@isTest
public class SCS_ContentDocumentLinkTriggerTest {
    
    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id goalRTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
        Id bundelOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            //Create record...
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
    
    @isTest static void testOpportunityGoal() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Get Campaign ...
            List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
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
            update cdl;
            delete cdl;
            
        }
        Test.stopTest();  
    }
    
    @isTest static void testProject() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Get Campaign ...
            List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
            List<Opportunity> updatedOpp = new List<Opportunity> ();
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            inspire1__Project__c prj = new inspire1__Project__c(Name = 'Test Project');
            prj.inspire1__Opportunity1__c = recordList[0].Id;
            insert prj;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = prj.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            update cdl;
            delete cdl;
            
        }
        Test.stopTest();  
    }
    
     @isTest static void testOpportunityCertificate() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Get Campaign ...
            List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
            List<Opportunity> updatedOpp = new List<Opportunity> ();
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            List<Opportunity_Certificate__c> opptyCertList = [SELECT Id FROM Opportunity_Certificate__c];
            update opptyCertList;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = opptyCertList[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            update cdl;
            delete cdl;
            
        }
        Test.stopTest();  
    }
    
    @isTest static void testAccount() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accList =[SELECT Id,Name FROM Account];
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
            cdl.LinkedEntityId = accList[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            update cdl;
            delete cdl;
            
        }
        Test.stopTest();  
    }
    
    @isTest static void testEmailMessage() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Get Opportunity ...
            List<Opportunity> recordList =[SELECT Id,Name,StageName,Type FROM Opportunity];
            List<Opportunity> updatedOpp = new List<Opportunity> ();
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //Insert emailmessage for case
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = True;
            email.ToAddress= 'test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            String[] toIds = new String[]{ recordList[0].Id };
            email.toIds = toIds; 
            insert email;
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = email.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            update cdl;
            delete cdl;
            
        }
        Test.stopTest();   
    }
    
}