@isTest
private class EE_ChatterFeed_Test {
    @TestSetup
    static void testSetupData() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        Id leadRT_Id = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SCS_Global_Services').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        List<Campaign> campList = SCS_TestDataFactory.createCampaing(1);
        insert campList;
        
        List<Program__c> programList = SCS_TestDataFactory.createPrograms(1);
        insert programList;
        
        List<Lead> ldList = SCS_TestDataFactory.createLead(1, 'New', leadRT_Id);
        for(Lead ln:ldList)
        {
            ln.LeadSource = 'Website';
            ln.Recent_Campaign__c = campList[0].Id;
            ln.program__c = programList[0].Id;
            
        }
        insert ldList;   
    }
    
    static testMethod void triggerHandlerTest(){
        
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        String prevEmail = '';
        System.runAs(integratorUser[0]){            
            Test.startTest();
            SCS_ChatterFeedHelper.isTest = true;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());                
            List<Lead> ldList = [SELECT Id, Name,Email,program__c,External_Record_Id__c,leadsource FROM Lead WHERE CreatedDate = Today LIMIT 1];          
            FeedItem f = new FeedItem();
            f.body = '@SFDC Support';
            f.ParentId = ldList[0].Id;
            insert f;
            
            FeedComment fComm = new FeedComment();
            fComm.CommentBody = '#resolved';
            fComm.FeedItemId = f.Id;
            insert fComm;
            
            fComm.CommentBody = '#reopened';
            update fComm;
            
            fComm.CommentBody = '#InProgress';
            update fComm;
            
            fComm.CommentBody = '#closed';
            update fComm;
            
            fComm.CommentBody = '#escalated';
            update fComm;
            
            fComm.CommentBody = '#high';
            update fComm;
            
            fComm.CommentBody = '#medium';
            update fComm;
            
            fComm.CommentBody = '#low';
            update fComm;
            
            Test.stopTest();
        }
    }
}