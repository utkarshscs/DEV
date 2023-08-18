/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoCreateFoldersTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesBatchtoCreateFolders', 'sFilesBatchtoUploadFiles' and 'sFilesBatchQueabletoUploadFiles' apex class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesBatchtoCreateFoldersTest{
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
            accountList[0].SC_SharePoint_Folder_Id__c = '255222XDF';
            accountList[0].Payment_Terms__c = 'Net 30';
            insert accountList;
            
            List<Contact> blcont = SCS_TestDataFactory.createContacts(accountList[0].id, contRecTypeId, 1);
            insert blcont;
            
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(2);
            proList[0].name = 'SQF';
            proList[0].Entity__c = 'ECS';
            proList[1].name = 'IRMA';
            proList[1].Entity__c = 'SCS Standard';
            insert proList; 
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            insert standards;
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            List<fw1__Entity__c> entList=SCS_TestDataFactory.createEntity(1);
            insert entList;
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry', accountList[0].Id, proList[0].Id, oppRTId ,Date.newInstance(2023,1,5), 2);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].IsConverted__c = True;
            
            oppList[1].Type = 'New Business';
            oppList[1].RecordTypeId = oppSCSStandrdRTId;
            oppList[1].Programc__c = proList[1].Id;
            oppList[1].IsConverted__c = True;
            oppList[1].Engagement_Type__c = 'Initial';
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[1].Id, 2);
            projects[1].inspire1__Opportunity1__c = oppList[0].Id;
            insert projects;
            
            List<Certificate__c> certList =new List<Certificate__c>();
            List<Opportunity_certificate__c> opcerlist = new List<Opportunity_certificate__c>();
            certList = SCS_TestDataFactory.createCertificate(1);
            insert certList;
        
            opcerlist = SCS_TestDataFactory.createOppsCertificate(certList[0], oppList);
            insert opcerlist;
        }
        
    }
    
    @isTest 
    static void testOpportunitySCSStandard() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> opptyIdSet = new Set<Id>();
            set<id> opptySCSSet = new Set<Id>();
            set<id> opptySCSSt = new Set<Id>();
            
            Set<Id> prjIdSet = new Set<Id>();
            List<Account> accList =[SELECT Id, Name FROM Account];
            Id oppSCSStandrdRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
           
            List<Opportunity> recordListST = [SELECT Id,Name,StageName,RecordTypeId,Type FROM Opportunity WHERE RecordTypeId =:oppSCSStandrdRTId];
            SYstem.debug('recordListST 92-- '+recordListST);
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Opportunity> opptyListSCS = new List<Opportunity>();
            List<Opportunity> opptyListST = new List<Opportunity>();
            List<ContentVersion> converList = new List<ContentVersion>();
            
            for(Account acc : accList){
                accIdSet.add(acc.Id);
            }
            
            for(Opportunity oppst:recordListST)
            {
                oppst.fileforcem1__Sharepoint_Folder_Id__c = '13221314213123123';
                opptySCSSt.add(oppst.Id);
                opptyListST.add(oppst);
            }
            update opptyListST;
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__r.fileforcem1__Sharepoint_Folder_Id__c != null];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                FirstPublishLocationId = opptyListST[0].Id
            );
            insert contentVersion;
            converList.add(contentVersion);
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = opptyListST[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            //insert cdl;
            
            sFilesBatchtoCreateFolders obj = new sFilesBatchtoCreateFolders();
            DataBase.executeBatch(obj); 
            
            sFilesBatchtoUploadFiles obh = new sFilesBatchtoUploadFiles();
            DataBase.executeBatch(obh); 
            
            System.enqueuejob(new sFilesBatchQueabletoUploadFiles(converList, opptySCSSt));
            
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testOpportunitySCSGlobalServices() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> opptyIdSet = new Set<Id>();
            Set<Id> prjIdSet = new Set<Id>();
            List<Account> accList = [SELECT Id, Name FROM Account];
            List<Program__c> proList = [Select Id, Name FROM Program__c];

            List<Opportunity> opActList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordTypeId =:oppRTId];
            List<Opportunity> opptyList = new List<Opportunity>();
            
            for(Account acc : accList){
                accIdSet.add(acc.Id);
            }
            
            for(Opportunity opp : opActList){
                opp.AllProjectSharePointFolderId__c = '4534567444';
                opptyIdSet.add(opp.Id);
                opptyList.add(opp);
            }
            update opptyList;
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__r.AllProjectSharePointFolderId__c != null];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
        }
        Test.stopTest();  
    }
    
    
    
    public class SCS_sFilesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"ApiActionStatus":null,"CreatedBy":null, "CreatedDateTime":null, "CustomFields":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":null, "FormattedLastModified":null, "Id":"01ZEWS4T24FTSQMPOYZND3Z4VEGORXFNLU", "Index":null, "ModifiedBy":null, "Name":"007AAbb", "NameWithoutExt":"007AAbb", "NextLink":null, "OpenUrl":"https://scsglobalservices.sharepoint.com/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "ParentId":"01ZEWS4T7GSH5FJ4YC7NDIRHROT7HKKVF7", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FQA", "RootLevel":null, "SalesforceId":null, "SecurityFields":null, "SharepointGuid":null, "SharepointListId":null, "Size":"0 bytes", "Type":"Folder", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "items":null}');
            response.setStatusCode(201);
            return response; 
        }
    }
    
    
}