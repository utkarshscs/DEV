/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : SNM_ContactOpportunitySchedular
* Related Class Name: SCS_SFToSFConnector,SNM_OpportunitySchedular
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-74
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-74
* Functionality     : This schedular use to sync cvent contact in evey 30 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/


public with sharing class SNM_ContactOpportunitySchedular implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Get fields from custom meta data using object name...
        Map<String,List<SF_TO_SF_FIELD_MAPPING__mdt>> cmdMap = SCS_IntegrationUtil.getCustomMetaDataRecord('Contact');
        //Create dynamic query...
        String query ='SELECT Id,';
        for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : cmdMap.get('Contact')){
            query = query + cmdRecord.SF_Field_API_Name__c+',';
        }
        //removed , from ent of string...
        query = query.removeEnd(',');
        //Get custom label...
        //String cventUserId = System.Label.SCS_CVENT_USER_Id;
        String dmsUserId = System.Label.FnA_DMS_USER_Id;
        String webIntegratorId = System.Label.Web_Integrator;
        //Get customer record type from contact...
        String customerRTId = SCS_ConstantRTypeReference.standard_Contact_RTId;
        //query = query +' FROM Contact WHERE LastModifiedById =:cventUserId AND RecordTypeId =:customerRTId';
        query = query +'  FROM Contact WHERE External_Record_Id__c = null AND LastModifiedById !=:dmsUserId AND LastModifiedById !=:webIntegratorId AND RecordTypeId =:customerRTId AND LastModifiedDate = LAST_N_DAYS:7 Order By LastModifiedDate DESC LIMIT 10';
        //Query contact record where LastModifiedBy cvent user...
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> recordList){
        //Call sf connector to sync data from new org to old org...
        if(!recordList.isEmpty()){
            SCS_SFToSFConnector.makeFutureCallout(recordList,'Contact','PATCH','');
        }
    }
    public void finish(Database.BatchableContext bc){
        //Call opportunity schedular to sync cvent opportunity...
        Database.executebatch(new SNM_OpportunitySchedular(),1);
    }
}