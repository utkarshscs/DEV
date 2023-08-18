@isTest
public class FnA_ScheduleCreditMemoLine_Test {
    
    @TestSetup
    static void makeData(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
        
        Id oppRT_Id = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
        Id accRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Id contactRT_Id = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        List<Account> accList = SCS_TestDataFactory.createAccounts(accRT_Id,1);
        accList[0].Type ='Customer';
        accList[0].Quickbooks_ID__c ='QUICKBOOKID';
        insert accList;
        
        List<Contact> contacts = SCS_TestDataFactory.createContacts(accList[0].Id,contactRT_Id,1);
        insert contacts;
        
        List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
        programs[0].name = 'SQF';
        programs[0].SCS_Global_QB_Entity__c = true;
        insert programs;
        
        List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
        insert pcs;
        
        List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntity(1);
        entitys[0].fw1__Payment_Center_Setting__c = pcs[0].Id;
        entitys[0].Name = 'SCS Global';
        insert entitys;
        
        List<Campaign> camp = SCS_TestDataFactory.createCampaing(1);
        insert camp;
        
        List<Opportunity> opportunity = SCS_TestDataFactory.createOpportunity('Closed Won', accList[0].Id,programs[0].Id,oppRT_Id,Date.Today(),1);
        opportunity[0].fw2__Entity__c = entitys[0].Id;
        opportunity[0].CampaignId = camp[0].Id;
        opportunity[0].Billing_Contact__c = contacts[0].Id;
        insert opportunity;
        
        List<fw1__PaymentProfile__c> paymentProfile = SCS_TestDataFactory.createPaymentProfiles(accList[0].Id,entitys[0].Id,1);
        insert paymentProfile;
        
        List<fw1__Invoice__c> invoice = SCS_TestDataFactory.createInvoice(1);
        invoice[0].fw1__Entity__c = entitys[0].Id;
        invoice[0].fw1__Payment_Profile__c = paymentProfile[0].Id;
        invoice[0].fw1__Account__c = accList[0].Id;
        invoice[0].fw1__Contact__c = contacts[0].Id;
        invoice[0].fw1__Opportunity__c = opportunity[0].Id;
        insert invoice;
        
        List<fw1__Credit_Memo__c> creditMemo = SCS_TestDataFactory.createCreditMemo(1,accList[0].Id);
        creditMemo[0].fw1__Contact__c = contacts[0].Id;
        creditMemo[0].fw1__Entity__c = entitys[0].Id;
        creditMemo[0].fw1__Generated_From__c = invoice[0].Id;
        insert creditMemo;
        
        List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
        insert prodListDummy;
        
        List<fw1__Credit_Memo_Line__c> creditMemoLine = SCS_TestDataFactory.createCreditMemoLines(creditMemo[0].Id,prodListDummy[0].Id,1);
        creditMemoLine[0].Name = 'CMLINE';
        insert creditMemoLine;
        
    }
    
    @isTest static void creditMemoTest(){
        List<User> integratorUser = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(), 1);
        System.runAs(integratorUser[0]){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            FnA_ScheduleCreditMemoLine obj = new FnA_ScheduleCreditMemoLine ();
            obj.execute(null);
            Test.stopTest();
        }
        
    }
    
}