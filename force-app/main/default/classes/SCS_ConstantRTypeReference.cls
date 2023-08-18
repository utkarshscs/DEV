/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : Product Object Trigger Handler.
*/

public class SCS_ConstantRTypeReference {
    
    //Goal
    public static Id programGoal_Goal_RTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('Program_Goal').getRecordTypeId();
    public static Id userGoal_Goal_RTId = Schema.SObjectType.Goal__c.getRecordTypeInfosByDeveloperName().get('User_Goal').getRecordTypeId();
   
    //Account
    public static Id customerSite_Account_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CustomerSite').getRecordTypeId();
    public static Id account_Account_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
   
    //Contact
    public static Id standard_Contact_RTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    public static Id auditor_Contact_RTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Auditor').getRecordTypeId();
    //public static Id stakeholder_Contact_RTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Stakeholder').getRecordTypeId();
    
    //Opportunity
    public static Id standard_RTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
    public static Id training_Oppo_RTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Training_Opportunity').getRecordTypeId();
    
    //Project
    public static Id standard_Project_RTId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('SCS_Standard').getRecordTypeId();
    
    //Scope 
    public static Id scope_SubScopeRTId = Schema.SObjectType.Scope__c.getRecordTypeInfosByDeveloperName().get('Sub_Scope').getRecordTypeId();
    public static Id scope_opportunityRTId = Schema.SObjectType.Scope__c.getRecordTypeInfosByDeveloperName().get('Opportunity').getRecordTypeId();
    
}