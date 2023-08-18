/**************************************************** NEW ORG CODE ***************************************************************** 
* Trigger Name      : SCS_StandardCoveredTrigger
* Related Class Name: SCS_StandardCoveredTriggerHandler
* Version           : 1.0
* Description     	: Standard Covered Object Trigger
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Sohit Tripathi                    21-06-2023                          Initial version 
************************************************************************************************************************************/
trigger SCS_StandardCoveredTrigger on Standard_Covered__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_StandardCoveredTriggerHandler(), 'Standard_Covered');    
}