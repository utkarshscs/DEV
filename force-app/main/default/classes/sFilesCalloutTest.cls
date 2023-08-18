/************************************************************************************************************************************************
Apex Class Name : sFilesCalloutTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sFilesCallout' and 'sfilesOpportunityFolderQueable' apex class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	21/10/2022                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sFilesCalloutTest {
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
            accountList[1].BillingCountry= 'United States';
            accountList[1].Payment_Terms__c = 'Net 30';
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
            
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry', accountList[0].Id, proList[0].Id, oppRTId ,Date.newInstance(2025,1,5), 6);
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
            oppList[3].Type = 'New Business';
            oppList[3].TotalAmount__c = 1000;
            oppList[3].CampaignId  = campaign[0].Id;
            oppList[3].IsConverted__c = True;
            oppList[4].Type = 'New Business';
            oppList[4].TotalAmount__c = 1000;
            oppList[4].CampaignId  = campaign[0].Id;
            oppList[4].IsConverted__c = True;
            oppList[4].RecordTypeId = oppSCSStandrdRTId;
            oppList[4].Programc__c = proList[2].Id;
            oppList[5].Type = 'New Business';
            oppList[5].TotalAmount__c = 1000;
            oppList[5].CampaignId  = campaign[0].Id;
            oppList[5].IsConverted__c = True;
            oppList[5].RecordTypeId = consOpRTId;
            oppList[5].Programc__c = proList[1].Id;
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id, 9);
            projects[0].RecordTypeId = prjRTId;
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
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'ECS'];
            Set<Id> opptyIdSet = new Set<Id>();

            for(Opportunity opp : oppList){
                opptyIdSet.add(opp.Id);
            }
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'ECS'];
            Set<Id> ocIdSet = new Set<Id>();

            for(Opportunity_certificate__c oc : ocList){
                ocIdSet.add(oc.Id);
            }
            sFilesCallout.createFoldersonSharePointForOpptyCertificate(ocIdSet);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testOpptySCSStandard() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'SCS_Standard'];
            Set<Id> opptyIdSet = new Set<Id>();

            for(Opportunity opp : oppList){
                opptyIdSet.add(opp.Id);
            }
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'SCS_Standard'];
            Set<Id> ocIdSet = new Set<Id>();

            for(Opportunity_certificate__c oc : ocList){
                ocIdSet.add(oc.Id);
            }
            sFilesCallout.createFoldersonSharePointForOpptyCertificate(ocIdSet);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testOpptySCSConsulting() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'SCS_Consulting'];
            Set<Id> opptyIdSet = new Set<Id>();

            for(Opportunity opp : oppList){
                opptyIdSet.add(opp.Id);
            }
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            
            List<Opportunity_certificate__c> ocList = [SELECT Id FROM Opportunity_certificate__c WHERE Opportunity__r.RecordType.DeveloperName = 'SCS_Consulting'];
            Set<Id> ocIdSet = new Set<Id>();

            for(Opportunity_certificate__c oc : ocList){
                ocIdSet.add(oc.Id);
            }
            sFilesCallout.createFoldersonSharePointForOpptyCertificate(ocIdSet);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testProjectSCSGlobalServices() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            Set<Id> opptyIdSet = new Set<Id>();
            Set<Id> prjIdSet = new Set<Id>();
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Account> acctList = new List<Account>();

            List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
            for(Account acc: accList){
                acc.SharePoint_Folder_Id__c = 'DFDV345533234324234';
                acc.AllProjectSGSSharePointFolderId__c = 'JHM7876867888GH';
                acctList.add(acc);
            }
            update acctList;
            
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'ECS'];
            
            List<inspire1__Project__c> projects = [SELECT Id, Name, inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c, inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null AND RecordType.DeveloperName = 'ECS' AND inspire1__Opportunity1__r.RecordType.DeveloperName='ECS' AND inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c != null];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
            sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
        }
        Test.stopTest();  
    }  
    
    @isTest 
    static void testProjectSCSStandard() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            Set<Id> opptyIdSet = new Set<Id>();
            Set<Id> prjIdSet = new Set<Id>();
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Account> acctList = new List<Account>();
            
            List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
            for(Account acc: accList){
                acc.SS_SharePoint_Folder_Id__c = 'JHM7876867888GH';
                acc.AllProjectSSSharePointFolderId__c = 'JHM7876867888GH';
                acctList.add(acc);
            }
            update acctList;
            
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'SCS_Standard'];
            
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null AND RecordType.DeveloperName = 'SCS_Standard' AND inspire1__Opportunity1__r.RecordType.DeveloperName='SCS_Standard'];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            
            sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testProjectSCSConsulting() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new SCS_sFilesMock()); 
            Set<Id> opptyIdSet = new Set<Id>();
            Set<Id> prjIdSet = new Set<Id>();
            List<Opportunity> opptyList = new List<Opportunity>();
            List<Account> acctList = new List<Account>();
            
            List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
            for(Account acc: accList){
                acc.SC_SharePoint_Folder_Id__c = 'JHM7876867888GH';
                acc.AllProjectSCSharePointFolderId__c = 'JHM7876867888GH';
                acctList.add(acc);
            }
            update acctList;
            
            List<Opportunity> oppList = [Select id, type,totalamount__c,fileforcem1__Sharepoint_Folder_Id__c from Opportunity WHERE RecordType.DeveloperName = 'SCS_Consulting'];
            
            List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Opportunity1__c != null AND RecordType.DeveloperName = 'SCS_Consulting' AND inspire1__Opportunity1__r.RecordType.DeveloperName='SCS_Consulting'];
            for(inspire1__Project__c prj : projects){
                prjIdSet.add(prj.Id);
            }
            
            sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
        }
        Test.stopTest();  
    }
    
    @isTest 
    static void testAccount() {
        Set<Id> prjIdSet = new Set<Id>();
        List<Account> acctList = new List<Account>();

            List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
            for(Account acc: accList){
                acc.SharePoint_Folder_Id__c = 'DFDV345533234324234';
                acc.AllProjectSGSSharePointFolderId__c = 'JHM7876867888GH';
                acctList.add(acc);
            }
            update acctList;
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null];
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
    }
    
    @isTest 
    static void testAccountStandard() {
        Set<Id> prjIdSet = new Set<Id>();
        List<Account> acctList = new List<Account>();
        
        List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
        for(Account acc: accList){
            acc.SS_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            acc.AllProjectSSSharePointFolderId__c = 'JHM7876867888GH';
            acctList.add(acc);
        }
        update acctList;
        List<inspire1__Project__c> projects = [SELECT Id, Name, inspire1__Account__r.SS_SharePoint_Folder_Id__c, inspire1__Account__r.AllProjectSSSharePointFolderId__c FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Standard'];
        System.debug('projects313--'+projects);
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
    }
    
    @isTest 
    static void testAccountConsulting() {
        Set<Id> prjIdSet = new Set<Id>();
        List<Account> acctList = new List<Account>();
        
        List<Account> accList = [Select Id, SharePoint_Folder_Id__c, AllProjectSGSSharePointFolderId__c, SS_SharePoint_Folder_Id__c, AllProjectSSSharePointFolderId__c, SC_SharePoint_Folder_Id__c, AllProjectSCSharePointFolderId__c FROM Account];
        for(Account acc: accList){
            acc.SC_SharePoint_Folder_Id__c = 'JHM7876867888GH';
            acc.AllProjectSCSharePointFolderId__c = 'JHM7876867888GH';
            acctList.add(acc);
        }
        update acctList;
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c != null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Consulting'];
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
    }
    
    @isTest 
    static void testProjectSGS() {
        Set<Id> prjIdSet = new Set<Id>();
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null];
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
    }
    
    @isTest 
    static void testProjectSS() {
        Set<Id> prjIdSet = new Set<Id>();
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Standard'];
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
    }
    
    @isTest 
    static void testProjectSC() {
        Set<Id> prjIdSet = new Set<Id>();
        List<inspire1__Project__c> projects = [SELECT Id, Name FROM inspire1__Project__c WHERE inspire1__Account__c = null AND inspire1__Opportunity1__c = null AND RecordType.DeveloperName = 'SCS_Consulting'];
        for(inspire1__Project__c prj : projects){
            prjIdSet.add(prj.Id);
        }
        sFilesCallout.createFoldersonSharePointForProject(prjIdSet);
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