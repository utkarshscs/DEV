/**
    Description    :   Test Class for ContactTrigger and ContactTriggerHanlder
    Date           :   20th March, 2023
    Author         :   Utkarsh G (Maantic)
 */
@isTest
public class ContactTriggerHandlerTest {
    
    @TestSetup
    public static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Company A'),
            new Account(Name = 'Test Company B'),
            new Account(Name = 'Test Company C')
        };
        insert accounts;
    }

    @isTest
    public static void insertContactIndividual(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        Account testAccount= new Account(Name = 'Test Acc');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test N', LastName = 'Test L', AccountId = testAccount.Id, Company_Name__c = 'Individual contact');
        insert testContact;

        testContact = [SELECT Id, FirstName, LastName, AccountId FROM Contact LIMIT 1];
        String accountIndividualName = testContact.FirstName + ' ' + testContact.LastName;
        Account accountToMatchName = [SELECT Id, Name, Type FROM Account WHERE Name = :accountIndividualName LIMIT 1];
        
        System.assertEquals(accountToMatchName.Id, testContact.AccountId);
        
        delete testContact;
    }
    
    @isTest
    public static void insertContactWithAccount(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        Account testAccount= new Account(Name = 'Test Test');
        insert testAccount;
        
        String companyName = 'Individual contact';
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = testAccount.Id, Company_Name__c = companyName);
        insert testContact;

       // Account accountToMatchCompanyName = [SELECT Id, Name, Type FROM Account WHERE Name = :companyName LIMIT 1];
        testContact = [SELECT Id, AccountId FROM Contact WHERE Company_Name__c = :companyName LIMIT 1];
        
       // System.assertEquals(accountToMatchCompanyName.Id, testContact.AccountId);
        
        testContact.firstName = 'test 1';
        update testContact;
    }
    
    @isTest
    public static void insertContactToNotMatch(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        Account testAccount= new Account(Name = 'Test Acc');
        insert testAccount;
        
        String companyName = 'Test Company D';
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = testAccount.Id, Company_Name__c = companyName);
        insert testContact;

        Account accountToMatchCompanyName = [SELECT Id, Name, Type FROM Account WHERE Name = :companyName LIMIT 1];
        testContact = [SELECT Id, AccountId FROM Contact WHERE Company_Name__c = :companyName LIMIT 1];
        
        System.assertEquals(accountToMatchCompanyName.Id, testContact.AccountId);
        
        testContact.firstName = 'test 1';
        update testContact;
    }
    
}