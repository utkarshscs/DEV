/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : FnA_InvoiceLineSchedular_Test
* Related Class Name: FnA_InvoiceLineSchedular
* Division          : FnA
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : This schedular use to sync fw1__Invoice_Line__c in evey 20 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        30-01-2023                          Initial version 
************************************************************************************************************************************/

@isTest
public class FnA_InvoiceLineSchedular_Test {
    //Setup data...
    @testSetup static void setup() {
        //Create web integrator user...
        List<User> userList = SCS_TestDataFactory.createUser('Sales User',1);
        userList[0].Username ='salesuser@scsuser.com';
        insert userList;
        System.runAs(userList[0]){
            //Set Mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Insert account...
            List<Account> accList = SCS_TestDataFactory.createAccounts(SNM_TestConstant.customerAccRTId,1);
            insert accList;
            
            //Insert Contact...
            List<Contact> contacts = SCS_TestDataFactory.createContacts(accList[0].Id,SNM_TestConstant.customerConRTId,1);
            insert contacts;
            
            //Insert Program...
            List<Program__c> programs = SCS_TestDataFactory.createPrograms(1);
            programs[0].name = 'SQF';
            programs[0].SCS_Global_QB_Entity__c = true;
            insert programs;
            
            //Create payment Center Setting...
            List<fw1__Payment_Center_Setting__c> pcs = SCS_TestDataFactory.createPaymentCenterSettings(1);
            insert pcs;
            //Create scs global entity...
            List<fw1__Entity__c> entitys = SCS_TestDataFactory.createEntity(1);
            entitys[0].fw1__Payment_Center_Setting__c = pcs[0].Id;
            insert entitys;
            //Insert Campaign...
            List<Campaign> camp = SCS_TestDataFactory.createCampaing(1);
            insert camp;
            //Insert Opportunity...
            List<Opportunity> opportunity = SCS_TestDataFactory.createOpportunity('Closed Won', accList[0].Id,programs[0].Id,SNM_TestConstant.eCSOppoRTId,Date.Today(),1);
            opportunity[0].fw2__Entity__c = entitys[0].Id;
            opportunity[0].CampaignId = camp[0].Id;
            opportunity[0].Billing_Contact__c = contacts[0].Id;
            insert opportunity;
            //Insert payment Profile...
            List<fw1__PaymentProfile__c> paymentProfile = SCS_TestDataFactory.createPaymentProfiles(accList[0].Id,entitys[0].Id,1);
            insert paymentProfile;
            //Insert Invoice...
            List<fw1__Invoice__c> invoice = SCS_TestDataFactory.createInvoice(1);
            invoice[0].fw1__Entity__c = entitys[0].Id;
            invoice[0].fw1__Payment_Profile__c = paymentProfile[0].Id;
            invoice[0].fw1__Account__c = accList[0].Id;
            invoice[0].fw1__Contact__c = contacts[0].Id;
            invoice[0].fw1__Opportunity__c = opportunity[0].Id;
            insert invoice;
            //
            PriceBook2 pb2=new PriceBook2();
            pb2.Name = 'test';
            pb2.IsActive = true;      
            insert pb2;
            //Insert product...
            List<Product2> prodListDummy = SCS_TestDataFactory.createProduct(1,'P - Professional Fees','USD');
            insert prodListDummy;
            //Insert Invoice line...
            List<fw1__Invoice_Line__c> invoiceLine = SCS_TestDataFactory.createInvoiceLines(prodListDummy[0].Id,pb2.Id,invoice[0].Id,1);
            invoiceLine[0].Name = 'IL';
            insert invoiceLine;
            
            FnA_InvoiceLineSchedular obj = new FnA_InvoiceLineSchedular();
            obj.execute(null);
            
        }
        
    }
    
    @isTest static void testInvoiceLineSchedular() {
        Test.startTest();
        //Query web integrator user...
        User usr =[SELECT Id FROM User WHERE Username = 'salesuser@scsuser.com' LIMIT 1];
        System.runAs(usr){
            //Set mock response...
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass());
            //Get records ...
            //List<fw1__Invoice_Line__c> recordList =[SELECT Id,Name,External_Record_Id__c FROM fw1__Invoice_Line__c];
            //Verify the response...
            //System.assertEquals('external-Id',recordList[0].External_Record_Id__c,'External Record should not be blank');
        }
        Test.stopTest();  
    }
    
}