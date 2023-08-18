/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_ProjectTaskTrigger_Test
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1420
* Functionality     : This test class .

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        11-04-2023                          Initial version
* Umesh Kumar                        30-05-2023                          modified for coi...
* Umesh Kumar                        22-06-2023                          modified for coi...
************************************************************************************************************************************/

@isTest
public class SCS_ProjectTaskTrigger_Test {
    //Setup data...
    @testSetup static void setup() {
        //Create Sales user...
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
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
            
            //Create standard...
            List<Standard__c> standards = SCS_TestDataFactory.createStandard(proList[0].Id,1);
            standards[0].Language__c = 'English';
            insert standards;
            
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
            oppList[0].WO_Sent_Date_Time__c  = System.today();
            oppList[0].WO_Signed_Date_Time__c  = System.today();
            oppList[0].Initial_Invoice_Send_Date__c  = System.today();
            oppList[0].Initial_Invoice_Payment_Date__c = System.today();
            oppList[0].Final_Invoice_Send_Date__c = System.today();
            oppList[0].Final_Invoice_Payment_Date__c = System.today();
            insert oppList;
            
            //Create Project...
            List<inspire1__Project__c> projects = SCS_TestDataFactory.createProject(accountList[0].Id, oppList[0].Id,1);
            projects[0].RecordTypeId = SNM_TestConstant.ecsRT_Project;
            projects[0].Program__c = proList[0].Id;
            projects[0].Schedule_Automation__c = true;
            insert projects;
            
            //Create Project Task...
            List<inspire1__Project_Tasks__c> projectTask = SCS_TestDataFactory.createProjectTask(projects[0].Id,7);
            projectTask[0].inspire1__RowNumber__c =1;
            projectTask[0].inspire1__sysAssignedToIDs__c ='005';
            projectTask[1].Task_Category__c = 'WO Signed';
            projectTask[1].Lag__c ='1';
            projectTask[2].Task_Category__c = 'Initial Invoice Sent';
            projectTask[2].Lag__c ='1';
            projectTask[3].Task_Category__c = 'Initial Payment Received';
            projectTask[3].Lag__c ='1';
            projectTask[4].Task_Category__c = 'Final Invoice Sent';
            projectTask[4].Lag__c ='1';
            projectTask[5].Task_Category__c = 'Final Payment Received';
            projectTask[5].Lag__c ='1';
            projectTask[5].inspire1__Duration__c =2;
            projectTask[5].inspire1__DurationUnit__c = 'd';
            projectTask[6].Task_Category__c = 'WO Sent';
            projectTask[6].Lag__c ='1';
            projectTask[6].inspire1__Duration__c =2;
            projectTask[6].inspire1__DurationUnit__c = 'd';
            insert projectTask;
            
            //Create COI ...
            List<Conflict_of_Interest__c> coiList = SCS_TestDataFactory.createCOI(conList[0].Id,accountList[0].Id,1);
            coiList[0].Program__c = proList[0].Id;
            insert coiList;
        }
        
    }
    
    @isTest static void testProjectTask() {
        Test.startTest();
        System.runAs(SCS_TestDataFactory.getWebIntegratorUser()){
             List<Contact> conList = [SELECT Id FROM Contact];
            
             List<inspire1__Project_Tasks__c> ptask =[SELECT Id,inspire1__RowNumber__c,inspire1__Status__c,IsParent__c,inspire1__sysAssignedToIDs__c FROM inspire1__Project_Tasks__c];
             ptask[0].inspire1__Status__c = 'Not Started';
             //ptask[0].IsParent__c = true;
             String rowNumber = String.valueOf(ptask[0].inspire1__RowNumber__c);
             system.debug('rowNUM'+ptask);
             ptask[1].Parent__c = rowNumber ;
             ptask[1].inspire1__Status__c = 'Not Started';
             ptask[2].Parent__c = rowNumber;
             ptask[2].inspire1__Status__c = 'Not Started';
             ptask[3].Parent__c = rowNumber;
             ptask[3].inspire1__sysAssignedToIDs__c = conList[0].Id;
             ptask[3].inspire1__Status__c = 'Not Started';
             ptask[4].Parent__c = rowNumber;
             ptask[4].inspire1__Status__c = 'Not Started';
             ptask[5].Parent__c = rowNumber;
             ptask[5].inspire1__Status__c = 'Not Started';
             ptask[6].Parent__c = rowNumber;
             ptask[6].inspire1__Status__c = 'Not Started';
             ptask[6].inspire1__sysAssignedToIDs__c ='005';
             update ptask;
            
            List<inspire1__Project_Tasks__c> parentTask =[SELECT Id,inspire1__Status__c,inspire1__sysAssignedToIDs__c FROM inspire1__Project_Tasks__c WHERE inspire1__RowNumber__c =1];
            parentTask[0].inspire1__Status__c ='Completed';
            parentTask[0].inspire1__sysAssignedToIDs__c = '';
            update parentTask;
            
            List<Opportunity> oppList =[SELECT Id,WO_Sent_Date_Time__c FROM Opportunity];
            oppList[0].WO_Sent_Date_Time__c  = System.today().adddays(2);
            update oppList;
            delete ptask;
            //Un-Delete record to cover delete event in trigger...
            undelete ptask;
            
        }
        Test.stopTest();  
    }
    
    
}