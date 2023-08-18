/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : SCS_SchedularDeleteAttriAssignment_Test
* Related class     : SCS_SchedularDeleteAttributeAssignment and SCS_DeleteAttributeAssignment
* Version           : 1.0
* Functionality     : 

* Modification Log  : This test class test the functionality of SCS_SchedularDeleteAttributeAssignment and SCS_DeleteAttributeAssignment
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        08-06-2023                          Initial version 
************************************************************************************************************************************/


@isTest
public class SCS_SchedularDeleteAttriAssignment_Test {
    
    //Setup data...
    @testSetup static void setup() {
        //Insert sales user...
        List<User> userList = SCS_TestDataFactory.createUser('System Administrator',1);
        userList[0].Username ='scsadministrator@scsuser.com';
        insert userList;
        //Execute with respect to sales user...
        System.runAs(userList[0]){
            //Insert account...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
            insert accountList;
            //Insert Contact...
            List<Contact> contactList = SCS_TestDataFactory.createContacts(accountList[0].Id,SNM_TestConstant.customerConRTId,1);
            insert contactList;
            //Insert Resource Attribute...
            inspire1__Resource_Attribute__c resourceAttribute = new inspire1__Resource_Attribute__c (Name = 'RATEST',inspire1__Type__c = 'Skill');
            insert resourceAttribute;
            //Insert Attribute Assignment...
            inspire1__Attribute_Assignment__c attributeAssignment = new inspire1__Attribute_Assignment__c ();
            attributeAssignment.inspire1__Contact__c = contactList[0].Id;
            attributeAssignment.inspire1__Resource_Attribute__c = resourceAttribute.Id;
            Date dt = Date.today();
            dt = dt.addDays(-1);
            attributeAssignment.EndDate__c = dt;
            insert attributeAssignment;
        }
    }
    
    @isTest static void testAttributeAssignmentDeletionSchedular() {
        Test.startTest();
        //Query sales user...
        User usr =[SELECT Id FROM User WHERE Username = 'scsadministrator@scsuser.com' LIMIT 1];
        System.runAs(usr){
            SCS_SchedularDeleteAttributeAssignment obj = new SCS_SchedularDeleteAttributeAssignment();
            obj.execute(null);
        }
        Test.stopTest();
        //Get records ...
        List<inspire1__Attribute_Assignment__c> recordList =[SELECT Id FROM inspire1__Attribute_Assignment__c];
        //Verify the response...
        System.assertEquals(0,recordList.size(),'Record should be deleted');
    }
    
}