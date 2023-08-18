/*
@Author : MAANTIC - Raj
@CreatedDate : 28th Oct 2022
@Description : Project Object Trigger Helper use to update Project and create sharepoint folders.
*/

public class SCS_ProjectTriggerHelper {
    //Use to stop the recursion...
    public static Boolean isRecursive = true;
    
    public static void sFilesCreateProjectFolder(List<inspire1__Project__c> newList, Map<Id, inspire1__Project__c> oldMap){
        
        Set<Id> projectIdSet = new Set<Id>();
        for(inspire1__Project__c pro : newList){
            if(oldMap == null){
                if( pro.createdById != System.Label.SCS_CVENT_USER_Id){
                    projectIdSet.add(pro.id);
                }
            }
            else{
                if(pro.Create_Sharepoint_Folder__c != oldMap.get(pro.Id).Create_Sharepoint_Folder__c && pro.Create_Sharepoint_Folder__c == true){
                    projectIdSet.add(pro.Id);
                }
            }
        }
        
        System.debug('projectIdSet-->'+projectIdSet);
        if(projectIdSet != null && !projectIdSet.isEmpty() && !(Test.isRunningTest()) ){
            system.debug('createFoldersonSharePointForProject called');
            sFilesCallout.createFoldersonSharePointForProject(projectIdSet); 
        }
    }
}