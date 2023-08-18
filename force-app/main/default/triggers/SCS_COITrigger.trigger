/****************************************************New ORG CODE ***************************************************************** 
* Trigger Name       : SCS_COITrigger
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1312
* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        20-06-2023                          Initial version 
************************************************************************************************************************************/
trigger SCS_COITrigger on Conflict_of_Interest__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
     TriggerDispatcher.run(new SCS_COITriggerHandler(), 'SCS_COITrigger');
}