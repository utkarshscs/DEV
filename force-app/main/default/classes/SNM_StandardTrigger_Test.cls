/**************************************************** NEW ORG CODE ***************************************************************** 
* Test Class Name   : SNM_StandardTrigger_Test
* Test Class For    : SNM_StandardTrigger,SNM_StandardTriggerHandler
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Test standard sync functionality from new org to old org...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        02-11-2022                          Initial version 
************************************************************************************************************************************/

@isTest
public class SNM_StandardTrigger_Test {
    
    //Setup data...
    @testSetup static void setup() {
        //Create web integrator user...
        List<User> userList = SCS_TestDataFactory.createUser('SCS Integration',1);
        userList[0].Username ='salesuser@scsuser.com';
        insert userList;
        System.runAs(userList[0]){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass()); 
            //Create Program...
            List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
            programs[0].Name = 'SQF';
            insert programs;
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(programs[0].Id,1);
            standards[0].Name = 'SNMSTND';
            insert standards;
        }
        
    }
    
    @isTest static void testStandard() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Get Record ...
            List<Standard__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM Standard__c  WHERE Name ='SNMSTND'];
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