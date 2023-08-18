/*
@Author : MAANTIC
@CreatedDate : 14th April 2023
@Description : This class is the controller class of Create sharepoint folder lightning web component.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/

public class CreateSharepointFolderLWCController {
    
    @AuraEnabled(cacheable=true)
    public static sObject checkParentFolder(String recordId){
        System.debug('I am in dev console');
        try{
            if(recordId.startsWith('a0e')){
            return [SELECT Id, inspire1__Opportunity1__r.fileforcem1__Sharepoint_Folder_Id__c FROM inspire1__Project__c WHERE Id=:recordId];
            }
            else if(recordId.startsWith('a2C')){
                return [SELECT Id, Opportunity__r.fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE Id=:recordId];
            }
            else{return null;}
        }
        catch(Exception e){throw new AuraHandledException(e.getMessage());}
    }
        
}