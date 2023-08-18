/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : SNM_OpportunitySchedular
* Related Class Name: SCS_SFToSFConnector
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* JIRA Ticket       : SF20FA-74
* JIRA Link         : https://scsglobalservices.atlassian.net/jira/software/projects/SF20FA/boards/56?assignee=61b19c2cb43d5b006ad59a59&selectedIssue=SF20FA-74
* Functionality     : This schedular use to sync cvent Opportunity in evey 30 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        28-10-2022                          Initial version 
************************************************************************************************************************************/



public with sharing class SNM_OpportunitySchedular implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Get fields from custom meta data using object name...
        Map<String,List<SF_TO_SF_FIELD_MAPPING__mdt>> cmdMap = SCS_IntegrationUtil.getCustomMetaDataRecord('Opportunity');
        //Create dynamic query...
        String query ='SELECT Id,';
        for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : cmdMap.get('Opportunity')){
            query = query + cmdRecord.SF_Field_API_Name__c+',';
        }
        //Get custom label...
        //String cventUserId = System.Label.SCS_CVENT_USER_Id;
        //String dmsUserId = System.Label.FnA_DMS_USER_Id;
        String webIntegratorId = System.Label.Web_Integrator;
        //Get training record type id from opportunity...
        String trainingRTId = SCS_ConstantRTypeReference.training_Oppo_RTId;
        //query = query +'Record_Type_Name__c,Id FROM Opportunity WHERE LastModifiedById =:cventUserId AND RecordTypeId =:trainingRTId';
        query = query +'Record_Type_Name__c FROM Opportunity WHERE External_Record_Id__c = null AND DMS_Project_ID__c = null AND LastModifiedById !=:webIntegratorId AND RecordTypeId != null AND LastModifiedDate = LAST_N_DAYS:7 Order By LastModifiedDate DESC LIMIT 10';
        //Query all account where lastmodified by cvent use...
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> recordList){
        //Call sf connector to sync data from new org to old org...
        if(!recordList.isEmpty()){
            SCS_SFToSFConnector.makeFutureCallout(recordList,'Opportunity','PATCH',recordList[0].Record_Type_Name__c);
        }
    }
    public void finish(Database.BatchableContext bc){ }
}