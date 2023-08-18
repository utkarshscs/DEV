/************************************************************************************************************************************************
Apex Class Name : sFilesBatchToRetrieveFiles
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchToRetrieveFilesTest
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          26/06/2023                            Initial version
Note: Need to add the query in "File_Upload_Batch_Query" custom label one by one before running the batch class.
//String query = 'SELECT Id, Name, fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHERE fileforcem1__Sharepoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Account WHERE SharePoint_Folder_Id__c != null';
//String query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE SharePoint_Folder_Id__c != null';
**************************************************************************************************************************************************/
global class sFilesBatchToRetrieveFiles implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    public String objectName;
    global database.querylocator start(database.batchableContext bc){
        String query;
        if(!Test.isRunningTest()){
            query = Label.File_Upload_Batch_Query;
        }else if(objectName == 'Opportunity'){
            query = 'SELECT Id, Name, fileforcem1__Sharepoint_Folder_Id__c FROM Opportunity WHERE fileforcem1__Sharepoint_Folder_Id__c != null LIMIT 1';
        }
        else if(objectName == 'Project'){
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE SharePoint_Folder_Id__c != null LIMIT 1';
        }
        else if(objectName == 'Opportunity Certificate'){
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE SharePoint_Folder_Id__c != null LIMIT 1';
        }
        else{
            query = 'SELECT Id, Name, SharePoint_Folder_Id__c FROM Account WHERE SharePoint_Folder_Id__c != null LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<SObject> sObjList){
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Opportunity' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        List<fileforcem1.SharePointFileInfo> folderContent = new List<fileforcem1.SharePointFileInfo>();
        List<ContentVersion> conVerListToInsert = new List<ContentVersion>();
        Map<String, List<fileforcem1.SharePointFileInfo>> mapParentIdAndFolderContents = new Map<String, List<fileforcem1.SharePointFileInfo>>();
        Set<Id> conVerIdSet = new Set<Id>();
        List<ContentDocumentLink> cdLinkToInsert = new List<ContentDocumentLink>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<File_Store__c> fileIdListToInsert = new List<File_Store__c>();
        Map<String, String> mapSPIdAndRecordId = new Map<String, String>();
        
        String strObjPrefix = String.valueOf(sObjList[0].Id).substring(0, 3);
        //Opportunity
        if(strObjPrefix == Opportunity.sObjectType.getDescribe().getKeyPrefix()){
            List<Opportunity> opptyList = sObjList;
            for(Opportunity opp: opptyList){
                try{
                    if(!Test.isRunningTest()){
                        folderContent.addAll(apiClient.getFolderContents(opp.fileforcem1__Sharepoint_Folder_Id__c, false));
                        if(!mapSPIdAndRecordId.containsKey(opp.fileforcem1__Sharepoint_Folder_Id__c)){mapSPIdAndRecordId.put(opp.fileforcem1__Sharepoint_Folder_Id__c, opp.Id);}
                        
                        if(!mapParentIdAndFolderContents.containsKey(opp.fileforcem1__Sharepoint_Folder_Id__c)){mapParentIdAndFolderContents.put(opp.fileforcem1__Sharepoint_Folder_Id__c, folderContent);}
                    }
                    else{
                        String jsonString1 = '{"ApiActionStatus":null, "ByteSize":"256578.0", "CreatedBy":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":"pdf", "FormattedLastModified":null, "Id":"01ZEWS4T6GC4OLND4O5BB2A5AWN3PC5DS3", "Index":null, "ModifiedBy":null, "Name":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf", "NameWithoutExt":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4)", "NextLink":null, "OpenUrl":"https%3A%2F%2Fscsglobalservices.sharepoint.com%2FShared%2520Documents%2FSalesforce%2520sFiles%2FSANDBOX%2FNew%2520UAT%2FSCS%2520Global%2520Services%2FPT%2520SCS%2520Indonesia%2FOpportunities%2FRSB%25201%2FPT%2520SCS%2520Indonesia._RSB%2520SAF%2520Book-and-Claim_SCS-RSBSAFBC-1000%2520%284%29.pdf", "ParentId":"01ZEWS4T3XBKJCECKB2NAJCS7GTXFOIY2W", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FNew%20UAT%2FSCS%20Global%20Services%2FPT%20SCS%20Indonesia%2FOpportunities%2FRSB%201", "RootLevel":null, "SalesforceId":null, "SharepointGuid":null, "SharepointListId":null, "Size":"250.6 KB", "Type":"File", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/New%20UAT/SCS%20Global%20Services/PT%20SCS%20Indonesia/Opportunities/RSB%201/PT%20SCS%20Indonesia._RSB%20SAF%20Book-and-Claim_SCS-RSBSAFBC-1000%20(4).pdf", "items":null}';
                        fileforcem1.SharePointFileInfo folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
                        folderContent.add(folder);
                        mapSPIdAndRecordId.put(opp.fileforcem1__Sharepoint_Folder_Id__c, opp.Id);
                        mapParentIdAndFolderContents.put(opp.fileforcem1__Sharepoint_Folder_Id__c, folderContent);
                    }
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Opportunity__c = opp.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);}
            }
        }
        //Account
        else if(strObjPrefix == Account.sObjectType.getDescribe().getKeyPrefix()){
            List<Account> accList = sObjList;
            for(Account acc: accList){
                try{
                    if(!Test.isRunningTest()){
                        folderContent.addAll(apiClient.getFolderContents(acc.SharePoint_Folder_Id__c, false));
                        if(!mapSPIdAndRecordId.containsKey(acc.SharePoint_Folder_Id__c)){mapSPIdAndRecordId.put(acc.SharePoint_Folder_Id__c, acc.Id);}
                        
                        if(!mapParentIdAndFolderContents.containsKey(acc.SharePoint_Folder_Id__c)){mapParentIdAndFolderContents.put(acc.SharePoint_Folder_Id__c, folderContent);}
                    }
                    else{
                        String jsonString1 = '{"ApiActionStatus":null, "ByteSize":"256578.0", "CreatedBy":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":"pdf", "FormattedLastModified":null, "Id":"01ZEWS4T6GC4OLND4O5BB2A5AWN3PC5DS3", "Index":null, "ModifiedBy":null, "Name":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf", "NameWithoutExt":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4)", "NextLink":null, "OpenUrl":"https%3A%2F%2Fscsglobalservices.sharepoint.com%2FShared%2520Documents%2FSalesforce%2520sFiles%2FSANDBOX%2FNew%2520UAT%2FSCS%2520Global%2520Services%2FPT%2520SCS%2520Indonesia%2FOpportunities%2FRSB%25201%2FPT%2520SCS%2520Indonesia._RSB%2520SAF%2520Book-and-Claim_SCS-RSBSAFBC-1000%2520%284%29.pdf", "ParentId":"01ZEWS4T3XBKJCECKB2NAJCS7GTXFOIY2W", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FNew%20UAT%2FSCS%20Global%20Services%2FPT%20SCS%20Indonesia%2FOpportunities%2FRSB%201", "RootLevel":null, "SalesforceId":null, "SharepointGuid":null, "SharepointListId":null, "Size":"250.6 KB", "Type":"File", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/New%20UAT/SCS%20Global%20Services/PT%20SCS%20Indonesia/Opportunities/RSB%201/PT%20SCS%20Indonesia._RSB%20SAF%20Book-and-Claim_SCS-RSBSAFBC-1000%20(4).pdf", "items":null}';
                        fileforcem1.SharePointFileInfo folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
                        folderContent.add(folder);
                        mapSPIdAndRecordId.put(acc.SharePoint_Folder_Id__c, acc.Id);
                        mapParentIdAndFolderContents.put(acc.SharePoint_Folder_Id__c, folderContent);
                    }
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Account__c = acc.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);}
            }
        }
        //Opportunity Certificate
        else if(strObjPrefix == Opportunity_Certificate__c.sObjectType.getDescribe().getKeyPrefix()){
            List<Opportunity_Certificate__c> ocList = sObjList;
            for(Opportunity_Certificate__c oc: ocList){
                try{
                    if(!Test.isRunningTest()){
                        folderContent.addAll(apiClient.getFolderContents(oc.SharePoint_Folder_Id__c, false));
                        if(!mapSPIdAndRecordId.containsKey(oc.SharePoint_Folder_Id__c)){mapSPIdAndRecordId.put(oc.SharePoint_Folder_Id__c, oc.Id);}
                        
                        if(!mapParentIdAndFolderContents.containsKey(oc.SharePoint_Folder_Id__c)){mapParentIdAndFolderContents.put(oc.SharePoint_Folder_Id__c, folderContent);}
                    }
                    else{
                        String jsonString1 = '{"ApiActionStatus":null, "ByteSize":"256578.0", "CreatedBy":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":"pdf", "FormattedLastModified":null, "Id":"01ZEWS4T6GC4OLND4O5BB2A5AWN3PC5DS3", "Index":null, "ModifiedBy":null, "Name":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf", "NameWithoutExt":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4)", "NextLink":null, "OpenUrl":"https%3A%2F%2Fscsglobalservices.sharepoint.com%2FShared%2520Documents%2FSalesforce%2520sFiles%2FSANDBOX%2FNew%2520UAT%2FSCS%2520Global%2520Services%2FPT%2520SCS%2520Indonesia%2FOpportunities%2FRSB%25201%2FPT%2520SCS%2520Indonesia._RSB%2520SAF%2520Book-and-Claim_SCS-RSBSAFBC-1000%2520%284%29.pdf", "ParentId":"01ZEWS4T3XBKJCECKB2NAJCS7GTXFOIY2W", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FNew%20UAT%2FSCS%20Global%20Services%2FPT%20SCS%20Indonesia%2FOpportunities%2FRSB%201", "RootLevel":null, "SalesforceId":null, "SharepointGuid":null, "SharepointListId":null, "Size":"250.6 KB", "Type":"File", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/New%20UAT/SCS%20Global%20Services/PT%20SCS%20Indonesia/Opportunities/RSB%201/PT%20SCS%20Indonesia._RSB%20SAF%20Book-and-Claim_SCS-RSBSAFBC-1000%20(4).pdf", "items":null}';
                        fileforcem1.SharePointFileInfo folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
                        folderContent.add(folder);
                        mapSPIdAndRecordId.put(oc.SharePoint_Folder_Id__c, oc.Id);
                        mapParentIdAndFolderContents.put(oc.SharePoint_Folder_Id__c, folderContent);
                    }
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Opportunity_Certificate__c = oc.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);}
            }
        }
        //Project
        else if(strObjPrefix == inspire1__Project__c.sObjectType.getDescribe().getKeyPrefix()){
            List<inspire1__Project__c> prjList = sObjList;
            for(inspire1__Project__c prj: prjList){
                try{
                    if(!Test.isRunningTest()){
                        folderContent.addAll(apiClient.getFolderContents(prj.SharePoint_Folder_Id__c, false));
                        if(!mapSPIdAndRecordId.containsKey(prj.SharePoint_Folder_Id__c)){mapSPIdAndRecordId.put(prj.SharePoint_Folder_Id__c, prj.Id);}
                        
                        if(!mapParentIdAndFolderContents.containsKey(prj.SharePoint_Folder_Id__c)){mapParentIdAndFolderContents.put(prj.SharePoint_Folder_Id__c, folderContent);}
                    }
                    else{
                        String jsonString1 = '{"ApiActionStatus":null, "ByteSize":"256578.0", "CreatedBy":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":"pdf", "FormattedLastModified":null, "Id":"01ZEWS4T6GC4OLND4O5BB2A5AWN3PC5DS3", "Index":null, "ModifiedBy":null, "Name":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf", "NameWithoutExt":"PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4)", "NextLink":null, "OpenUrl":"https%3A%2F%2Fscsglobalservices.sharepoint.com%2FShared%2520Documents%2FSalesforce%2520sFiles%2FSANDBOX%2FNew%2520UAT%2FSCS%2520Global%2520Services%2FPT%2520SCS%2520Indonesia%2FOpportunities%2FRSB%25201%2FPT%2520SCS%2520Indonesia._RSB%2520SAF%2520Book-and-Claim_SCS-RSBSAFBC-1000%2520%284%29.pdf", "ParentId":"01ZEWS4T3XBKJCECKB2NAJCS7GTXFOIY2W", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FNew%20UAT%2FSCS%20Global%20Services%2FPT%20SCS%20Indonesia%2FOpportunities%2FRSB%201", "RootLevel":null, "SalesforceId":null, "SharepointGuid":null, "SharepointListId":null, "Size":"250.6 KB", "Type":"File", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/New%20UAT/SCS%20Global%20Services/PT%20SCS%20Indonesia/Opportunities/RSB%201/PT%20SCS%20Indonesia._RSB%20SAF%20Book-and-Claim_SCS-RSBSAFBC-1000%20(4).pdf", "items":null}';
                        fileforcem1.SharePointFileInfo folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
                        folderContent.add(folder);
                        mapSPIdAndRecordId.put(prj.SharePoint_Folder_Id__c, prj.Id);
                        mapParentIdAndFolderContents.put(prj.SharePoint_Folder_Id__c, folderContent);
                    }
                }
                catch (Exception e){Integration_Log__c log = new Integration_Log__c(Project__c = prj.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());integrationLogs.add(log);}
            }
        }
        
        if(folderContent != null && !folderContent.isEmpty()){
            for(String parentFolderId: mapParentIdAndFolderContents.keySet()){
                if(mapParentIdAndFolderContents.containsKey(parentFolderId)){
                    for(fileforcem1.SharePointFileInfo sFile : mapParentIdAndFolderContents.get(parentFolderId)){
                        if(sFile.Type == 'File'){
                            String linkedRecordId = mapSPIdAndRecordId.containsKey(parentFolderId) && String.isNotBlank(mapSPIdAndRecordId.get(parentFolderId)) ? mapSPIdAndRecordId.get(parentFolderId) : '';
                            File_Store__c fileData = new File_Store__c();
                            fileData.Name = 'FileId: '+sFile.Id;
                            fileData.FileId__c = sFile.Id;
                            fileData.ParentFolderId__c = parentFolderId;
                            fileData.LinkedRecordId__c = linkedRecordId;
                            fileIdListToInsert.add(fileData);
                        }
                    }
                }
            }
        }
        
        if(!fileIdListToInsert.isEmpty()){
            insert fileIdListToInsert;
        }
    }
    
    global void finish(database.batchableContext bc){
        List<String> fileIdList = new List<String>();
        for(File_Store__c file : [SELECT Id, FileId__c FROM File_Store__c]){
            fileIdList.add(String.isNotBlank(file.FileId__c) ? file.FileId__c : '');
        }
        
        sFilesBatchToGetBackFiles callAnotherBatch = new sFilesBatchToGetBackFiles(fileIdList); 
        database.executeBatch(callAnotherBatch, 1); 
    }
    
    
}