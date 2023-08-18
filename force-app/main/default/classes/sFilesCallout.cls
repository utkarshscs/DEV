/************************************************************************************************************************************************
Apex Class Name : sFilesCallout
Version         : 1.0
Created Date    : 
Function        : This class is used to create Account/Opportunity folder on SharePoint.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                        	21/10/2022                            Initial version
Rohit Raj 								28/10/2022							  added folder structure for Projects
**************************************************************************************************************************************************/

global class sFilesCallout{
    
    @future (callout=true)
    Public static void createFoldersonSharePoint(Set<Id> opptyIdSet){
        List<Account> accListToUpdate = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> oppIdSetForExistingAccFolder = new Set<Id>();
        Set<Id> oppIdSetForNewAccFolder = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        Map<Id, String> mapAccOppSGS = new Map<Id, String>();
        Map<Id, String> mapAccOppSS = new Map<Id, String>();
        Map<Id, String> mapAccOppSC = new Map<Id, String>();
        Map<Id, String> mapAccOppSIC = new Map<Id, String>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        //Getting Account RecordType from Custom Label
        List<String> accountRTList = Label.Account_RecordType.contains(',')?Label.Account_RecordType.split(',') : new List<String>{Label.Account_RecordType};
            //Getting Opportunity's SCS Global Services RecordType from Custom Label  
            List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
                //Getting Opportunity's SCS Consulting RecordType from Custom Label
                List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                    //Getting Opportunity's SCS Standard RecordType from Custom Label
                    List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                        //Getting Opportunity's SCS Ivory Coast Entity from Custom Label
                        List<String> sicOpptyRTList = Label.Opportunity_RT_SCS_Ivory_Coast.contains(',')?Label.Opportunity_RT_SCS_Ivory_Coast.split(',') : new List<String>{Label.Opportunity_RT_SCS_Ivory_Coast};
                            
                            //Query on Opportunities coming from trigger
                            if(opptyIdSet != null && !opptyIdSet.isEmpty()){
                                for(Opportunity opp : [SELECT Id, Name, RecordType.DeveloperName, AccountId,fileforcem1__Sharepoint_Folder_Id__c, SharePoint_Folder_URL__c, 
                                                       Account.OpportunityFolderSharePointId__c, Account.SCOpportunityFolderSharePointId__c, Account.SGSOpportunityFolderSharePointId__c, 
                                                       Account.SSOpportunityFolderSharePointId__c, Account.SharePoint_Folder_Id__c, Account.SS_SharePoint_Folder_Id__c, 
                                                       Account.SC_SharePoint_Folder_Id__c, Account.SIC_SharePoint_Folder_Id__c, Account.SIC_SharePoint_Folder_URL__c 
                                                       FROM Opportunity WHERE id IN:opptyIdSet AND Account.RecordType.DeveloperName IN:accountRTList]){
                                                           if((String.isNotBlank(opp.Account.SharePoint_Folder_Id__c) && sgsOpptyRTList.contains(opp.RecordType.DeveloperName)) || 
                                                              (String.isNotBlank(opp.Account.SS_SharePoint_Folder_Id__c) && ssOpptyRTList.contains(opp.RecordType.DeveloperName)) ||
                                                              (String.isNotBlank(opp.Account.SC_SharePoint_Folder_Id__c) && scOpptyRTList.contains(opp.RecordType.DeveloperName)) ||
                                                              (String.isNotBlank(opp.Account.SIC_SharePoint_Folder_Id__c) && sicOpptyRTList.contains(opp.RecordType.DeveloperName))){
                                                                  System.debug('I am in Existign Record Folder');
                                                                  oppIdSetForExistingAccFolder.add(opp.Id);
                                                              }
                                                           else{
                                                               oppIdSetForNewAccFolder.add(opp.Id);
                                                               if(opp.AccountId != null){
                                                                   accIdSet.add(opp.AccountId);
                                                               }
                                                               if(!mapAccOppSGS.containsKey(opp.AccountId) && opp.AccountId != null && sgsOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                                                   mapAccOppSGS.put(opp.AccountId, opp.RecordType.DeveloperName);
                                                               }
                                                               if(!mapAccOppSS.containsKey(opp.AccountId) && opp.AccountId != null && ssOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                                                   mapAccOppSS.put(opp.AccountId, opp.RecordType.DeveloperName);
                                                               }
                                                               if(!mapAccOppSC.containsKey(opp.AccountId) && opp.AccountId != null && scOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                                                   mapAccOppSC.put(opp.AccountId, opp.RecordType.DeveloperName);
                                                               }
                                                               if(!mapAccOppSIC.containsKey(opp.AccountId) && opp.AccountId != null && sicOpptyRTList.contains(opp.RecordType.DeveloperName)){
                                                                   mapAccOppSIC.put(opp.AccountId, opp.RecordType.DeveloperName);
                                                               }
                                                           }
                                                       }
                            }
        
        //This section creates folders for new Accounts and Opportunities
        if(oppIdSetForNewAccFolder != null && !oppIdSetForNewAccFolder.isEmpty()){
            if(accIdSet != null && !accIdSet.isEmpty()){
                mapAccount = new Map<Id, Account>([SELECT Id, Name, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, SS_SharePoint_Folder_Id__c, SS_SharePoint_Folder_URL__c, SC_SharePoint_Folder_Id__c, SC_SharePoint_Folder_URL__c FROM Account WHERE Id In:accIdSet]);
            }
            
            fileforcem1.SharePointFileInfo acctFolder;
            fileforcem1.SharePointFileInfo sgsAllOpptyFolder;
            fileforcem1.SharePointFileInfo scAllOpptyFolder;
            fileforcem1.SharePointFileInfo ssAllOpptyFolder;
            fileforcem1.SharePointFileInfo sicAllOpptyFolder;
            
            fileforcem1.SharePointFileInfo sgsAllPrjFolder;
            fileforcem1.SharePointFileInfo ssAllPrjFolder;
            fileforcem1.SharePointFileInfo scAllPrjFolder;
            fileforcem1.SharePointFileInfo sicAllPrjFolder;
            
            fileforcem1.SharePointFileInfo sgsAllOCFolder;
            fileforcem1.SharePointFileInfo ssAllOCFolder;
            fileforcem1.SharePointFileInfo scAllOCFolder;
            fileforcem1.SharePointFileInfo sicAllOCFolder;
            
            Map<string,string> fields = new Map<string,string>();
            
            if(mapAccount != null){
                for(Account acc : mapAccount.values()){
                    String accName = '';
                    accName = acc.Name;
                    accName = accName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
                    accName = accName.removeEnd('_');
                    System.debug('accName ======> '+accName);
                    try{
                        if(mapAccOppSGS.containsKey(acc.Id) && String.isNotBlank(mapAccOppSGS.get(acc.Id)) && sgsOpptyRTList.contains(mapAccOppSGS.get(acc.Id)) && String.isBlank(acc.SharePoint_Folder_Id__c)){
                            //Creating account folder
                            acctFolder = createFolder(Label.Account_Root_FolderId_SGS, accName, null);
                            acc.SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            //Creating all opportunity folder
                            sgsAllOpptyFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SGSOpportunityFolderSharePointId__c = sgsAllOpptyFolder != null ? sgsAllOpptyFolder.Id : null;
                            acc.SGSOpportunityFolderSharePointURL__c = sgsAllOpptyFolder != null ? sgsAllOpptyFolder.OpenUrl : null;
                            //Creating all projects folder
                            sgsAllPrjFolder = createFolder(acctFolder.Id, Label.All_Projects_SharePoint_FolderName, null);
                            acc.AllProjectSGSSharePointFolderId__c = sgsAllPrjFolder != null ? sgsAllPrjFolder.Id : null;
                            acc.AllProjectSGSSharePointFolderURL__c = sgsAllPrjFolder != null ? sgsAllPrjFolder.OpenUrl : null;
                            //Creating all oc's folder
                            sgsAllOCFolder = createFolder(acctFolder.Id, Label.All_OppCert_SharePoint_FolderName, null);
                            acc.AllOCSGSSharePointFolderId__c = sgsAllOCFolder != null ? sgsAllOCFolder.Id : null;
                            acc.AllOCSGSSharePointFolderURL__c = sgsAllOCFolder != null ? sgsAllOCFolder.OpenUrl : null;
                            
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        if(mapAccOppSS.containsKey(acc.Id) && String.isNotBlank(mapAccOppSS.get(acc.Id)) && ssOpptyRTList.contains(mapAccOppSS.get(acc.Id)) && String.isBlank(acc.SS_SharePoint_Folder_Id__c)){
                            //Creating account folder
                            acctFolder = createFolder(Label.Account_Root_FolderId_SS, accName, null);
                            acc.SS_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SS_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            //Creating all opportunity folder
                            ssAllOpptyFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SSOpportunityFolderSharePointId__c = ssAllOpptyFolder != null ? ssAllOpptyFolder.Id : null;
                            acc.SSOpportunityFolderSharePointURL__c = ssAllOpptyFolder != null ? ssAllOpptyFolder.OpenUrl : null;
                            //Creating all projects folder
                            ssAllPrjFolder = createFolder(acctFolder.Id, Label.All_Projects_SharePoint_FolderName, null);
                            acc.AllProjectSSSharePointFolderId__c = ssAllPrjFolder != null ? ssAllPrjFolder.Id : null;
                            acc.AllProjectSSSharePointFolderURL__c = ssAllPrjFolder != null ? ssAllPrjFolder.OpenUrl : null;
                            //Creating all oc's folder
                            ssAllOCFolder = createFolder(acctFolder.Id, Label.All_OppCert_SharePoint_FolderName, null);
                            acc.AllOCSSSharePointFolderId__c = ssAllOCFolder != null ? ssAllOCFolder.Id : null;
                            acc.AllOCSSSharePointFolderURL__c = ssAllOCFolder != null ? ssAllOCFolder.OpenUrl : null;
                            
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        if(mapAccOppSC.containsKey(acc.Id) && String.isNotBlank(mapAccOppSC.get(acc.Id)) && scOpptyRTList.contains(mapAccOppSC.get(acc.Id)) && String.isBlank(acc.SC_SharePoint_Folder_Id__c)){
                            //Creating account folder
                            acctFolder = createFolder(Label.Account_Root_FolderId_SC, accName, null);
                            acc.SC_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SC_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            //Creating all opportunity folder
                            scAllOpptyFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SCOpportunityFolderSharePointId__c = scAllOpptyFolder != null ? scAllOpptyFolder.Id : null;
                            acc.SCOpportunityFolderSharePointURL__c = scAllOpptyFolder != null ? scAllOpptyFolder.OpenUrl : null;
                            //Creating all projects folder
                            scAllPrjFolder = createFolder(acctFolder.Id, Label.All_Projects_SharePoint_FolderName, null);
                            acc.AllProjectSCSharePointFolderId__c = scAllPrjFolder != null ? scAllPrjFolder.Id : null;
                            acc.AllProjectSCSharePointFolderURL__c = scAllPrjFolder != null ? scAllPrjFolder.OpenUrl : null;
                            //Creating all oc's folder
                            scAllOCFolder = createFolder(acctFolder.Id, Label.All_OppCert_SharePoint_FolderName, null);
                            acc.AllOCSCSharePointFolderId__c = scAllOCFolder != null ? scAllOCFolder.Id : null;
                            acc.AllOCSCSharePointFolderURL__c = scAllOCFolder != null ? scAllOCFolder.OpenUrl : null;
                            
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        if(mapAccOppSIC.containsKey(acc.Id) && String.isNotBlank(mapAccOppSIC.get(acc.Id)) && sicOpptyRTList.contains(mapAccOppSIC.get(acc.Id)) && String.isBlank(acc.SIC_SharePoint_Folder_Id__c)){
                            //Creating account folder
                            acctFolder = createFolder(Label.Account_Root_FolderId_SIC, accName, null);
                            acc.SIC_SharePoint_Folder_Id__c = acctFolder != null ? acctFolder.Id : null;
                            acc.SIC_SharePoint_Folder_URL__c = acctFolder != null ? acctFolder.OpenUrl : null;
                            //Creating all opportunity folder
                            sicAllOpptyFolder = createFolder(acctFolder.Id, Label.All_Opportunities_SharePoint_FolderName, null);
                            acc.SICOpportunityFolderSharePointId__c = sicAllOpptyFolder != null ? sicAllOpptyFolder.Id : null;
                            acc.SICOpportunityFolderSharePointURL__c = sicAllOpptyFolder != null ? sicAllOpptyFolder.OpenUrl : null;
                            //Creating all projects folder
                            sicAllPrjFolder = createFolder(acctFolder.Id, Label.All_Projects_SharePoint_FolderName, null);
                            acc.AllProjectSICSharePointFolderId__c = sicAllPrjFolder != null ? sicAllPrjFolder.Id : null;
                            acc.AllProjectSICSharePointFolderURL__c = sicAllPrjFolder != null ? sicAllPrjFolder.OpenUrl : null;
                            //Creating all oc's folder
                            sicAllOCFolder = createFolder(acctFolder.Id, Label.All_OppCert_SharePoint_FolderName, null);
                            acc.AllOCSICSharePointFolderId__c = sicAllOCFolder != null ? sicAllOCFolder.Id : null;
                            acc.AllOCSICSharePointFolderURL__c = sicAllOCFolder != null ? sicAllOCFolder.OpenUrl : null;
                            
                            fields = new Map<string,string>();
                            fields.put('SalesforceId',acc.Id);
                            if(acctFolder != null && fields != null){
                                createFolder(acctFolder.Id, '',fields);
                            }
                        }
                        
                        accListToUpdate.add(acc);
                    }
                    catch (Exception e){
                        Integration_Log__c log = new Integration_Log__c(Account__c = acc.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                        integrationLogs.add(log);
                    }
                }
            }
            
            if(accListToUpdate != null && !accListToUpdate.isEmpty()){
                update accListToUpdate;
                //Calling Queable class to create Opportunity Folder for new Account
                System.enqueuejob(new sFilesOpportunityFolderQueable(oppIdSetForNewAccFolder));
            }
        }
        
        //Capturing Exception logs
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
        
        //Calling Queable class to create Opportunity Folder for existing Account
        if(oppIdSetForExistingAccFolder != null && !oppIdSetForExistingAccFolder.isEmpty()){
            System.debug('I am inside oppIdSetForExistingAccFolder');
            System.enqueuejob(new sFilesOpportunityFolderQueable(oppIdSetForExistingAccFolder));
        }
        
    }
    
    @future (callout=true)
    Public static void createFoldersonSharePointForProject(Set<Id> projectIdSet){
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Account> accountList = new List<Account>();
        List<inspire1__Project__c> projectList = new List<inspire1__Project__c>();
        List<inspire1__Project__c> prjListToUpdate = new List<inspire1__Project__c>();  
        
        //Getting Opportunity's SCS Global Services Entity from Custom Label
        List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
            //Getting Opportunity's SCS Consulting Entity from Custom Label
            List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                //Getting Opportunity's SCS Standard Entity from Custom Label
                List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                    //Getting Opportunity's SCS Ivory Coast Entity from Custom Label
                    List<String> sicOpptyRTList = Label.Opportunity_RT_SCS_Ivory_Coast.contains(',')?Label.Opportunity_RT_SCS_Ivory_Coast.split(',') : new List<String>{Label.Opportunity_RT_SCS_Ivory_Coast};
                        
                        //Query on Project coming from trigger
                        if(projectIdSet != null && !projectIdSet.isEmpty()){
                            for(inspire1__Project__c prj : [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, inspire1__Account__c, 
                                                            inspire1__Opportunity1__c, inspire1__Opportunity1__r.RecordType.DeveloperName, inspire1__Opportunity1__r.Account.SGSOpportunityFolderSharePointId__c, 
                                                            inspire1__Opportunity1__r.Account.SCOpportunityFolderSharePointId__c, inspire1__Opportunity1__r.Account.SSOpportunityFolderSharePointId__c, 
                                                            inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c, inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c, 
                                                            inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c, inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c, 
                                                            inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c, inspire1__Account__r.AllProjectSCSharePointFolderId__c, 
                                                            inspire1__Account__r.AllProjectSGSSharePointFolderId__c, inspire1__Account__r.AllProjectSICSharePointFolderId__c, inspire1__Account__r.AllProjectSSSharePointFolderId__c,
                                                            inspire1__Opportunity1__r.Account.SC_SharePoint_Folder_Id__c,inspire1__Opportunity1__r.Account.SS_SharePoint_Folder_Id__c,
                                                            inspire1__Opportunity1__r.Account.SIC_SharePoint_Folder_Id__c, inspire1__Account__r.SharePoint_Folder_Id__c, inspire1__Account__r.SC_SharePoint_Folder_Id__c, 
                                                            inspire1__Account__r.SSOpportunityFolderSharePointId__c, inspire1__Account__r.SIC_SharePoint_Folder_Id__c FROM inspire1__Project__c WHERE Id IN:projectIdSet]){
                                                                fileforcem1.SharePointFileInfo allPrjFolder;
                                                                fileforcem1.SharePointFileInfo prjFolder;
                                                                Map<string,string> fields = new Map<string,string>();
                                                                String prjName = '';
                                                                prjName = prj.Name;
                                                                prjName = prjName.replaceAll('[^a-zA-Z0-9\\s+]', '_');
                                                                prjName = prjName.removeEnd('_');
                                                                try{
                                                                    if(prj.inspire1__Opportunity1__c != null){
                                                                        if(sgsOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSGSSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(scOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SC_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSCSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(ssOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SS_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSSSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(sicOpptyRTList.contains(String.valueOf(prj.inspire1__Opportunity1__r.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Opportunity1__r.Account.SIC_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Opportunity1__r.Account.AllProjectSICSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(prj.inspire1__Opportunity1__c == null && prj.inspire1__Account__c != null){
                                                                        if(sgsOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Account__r.AllProjectSGSSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSGSSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(scOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SC_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Account__r.AllProjectSCSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSCSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(ssOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SS_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Account__r.AllProjectSSSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSSSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                        else if(sicOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName)) && String.isNotBlank(prj.inspire1__Account__r.SIC_SharePoint_Folder_Id__c)){
                                                                            if(prj.inspire1__Account__r.AllProjectSICSharePointFolderId__c != null){
                                                                                prjFolder = createFolder(prj.inspire1__Account__r.AllProjectSICSharePointFolderId__c, prjName, null);    
                                                                                prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                                prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                                prjListToUpdate.add(prj);
                                                                            }
                                                                        }
                                                                    }
                                                                    else if(prj.inspire1__Opportunity1__c == null && prj.inspire1__Account__c == null){
                                                                        if(sgsOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                                                            prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SGS, prjName, null);    
                                                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                            prjListToUpdate.add(prj);
                                                                        }
                                                                        else if(scOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                                                            prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SC, prjName, null);    
                                                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                            prjListToUpdate.add(prj);
                                                                        }
                                                                        else if(ssOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                                                            prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SS, prjName, null);    
                                                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                            prjListToUpdate.add(prj);
                                                                        }
                                                                        else if(sicOpptyRTList.contains(String.valueOf(prj.RecordType.DeveloperName))){
                                                                            prjFolder = createFolder(Label.Project_Root_FolderId_without_Acc_Opp_SIC, prjName, null);    
                                                                            prj.SharePoint_Folder_Id__c = prjFolder != null ? prjFolder.Id : null;
                                                                            prj.SharePoint_Folder_URL__c = prjFolder != null ? prjFolder.OpenUrl : null;  
                                                                            prjListToUpdate.add(prj);
                                                                        }
                                                                    }
                                                                    
                                                                    fields.put('SalesforceId',prj.Id);
                                                                    if(prjFolder != null && fields != null){
                                                                        createFolder(prjFolder.Id, '' ,fields);
                                                                    }
                                                                }
                                                                catch (Exception e){
                                                                    Integration_Log__c log = new Integration_Log__c(Project__c = prj.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                                                    integrationLogs.add(log);
                                                                }
                                                            }
                            if(!prjListToUpdate.isEmpty()){
                                update prjListToUpdate;  
                            }
                            if(!integrationLogs.isEmpty()){
                                insert integrationLogs;  
                            }
                        }                    
        
    }
    
    @future (callout=true)
    public static void createFoldersonSharePointForOpptyCertificate(Set<Id> opptyCertIdSet){
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Account> accountList = new List<Account>();
        List<Opportunity_Certificate__c> opptyCertList = new List<Opportunity_Certificate__c>();
        
        //Getting Opportunity's SCS Global Services Entity from Custom Label
        List<String> sgsOpptyRTList = Label.Opportunity_RT_SCS_Global_Services.contains(',')?Label.Opportunity_RT_SCS_Global_Services.split(',') : new List<String>{Label.Opportunity_RT_SCS_Global_Services};
            //Getting Opportunity's SCS Consulting Entity from Custom Label
            List<String> scOpptyRTList = Label.Opportunity_RT_SCS_Consulting.contains(',')?Label.Opportunity_RT_SCS_Consulting.split(',') : new List<String>{Label.Opportunity_RT_SCS_Consulting};
                //Getting Opportunity's SCS Standard Entity from Custom Label
                List<String> ssOpptyRTList = Label.Opportunity_RT_SCS_Standard.contains(',')?Label.Opportunity_RT_SCS_Standard.split(',') : new List<String>{Label.Opportunity_RT_SCS_Standard};
                    //Getting Opportunity's SCS Ivory Coast Entity from Custom Label
                    List<String> sicOpptyRTList = Label.Opportunity_RT_SCS_Ivory_Coast.contains(',')?Label.Opportunity_RT_SCS_Ivory_Coast.split(',') : new List<String>{Label.Opportunity_RT_SCS_Ivory_Coast};
                        
                        //Query on Opportunity Certificate coming from trigger
                        if(opptyCertIdSet != null && !opptyCertIdSet.isEmpty()){
                            for(Opportunity_Certificate__c oppCert : [SELECT Id, Name, SharePoint_Folder_Id__c, SharePoint_Folder_URL__c, Opportunity__c, Opportunity__r.RecordType.DeveloperName, Opportunity__r.fileforcem1__Sharepoint_Folder_Id__c, 
                                                                      Opportunity__r.Account.AllOCSCSharePointFolderId__c, Opportunity__r.Account.AllOCSGSSharePointFolderId__c, Opportunity__r.Account.AllOCSICSharePointFolderId__c, 
                                                                      Opportunity__r.Account.AllOCSSSharePointFolderId__c, Opportunity__r.Account.SharePoint_Folder_Id__c, Opportunity__r.Account.SC_SharePoint_Folder_Id__c, 
                                                                      Opportunity__r.Account.SS_SharePoint_Folder_Id__c, Opportunity__r.Account.SIC_SharePoint_Folder_Id__c FROM Opportunity_Certificate__c WHERE Id IN:opptyCertIdSet]){
                                                                          fileforcem1.SharePointFileInfo oppCertFolder;
                                                                          fileforcem1.SharePointFileInfo oppCertChildFolder;
                                                                          Map<string,string> fields = new Map<string,string>();
                                                                          try{
                                                                              if(sgsOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SharePoint_Folder_Id__c)){
                                                                                  if(oppCert.Opportunity__r.Account.AllOCSGSSharePointFolderId__c != null){
                                                                                      oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSGSSharePointFolderId__c, oppCert.Name, null);
                                                                                      oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                                                                      oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                                                                      opptyCertList.add(oppCert);
                                                                                  }
                                                                              }
                                                                              else if(scOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SC_SharePoint_Folder_Id__c)){
                                                                                  if(oppCert.Opportunity__r.Account.AllOCSCSharePointFolderId__c != null){
                                                                                      oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSCSharePointFolderId__c, oppCert.Name, null);
                                                                                      oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                                                                      oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                                                                      opptyCertList.add(oppCert);
                                                                                  }
                                                                              }
                                                                              else if(ssOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SS_SharePoint_Folder_Id__c)){
                                                                                  if(oppCert.Opportunity__r.Account.AllOCSSSharePointFolderId__c != null){
                                                                                      oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSSSharePointFolderId__c, oppCert.Name, null);
                                                                                      oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                                                                      oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                                                                      opptyCertList.add(oppCert);
                                                                                  }
                                                                              }
                                                                              else if(sicOpptyRTList.contains(String.valueOf(oppCert.Opportunity__r.RecordType.DeveloperName)) && String.isNotBlank(oppCert.Opportunity__r.Account.SIC_SharePoint_Folder_Id__c)){
                                                                                  if(oppCert.Opportunity__r.Account.AllOCSICSharePointFolderId__c != null){
                                                                                      oppCertChildFolder = createFolder(oppCert.Opportunity__r.Account.AllOCSICSharePointFolderId__c, oppCert.Name, null);
                                                                                      oppCert.SharePoint_Folder_Id__c = oppCertChildFolder != null ? oppCertChildFolder.Id : null;
                                                                                      oppCert.SharePoint_Folder_URL__c = oppCertChildFolder != null ? oppCertChildFolder.OpenUrl : null;  
                                                                                      opptyCertList.add(oppCert);
                                                                                  }
                                                                              }
                                                                              
                                                                              fields.put('SalesforceId',oppCert.Id);
                                                                              if(oppCert != null && fields != null){
                                                                                  createFolder(oppCertChildFolder.Id, '' ,fields);
                                                                              }
                                                                          }
                                                                          catch (Exception e){
                                                                              Integration_Log__c log = new Integration_Log__c(Opportunity_Certificate__c = oppCert.Id, Integration_Status__c = 'API Exception', JSON_Body__c = String.valueOf(e), Error_Message__c = e.getMessage());
                                                                              integrationLogs.add(log);
                                                                          }
                                                                      }
                            if(opptyCertList != null && !opptyCertList.isEmpty()){
                                update opptyCertList;  
                            }
                            if(integrationLogs != null && !integrationLogs.isEmpty()){
                                insert integrationLogs;
                            }
                        }                    
    }
    
    public static fileforcem1.SharePointFileInfo createFolder(String rootFolderId, String folderName, Map<string,string> fields){
        fileforcem1.SharePointFileInfo folder;
        fileforcem1__SharePoint_Settings__mdt orgSettings = [SELECT fileforcem1__Named_Credential__c,fileforcem1__Document_Library_Id__c,fileforcem1__Site_Id__c FROM fileforcem1__SharePoint_Settings__mdt WHERE Developername = 'Default' limit 1];
        fileforcem1__SharePoint_Object_Settings__mdt objectSettings = [SELECT fileforcem1__Root_Folder_Id__c,fileforcem1__Site_Id__c,fileforcem1__Document_Library_Id__c FROM fileforcem1__SharePoint_Object_Settings__mdt WHERE MasterLabel ='Account' LIMIT 1 ];
        
        fileforcem1.ClientApi apiClient = new fileforcem1.ClientApi();
        apiClient.namedCredentialName = orgSettings.fileforcem1__Named_Credential__c;
        apiClient.sharepointSiteId = objectSettings.fileforcem1__Site_Id__c;
        apiClient.documentLibraryId = objectSettings.fileforcem1__Document_Library_Id__c;
        
        if(!Test.isRunningTest()){
            if(fields == null && String.isNotBlank(rootFolderId) && String.isNotBlank(folderName)){
                folder = apiClient.createFolder(rootFolderId, folderName);
            }
            else{
                folder = apiClient.updateCustomFields(rootFolderId,fields);
            }
        }
        else{
            String jsonString1 = '{"ApiActionStatus":null,"CreatedBy":null, "CreatedDateTime":null, "CustomFields":null, "Description":null, "DisplayName":null, "DriveFolderId":null, "Format":null, "FormattedLastModified":null, "Id":"01ZEWS4T24FTSQMPOYZND3Z4VEGORXFNLU", "Index":null, "ModifiedBy":null, "Name":"007AAbb", "NameWithoutExt":"007AAbb", "NextLink":null, "OpenUrl":"https://scsglobalservices.sharepoint.com/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "ParentId":"01ZEWS4T7GSH5FJ4YC7NDIRHROT7HKKVF7", "ParentPath":"Salesforce%20sFiles%2FSANDBOX%2FQA", "RootLevel":null, "SalesforceId":null, "SecurityFields":null, "SharepointGuid":null, "SharepointListId":null, "Size":"0 bytes", "Type":"Folder", "Url":"/Shared%20Documents/Salesforce%20sFiles/SANDBOX/QA/007AAbb", "items":null}';
            folder = (fileforcem1.SharePointFileInfo)JSON.deserialize(jsonString1, fileforcem1.SharePointFileInfo.class);
        }
        return folder;
    }
}