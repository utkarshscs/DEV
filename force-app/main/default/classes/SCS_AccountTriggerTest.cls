@isTest
public class SCS_AccountTriggerTest {
    
    @testSetup 
    static void setup() {
        //Create Sales user...
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        System.runAs( SCS_TestDataFactory.getWebIntegratorUser()){
            //Create record...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
            accountList[0].BillingCountry= 'United States';
            accountList[0].Create_Sharepoint_Folder__c = false;
            insert accountList;
            
        }
        
    }
    @isTest static void testOpportunityGoal() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
            List<Account> accListUpdate = new List<Account>();
            List<Account> accList = [SELECT Id FROM Account];
            for(Account acc : accList){
                acc.Create_Sharepoint_Folder__c = true;
                accListUpdate.add(acc);
            }
            update accListUpdate;
            
            delete accListUpdate;
            
            undelete accListUpdate;
        }
        Test.stopTest();  
    }
    
}