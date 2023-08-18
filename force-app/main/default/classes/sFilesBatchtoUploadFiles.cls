/************************************************************************************************************************************************
Apex Class Name : sFilesBatchtoUploadFiles
Version         : 1.0
Created Date    : 
Modification Log:
Test Class		: sFilesBatchtoUploadFilesTest
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          19/01/2023                            Initial version
Note: Need to add the query in "File_Upload_Batch_Query" custom label one by one before running the batch class. 
//String query = 'SELECT Id, Name, fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHERE fileforcem1__Sharepoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Account WHERE SharePoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE SharePoint_Folder_Id__c != null';
**************************************************************************************************************************************************/
global class sFilesBatchtoUploadFiles implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    public String objectName;
    global database.querylocator start(database.batchableContext bc){
        String query;
        if(!Test.isRunningTest()){
            query = Label.File_Upload_Batch_Query;
        }else if(objectName == 'Opportunity'){
            query = 'SELECT Id, Name, fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHERE fileforcem1__Sharepoint_Folder_Id__c != null';
        }
        else if(objectName == 'Project'){
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c != null';
        }
        else if(objectName == 'Opportunity Certificate'){
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE SharePoint_Folder_Id__c != null';
        }
        else{
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Account WHERE SharePoint_Folder_Id__c != null';
        }
        return Database.getQueryLocator(query);
	}
    
    global void execute(database.batchableContext bc, List<sObject> sObjList){
		Set<Id> recIdSet = new Set<Id>();
        List<SObject> sObjRecordList = new List<SObject>();
        String strObjPrefix = String.valueOf(sObjList[0].Id).substring(0, 3);
        for(SObject obj : sObjList){
            sObjRecordList.add(obj);
            recIdSet.add(obj.Id);
        }
        
        if(!recIdSet.isEmpty()){
            List<ContentDocumentLink> conDocLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recIdSet];
            
            if(!conDocLinkList.isEmpty()){
                System.enqueuejob(new sFilesBatchQueabletoUploadFiles(conDocLinkList, sObjRecordList));
            }
        }
	}
    
    global void finish(database.batchableContext bc){
        
	}
    
    
}