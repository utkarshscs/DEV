/*
@Author : MAANTIC
@CreatedDate : 1st AUG 2022
@Description : This batch class run in every hr to create pricebookEntry in target org.
*/

public with sharing class SCS_PriceBookEntrySchedular implements Database.Batchable<sObject>,schedulable,Database.AllowsCallouts{
    //Call by apex schedular...
    public void execute(SchedulableContext sc){
        Database.executebatch(new SCS_PriceBookEntrySchedular(),1);
    }
    //Query the record from price book entry last 1 hr created or modified record...
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,External_Product_Id__c,Pricebook2.External_Record_Id__c,UnitPrice,Revenue_Type__c,ProductCode,UseStandardPrice,IsActive,External_Program_Id__c FROM PricebookEntry WHERE (LastModifiedDate = TODAY AND HOUR_IN_DAY(LastModifiedDate) > 1) OR External_Record_Id__c = null ]);
    }
    public void execute(Database.BatchableContext bc, List<sObject> recordList){
        //Call SF connector to create or update price book entry in old org...
        SCS_SFToSFConnector.makeFutureCallout(recordList,'PricebookEntry','PATCH','');
    }
    public void finish(Database.BatchableContext bc){}
}