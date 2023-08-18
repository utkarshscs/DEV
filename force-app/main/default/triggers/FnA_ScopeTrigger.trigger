/**************************************************** NEW ORG CODE ***************************************************************** 
* Trigger Name      : FnA_ScopeTrigger
* Related Class Name: FnA_ScopeTriggerHandler
* Division          : Food and agriculture
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-136
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-136
* Functionality     : This trigger use to sync scope into client activity and opportunity client activity from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        15-12-2022                          Initial version 
************************************************************************************************************************************/



trigger FnA_ScopeTrigger on Scope__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new FnA_ScopeTriggerHandler(), 'Scope_Sync_Trigger');
    
}