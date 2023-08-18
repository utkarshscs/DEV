/*
    Description :   Class to query show the Program Contact Role Data used in programContactRole LWC
    Author      :   Utkarsh Goswami
    Date        :   9th Aug, 2023
*/

public class ProgramContactRole {

    @AuraEnabled(cacheable=true)
    public static List<ProgramContactRoleWrapper> getProgramContactRoleData(String programId, String accountId){
   // public static List<ProgramContactRoleWrapper> getProgramContactRoleData(){

        List<ProgramContactRoleWrapper> pcrList = new List<ProgramContactRoleWrapper>();
        ProgramContactRoleWrapper pcrObject = new ProgramContactRoleWrapper();
        
        for(Program_Contact_Role__c pr : [Select Id,Program__r.Name,Program_Role__c, AccountName__c, Contact__r.AccountId, Program__c,
                                            Contact__r.firstName, Contact__r.LastName, Contact__r.Title,
                                            Contact__r.Phone, Contact__r.Fax, Contact__r.Email, Contact__r.MobilePhone from Program_Contact_Role__c
                                            where Program__c = :programId and Contact__r.AccountId = :accountId]){
            pcrObject = new ProgramContactRoleWrapper();

            pcrObject.program = pr.Program__r.Name;                                
            pcrObject.accountName = pr.AccountName__c;                          
            pcrObject.firstName = pr.Contact__r.firstName;                              
            pcrObject.lastName = pr.Contact__r.LastName;                              
            pcrObject.title = pr.Contact__r.Title;                                
            pcrObject.phone = pr.Contact__r.Phone;                                 
            pcrObject.fax = pr.Contact__r.Fax;                                 
            pcrObject.email = pr.Contact__r.Email;                                
            pcrObject.mobile = pr.Contact__r.MobilePhone;                               
            pcrObject.programRole = pr.Program_Role__c;                               
            pcrObject.recordId = pr.Id;                               
            pcrObject.accountId = pr.Contact__r.AccountId;                               
            pcrObject.progrId = pr.Program__c;                               


            pcrList.add(pcrObject);
        }

        return pcrList;
    }


    Public Class ProgramContactRoleWrapper {

        @AuraEnabled
        public String program;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String fax;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String mobile;
        @AuraEnabled
        public String programRole;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String progrId;

    }
}