/*
@Author : MAANTIC - Raj
@CreatedDate : 28th Oct 2022
@Description : Project Object Trigger.
*/

public class SCS_ProjectTriggerHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Opportunity> newList) {
        
    }
    
    //Call after insert...
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        //Stop the recursion...
        if(SCS_ProjectTriggerHelper.isRecursive){
            system.debug('afterInsert sFilesCreateProjectFolder called');
            SCS_ProjectTriggerHelper.sFilesCreateProjectFolder(newList,null);
        }
    }
    
    //Call before update...
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        
    }
    
    //Call after update...
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) { 
        SCS_ProjectTriggerHelper.sFilesCreateProjectFolder((List<inspire1__Project__c>)newList,(Map<Id, inspire1__Project__c>)oldMap);
    }
    
    //Call before Delete...
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    //Call after Delete...
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }

}