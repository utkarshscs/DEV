/**************************************************** NEW ORG CODE ***************************************************************** 
* Test Class Name   : SNM_OpportunitySchedular_Test
* Test Class For    : SNM_ContactOpportunitySchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Test Opportunity sync functionality from new org to old org...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/

@isTest
public class SNM_OpportunitySchedular_Test {
    //Setup data...
    @testSetup static void setup() {
        //Get cvent user...
        User cventUser = SCS_TestDataFactory.getCventUser();
        System.runAs(cventUser){
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
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accList[0].Id,programs[0].Id,SNM_TestConstant.training_Oppo_RTId,Date.today(),1);
            oppList[0].CampaignId  = campaign[0].Id;
            insert oppList;
            Database.executebatch(new SNM_OpportunitySchedular(),1);
        }
        
    }
    
    @isTest static void testOpportunitySync() {
        Test.startTest();
        //Get cvent user...
        User cventUser = SCS_TestDataFactory.getCventUser();
        System.runAs(cventUser){
            //Get record ...
            List<Opportunity> recordList =[SELECT Id,Name,External_Record_Id__c FROM Opportunity];
            //Verify the response...
           // System.assertEquals('external-Id',recordList[0].External_Record_Id__c,'External Record should not be blank');
        }
        Test.stopTest();  
    }
    
}