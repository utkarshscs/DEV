/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : SNM_AccountContactOppoSyncSchedular
* Related Class Name: SNM_AccountContactOppoSchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-74
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-74
* Functionality     : This schedular use to sync cvent account,contact and opportunity in evey 30 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/


public with sharing class SNM_AccountContactOppoSyncSchedular implements Schedulable {
    //Call SNM_AccountContactOppoSchedular class to sync account,contact and opportunity...
    public void execute(SchedulableContext sc){
       // Database.executebatch(new SNM_AccountContactOppoSchedular(),1);
        Database.executebatch(new FnA_SyncLead(),1);
    }
}