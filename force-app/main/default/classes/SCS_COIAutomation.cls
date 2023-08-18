/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_COIAutomation
* Version           : 1.1
* Code reviewed By  : Ratan Kumar
* JIRA Ticket       : SF20FA-1312
* Functionality     : This class use in project task trigger handler to identify the COI for assigned auditor.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        19-06-2023                          Initial version 
************************************************************************************************************************************/


public with sharing class SCS_COIAutomation {
    
    
    //This method is calling from project task trigger handler on before update...
    public static void checkCOI(List<inspire1__Project_Tasks__c> newList,Map<Id,inspire1__Project_Tasks__c> oldMap){
        
        /**********************************************Start - declation ********************************************************************/
        //Assigned auditor id set...
        Set<String> assignedAuditorIdSet = new Set<String> ();
        //declation of map for string type...
        Map<String,Conflict_of_Interest__c> coiMap = new Map<String,Conflict_of_Interest__c>();
        //List of modified records...
        List<inspire1__Project_Tasks__c> modifiedList = new List<inspire1__Project_Tasks__c>();
        /**********************************************Start - declation ********************************************************************/
        
        /**********************************************Start- When Assigned To Change***********************************************************/
        //iteration of modified record...
        for(inspire1__Project_Tasks__c record : newList) {
            //Is start date change ?...
            Boolean isStartDateChange = record.inspire1__StartDate__c != oldMap.get(record.Id).inspire1__StartDate__c ? true : false;
            //Is finish date change ?...
            Boolean isFinishDateChange = record.inspire1__FinishDate__c != oldMap.get(record.Id).inspire1__FinishDate__c ? true : false;
            //Check task start date and end date is null ?...
            Boolean hasStartDate = record.inspire1__StartDate__c != null && record.inspire1__FinishDate__c != null ? true : false;
            //Check assigned to auditor is change ?...
            if( hasStartDate && (record.inspire1__sysAssignedToIDs__c != oldMap.get(record.Id).inspire1__sysAssignedToIDs__c || isStartDateChange || isFinishDateChange)) {    
                modifiedList.add(record);
                //Store assigned To Ids...
                String strids = record.inspire1__sysAssignedToIDs__c;
                //Check assigned id is not null ?...
                if(String.isNotBlank(strids)) {
                    strids = strids.contains(';') ? strids.replace(';',':') : strids ;
                    //Add auditor id into set...
                    for(String audiorId : strids.split(':')) {
                        assignedAuditorIdSet.add(audiorId);
                    }
                }
            }
        }
        /**********************************************End- When Assigned To Change***********************************************************/
        
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
        //check modifiedList is not blank....
        if(! modifiedList.isEmpty() ) {
            //Iterate modified record...
            for(inspire1__Project_Tasks__c record : modifiedList) {
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
                } else {
                    //Make COI inactive... 
                    record.Has_Active_COI__c = false;
                    record.inspire1__Color__c  = '';
                    System.debug('AUditor Field Blank');
                }
            }    
        }
        /**********************************************End- apply COI ************************************************************************/
    }
}