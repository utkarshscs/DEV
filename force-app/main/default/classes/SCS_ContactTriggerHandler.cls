/*
@Author : MAANTIC
@CreatedDate : 20th JULY 2022
@Description : Contact Trigger Handler.

===== Modified by : Amit =========
Added method for CVENT Contact Account m


*/
/****************************** NEW ORG CODE *****************************************************/
public with sharing class SCS_ContactTriggerHandler implements ITriggerHandler {
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
        
        Set<String> companyNames = new Set<String>();
        
        List<Contact> contactsWithCompanyNames = new List<Contact>();
        List<Contact> newContactsList = (List<Contact>)newList;
        
        List<Contact> contactsIndividual = new List<Contact>();
        Set<String> individualAccountNames = new Set<String>();
        
       Id accCustRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        for(Contact newContact : newContactsList){
             if(newContact.isClone()) {
	             newContact.External_Record_Id__c = null;
	           }
            if(newContact.DMS_Client_Id__c != null){
        //Get Account(s) for the DMS client_id
        List<Account> getAccList = [SELECT Id FROM Account WHERE DMS_Client_Id__c =: newContact.DMS_Client_Id__c AND RecordTypeId =: accCustRecTypeId];
        
        if(getAccList != null && getAccList.Size() > 0){
          newContact.AccountId = getAccList[0].Id; 
        }
      }

            if(newContact.Company_Name__c == null) continue;

            if(newContact.Company_Name__c.containsIgnoreCase('Individual')){
                contactsIndividual.add(newContact);
                individualAccountNames.add(newContact.FirstName + ' ' + newContact.LastName);
                continue;
            }

            companyNames.add(newContact.Company_Name__c);
            contactsWithCompanyNames.add(newContact);
        }

        assignAccIdToContacts(individualAccountNames, contactsIndividual);
      
        List<Account> accountsMatchToCompanyNames = [SELECT Id, Name FROM Account WHERE Name IN :companyNames];
        Map<String, Account> accountNameToAccount = new Map<String, Account>();
        for (Account account : accountsMatchToCompanyNames) {
            if(accountNameToAccount.get(account.Name) == null){
                accountNameToAccount.put(account.Name, account);
            }
        }

        Set<String> companyNamesNotMatched = new Set<String>();
        List<Contact> contactsNotMatched = new List<Contact>();
        for(Contact contact : contactsWithCompanyNames){
            if(accountNameToAccount.get(contact.Company_Name__c) != null){
                contact.AccountId = accountNameToAccount.get(contact.Company_Name__c).Id;
            }
            else{
                companyNamesNotMatched.add(contact.Company_Name__c);
                contactsNotMatched.add(contact);
            }
        }
        assignAccIdToContacts(companyNamesNotMatched, contactsNotMatched);

        
        
        
    }
    //Util method
    
    private static void assignAccIdToContacts(Set<String> companyNames, List<Contact> contactsList){
        if(companyNames.isEmpty()) return;

        Map<String, Account> accountNameToAccountToInsert = new Map<String, Account>();
        for(String companyName : companyNames){  
            Account newAccount = new Account(Name = companyName);
            accountNameToAccountToInsert.put(newAccount.Name, newAccount);
        }
        
        if(!accountNameToAccountToInsert.isEmpty()) insert accountNameToAccountToInsert.values();

        for(Contact contact : contactsList){
            if(contact.Company_Name__c.containsIgnoreCase('Individual') && 
                accountNameToAccountToInsert.get(contact.FirstName + ' ' + contact.LastName) != null){
                    contact.AccountId = accountNameToAccountToInsert.get(contact.FirstName + ' ' + contact.LastName).Id;
                    continue;
            }

            if(accountNameToAccountToInsert.get(contact.Company_Name__c) != null){
                contact.AccountId = accountNameToAccountToInsert.get(contact.Company_Name__c).Id;
            }
        }
    }
    //end
    
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Use to store object name...
        String objectName = '';
        //Convert List<Sobject> into List<Contact>...
        List<Contact> conList =(List<Contact>)newList;
        //Check current record type is equal to standard record type or auditor record type...
        if(conList[0].RecordTypeId == SCS_ConstantRTypeReference.standard_Contact_RTId || conList[0].RecordTypeId == SCS_ConstantRTypeReference.auditor_Contact_RTId) {
            objectName = 'Contact';
        }
        //Filter record list...
        List<Contact> contactList = new List<Contact>();
        //Loop each record...
        for(Contact con : conList){
            //Check last modified is not equal to web integrator user or cvent user or admin(...)
            if(con.LastModifiedById != System.Label.Web_Integrator && con.LastModifiedById != System.Label.SCS_CVENT_USER_Id && con.LastModifiedById != System.Label.SCS_ADMIN_USER_Id && String.isNotBlank(con.External_Account_Id__c)){
                //Add filter record into list...
                contactList.add(con); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && objectName !='' && !contactList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(contactList),objectName,'PATCH',''); 
        }   
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Use to store object name...
        String objectName ='';
        //Convert List<Sobject> into List<Contact>...
        List<Contact> conList =(List<Contact>)newList;
        //Check current record type is equal to standard record type or auditor record type...
        if(conList[0].RecordTypeId == SCS_ConstantRTypeReference.standard_Contact_RTId || conList[0].RecordTypeId == SCS_ConstantRTypeReference.auditor_Contact_RTId) {
            objectName = 'Contact';
        }
        //Filter record list...
        List<Contact> contactList = new List<Contact>();
        //Loop each record...
        for(Contact con : conList){
            //Check last modified is not equal to web integrator user or cvent user or admin(...)
            if(con.LastModifiedById != System.Label.Web_Integrator && con.LastModifiedById != System.Label.SCS_CVENT_USER_Id && con.LastModifiedById != System.Label.SCS_ADMIN_USER_Id && String.isNotBlank(con.External_Account_Id__c)){
                //Add filter record into list...
                contactList.add(con); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && !contactList.isEmpty() && objectName !=''){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(contactList),objectName,'PATCH','');
        }
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
    
}