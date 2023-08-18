/**************************************************** NEW ORG CODE ***************************************************************** 
* Trigger Name      : SNM_SiteCoveredTrigger
* Related Class Name: SNM_SiteCoveredTriggerHandler
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-37
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-37
* Functionality     : This trigger use to sync site covered into opportunity sites object from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        21-10-2022                          Initial version 
************************************************************************************************************************************/

trigger SNM_SiteCoveredTrigger on Site_Covered__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    System.debug(' !!!! SNM_SiteCoveredTrigger Trigger Entry');
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SNM_SiteCoveredTriggerHandler(), 'Site_Covered_Sync_Trigger'); 
    System.debug(' !!!! SNM_SiteCoveredTrigger Trigger Exit'); 
}