/*
@Author : MAANTIC
@CreatedDate : 3rd JUN 2022
@Description : Test Data Factory class use to create User,Account,Contact,Project,Project Stakeholder and Project comment.
*/
@isTest
public class SCS_TestDataFactory {


    // Get System Integrator profile Id
    // Created a custom label for system Integrator profile.
    // Change the value in Custom Label if profile is changed
    public static Id getSystemIntegratorProfile(){
        return [Select Id FROM Profile Where Name = :Label.System_Integrator_For_Test].Id;
    }
    
    public static User getWebIntegratorUser(){
        return [Select Id FROM User Where Id = :System.Label.Web_Integrator];
    }
    public static User getCventUser(){
        return [Select Id FROM User Where Id = :System.Label.SCS_CVENT_USER_Id];
    }
    public static User getProfile( String profileId){
        return [Select Id FROM User Where Id = :profileId];
    }

    //Create Users...
    public static List<User> createUsers(String profileId,Integer recordCount){
        List<User> userList = new List<User>();
        for(Integer i=0;i<recordCount;i++) {
            User usr = new User();
            usr.FirstName = 'Sys';
            usr.LastName = 'Admin';
            usr.Email = 'sys.admin'+i+'@gmail.com';
            usr.Username = 'sys.admin'+i+'@gmail.com';
            usr.Alias = 'sysadmuk';
            usr.ProfileId = profileId;
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.LocaleSidKey = 'en_US';
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.Entities__c ='ECS';
            userList.add(usr);
        }   
        return userList;
    }
    /****************************
     * @Author      : Umesh Kumar
     * Mehtod Name  : createUser
     * Modified Date:21-10-2022
     ****************************/
    //Create Users...
    public static List<User> createUser(String profileName,Integer recordCount){
        Profile  pId =[SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1];
        List<User> userList = new List<User>();
        for(Integer i=0;i<recordCount;i++) {
            User usr = new User();
            usr.FirstName = 'Sys';
            usr.LastName = 'Admin';
            usr.Email = 'sys.admin'+i+'@gmail.com';
            usr.Username = 'sys.admin'+i+'@gmail.com';
            usr.Alias = 'sysadmuk';
            usr.ProfileId = pId.Id;
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.LocaleSidKey = 'en_US';
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            userList.add(usr);
        }   
        return userList;
    }
    
    //Create Site_Covered__c ...
    public static List<Site_Covered__c> createSiteCovered(String oppoId,Integer recordCount){
        List<Site_Covered__c> recordList = new List<Site_Covered__c>();
        for(Integer i=0;i<recordCount;i++) {
            Site_Covered__c record = new Site_Covered__c();
            record.Opportunity__c = oppoId;
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create Account...
    public static List<Account> createAccounts(String recordTId,Integer recordCount){
        List<Account> accountList = new List<Account>();
        for(Integer i=0;i<recordCount;i++) {
            Account acc = new Account();
            acc.Name ='AccountName'+i;
            acc.BillingCountry = 'Denmark';
            acc.RecordTypeId = recordTId;
            accountList.add(acc);
        }   
        return accountList;
    }
    
    //Create Contact...
    public static List<Contact> createContacts(String accId,String recordTId,Integer recordCount){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<recordCount;i++) {
            Contact con = new Contact();
            con.FirstName ='ContactFN'+i;
            con.LastName ='ContactLN'+i;
            con.Email ='pcomment'+i+'@pc.com';
            con.RecordTypeId = recordTId;
            con.AccountId = accId;
            contactList.add(con);
        }   
        return contactList;
    }

    //Create Lead
    public static List<Lead> createLead(Integer recordCount, String status, Id recordTId){
        List<Lead> leadList = new List<Lead>();
        Lead ld;
        for(Integer i=0;i<recordCount;i++) {
            ld = new Lead();
            ld.LastName ='Lead_'+i;
            ld.Company ='Company_'+i;
            ld.RecordTypeId = recordTId;
            ld.Status = status;
            ld.Email = 'test_'+i + '@test.com';
            leadList.add(ld);
        }   
        return leadList;
    }
    
    // Create Program
    public static List<Program__c> createPrograms(Integer recordCount){
        List<Program__c> programList = new List<Program__c>();
        for(Integer i=0;i<recordCount;i++) {
            Program__c pro = new Program__c();
            pro.name = 'Test Program'+i;
          //  pro.Engagement_Type__c = 'Initial';
            pro.Status__c = 'Active';
            pro.Entity__c = 'ECS';
            pro.Type__c = 'Program';
            pro.G_A__c = 10;
            pro.Commission__c = 10; 
            programList.add(pro);
        }
        return programList;
    }
    
    //Create Goal..
    public static List<Goal__c> createGoalRecord(String recordTId,String progId,String qaarter, String Year, Integer recordCount){
        List<Goal__c> goalList = new List<Goal__c>();
        for(Integer i=0;i<recordCount;i++) {
            Goal__c goal = new Goal__c();
            goal.Programc__c = progId;
            goal.RecordTypeId = recordTId;
            goal.Quarter__c = qaarter;
            goal.year__c = year;
            goalList.add(goal);
        }   
        return goalList;
    }
    
    
    //Create Opportunity...
    public static List<Opportunity> createOpportunity(String stage,String accId,String programId, String recordTId, Date clsDate, Integer recordCount){
        List<Opportunity> OppList = new List<Opportunity>();
        for(Integer i=0;i<recordCount;i++) {
            Opportunity opp = new Opportunity();
            opp.Name ='OppName'+i;
            opp.RecordTypeId = recordTId;
            opp.AccountId = accId;
            opp.StageName = stage;
            opp.Programc__c = programId;
            opp.CloseDate = clsDate;
            OppList.add(opp);
        }   
        return OppList;
    }   
    

    public static List<OpportunityLineItem> createOpportunityLI(Id opptyId, Id pbEntryId, Integer recordCount){
        List<OpportunityLineItem> OppList = new List<OpportunityLineItem>();
        OpportunityLineItem oli;
        for(Integer i=0;i<recordCount;i++) {
            oli = new OpportunityLineItem();
            oli.Description ='OppName'+i;
            oli.OpportunityId = opptyId;
            oli.Quantity = 2;
            oli.PricebookEntryId = pbEntryId;
            OppList.add(oli);
        }   
        return OppList;
    }
    
    
    //Product
    public static List<Product2> createProduct(Integer recCount, String revenueType, String cur){

        List<Product2> prodList = new List<Product2>();
        Product2 prod;

        for(Integer i=0;i<recCount;i++) {
            prod = new Product2();
            prod.Name ='Product_'+i;
            prod.Revenue_Type__c = revenueType;
          //  prod.CurrencyIsoCode = cur;
            prod.External_Record_Id__c = '';
            prodList.add(prod);
        }
        return prodList;
    }
   
    //Certification dummy data zone
    //NORMAL CERTIFICATION
    public static List<Certificate__c> createCertificate(Integer recCount){

        List<Certificate__c> certList = new List<Certificate__c>();
        Certificate__c cert;

        for(Integer i=0;i<recCount;i++) {
            cert = new Certificate__c();
            cert.ValidFrom__c = Date.Today();
            certList.add(cert);
        }
        return certList;
    }
    
      //Opportunity certificate
   @testVisible public static List<Opportunity_certificate__c> createOppsCertificate(certificate__c cid,List<Opportunity> opMain)
    {
        List<Opportunity_certificate__c> ocl = new List<Opportunity_certificate__c>();
        Opportunity_certificate__c oct;
        for(Opportunity opm:opMain)
        {
            oct = new Opportunity_certificate__c();
            oct.Opportunity__c =  opm.id;
            oct.Certificate__c = cid.Id;
            oct.Account__c = opm.accountid;
  			oct.Certificate_Type__c = 'Account-Owned';
            oct.Certificate_Status__c = 'Issued';
            oct.Certification_Type__c = 'Initial';  
            oct.Certificate_Issue_Date__c = Date.today();
            oct.End_date_of_current_certificate__c = Date.today().addYears(1);
                                                                          
            ocl.add(oct);
            System.debug('OPP CERTIFICATE' + ocl);
            
        }
        return ocl;
        
    }
    //Certified Sites
	public static List<Certified_Sites__c> createCertifiedSites(List<Opportunity_certificate__c> oclist)
    {
        List<Certified_Sites__c> cslist = new List<Certified_Sites__c>();
        for(Opportunity_certificate__c cm:oclist)
        {
            Certified_Sites__c cs = new Certified_Sites__c();
            cs.Account__c = cm.account__c;
            cs.Certificate__c = cm.certificate__c;
            cs.CustomerSite__c = cm.Account__c;
            cs.OpportunityCertificate__c = cm.id;
            cslist.add(cs);
        }
        return cslist;
    }
    //Certified Products
    
    
    public static List<fw1__Payment_Activity__c> createPaymentActivitys(Id paymentId,Id invoiceId,Integer recordCount){
        List<fw1__Payment_Activity__c> recordList = new List<fw1__Payment_Activity__c>();
        for(Integer i=0;i<recordCount;i++) {
            fw1__Payment_Activity__c record = new fw1__Payment_Activity__c();
            record.Name = 'PAYMENT Activity'+i;
            record.fw1__Payment__c = paymentId;
            record.fw1__Invoice__c = invoiceId;
            recordList.add(record);
        }
        return recordList;
    }

    public static List<fw1__Credit_Memo__c> createCreditMemo(Integer recCount, String accountId){

        List<fw1__Credit_Memo__c> creditMList = new List<fw1__Credit_Memo__c>();
        fw1__Credit_Memo__c creditM;

        for(Integer i=0;i<recCount;i++) {
            creditM = new fw1__Credit_Memo__c();
            creditM.fw1__Description__c ='Credit_'+i;
            creditM.fw1__Account__c =accountId;
            creditMList.add(creditM);
        }
        return creditMList;
    }

    public static List<fw1__Credit_Memo_Line__c> createCreditMemoLines(String creditMemoId,String productId,Integer recordCount){
        List<fw1__Credit_Memo_Line__c> recordList = new List<fw1__Credit_Memo_Line__c>();
        for(Integer i=0;i<recordCount;i++) {
            fw1__Credit_Memo_Line__c record = new fw1__Credit_Memo_Line__c();
            record.Name = 'SCSCreditMemoline'+i;
            record.fw1__Credit_Memo__c = creditMemoId;
            record.fw1__Quantity__c = 1;
            record.fw1__Unit_Price__c = 100;
            record.fw1__Product__c = productId;
            recordList.add(record);
        }
        return recordList;
    }

    public static List<fw1__Entity__c> createEntity(Integer recCount){

        List<fw1__Entity__c> entList = new List<fw1__Entity__c>();
        fw1__Entity__c ent;

        for(Integer i=0;i<recCount;i++) {
            ent = new fw1__Entity__c();
            ent.Name ='Entity_'+i;
            entList.add(ent);
        }
        return entList;
    }

    public static List<fw1__Payment__c> createPayment(Integer recCount, String credMemo){

        List<fw1__Payment__c> paymentList = new List<fw1__Payment__c>();
        fw1__Payment__c payment;

        for(Integer i=0;i<recCount;i++) {
            payment = new fw1__Payment__c();
            payment.Name ='Payment_'+i;
            payment.fw1__Credit_Memo__c = credMemo;
            paymentList.add(payment);
        }
        return paymentList;
    }

    public static List<fw1__Invoice__c> createInvoice(Integer recCount){

        List<fw1__Invoice__c> invoiceList = new List<fw1__Invoice__c>();
        fw1__Invoice__c invoice;

        for(Integer i=0;i<recCount;i++) {
            invoice = new fw1__Invoice__c();
            invoice.fw1__Email_CC_Recipients__c ='Invoice_'+i+ '@test.com';
            invoiceList.add(invoice);
        }
        return invoiceList;
    }

    public static List<fw1__Invoice_Line__c> createInvoiceLines(String productId,String pbookId,String invoiceId,Integer recordCount){
        List<fw1__Invoice_Line__c> recordList = new List<fw1__Invoice_Line__c>();
        for(Integer i=0;i<recordCount;i++) {
            fw1__Invoice_Line__c record = new fw1__Invoice_Line__c();
            record.Name = 'InvoiceLine'+i;
            record.fw1__Product2__c = productId;
            record.fw1__Price_Book__c = pbookId;
            record.fw1__Invoice__c = invoiceId;
            recordList.add(record);
        }
        return recordList;
    }
 
    public static List<fw1__Payment__c> createPayment(Integer recCount){

        List<fw1__Payment__c> paymentList = new List<fw1__Payment__c>();
        fw1__Payment__c pay;

        for(Integer i=0;i<recCount;i++) {
            pay = new fw1__Payment__c();
            pay.Name ='Payment_'+i;
            pay.fw1__Payment_Date__c = Date.TODAY();
            paymentList.add(pay);
        }
        return paymentList;
    }

    public static List<Campaign> createCampaing(Integer recCount){

        List<Campaign> campList = new List<Campaign>();
        Campaign camp;

        for(Integer i=0;i<recCount;i++) {
            camp = new Campaign();
            camp.Name ='Test';
            campList.add(camp);
        }
        return campList;
    }

    public static List<CampaignMember> createCampaingMember(Integer recCount, String campid, Id con){

        List<CampaignMember> campMemList = new List<CampaignMember>();
        CampaignMember camp;

        for(Integer i=0;i<recCount;i++) {
            camp = new CampaignMember();
            camp.CampaignId =campid;
            camp.ContactId = con;
            camp.Status = 'Responded';
            campMemList.add(camp);
        }
        return campMemList;
    }

    public static List<PricebookEntry> createPriceBookEntry(Id pbId, Id prodId){

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry pbe;
																																								
        pbe = new PricebookEntry();
        pbe.pricebook2id =pbId;
        pbe.product2id = prodId;
        pbe.unitprice = 2.0;
        pbe.isActive = TRUE;
        pbeList.add(pbe);

        return pbeList;
    }
    
    // get standard pricebook
    public static PriceBook2 getStandardPriceBook(){
        Pricebook2 standardPricebook = new Pricebook2(
                                                Id = Test.getStandardPricebookId(),
                                                IsActive = true
                                            );
        return standardPricebook;
    }
    
    //Create payment center setting...
    public static List<fw1__Payment_Center_Setting__c> createPaymentCenterSettings(Integer recordCount){
        List<fw1__Payment_Center_Setting__c> recordList = new List<fw1__Payment_Center_Setting__c>(); 
        for(Integer i=0;i<recordCount;i++) {
            fw1__Payment_Center_Setting__c record = new fw1__Payment_Center_Setting__c();
            record.Name = 'Default Settings';
            record.fw1__Attach_Terms_And_Conditions__c =  true;
            record.fw1__Batch_Invoice_Default_Template__c = 'Invoice Template - Batch';
            record.fw1__CC_Receipt_To_Invoice_CC_Recipients__c = true;
            record.fw1__Close_Out_Invoice_Default__c = 'True';
            record.fw1__CreditCard_Expiry_Template_2__c = 'Credit Card Expiration Reminder - Installments';
            record.fw1__CreditCard_Expiry_Template__c = 'Credit Card Expiration Reminder - Recurring';
            record.fw1__Credit_Card_Surcharge_Label__c ='Convenience fee';
            record.fw1__Custom_Css__c = 'OnlinePaymentCss';
            record.fw1__Default_Payment_Method__c = 'Credit Card';
            record.fw1__Disable_Email_Signature__c = true;
            record.fw1__Display_Profile_By_Contact__c = true;
            record.fw1__Dunning_Age__c =30;
            record.fw1__Email_Currency_Symbol__c ='$';
            record.fw1__Email_me_a_copy_of_invoice__c = true;
            record.fw1__Enable_Check__c = true;
            record.fw1__Enable_Credit_Card__c = true;
            record.fw1__Enable_More_Payment_Methods__c = true;
            record.fw1__Enable_Payment_With_Credit_Memo__c = true;
            record.fw1__Enforce_Internal_CRUD_And_FLS__c = true;
            record.fw1__Failed_Attempt1__c = '3';
            record.fw1__Failed_Auto_Payment_Template__c = 'Failed Automatic Payment';
            record.fw1__Invoice_Owner_Inherits_Recurring_Owner__c = true;
            record.fw1__Invoice_Template__c = 'Invoice Template';
            record.fw1__Is_Auto_Submit_On_Swipe__c = true;
            record.fw1__Notification_Email__c ='maantic.tech@maantic.com';
            record.fw1__Online_Payment_Type__c = 'Charge';
            record.fw1__Require_Credit_Memo__c = true;
            record.fw1__Second_Line__c ='fw1__Item_Description__c';
            record.fw1__Selected_Invoice_Line_Fields__c = 'Name,fw1__Quantity__c,fw1__Discount_Percentage__c,fw1__Discount_Amount__c,fw1__Total_Discount_Amount__c,fw1__Unit_Price__c,fw1__Amount__c';
            record.fw1__Sender_Display_Name__c = 'SCS Global Services';
            record.fw1__Statement_Default_Template__c = 'Account Statement';
            record.fw1__Store_Credit_Card__c = true;
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create Entity...
    public static List<fw1__Entity__c> createEntitys(String pcsId,Integer recordCount){
        List<fw1__Entity__c> recordList = new List<fw1__Entity__c>();
        for(Integer i=0;i<recordCount;i++) {
            fw1__Entity__c record = new fw1__Entity__c();
            record.Name = 'SCSEntity'+i;
            record.fw1__Payment_Center_Setting__c = pcsId;
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create Payment Profile...
    public static List<fw1__PaymentProfile__c> createPaymentProfiles(String accId,String entityId,Integer recordCount){
        List<fw1__PaymentProfile__c> recordList = new List<fw1__PaymentProfile__c>();
        for(Integer i=0;i<recordCount;i++) {
            fw1__PaymentProfile__c record = new fw1__PaymentProfile__c();
            record.Name = 'PaymentProfile'+i;
            record.fw1__Account__c = accId;
            record.fw1__Requesting_Entity__c = entityId;
            recordList.add(record);
        }
        return recordList;
    }
      
     //Create Standard...
    public static List<Standard__c> createStandard(String programId,Integer recordCount){
        List<Standard__c> stdList = new List<Standard__c>();
        for(Integer i=0;i<recordCount;i++) {
            Standard__c std = new Standard__c();
            std.Name ='Standard'+i;
            std.DefaultStandard__c = true;
            std.Program__c = programId;
            std.Status__c = 'Active';
            stdList.add(std);
        }   
        return stdList;
    }
    
    //Create Standard Covered...
    public static List<Standard_Covered__c> createStandardCovered(String oppoId,String standardId,Integer recordCount){
        List<Standard_Covered__c> recordList = new List<Standard_Covered__c>();
        for(Integer i=0;i<recordCount;i++) {
            Standard_Covered__c record = new Standard_Covered__c();
            record.Opportunity__c = oppoId;
            record.Standard__c = standardId;
            recordList.add(record);
        }   
        return recordList;
    }
    
    //Create Project...
    public static List<inspire1__Project__c> createProject(String accId, String oppId, Integer recordCount){
        List<inspire1__Project__c> recordList = new List<inspire1__Project__c>();
        for(Integer i=0;i<recordCount;i++) {
            inspire1__Project__c record = new inspire1__Project__c();
            record.Name = 'Project '+i;
            record.inspire1__Opportunity1__c = oppId;
            record.inspire1__Account__c = accId;
            recordList.add(record);
        }   
        return recordList;
    }


    //Create Lock periodData...
    public static List<Lock_Out_Period__c> createLockPeriod(Integer recordCount){
        List<Lock_Out_Period__c> recordList = new List<Lock_Out_Period__c>();
        Lock_Out_Period__c lop;
        for(Integer i=0;i<recordCount;i++) {
            lop = new Lock_Out_Period__c();
            lop.Name = 'LP '+i;
            lop.Start_Date__c = Date.today();
            lop.End_Date__c = Date.today().addDays(160);
            lop.Locked__c = false;
            recordList.add(lop);
        }   
        return recordList;
    }
    
     //Create Scope__c ...
    public static List<Scope__c> createScope(Integer recordCount){
        List<Scope__c> recordList = new List<Scope__c>();
        for(Integer i=0; i<recordCount; i++) {
            Scope__c record = new Scope__c(); 
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create OpportunityTeamMember ...
    public static List<OpportunityTeamMember> createOppTeamMembers(String oppId, Integer recordCount){
        List<OpportunityTeamMember> recordList = new List<OpportunityTeamMember>();
        for(Integer i=0; i<recordCount; i++) {
            OpportunityTeamMember record = new OpportunityTeamMember(); 
            record.OpportunityId = oppId; 
            record.UserId = UserInfo.getUserId();
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create OpportunityContactRoles ...
    public static List<OpportunityContactRole> createOppContactRoles(String oppId, string conId, Integer recordCount){
        List<OpportunityContactRole> recordList = new List<OpportunityContactRole>();
        for(Integer i=0; i<recordCount; i++) {
            OpportunityContactRole record = new OpportunityContactRole(); 
            record.OpportunityId = oppId; 
            record.ContactId = conId;
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create Opportunity_Certificate__c ...
    public static List<Opportunity_Certificate__c> createOppCertificates(String oppId, Integer recordCount){
        List<Opportunity_Certificate__c> recordList = new List<Opportunity_Certificate__c>();
        for(Integer i=0; i<recordCount; i++) {
            Opportunity_Certificate__c record = new Opportunity_Certificate__c(); 
            record.Opportunity__c = oppId; 
            record.Date_of_Audit__c = Date.Today().addMonths(1);
            record.Date_of_issuing__c = Date.Today().addYears(-1);
            record.Anniversary_Date__c = Date.Today().addYears(-2);
            record.Date_of_Next_Recertification_Audit__c = Date.Today().addYears(1);
            
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create CertifiedProducts__c ...
    public static List<CertifiedProducts__c> createOppCertifiedProds(String oppCertId, Integer recordCount){
        List<CertifiedProducts__c> recordList = new List<CertifiedProducts__c>();
        for(Integer i=0; i<recordCount; i++) {
            CertifiedProducts__c record = new CertifiedProducts__c(); 
            record.OpportunityCertificate__c = oppCertId;             
            recordList.add(record);
        }
        return recordList;
    }

    public static ID getSCSEntity (){
        return [SELECT Id,name from fw1__Entity__c where name='SCS Global' LIMIT 1].Id;
    }
    /*
    //Create Customer Risks
    public static List<Customer_Risk__c> createCustomerRisks(String accId, Integer recordCount){
        List<Customer_Risk__c> customerRiskList = new List<Customer_Risk__c>();
        for(Integer i=0;i<recordCount;i++) {
            Customer_Risk__c cr = new Customer_Risk__c();
            cr.Category__c = 'Resources';
            cr.Date_Closed__c = Date.Today().addMonths(4);
            cr.Date_Opened__c = Date.Today().addMonths(1);
            cr.Impact_Description__c = 'Test';
            cr.Impact_Level__c = '2';
            cr.Mitigation_Notes__c = 'Test';
            cr.OwnerId = UserInfo.getUserId();
            cr.Probability_Level__c = '3'; 
            cr.Customer__c = accId;
            cr.Risk_Description__c = 'Test';
            cr.Risk_Status__c = 'Active';
            cr.Type__c = 'Risk';
            customerRiskList.add(cr);
        }   
        return customerRiskList;
    }
    */
    //Create projectTask ...
    public static List<inspire1__Project_Tasks__c> createProjectTask( Id projectId, Integer recordCount){

        List<inspire1__Project_Tasks__c> recordList = new List<inspire1__Project_Tasks__c>();
        inspire1__Project_Tasks__c record; 
        Date dt = System.today();
        for(Integer i=0; i<recordCount; i++) {
            record = new inspire1__Project_Tasks__c(); 
            record.Name = 'Task ' + i;             
            record.inspire1__Project__c = projectId;
            record.inspire1__StartDate__c = System.today();
            record.inspire1__FinishDate__c = dt.addDays(4);
            recordList.add(record);
        }
        return recordList;
    }
     //Create CAP ...
   /* public static List<Corrective_Action_Plan__c> createCAPData(String capStatus, Id projectId, Id projectTaskId, Integer recordCount){

        List<Corrective_Action_Plan__c> recordList = new List<Corrective_Action_Plan__c>();
        Corrective_Action_Plan__c record; 

        for(Integer i=0; i<recordCount; i++) {
            record = new Corrective_Action_Plan__c(); 
            record.CAPStatus__c = capStatus;             
            record.Project__c = projectId;             
            record.ProjectTask__c = projectTaskId;             
            recordList.add(record);
        }
        return recordList;
    }*/
    
   //Create COI ...
     public static List<Conflict_of_Interest__c> createCOI(String conId,String accId, Integer recordCount){
        List<Conflict_of_Interest__c> recordList = new List<Conflict_of_Interest__c>();
         Date dt = System.today();
        for(Integer i=0; i<recordCount; i++) {
            Conflict_of_Interest__c record = new Conflict_of_Interest__c(); 
            record.Auditor__c = conId;             
            record.Customer__c = accId;
            record.StartDate__c = System.today();
            record.EndDate__c = dt.addDays(30);
            recordList.add(record);
        }
        return recordList;
    }
    
    //Create Salesforce Task ...
     public static List<Task> createSFTask(String ConId, String userId,Integer recordCount){
        List<Task> recordList = new List<Task>();
        for(Integer i=0; i<recordCount; i++) {
            Task record = new Task();
            record.Subject = 'Test Subject';
            record.WhoId = ConId;
            record.Status ='Not Started';
            record.OwnerId = userId;
            recordList.add(record);
        }
        return recordList;
    }

    //Create Certified Species
    public static List<Species__c> createSpecies(Integer recordCount){
        List<Species__c> recordList = new List<Species__c>();
        for(Integer i=0; i<recordCount; i++) {
            Species__c record = new Species__c();
            record.Category__c = 'Test Category ' + i;
            record.Comments__c = 'Test ' + i;
            record.Code__c ='Test Code ' + i;
            record.Name = 'Test ' + i;
            record.Synonyms__c = 'Test Sym ' + i;
            record.Name = 'Test Translate__c ' + i;
            recordList.add(record);
        }
        return recordList;
    }

    //Create Certified Volume
    public static List<Certified_volume__c> createCertifiedVolume(String ocId, Integer recordCount){
        List<Certified_volume__c> recordList = new List<Certified_volume__c>();
        for(Integer i=0; i<recordCount; i++) {
            Certified_volume__c record = new Certified_volume__c();
            record.FFB_Projected_Tonnage__c = 1;
            record.IS_CSPKE_Projected_Tonnage_Total__c = 2;
            record.IS_CSPKO_Projected_Tonnage_Total__c =3;
            record.IS_CSPO_Projected_Tonnage_Total__c = 4;
            record.IS_FFB_Projected_Tonnage__c = 5;
            record.Opportunity_Certificate__c = ocId;
            recordList.add(record);
        }
        return recordList;
    }

    //Create Certified Species
    public static List<Certified_Species__c> createCertifiedSpecies(String certifiedProd, String species,Integer recordCount){
        List<Certified_Species__c> recordList = new List<Certified_Species__c>();
        for(Integer i=0; i<recordCount; i++) {
            Certified_Species__c record = new Certified_Species__c();
            record.Certified_Product__c = certifiedProd;
            record.Name = 'Test record';
            record.Product_Group_FSCCH__c ='Test';
            record.Product_Species_FSCPK__c = 'test';
            record.Species__c = species;
            recordList.add(record);
        }
        return recordList;
    }


    //Create Certified Species
    public static List<Program_Contact_Role__c> createProgramContactRole(String contId, String progId,Integer recordCount){
        List<Program_Contact_Role__c> recordList = new List<Program_Contact_Role__c>();
        for(Integer i=0; i<recordCount; i++) {
            Program_Contact_Role__c record = new Program_Contact_Role__c();
            record.Contact__c = contId;
            record.Program__c = progId;
            record.Program_Role__c = 'Primary';
            recordList.add(record);
        }
        return recordList;
    }
}