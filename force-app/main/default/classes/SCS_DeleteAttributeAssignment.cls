/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : SCS_DeleteAttributeAssignment
* Version           : 1.0
* Functionality     : 

* Modification Log  : This schedular Runs Daily at 1:00 AM to delete attribute assignment where end date or expire date yesterday
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        08-06-2023                          Initial version 
************************************************************************************************************************************/


public with sharing class SCS_DeleteAttributeAssignment implements Database.Batchable<sObject>{
    //Start...
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Query all attribute assignment where end date or expiry date is equal to YESTERDAY.
        return Database.getQueryLocator([SELECT Id,EndDate__c FROM inspire1__Attribute_Assignment__c WHERE EndDate__c = YESTERDAY OR Expiry_Date__c = YESTERDAY]);
    }
    //Execute method to execute the thread...
    public void execute(Database.BatchableContext bc, List<inspire1__Attribute_Assignment__c> recordList){
        if(! recordList.isEmpty()){
            //Delete the record...
            delete recordList;
        }
    }
    //Finish method...
    public void finish(Database.BatchableContext bc){ 
    }
}