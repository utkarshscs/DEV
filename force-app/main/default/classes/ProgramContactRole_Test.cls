@isTest
public class ProgramContactRole_Test {
    
    @testSetup static void setup() {


        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        List<Account> accountList = SCS_TestDataFactory.createAccounts(accRTId,1);
        accountList[0].BillingCountry= 'United States';
        insert accountList;
        //Create Program record...
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
        proList[0].name = 'SQF';
        insert proList;
        //Create Campaign record... 
        List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
        insert campaign;
        //Create Contact record...
        List<Contact> conList = SCS_TestDataFactory.createContacts(accountList[0].Id,conRTId,1);
        insert conList;

        List<Program_Contact_Role__c> pcr = SCS_TestDataFactory.createProgramContactRole(conList[0].Id,proList[0].Id,1 );
        insert pcr;
    
    }

    @isTest static void testPCR() {

        Program__c prId = [SElect id from Program__c where CreatedDate = Today Limit 1];
        Account accId = [Select Id from Account Where CreatedDate = Today Limit 1];
        
        List<ProgramContactRole.ProgramContactRoleWrapper> progRoleList = ProgramContactRole.getProgramContactRoleData(prId.Id, accId.Id);

        System.assert(progRoleList.size() > 0); 

    }


}