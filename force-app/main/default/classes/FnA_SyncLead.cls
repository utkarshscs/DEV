/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : FnA_SyncLead
* Related Class Name: SCS_SFToSFConnector
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : This schedular use to sync lead in evey 15 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        08-12-2022                          Initial version 
************************************************************************************************************************************/


public with sharing class FnA_SyncLead implements Database.Batchable<sObject>,Database.AllowsCallouts{
    //Start...
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Set of unique field api Name...
        Set<String> fieldSet = new Set<String> ();
        //Get fields from custom meta data using object name...
        for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : [SELECT SF_Field_API_Name__c FROM SF_TO_SF_FIELD_MAPPING__mdt WHERE SF_Object_Name__c ='Lead']){
            fieldSet.add(cmdRecord.SF_Field_API_Name__c);
        }
        //Create dynamic query...
        String query ='SELECT Id,';
        for(String field : fieldSet){
            query = query + field +',';
        }
        //removed , from ent of string...
        query = query.removeEnd(',');
        String webIntegratorId = System.Label.Web_Integrator;
        query = query +'  FROM Lead WHERE External_Record_Id__c = null AND LastModifiedById !=:webIntegratorId AND LastModifiedDate = LAST_N_DAYS:7 Order By LastModifiedDate DESC LIMIT 10';
        //Query all Lead...
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> recordList){
        //Use to store object name...
        System.debug('recordList*********'+recordList);
        //Call sf connector to sync data from new org to old org...
        if(!recordList.isEmpty()){
            SCS_SFToSFConnector.makeFutureCallout(recordList,'Lead','PATCH','');
        }
    }
    public void finish(Database.BatchableContext bc){ 
        // Call account contact opportunity schedular to sync record...
        Database.executebatch(new SNM_AccountContactOppoSchedular(),1);
    }
}