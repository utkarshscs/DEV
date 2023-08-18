/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_ProjectTaskTrigger
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1330
* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        11-04-2023                          Initial version 
************************************************************************************************************************************/
trigger SCS_ProjectTaskTrigger on inspire1__Project_Tasks__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_ProjectTaskTriggerHandler(), 'SCS_ProjectTaskTrigger');
    //SCS_ProjectTaskTriggerHandler is handler class and SCS_ProjectTaskTrigger is trigger name in custom meta data to controll the trigger.
}