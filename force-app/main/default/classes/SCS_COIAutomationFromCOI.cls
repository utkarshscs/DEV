/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_COIAutomationFromCOI
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1312
* Functionality     : This class check coi is active or inactive...

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        20-06-2023                          Initial version 
************************************************************************************************************************************/


public with sharing class SCS_COIAutomationFromCOI {
    
    //This method is calling from COI trigger handler on after update...
    public static void checkCOI(List<Conflict_of_Interest__c> newList,Map<Id,Conflict_of_Interest__c> oldMap){
        //Auditor Id set...
        Set<String> auditorIdSet = new Set<String> ();
        //Project Task Id Set...
        Set<String> projectTaskIdSet = new Set<String> ();
        //Assigned auditor id set...
        Set<String> assignedAuditorIdSet = new Set<String> ();
        //updated project task list...
        List<inspire1__Project_Tasks__c> updatedTaskList = new List<inspire1__Project_Tasks__c>();
        //map of COI...
        Map<String,Conflict_of_Interest__c> coiMap = new Map<String,Conflict_of_Interest__c>();
        
        /**********************************************Start-When End Date Change***********************************************************/
        
        for(Conflict_of_Interest__c record : newList) {
            //Is end date chnage ?...
            if((record.Is_Active__c && oldMap == null ) || (oldMap != null && record.EndDate__c != oldMap.get(record.Id).EndDate__c)) {
                if(record.Auditor_Internal__c != null) {
                    auditorIdSet.add(record.Auditor_Internal__c);
                } else if(record.Auditor__c != null) {
                    auditorIdSet.add(record.Auditor__c);
                }
            }
        }
        /**********************************************End-When End Date Change*****************************************************************/
        
        /**********************************************Start- Get all Salesforce Task***********************************************************/
        if(! auditorIdSet.isEmpty() ) {
            //Get project task id from salesforce task and add into set...
            for(Task sFTask : [SELECT Id,inspire1__Inspire_Task__c,inspire1__Inspire_Task__r.inspire1__sysAssignedToIDs__c FROM Task WHERE inspire1__Inspire_Task__c != null AND (WhoId IN : auditorIdSet OR OwnerId IN : auditorIdSet)]){
                //Store assigned To Ids...
                String strids = sFTask.inspire1__Inspire_Task__r.inspire1__sysAssignedToIDs__c;
                //Check assigned id is not null ?...
                if(String.isNotBlank(strids)) {
                    strids = strids.contains(';') ? strids.replace(';',':') : strids ;
                    //Add auditor id into set...
                    for(String audiorId : strids.split(':')) {
                        assignedAuditorIdSet.add(audiorId);
                    }
                    //Add project task id into set...
                    projectTaskIdSet.add(sFTask.inspire1__Inspire_Task__c);
                }
            }
        }
        /**********************************************End - Get all Salesforce Task***********************************************************/
        
        /**********************************************Start - Get all COI ********************************************************************/
        if(! assignedAuditorIdSet.isEmpty()) {
            //Query active COI based on program and customer...
            for(Conflict_of_Interest__c coi : [SELECT Id,Customer__c,Program__c,StartDate__c,EndDate__c,Auditor__c,Auditor__r.RecordTypeId,Auditor__r.RecordType.DeveloperName,Auditor_Internal__c FROM Conflict_of_Interest__c WHERE Is_Active__c = true AND Customer__c != null AND Program__c != null AND (Auditor__c IN : assignedAuditorIdSet OR Auditor_Internal__c IN : assignedAuditorIdSet)]) {
                //If COI exist for auditor add into map...
                if(String.isNotBlank(coi.Auditor__c) && String.isBlank(coi.Auditor_Internal__c) && coi.Auditor__r.RecordTypeId != null && coi.Auditor__r.RecordType.DeveloperName == 'Auditor'){
                    coiMap.put(coi.Customer__c+':'+coi.Program__c+':'+coi.Auditor__c,coi);
                    //If COI exist for internal auditor add into map...
                } else if(String.isNotBlank(coi.Auditor_Internal__c) && String.isBlank(coi.Auditor__c)) { 
                    coiMap.put(coi.Customer__c+':'+coi.Program__c+':'+coi.Auditor_Internal__c,coi);
                }
            }  
        }
        
        /**********************************************End - Get all COI ************************************************************************/
        
        /**********************************************Start - apply COI ************************************************************************/
        if(! projectTaskIdSet.isEmpty() ) {
            //Get all project task that has assigned to auditor...
            for(inspire1__Project_Tasks__c record :[SELECT Id,inspire1__StartDate__c,inspire1__FinishDate__c,inspire1__sysAssignedToIDs__c,Account_Id__c,Program_Id__c, inspire1__Color__c FROM inspire1__Project_Tasks__c WHERE inspire1__Status__c NOT IN ('Cancelled','Completed') AND Id IN : projectTaskIdSet]){
                //Store assigned To Ids...
                String strids = record.inspire1__sysAssignedToIDs__c;
                //Strore Project task start date and time...
                DateTime taskSDT = record.inspire1__StartDate__c;
                //Strore Project task finish date and time...
                DateTime taskFDT = record.inspire1__FinishDate__c;
                //Convert task start date Time into date...
                Date taskStartDate = Date.newInstance(taskSDT.year(), taskSDT.month(), taskSDT.day());
                //Convert task finish date Time into date...
                Date taskFinishDate = Date.newInstance(taskFDT.year(), taskFDT.month(), taskFDT.day());
                //If string not blank...
                if(String.isNotBlank(strids)) {
                    strids = strids.contains(';') ? strids.replace(';',':') : strids ;
                    for(String audiorId : strids.split(':')) {
                        //create a unique key...
                        String key = record.Account_Id__c+':'+record.Program_Id__c+':'+audiorId;
                        //Check COI is exist for assigned auditor ?...
                        if(coiMap.containsKey(key) && ((taskStartDate >= coiMap.get(key).StartDate__c && (coiMap.get(key).EndDate__c == null || taskStartDate <= coiMap.get(key).EndDate__c)) || 
                        (taskFinishDate >= coiMap.get(key).StartDate__c && (coiMap.get(key).EndDate__c == null || taskFinishDate <= coiMap.get(key).EndDate__c)))) {
                            //Make COI active...
                            record.Has_Active_COI__c = true;
                            record.inspire1__Color__c  = 'FF6600';
                            break;
                        } else {
                            //Make COI inactive...
                            record.Has_Active_COI__c = false;
                            record.inspire1__Color__c  = ''; 
                            System.debug('NO Active COI');
                        }
                    }
                    updatedTaskList.add(record);
                }   
            }  
        }
        //update COI on Project Task...
        if(! updatedTaskList.isEmpty() ) {
            update updatedTaskList;
        }
        /**********************************************End - apply COI ************************************************************************/
    }
    
    //created unique key...
    public static void preventDuplicate(List<Conflict_of_Interest__c> newList){
        for(Conflict_of_Interest__c record : newList) {
            String auditor = record.Auditor_Internal__c != null ? record.Auditor_Internal__c : record.Auditor__c;
            record.Unique_Name__c = record.Customer__c +':'+ record.Program__c +':'+ auditor + ':'+record.Is_Active__c;
        }       
    }
}