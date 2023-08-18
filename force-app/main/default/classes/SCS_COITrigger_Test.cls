/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_COITrigger_Test
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1312
* Functionality     : This test class .

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        22-06-2023                          Initial version
************************************************************************************************************************************/

@isTest
public class SCS_COITrigger_Test {
    //Setup data...
    @testSetup static void setup() {
        
        //Create Sales user...
        List<User> userList = SCS_TestDataFactory.createUser('System Administrator',1);
        userList[0].UserName ='sfdc@scsgs.com';
        insert userList;
        System.runAs(userList[0]){
            
            //Create Account...
            List<Account> accountList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
            accountList[0].BillingCountry= 'United States';
            insert accountList;
            
            //Create Contact...
            List<Contact> conList = SCS_TestDataFactory.createContacts(accountList[0].Id,SNM_TestConstant.auditorConRTId,1);
            conList[0].Auditor__c = true;
            insert conList;
            
            //Create Program...
            List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);
            proList[0].name = 'SQF';
            proList[0].SCS_Global_QB_Entity__c = true;
            insert proList;
            
            //Create Campaign...
            List<Campaign> campaign = SCS_TestDataFactory.createCampaing(1);
            insert campaign;
            
            //Create Opportunity...
            List<Opportunity> oppList = SCS_TestDataFactory.createOpportunity('Enquiry',accountList[0].Id,null,SNM_TestConstant.eCSOppoRTId ,System.today(),1);
            oppList[0].Type = 'New Business';
            oppList[0].TotalAmount__c = 1000;
            oppList[0].CampaignId  = campaign[0].Id;
            oppList[0].Programc__c = proList[0].Id;
            oppList[0].Language__c = 'English';
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id,1);
            projects[0].RecordTypeId = SNM_TestConstant.ecsRT_Project;
            projects[0].Program__c = proList[0].Id;
            insert projects;
            
            //Create Project Task...
            List<inspire1__Project_Tasks__c> projectTask = SCS_TestDataFactory.createProjectTask(projects[0].Id,2);
            projectTask[0].inspire1__sysAssignedToIDs__c =  conList[0].Id;
            projectTask[1].inspire1__sysAssignedToIDs__c =  userList[0].Id;
            insert projectTask;
            
            //Create salesforce task...
            List<Task> tskList = SCS_TestDataFactory.createSFTask(conList[0].Id, userList[0].Id,2);
            tskList[0].inspire1__Inspire_Task__c = projectTask[0].Id;
            tskList[1].inspire1__Inspire_Task__c = projectTask[1].Id;
            insert tskList;
            
            //Create COI...
            List<Conflict_of_Interest__c> coiList = SCS_TestDataFactory.createCOI(conList[0].Id,accountList[0].Id,2);
            coiList[0].Program__c = proList[0].Id;
            coiList[1].Program__c = proList[0].Id;
            coiList[1].Auditor__c = null;
            coiList[1].Auditor_Internal__c = userList[0].Id;
            insert coiList;
        }
        
    }
    
    @isTest static void testCOI() {
        Test.startTest();
        List<User> userList = [SELECT Id,UserName FROM User WHERE UserName = 'sfdc@scsgs.com'];
        
        System.runAs(userList[0]){
             List<Contact> conList = [SELECT Id FROM Contact];
            
             Date dt = System.today();
             List<Conflict_of_Interest__c> coi =[SELECT Id,EndDate__c FROM Conflict_of_Interest__c];
             coi[0].EndDate__c = dt.addDays(10);
             coi[1].EndDate__c = dt.addDays(10);
             update coi;
            
            delete coi;
            //Un-Delete record to cover delete event in trigger...
            undelete coi;
            List<inspire1__Project_Tasks__c> ptask =[SELECT Id FROM inspire1__Project_Tasks__c WHERE Has_Active_COI__c = true];
            System.assertEquals(2,ptask.size(),'Task count should be same');
        }
        Test.stopTest();  
    }
    
    
}