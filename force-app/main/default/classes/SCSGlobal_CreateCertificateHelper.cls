public with sharing class SCSGlobal_CreateCertificateHelper 
{   /*
    @AuraEnabled
    public static List<Certificate__c> getCertificateFromOpportunity(String opptyId)
    {
        Opportunity oppty=[SELECT AccountId, Programc__c FROM Opportunity WHERE Id=:opptyId LIMIT 1];
        return [SELECT Id,Name,Scheme_Certification_Number__c,SCS_Certification_Number__c,
                ValidFrom__c FROM Certificate__c WHERE Account__c =:oppty.AccountId AND Program__c =:oppty.Programc__c];
    }*/
     @AuraEnabled
     public static String getCertificateFromOpportunity(Integer pageSize, Integer pageNumber,String oppId){
        String jsonResult = '';
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        Opportunity opportunityRecord =[SELECT AccountId, Programc__c FROM Opportunity WHERE Id=:oppId LIMIT 1];
        //Total Records
		Integer totalRecords = [SELECT COUNT() FROM Certificate__c WHERE Account__c =:opportunityRecord.AccountId AND Program__c =:opportunityRecord.Programc__c];
        Integer recordEnd = pageSize * pageNumber;
        CertificateWrapper wrapperRecord =  new CertificateWrapper();  
        wrapperRecord.pageSize = pageSize;
        wrapperRecord.pageNumber = pageNumber;
        wrapperRecord.recordStart = offset + 1;
        wrapperRecord.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapperRecord.totalRecords = totalRecords;
        wrapperRecord.certificates = [SELECT Id,Name,Scheme_Certification_Number__c,SCS_Certification_Number__c,ValidFrom__c FROM Certificate__c WHERE Account__c =:opportunityRecord.AccountId AND Program__c =:opportunityRecord.Programc__c Order By Name DESC LIMIT :pageSize OFFSET :offset];
        jsonResult = JSON.serialize(wrapperRecord);
        return jsonResult;
    }
    
    public class CertificateWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<Certificate__c> certificates {get;set;}
    }
    
    @AuraEnabled
    public static Map<String, String> getFieldsListFromFieldSet(String fieldSetName)
    {
        Map<String, String> returnMap = new Map<String, String>();
        fieldSetName=fieldSetName.replaceAll('\\W+', '_');
        System.debug(fieldSetName);
        
        //get fields from FieldSet
        SObject sObj = (SObject)(Type.forName('Schema.Opportunity_Certificate__c')?.newInstance());
        List<Schema.FieldSetMember> lstFSMember = 
            sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(fieldSetName)?.getFields();
        
        returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
        returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());
        System.debug(returnMap);
        return returnMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getCertificateFieldsfromFieldSet(String fieldSetName){
        Map<String, String> returnMap = new Map<String, String>();
        fieldSetName=fieldSetName.replaceAll('\\W+', '_');
        System.debug(fieldSetName);
        
        //get fields from FieldSet
        SObject sObj = (SObject)(Type.forName('Schema.Certificate__c')?.newInstance());
        List<Schema.FieldSetMember> lstFSMember = 
            sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(fieldSetName)?.getFields();
        
        returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
        returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());
        System.debug(returnMap);
        return returnMap;
    }
    
    @AuraEnabled
    public static String createCertificateAndOC(Certificate__c cert, Opportunity_Certificate__c oppCert, String existingCertId){
        System.debug('Sohit-cert---'+cert);
        System.debug('Sohit-oppCert---'+oppCert);
        if(cert != null){
            try{
                insert cert;
            }
            catch (Exception e) {
                String errorMsg = e.getMessage();
                if(!Test.isRunningTest())
                    throw new AuraHandledException(errorMsg);
                
            }
        }
        
        if(oppCert != null){
            oppCert.Certificate__c = String.isNotBlank(existingCertId) ? existingCertId :cert.Id;
            try{
                insert oppCert;
                return oppCert.Id;
            }
            catch (Exception e) {
                String errorMsg = e.getMessage();
                throw new AuraHandledException(errorMsg);
            }
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean checkProjectExist(String oppId)
    { 
        if(string.isNotBlank(oppId)){
            List<Opportunity> oppList = [Select id,name,Affiliate_Opportunity_flag__c from Opportunity where id=:oppId];    
            if( oppList[0].Affiliate_Opportunity_flag__c ){
                return true;
            }else{
                List<inspire1__Project__c> projList = [SELECT Id FROM inspire1__Project__c WHERE inspire1__Opportunity1__c =: oppId];
                return projList.size() > 0;
            }
        }
        return false;        
    }
    
}