/*
@Author : MAANTIC
@CreatedDate : 1st AUGUST 2022
@Description : Certificate Object Trigger.
*/

trigger SCS_CertificateTrigger on Certificate__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_CertificateTrHandler(), 'CertificateSync_Trigger');

}