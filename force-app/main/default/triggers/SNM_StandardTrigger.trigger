/**************************************************** NEW ORG CODE ***************************************************************** 
* Trigger Name      : SNM_StandardTrigger
* Related Class Name: SNM_StandardTriggerHandler
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-37
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-37
* Functionality     : This trigger use to sync standard to standards object from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        31-10-2022                          Initial version 
************************************************************************************************************************************/



trigger SNM_StandardTrigger on Standard__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    System.debug(' !!!! SNM_StandardTrigger Trigger Entry');
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SNM_StandardTriggerHandler(), 'Standard_Sync_Trigger');
    System.debug(' !!!! SNM_StandardTrigger Trigger Exit'); 
    
}