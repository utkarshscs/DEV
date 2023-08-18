/************************************************************************************************************************************************
Apex Class Name : sFilesBatchToGetBackFiles
Version         : 1.0
Created Date    : 
Test Class		: sFilesBatchToRetrieveFilesTest
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          26/06/2023                            Initial version
**************************************************************************************************************************************************/
global class sFilesBatchToGetBackFiles implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    
    private List<String> fileIdList;
    
    public sFilesBatchToGetBackFiles(List<String> allFileIds) {
        fileIdList = allFileIds;
    }
    
    global database.querylocator start(database.batchableContext bc){
        String query = 'Select Id, FileId__c, ParentFolderId__c, LinkedRecordId__c, File_Uploaded__c FROM File_Store__c WHERE FileId__c IN:fileIdList AND File_Uploaded__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<File_Store__c> fileList){
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Opportunity' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        List<ContentVersion> conVerListToUpdate = new List<ContentVersion>();
        Map<String, List<fileforcem1.SharePointFileInfo>> mapParentIdAndFolderContents = new Map<String, List<fileforcem1.SharePointFileInfo>>();
        Set<Id> conVerIdSet = new Set<Id>();
        List<ContentDocumentLink> cdLinkToInsert = new List<ContentDocumentLink>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<File_Store__c>  fileStoreToUpdate = new List<File_Store__c>();
        Map<String, File_Store__c> mapSPIdAndOppty = new Map<String, File_Store__c>();
        Map<String, String> mapTitleAndExtn = new Map<String, String>();
        Set<Id> linkedRecordIdSet = new Set<Id>();
        Set<Id> contentDocIdSet = new Set<Id>();
        List<String> fileTitleList = new List<String>();
        
        for(File_Extension__c fileExtn: [SELECT Id, Name, File_Name__c, Extension__c FROM File_Extension__c]){
            if(!mapTitleAndExtn.containsKey(fileExtn.Name)){
                mapTitleAndExtn.put(fileExtn.File_Name__c, fileExtn.Extension__c);
            }
        }
        
        for(File_Store__c file: fileList){
            linkedRecordIdSet.add(file.LinkedRecordId__c);
            String fileId = file.FileId__c;
            String parentFolderId = file.ParentFolderId__c;
            if(!mapSPIdAndOppty.containsKey(parentFolderId)){
                mapSPIdAndOppty.put(parentFolderId, file);
            }
            try{
                ContentVersion myDownloadedFile;
                if(!Test.isRunningTest()){
                    myDownloadedFile = apiClient.downloadFile(fileId);
                    String fileExtension = myDownloadedFile.Title;
                    fileExtension = fileExtension.substringAfterLast('.');
                    if(String.isBlank(fileExtension)){
                        String fileExtn = mapTitleAndExtn.containsKey(myDownloadedFile.Title) && String.isNotBlank(mapTitleAndExtn.get(myDownloadedFile.Title)) ? mapTitleAndExtn.get(myDownloadedFile.Title) : '';
                        if(String.isNotBlank(fileExtn)){
                            myDownloadedFile.Title = myDownloadedFile.Title+'.'+fileExtn;
                        }
                    }
                }
                else{
                    myDownloadedFile = new ContentVersion(Title='PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf', PathOnClient='PT SCS Indonesia._RSB SAF Book-and-Claim_SCS-RSBSAFBC-1000 (4).pdf', Id=Label.ContentVersionIdForDeployment);
                }
                myDownloadedFile.SharePoint_Parent_FolderId__c = parentFolderId;
                conVerListToUpdate.add(myDownloadedFile);
            }
            catch (Exception e){
                Integration_Log__c log = new Integration_Log__c(Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                integrationLogs.add(log);
            }
        }
        
        if(linkedRecordIdSet != null && !linkedRecordIdSet.isEmpty()){
            for(ContentDocumentLink cdlink: [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:linkedRecordIdSet]){
                contentDocIdSet.add(cdlink.ContentDocumentId);
            }
        }
        
        if(contentDocIdSet != null && !contentDocIdSet.isEmpty()){
            for(ContentVersion conVer : [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:contentDocIdSet]){
                fileTitleList.add(conVer.Title);
            }
        }
        
        if(conVerListToUpdate != null && !conVerListToUpdate.isEmpty()){
            update conVerListToUpdate;
            
            for(ContentVersion cversion: conVerListToUpdate){
                conVerIdSet.add(cversion.Id);
            }
            
            Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:conVerIdSet]);
            for(ContentVersion cversion: conVerListToUpdate){
                if(!fileTitleList.contains(cversion.Title)){
                    String linkedRecordId = mapSPIdAndOppty.containsKey(cversion.SharePoint_Parent_FolderId__c) && mapSPIdAndOppty.get(cversion.SharePoint_Parent_FolderId__c) != null ? mapSPIdAndOppty.get(cversion.SharePoint_Parent_FolderId__c).LinkedRecordId__c : '';
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = linkedRecordId;
                    cdl.ContentDocumentId = mapContentVersion.containsKey(cversion.Id) && mapContentVersion.get(cversion.Id) != null ? mapContentVersion.get(cversion.Id).ContentDocumentId : null;
                    cdl.shareType = 'V';
                    cdLinkToInsert.add(cdl);
                    
                    Id fileStoreId = mapSPIdAndOppty.containsKey(cversion.SharePoint_Parent_FolderId__c) && mapSPIdAndOppty.get(cversion.SharePoint_Parent_FolderId__c) != null ? mapSPIdAndOppty.get(cversion.SharePoint_Parent_FolderId__c).Id : '';
                    File_Store__c file = new File_Store__c(Id = fileStoreId, File_Uploaded__c = true);
                    fileStoreToUpdate.add(file);
                }
            }
        }
        
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
        
        if(cdLinkToInsert != null && !cdLinkToInsert.isEmpty()){
            insert cdLinkToInsert;
        }
        
        if(fileStoreToUpdate != null && !fileStoreToUpdate.isEmpty()){
            update fileStoreToUpdate;
        }
        
    }
    
    global void finish(database.batchableContext bc){
        
    }
    
    
}