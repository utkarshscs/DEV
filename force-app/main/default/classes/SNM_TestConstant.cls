/**************************************************** NEW ORG CODE ***************************************************************** 
* Class Name        : SNM_TestConstant
* Use In            : Test Classes
* Division          : Sales and marketing
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : Query record type for test class.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        21-10-2022                          Initial version 
* Umesh Kumar                        28-10-2022                          Added contact customer record type functionality
************************************************************************************************************************************/

@isTest
public class SNM_TestConstant {
    
    //Get Account Record Types...
    //Get Customer record type from account object...
    public static Id customerAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    
    //Get Contact Record Types...
    //Get Customer record type from Contact object...
    public static Id customerConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    public static Id auditorConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Auditor').getRecordTypeId();
    //Get Opportunity Record Types...
    //Training record type...
    public static Id training_Oppo_RTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Training_Opportunity').getRecordTypeId();
    //ECS record type...
    public static Id eCSOppoRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();
    
    //Lead record type...
    //scs global service record type...
    public static Id scsGlobalServiceRTId_Lead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SCS_Global_Services').getRecordTypeId();
    //ECS record type...
    public static Id ecsRT_Project = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('ECS').getRecordTypeId();

}