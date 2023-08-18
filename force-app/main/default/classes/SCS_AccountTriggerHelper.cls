/*
@Author : MAANTIC
@CreatedDate : 11th JUly 2022
@Description : Account Object Trigger Helper use to update account and goal object..
*/
public with sharing class SCS_AccountTriggerHelper {
    
    public static void sFilesCreateAccountFolder(List<Account> newList, Map<Id, Account> oldMap){
        //Boolean hasPermission = FeatureManagement.checkPermission('Bypass_Permission');
        //System.debug('hasPermission-- '+hasPermission);
        
        //if(!hasPermission){
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : newList){
            if(oldMap == null){
                if(acc.CreatedById != System.Label.SCS_CVENT_USER_Id){
                    accIdSet.add(acc.Id);
                }
            }
            else{
                if(acc.Create_Sharepoint_Folder__c != oldMap.get(acc.Id).Create_Sharepoint_Folder__c && acc.Create_Sharepoint_Folder__c == true
                   && (acc.sharepoint_folder_id__c !=null || acc.sharepoint_folder_id__c != '')){
                       accIdSet.add(acc.Id);
                   }
            }
        }
        
        //Calling sFIlesCallout to create folder on SharePoint
        if(accIdSet != null && !accIdSet.isEmpty() && !(Test.isRunningTest()) ){	
            sFilesCallout.createAccountFolderonSharePoint(accIdSet);
        }
        //}
    }
    

}