/*
    Description : Apex Batch Class to delete integration log data before last month
    Author      : Maantic
    Date        : September, 2022

*/

public  class SCS_Batch_Before15DaysInteLogDel implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        String query1 = '';
        Date today = System.today();
        Datetime Date15th = datetime.newinstance(today.year(), (today.month()), 15);
        String stringDate = string.valueof(Date15th);
        List<String> res = stringDate.split(' ');
        stringDate = res[0]+'T00:00:00Z';
        if(Test.isRunningTest()){
            query = 'Select Id FROM Integration_Log__c WHERE CreatedDate = Today';
        }  
        else{
            if(today>Date15th) {query = 'Select Id FROM Integration_Log__c WHERE CreatedDate < '+stringDate;}
            else {query = 'Select Id FROM Integration_Log__c WHERE CreatedDate < THIS_MONTH';}
            system.debug(query);
       }
        return Database.getQueryLocator(query); 
    }

    /*
        Execute method to delete the records send by the start method
    */
    public void execute(Database.BatchableContext BC, List<Integration_Log__c> scope){
        if( scope != null && scope.size() > 0)
            delete scope;
    }

    /*
        Please add any post execution logic here
    */
    public void finish(Database.BatchableContext BC){
    }
}

/*
 
scheduledBatchable batch = new scheduledBatchable();
String sch = '0 0 0 15,30 * ? *';
String jobIDNew = system.schedule('Batch Scheduled', sch, batch);

*/