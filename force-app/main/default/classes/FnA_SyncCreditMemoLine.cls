/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : FnA_SyncCreditMemoLine
* Related Class Name: SCS_SFToSFConnector
* Division          : FnA
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : This schedular use to sync fw1__Credit_Memo_Line__c in evey 3 hr from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        14-03-2023                          Initial version 
************************************************************************************************************************************/


public with sharing class FnA_SyncCreditMemoLine implements Database.Batchable<sObject>,Database.AllowsCallouts{
    //Start...
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Set of unique field api Name...
        Set<String> fieldSet = new Set<String> ();
        //Get fields from custom meta data using object name...
        for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : [SELECT SF_Field_API_Name__c FROM SF_TO_SF_FIELD_MAPPING__mdt WHERE SF_Object_Name__c ='fw1__Credit_Memo_Line__c']){
            fieldSet.add(cmdRecord.SF_Field_API_Name__c);
        }
        //Create dynamic query...
        String query ='SELECT Id,';
        for(String field : fieldSet){
            query = query + field +',';
        }
        //removed , from ent of string...
        query = query.removeEnd(',');
        //String webIntegratorId = System.Label.Web_Integrator;
        query = query +' FROM fw1__Credit_Memo_Line__c WHERE External_Record_Id__c = null AND DMS_inv_line_Id__c = null AND External_Credit_Memo_Id__c != null AND LastModifiedDate = LAST_N_DAYS:7 Order By LastModifiedDate DESC';
        //Query all Lead...
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<fw1__Credit_Memo_Line__c> recordList){
        //Use to store object name...
        System.debug('recordList*********'+recordList);
        //Call sf connector to sync data from new org to old org...
        if(!recordList.isEmpty()){
            SCS_SFToSFConnector.makeFutureCallout(recordList,'fw1__Credit_Memo_Line__c','PATCH','');
        }
    }
    public void finish(Database.BatchableContext bc){ 
        // Call contact schedular to sync cvent record...
    }
}