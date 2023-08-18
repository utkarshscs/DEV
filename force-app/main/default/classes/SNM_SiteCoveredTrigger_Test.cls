/**************************************************** NEW ORG CODE ***************************************************************** 
* Test Class Name   : SNM_SiteCoveredTrigger_Test
* Test Class For    : SNM_SiteCoveredTrigger,SNM_SiteCoveredTriggerHandler
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Test site covered sync functionality from new org to old org...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        21-10-2022                          Initial version 
************************************************************************************************************************************/

@isTest
public class SNM_SiteCoveredTrigger_Test {
    //Setup data...
    @testSetup static void setup() {
        //Create web integrator user...
        List<User> userList = SCS_TestDataFactory.createUser('SCS Integration',1);
        userList[0].Username ='salesuser@scsuser.com';
        insert userList;
        System.runAs(userList[0]){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass()); 
            //Create Account record...
            List<Account> accList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
            insert accList;
            //Create Program record...
            List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
            programs[0].Name = 'SQF';
            insert programs;
            //Create Campaign...
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            //Create Opportunity record...
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,programs[0].Id,SNM_TestConstant.eCSOppoRTId,Date.today(),1);
            oppList[0].CampaignId  = campaign[0].Id;
            insert oppList;
            //Insert site covered...
            List<Site_Covered__c> oppoSite = SCS_TestDataFactory.createSiteCovered(oppList[0].Id,1);
            insert oppoSite;
            
        }
        
    }
    
    @isTest static void testSiteCovered() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Get record ...
            List<Site_Covered__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM Site_Covered__c];
            //Update  records...
            update recordList;
            //Verify the response...
            System.assertEquals('external-Id',recordList[0].External_Record_Id__c,'External Record should not be blank');
            //Delete record to cover delete event in trigger...
            Database.Delete(recordList,false);
            //Un-Delete record to cover delete event in trigger...
            undelete recordList;
        }
        Test.stopTest();  
    }
    
}