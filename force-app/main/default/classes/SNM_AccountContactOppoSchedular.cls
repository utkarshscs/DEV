/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : SNM_AccountContactOppoSchedular
* Related Class Name: SCS_SFToSFConnector,SNM_ContactOpportunitySchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-74
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-74
* Functionality     : This schedular use to sync cvent account in evey 30 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/


public with sharing class SNM_AccountContactOppoSchedular implements Database.Batchable<sObject>,Database.AllowsCallouts{
    //Start...
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Set of unique field api Name...
        Set<String> fieldSet = new Set<String> ();
        //Get fields from custom meta data using object name...
        for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : [SELECT SF_Field_API_Name__c FROM SF_TO_SF_FIELD_MAPPING__mdt WHERE SF_Object_Name__c ='Account']){
            fieldSet.add(cmdRecord.SF_Field_API_Name__c);
        }
        //Create dynamic query...
        String query ='SELECT Id,';
        for(String field : fieldSet){
            query = query + field +',';
        }
        //Get custom label...
         query = query.removeEnd(',');
        //String cventUserId = System.Label.SCS_CVENT_USER_Id;
        String dmsUserId = System.Label.FnA_DMS_USER_Id;
        String webIntegratorId = System.Label.Web_Integrator;
        //Get Customer record type from contact
        String customerRTId = SCS_ConstantRTypeReference.account_Account_RTId;

        //query = query +' FROM Account WHERE LastModifiedById =:cventUserId AND RecordTypeId =:customerRTId';
        query = query +'  FROM Account WHERE External_Record_Id__c = null AND LastModifiedById !=:dmsUserId AND LastModifiedById !=:webIntegratorId AND RecordTypeId =:customerRTId AND LastModifiedDate = LAST_N_DAYS:7 Order By LastModifiedDate DESC LIMIT 10';
        //Query all account where lastmodified by cvent use...
       
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> recordList){
        //Use to store object name...
        System.debug('recordList*********'+recordList);
        //Call sf connector to sync data from new org to old org...
        if(!recordList.isEmpty()){
            SCS_SFToSFConnector.makeFutureCallout(recordList,'Account','PATCH','');
        }
    }
    public void finish(Database.BatchableContext bc){ 
        // Call contact schedular to sync cvent record...
         Database.executebatch(new SNM_ContactOpportunitySchedular(),1);
    }
}