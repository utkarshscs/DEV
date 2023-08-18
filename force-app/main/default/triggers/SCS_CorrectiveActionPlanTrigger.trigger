/*
    Description : Trigger for Corrective Action Plan
    Author  :   Utkarsh Goswami
    Date    :   7th April, 2023
*/
trigger SCS_CorrectiveActionPlanTrigger on Corrective_Action_Plan__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    TriggerDispatcher.run(new SCS_CorrectiveActionPlanTriggerHandler(), 'CAP_Trigger');
}