/**
Description    :   Handler for Contact Trigger
Date           :   21st March, 2023
Author         :   Utkarsh G (Maantic)
Test Class     :   ContactTriggerHandlerTest
*/
public class ContactTriggerHandler {
    
    public static void beforeInsert(List<Contact> newContactsList){
        
        Boolean isDoceboUser = UserInfo.getUserId() == Label.Docebo_UserId ? True : False;
        
        System.debug('Called');
        if(isDoceboUser || Test.isRunningTest()){
            Set<String> companyNames = new Set<String>();
            List<Contact> contactsWithCompanyNames = new List<Contact>();
            
            List<Contact> contactsIndividual = new List<Contact>();
            List<Contact> contactsIndividualNotMatched = new List<Contact>();
            Set<String> individualAccountNames = new Set<String>();
            Set<String> individualAccountNamesNotMatched = new Set<String>();
            Map<String, String> contactBillToCountryMap = new Map<String,String>();
            Map<String, Account> individualAccountNameToAccount = new Map<String, Account>();
            Map<String, Id> mapDMSAccount = new Map<String, Id>(); 
            Set<String> dmsClientIdSet = new Set<String>();
            for(Contact newContact : newContactsList){
                if(newContact.Company_Name__c == null) continue;
                
                
                if(newContact.Company_Name__c.containsIgnoreCase('Individual')){
                    contactBillToCountryMap.put(newContact.FirstName + ' ' + newContact.LastName, newContact.MailingCountryCode);
                    contactsIndividual.add(newContact);
                    individualAccountNames.add(newContact.FirstName + ' ' + newContact.LastName);
                    continue;
                } 
                
                companyNames.add(newContact.Company_Name__c);
                contactsWithCompanyNames.add(newContact);
                
                if(newContact.DMS_Client_Id__c != null){
                    dmsClientIdSet.add(newContact.DMS_Client_Id__c);
                }
            }
            
            //Get Account(s) for the DMS client_id
            Id accCustRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
            if(!dmsClientIdSet.isEmpty()){
                for(Account acc :[SELECT Id, DMS_Client_Id__c FROM Account WHERE DMS_Client_Id__c IN: dmsClientIdSet AND RecordTypeId =: accCustRecTypeId]){
                    if(!mapDMSAccount.containsKey(acc.DMS_Client_Id__c)){
                        mapDMSAccount.put(acc.DMS_Client_ID__c, acc.Id);
                    }
                }
            }
            
            if(!mapDMSAccount.isEmpty()){
                for(Contact newContact : newContactsList){
                    newContact.AccountId = mapDMSAccount.containsKey(newContact.DMS_Client_Id__c) && mapDMSAccount.get(newContact.DMS_Client_Id__c) != null ? mapDMSAccount.get(newContact.DMS_Client_Id__c) : null;
                }
            }
            
            if(individualAccountNames.size() > 0){
                
                for(Account acc : [SELECT Id, Name FROM Account WHERE Name IN :individualAccountNames]){
                    if(individualAccountNameToAccount.get(acc.Name) == null){
                        individualAccountNameToAccount.put(acc.Name, acc);
                    }    
                }
                System.debug('$$$$$ ' + individualAccountNameToAccount);
                for(Contact contact : contactsIndividual){
                    if(individualAccountNameToAccount.get(contact.FirstName + ' ' + contact.LastName) != null){
                        contact.AccountId = individualAccountNameToAccount.get(contact.FirstName + ' ' + contact.LastName).Id;
                    }
                    else{
                        individualAccountNamesNotMatched.add(contact.FirstName + ' ' + contact.LastName);
                        contactsIndividualNotMatched.add(contact);
                        
                    }
                }
                
            }
            if(individualAccountNamesNotMatched.size() > 0)
                assignAccIdToContacts(individualAccountNamesNotMatched, contactsIndividualNotMatched,contactBillToCountryMap);
            
            System.debug('Called 2');
            Id customerSiteRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Site').getRecordTypeId();
            List<Account> accountsMatchToCompanyNames = [SELECT Id, Name FROM Account WHERE Name IN :companyNames and RecordTypeId != :customerSiteRT];
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
                    System.debug('Called 2 IFFF' + accountNameToAccount);
                    contact.AccountId = accountNameToAccount.get(contact.Company_Name__c).Id;
                }
                else{
                    companyNamesNotMatched.add(contact.Company_Name__c);
                    contactsNotMatched.add(contact);
                    contactBillToCountryMap.put(contact.Company_Name__c, contact.MailingCountryCode);
                    
                }
            }
            System.debug('companyNamesNotMatched ' + companyNamesNotMatched);
            assignAccIdToContacts(companyNamesNotMatched, contactsNotMatched,contactBillToCountryMap);
        }
        
    }
    
    private static void assignAccIdToContacts(Set<String> companyNames, List<Contact> contactsList,  Map<String, String> contactBillToCountryMap){
        if(companyNames.isEmpty()) return;
        
        System.debug('Called 3');
        Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        System.debug('%%%%%%%% Individual assignAccIdToContacts ' );
        Map<String, Account> accountNameToAccountToInsert = new Map<String, Account>();
        for(String companyName : companyNames){
            Account newAccount = new Account(Name = companyName, Type = 'Other', BillingCountryCode = contactBillToCountryMap.get(companyName),
                                             RecordTypeId = customerRT);
            accountNameToAccountToInsert.put(newAccount.Name, newAccount);
        }
        
        if(!accountNameToAccountToInsert.isEmpty()) 
            insert accountNameToAccountToInsert.values(); 
        
        for(Contact contact : contactsList){
            if(contact.Company_Name__c.containsIgnoreCase('Individual') && 
               accountNameToAccountToInsert.get(contact.FirstName + ' ' + contact.LastName) != null){
                   contact.AccountId = accountNameToAccountToInsert.get(contact.FirstName + ' ' + contact.LastName).Id;
                   System.debug('%%%%%%%% Individual contact ' + contact );
                   continue;
               }
            
            if(accountNameToAccountToInsert.get(contact.Company_Name__c) != null){
                contact.AccountId = accountNameToAccountToInsert.get(contact.Company_Name__c).Id;
                System.debug('%%%%%%%% Individual contact.AccountId ' + contact.AccountId);
            }
        }
    }
}