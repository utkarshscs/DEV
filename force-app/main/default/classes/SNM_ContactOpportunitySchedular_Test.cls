/**************************************************** NEW ORG CODE ***************************************************************** 
* Test Class Name   : SNM_ContactOpportunitySchedular_Test
* Test Class For    : SNM_ContactOpportunitySchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Test contact sync functionality from new org to old org...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/

@isTest
public class SNM_ContactOpportunitySchedular_Test {
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
            List<Contact> conList = SCS_TestDataFactory.createContacts(accList[0].Id,SNM_TestConstant.customerConRTId,1);
            insert  conList;
            Database.executebatch(new SNM_ContactOpportunitySchedular(),1);
        }
        
    }
    
    @isTest static void testContactSync() {
        Test.startTest();
        //Get cvent user...
        User cventUser = SCS_TestDataFactory.getCventUser();
        System.runAs(cventUser){
            //Get record ...
            List<Contact> recordList =[SELECT Id,Name,External_Record_Id__c FROM Contact];
            //Verify the response...
            //System.assertEquals('external-Id',recordList[0].External_Record_Id__c,'External Record should not be blank');
        }
        Test.stopTest();  
    }
    
}