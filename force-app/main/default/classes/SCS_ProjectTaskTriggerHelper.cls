/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_ProjectTaskTriggerHelper
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1330
* Functionality     : This helper use in SCS_ProjectTaskTriggerHandler class to update project task.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        11-04-2023                          Initial version 
* Umesh Kumar                        11-04-2023                          Update IsParent field on parent task.
* Umesh Kumar                        11-04-2023                          Update child task status and start date.
* Umesh Kumar                        11-04-2023                          Removed child relation.if parent task is deleted.
************************************************************************************************************************************/


public with sharing class SCS_ProjectTaskTriggerHelper {
    
    //call from trigger handler when record is created...
    public static void updateIsParentField( List<inspire1__Project_Tasks__c> newTrigger ){
        Set<Integer> rowNumberSet = new Set<Integer>();
        Set<Id> projectIdSet = new Set<Id>();
        for ( inspire1__Project_Tasks__c record: newTrigger ) {            
            if(record.Parent__c != null){
                String parentString = record.Parent__c;
                parentString = parentString.trim();
                if(parentString.isNumeric()){
                    rowNumberSet.add(Integer.valueOf(parentString));
                    projectIdSet.add(record.inspire1__Project__c);
                }
            } 
        } 
        //update Isparent field on parent task...
        if(! rowNumberSet.isEmpty() && ! projectIdSet.isEmpty()){
            List<inspire1__Project_Tasks__c> parentTaskList = new List<inspire1__Project_Tasks__c>();
            for(inspire1__Project_Tasks__c record :[SELECT Id FROM inspire1__Project_Tasks__c WHERE IsParent__c = false AND inspire1__RowNumber__c IN : rowNumberSet AND inspire1__Project__c IN :projectIdSet]){
                parentTaskList.add(new inspire1__Project_Tasks__c(Id = record.Id,IsParent__c = true));
            }
            if(! parentTaskList.isEmpty()){
                update parentTaskList;
            } 
        }
    }
    //Call from trigger handler when record is update...
    public static void updateProjectTask(List<inspire1__Project_Tasks__c> newTrigger ,Map<Id,inspire1__Project_Tasks__c> oldMap){
        Set<Id> projectIdSet = new Set<Id>();
        Set<String> rowNumberSet = new Set<String>();
        Map<String,String> mapOfRowNumber = new Map<String,String>();
        for (inspire1__Project_Tasks__c record: newTrigger ){
            //If status change then return true...
            Boolean isStatusChange = record.inspire1__Status__c != oldMap.get(record.Id).inspire1__Status__c ? true : false;
            //If Task row number is change...
            Boolean isRowNumberChange = record.inspire1__RowNumber__c != oldMap.get(record.Id).inspire1__RowNumber__c ? true : false;
            //If parent task status change to complete...
            if(record.IsParent__c && record.inspire1__Status__c == 'Completed' && isStatusChange && record.Schedule_Automation__c){
                rowNumberSet.add(String.valueOf(record.inspire1__RowNumber__c));
                projectIdSet.add(record.inspire1__Project__c);
                //If row number is change...
            } else if(isRowNumberChange && isStatusChange == false && record.IsParent__c){
                mapOfRowNumber.put(String.valueOf(oldMap.get(record.Id).inspire1__RowNumber__c),String.valueOf(record.inspire1__RowNumber__c));
                projectIdSet.add(record.inspire1__Project__c);
            }
        }
        //Update child task parent field when row number is change...
        if(! mapOfRowNumber.isEmpty() && ! projectIdSet.isEmpty()){
            updateParentNumber(mapOfRowNumber,projectIdSet);
        }
        //Update child task status and start date when parent project task status is completed...
        if(! rowNumberSet.isEmpty() && ! projectIdSet.isEmpty()){
            updateChildStatus(rowNumberSet,projectIdSet);
        }
    }
    //Call from trigger handler when parent task deleted...
    public static void parentTaskDelete(List<inspire1__Project_Tasks__c> oldList){
        Set<Id> projectIdSet = new Set<Id>();
        Map<String,String> mapOfRowNumber = new Map<String,String>();
        for (inspire1__Project_Tasks__c record: oldList ){
            mapOfRowNumber.put(String.valueOf(record.inspire1__RowNumber__c),'RemovedRelation');
            projectIdSet.add(record.inspire1__Project__c);
        }
        //Removed Relation from child...
        if(! mapOfRowNumber.isEmpty() && ! projectIdSet.isEmpty()){
            updateParentNumber(mapOfRowNumber,projectIdSet);
        }  
    }
    
    //Update child task parent field when parent task drag & drop...
    public static void updateParentNumber(Map<String,String> mapOfRowNumber,Set<Id> projectIdSet){
        if(! mapOfRowNumber.isEmpty() && ! projectIdSet.isEmpty()){
            List<inspire1__Project_Tasks__c> updatedParentField = new List<inspire1__Project_Tasks__c>();
            for(inspire1__Project_Tasks__c record: [SELECT Id,Parent__c FROM inspire1__Project_Tasks__c  WHERE inspire1__Project__c IN :projectIdSet AND Parent__c IN :mapOfRowNumber.keySet()]){
                if(String.isNotBlank(record.Parent__c)){
                    String parent = record.Parent__c;
                    parent = parent.trim();
                    if(mapOfRowNumber.containsKey(parent)){
                        record.Parent__c =  mapOfRowNumber.get(parent) == 'RemovedRelation' ? null : mapOfRowNumber.get(parent);
                        updatedParentField.add(record);
                    }
                }
            }
            if(! updatedParentField.isEmpty()){   
                update updatedParentField;
            }
        }  
    }  
    //Update child task status and start date when parent project task status is completed...
    public static void updateChildStatus(Set<String> rowNumberSet,Set<Id> projectIdSet){								
        if(! rowNumberSet.isEmpty() && ! projectIdSet.isEmpty()){
            List<inspire1__Project_Tasks__c> updatedChildTasks = new List<inspire1__Project_Tasks__c>();
            BusinessHours bsHours = [SELECT Id FROM BusinessHours WHERE Name = 'SCS Business Hours'];
            for(inspire1__Project_Tasks__c record: [SELECT Id,inspire1__Status__c,inspire1__StartDate__c,inspire1__FinishDate__c,Lag__c,inspire1__Duration__c,inspire1__DurationUnit__c,Weekend_Are_Workday__c,Actual_Start_Date__c FROM inspire1__Project_Tasks__c WHERE inspire1__Status__c = 'Not Started' AND inspire1__Project__c IN :projectIdSet AND Parent__c IN :rowNumberSet]){
                record.inspire1__Status__c = 'In Progress';
                Integer lag = 0;
                DateTime dt = System.now();
                record.Actual_Start_Date__c = dt;
                if(String.isNotBlank(record.Lag__c)){
                    String lagString = record.Lag__c;
                    lagString = lagString.trim();
                    lag = lagString.isNumeric() ? Integer.valueOf(lagString): 0;  
                } 
                dt = bsHours !=null && record.Weekend_Are_Workday__c == false ? BusinessHours.add(bsHours.Id,dt,86400000*lag) : dt.addDays(lag);
                record.inspire1__StartDate__c = dt;
                if(record.inspire1__Duration__c != null && record.inspire1__DurationUnit__c != null && record.inspire1__DurationUnit__c == 'd'){
                   lag = lag + Integer.valueOf(record.inspire1__Duration__c);
                   dt = bsHours !=null && record.Weekend_Are_Workday__c == false ? BusinessHours.add(bsHours.Id,dt,86400000*lag) : dt.addDays(lag);
                }
                record.inspire1__FinishDate__c = dt;
                updatedChildTasks.add(record);
            }
            if(! updatedChildTasks.isEmpty()){   
                update updatedChildTasks;
            }
        }
    }
}