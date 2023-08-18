/*
@Author : MAANTIC - Raj
@CreatedDate : 28th Oct 2022
@Description : Project Object Trigger.
*/

trigger SCS_ProjectTrigger on inspire1__Project__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    system.debug('SCS_ProjectTriggerHandler()-->1'); 
    TriggerDispatcher.run(new SCS_ProjectTriggerHandler(), 'Project_Trigger'); 
    system.debug('SCS_ProjectTriggerHandler()-->2');
}