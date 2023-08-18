/*
@Author : MAANTIC
@CreatedDate : 17th AUG 2023
@Description : CertifiedProducts__c Object Trigger.
*/

trigger SCS_CertifiedProduct on CertifiedProducts__c(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_CertifiedProductHandler(), 'SCS_CertifiedProduct_Trigger'); 
}