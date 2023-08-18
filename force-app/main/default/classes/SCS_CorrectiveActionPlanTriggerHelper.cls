/*
@Author : MAANTIC
@CreatedDate : 7th April, 2023
@Description : CAP Trigger Helper

*/
/****************************** NEW ORG CODE *****************************************************/
public class SCS_CorrectiveActionPlanTriggerHelper {

    
    
    public static void beforeCall(Map<Id,Corrective_Action_Plan__c> oldMap, Map<Id,Corrective_Action_Plan__c> newMap, List<Corrective_Action_Plan__c> newList){

        Map<Id, Corrective_Action_Plan__c> mapForUpdate = new Map<Id,Corrective_Action_Plan__c>();
        
        // to check if record is new
        if(oldMap == null){
            updateCustomerContact(newList, true);  
        }
        // to check if record is updated
        else{

            for(Corrective_Action_Plan__c cor : newMap.values()){
                // check if Responsible_for_Completion__c field is updated
                if(cor.Responsible_for_Completion__c != oldMap.get(cor.id).Responsible_for_Completion__c){
                    mapForUpdate.put(cor.Id, cor);
                }
            }
            if(mapForUpdate.size() > 0)
                updateCustomerContact(mapForUpdate.values(), false);
        }


    }

    /*
        Description :   Update Customer Contact lookup with the contact name provided in Responsible for Completion field
                        It querys the account from provided project and searches for the contact record from Account
                        Contact Relationship

        Called from :   SCS_CorrectiveActionPlanTriggerHandler

    */
    public static void updateCustomerContact(List<Corrective_Action_Plan__c> newList, Boolean isNew){

        Map<Id,Id> CAPProjectMap = new Map<Id,Id>();
        Map<Id,Id> projectAndProjectMap = new Map<Id,Id>();
        Map<Id,Id> capContactIdMap = new Map<Id,Id>();
        Map<Id,Id> capProjectContactIdMap = new Map<Id,Id>();
        Map<Id,Id> projectAndAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> projectProgramMap = new Map<Id,Id>();
        Map<Id,String> contactIdNameMap = new Map<Id,String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> contactIdToQuery = new Set<Id>();
        List<inspire1__Project__c> projectList = new List<inspire1__Project__c>();
        List<AccountContactRelation> accountContactRelationList = new List<AccountContactRelation>();
        Map<Id,Set<Id>> accountIdContactSetMap = new Map<Id,Set<Id>>();



        for(Corrective_Action_Plan__c cap : newList){
            projectIdSet.add(cap.Project__c);
            // if record is new we are creating map of procject_c and project__c since record id is not available
            if(isNew)
                projectAndProjectMap.put(cap.Project__c,cap.Project__c);
            else
            // for update we are creating a map for record id(cap id) and project
                CAPProjectMap.put(cap.Id, cap.Project__c);
        }

        System.debug('%%%%%% CAPProjectMap ' + CAPProjectMap);
        System.debug('%%%%%% projectAndProjectMap ' + projectAndProjectMap);

        // getting project data from the list
        if(projectIdSet.size() > 0){
            projectList = getProjectData(projectIdSet);
        }

        System.debug('%%%%%% projectList ' + projectList);
        // for project record queried from CAP project ids
        for(inspire1__Project__c proj : projectList){
            if(String.isNotBlank(proj.inspire1__Account__c)){
                // account id set
                accountIdSet.add (proj.inspire1__Account__c);
                // project Id and Account Id Map
                projectAndAccountIdMap.put(proj.Id, proj.inspire1__Account__c);
                // Project Id and Program map
                projectProgramMap.put(proj.Id, proj.Program__c);
            }
        }

        System.debug('%%%%%% accountIdSet ' + accountIdSet);
        System.debug('%%%%%% projectAndAccountIdMap ' + projectAndAccountIdMap);

        // Query Data from account contact Relationship for the account ids present in Project records above
        if(accountIdSet.size() > 0){
            accountContactRelationList = getAccountContactRelation(accountIdSet);
        }

        System.debug('%%%%%% accountContactRelationList ' + accountContactRelationList);

        // for ACR queried above we are creating a Map of AccountId(key) and Set of ContactId(value)
        // Since it is a one to many relation we are creating Map<Id,Set<Id>>
        for(AccountContactRelation acr : accountContactRelationList){

            if(accountIdContactSetMap.containsKey(acr.AccountId)){
                accountIdContactSetMap.get(acr.AccountId).add(acr.ContactID);
            }
            else{
                accountIdContactSetMap.put(acr.AccountId, new Set<id>{acr.ContactID});
            }
            contactIdToQuery.add(acr.ContactId);
        }

        System.debug('%%%%%% contactNameSet ' + contactIdToQuery);
        // we are quering for the contacts found acr
        if(contactIdToQuery.size() > 0){
            for(Contact con : getContactFromId(contactIdToQuery)){
                contactIdNameMap.put(con.Id,con.Name);
            }
        }

        System.debug('%%%%%% contactIdNameMap ' + contactIdNameMap);
        Id projectId;

        for(Corrective_Action_Plan__c cap : newList){

            // getting project Id from the CAP Record inserted/updated
            projectID = isNew ? projectAndProjectMap.get(cap.Project__c) :CAPProjectMap.get(cap.Id);

            if( String.isNotBlank(projectID) &&
                String.isNotBlank(projectAndAccountIdMap.get(projectID)) &&
                (accountIdContactSetMap.get(projectAndAccountIdMap.get(projectID))) != null

            )
            {
                // step 1 : We are getting the account Id for the respective project Id from projectAndAccountIdMap
                // Step 2 : Once we have the account Id, we are quering for the contact id set from accountIdContactSetMap for that accountId
                Set<Id> contactIdSet = accountIdContactSetMap.get(projectAndAccountIdMap.get(projectID));
                System.debug('%%%%%% Iff contactId ' + contactIdSet);
               // System.debug('%%%%%% Iff contactIdNameMap.get(contactId) ' + contactIdNameMap.get(contactId));
                System.debug('%%%%%% Iff Responsible_for_Completion__c ' + cap.Responsible_for_Completion__c);
                
                // from the contact set found above we are creating a map if contactIdName == Responsible for Completion map
                // if record is new we are creating map of Cap project and ConId
                // if record is updated we are creating of of capId and ContactId
                for(Id conId : contactIdSet){
                    if(contactIdNameMap.containskey(conId) &&
                        contactIdNameMap.get(conId) == cap.Responsible_for_Completion__c
                    ){
                        if(isNew)
                            capProjectContactIdMap.put(cap.Project__c,conId);
                        else
                            capContactIdMap.put(cap.Id, conId);
                    }
                }

            }
        }

        System.debug('%%%%%% Iff capProjectContactIdMap ' + capProjectContactIdMap);
        System.debug('%%%%%% Iff capContactIdMap ' + capContactIdMap);

        for(Corrective_Action_Plan__c cor : newList){

            // updating customer with Project Account
            cor.Customer__c = projectAndAccountIdMap.get(cor.Project__c);
            // updating program with project Program
            cor.Program__c = projectProgramMap.get(cor.Project__c);
            
            
            // updating CustomerContact for both Updated and Inserted
            if(isNew && capProjectContactIdMap.containsKey(cor.Project__c) && String.isNotBlank(capProjectContactIdMap.get(cor.Project__c))){
                cor.CustomerContact__c = capProjectContactIdMap.get(cor.Project__c);               
            }
            else if(capContactIdMap.containsKey(cor.Id) && String.isNotBlank(capContactIdMap.get(cor.Id))){
                cor.CustomerContact__c = capContactIdMap.get(cor.ID);
            }
            else
                cor.CustomerContact__c = null;

        }

    }

    // Method returns Project Data for the passed project Ids set
    public static List<inspire1__Project__c> getProjectData(Set<Id> projectIdSet){
        return new List<inspire1__Project__c>([Select ID,inspire1__Account__c, Program__c FROM inspire1__Project__c where Id IN :projectIdSet]);
    }
    
    // Method returns ACR Data for the passed account Ids set
    public static List<AccountContactRelation> getAccountContactRelation(Set<Id> accountIds){
        return new List<AccountContactRelation>([Select ID,AccountId,ContactId, Contact.Name FROM AccountContactRelation where AccountId IN :accountIds]);
    }

    // Method returns Contact Data for the passed contact Ids set
    public static List<Contact> getContactFromId(Set<Id> contactIds){
        return new List<Contact>([Select ID,Name FROM Contact where Id IN :contactIds]);
    }
    
}