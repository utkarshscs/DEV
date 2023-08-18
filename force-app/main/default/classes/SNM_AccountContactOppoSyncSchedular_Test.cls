/**************************************************** NEW ORG CODE ***************************************************************** 
* Test Class Name   : SNM_AccountContactOppoSyncSchedular_Test
* Test Class For    : SNM_AccountContactOppoSyncSchedular,SNM_AccountContactOppoSchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Test account sync functionality from new org to old org...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/

@isTest
public class SNM_AccountContactOppoSyncSchedular_Test {
    //Setup data...
    @testSetup static void setup() {
        //Get cvent user...
        User cventUser = SCS_TestDataFactory.getCventUser();
        System.runAs(cventUser){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass()); 
            //Create Lead record...
             List<Lead> leadList = SCS_TestDataFactory.createLead(1,'New',SNM_TestConstant.scsGlobalServiceRTId_Lead);
            insert leadList;
            List<Account> accList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
            insert accList;
            SNM_AccountContactOppoSyncSchedular obj = new SNM_AccountContactOppoSyncSchedular();
            obj.execute(null);
        }
        
    }
    
    @isTest static void testLeadAndAccountSync() {
        Test.startTest();
        //Get cvent user...
        User cventUser = SCS_TestDataFactory.getCventUser();
        System.runAs(cventUser){
            //Get record ...
            List<Account> recordList =[SELECT Id,Name,External_Record_Id__c FROM Account];
            //Verify the response...
            //System.assertEquals('external-Id',recordList[0].External_Record_Id__c,'External Record should not be blank');
        }
        Test.stopTest();  
    }
    
}