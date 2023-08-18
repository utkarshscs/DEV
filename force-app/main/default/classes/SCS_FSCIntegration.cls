public with sharing class SCS_FSCIntegration {
    
    @InvocableMethod(label='Data Sync with FSC')
    public static List<String> dataSyncToFsc(List<Id> ocIds) {
        List<String> statusCode = new List<String>();
        //Query custom meta data record...
        Map<String, List <FSC_Field_Mapping__mdt>> cmdMap = SCS_FSCIntegrationHelper.getCMDRecord();
        //Create dynamic query for OC object...
        String ocQuery = SCS_FSCIntegrationHelper.getQuery('Opportunity_Certificate__c',cmdMap);
        ocQuery = ocQuery + ',Id,Opportunity__c FROM Opportunity_Certificate__c WHERE Id = \''+ocIds.get(0)+'\'';
        //Execute query for OC...
        List<Opportunity_Certificate__c> ocResult = Database.query(ocQuery);
        
        system.debug('OC:QRY'+ocQuery);
        system.debug('OC:Result'+ocResult);
        if(! ocResult.isEmpty()) {
            //Json Generator object...
            JSONGenerator gen = JSON.createGenerator(true); 
            
            //Create dynamic query for Certified Site object...
            String siteQuery = SCS_FSCIntegrationHelper.getQuery('Certified_Sites__c',cmdMap);
            siteQuery = siteQuery + ',CustomerSite__c FROM Certified_Sites__c WHERE CustomerSite__c != null AND OpportunityCertificate__c = \''+ocResult[0].Id+'\'';
            //Execute query for Certified site...
            List<Certified_Sites__c> certifiedSiteResult = Database.query(siteQuery);
            system.debug('Site:QRY'+siteQuery);
            system.debug('Site:Result'+certifiedSiteResult);
            /***************************** OC Start Array ********************************************************************/
            gen.writeStartArray();//OC Start Array...
            Opportunity_Certificate__c opportunityCertificate = ocResult[0];
            gen.writeStartObject();//OC Start Object...
            for(FSC_Field_Mapping__mdt  field : cmdMap.get('Opportunity_Certificate__c')) {
                String fValue = field.FSC_Field_API__c == 'No_of_Sites' ? String.valueOf(certifiedSiteResult.size()) : SCS_FSCIntegrationHelper.getFieldValue (opportunityCertificate,field.SF_Field_API__c);
                fValue = SCS_FSCIntegrationHelper.getConvertedValue (fValue,field.Field_Type__c);
                if(field.FSC_Field_API__c == 'fsc_systemsofcontrol' ||field.FSC_Field_API__c =='fsc_countriesoforigin') {
                    List<String> sysOfcontrol = fValue.split(';');
                    gen.writeObjectField(String.valueOf(field.FSC_Field_API__c), sysOfcontrol);
                } else {
                    gen.writeStringField(field.FSC_Field_API__c, String.valueOf(fValue)); 
                }
            }
            
            /***************************** Certified Site Start Array **********************************************************/
            gen.writeFieldName('certificates_CERTD400PLANT_|idcert|');
            gen.writeStartArray();// Certified Site Start Array...
            if( !certifiedSiteResult.isEmpty()){
                //Create account set...
                Set<String> siteSet = new Set<String>();
                Map<String,List<Contact>> contactMap = new Map<String,List<Contact>>();
                //Add site id into set...
                for(Certified_Sites__c cs : certifiedSiteResult) {
                    siteSet.add(cs.CustomerSite__c);
                }
                
                //Create dynamic query for Site contact object...
                String siteContactQuery = SCS_FSCIntegrationHelper.getQuery('Contact',cmdMap);
                siteContactQuery = siteContactQuery + ',AccountId FROM Contact WHERE AccountId IN :siteSet';
                //Execute query for Site contact...
                List<Contact> siteContactResult = Database.query(siteContactQuery);
                system.debug('Contact:QRY'+siteContactQuery);
                system.debug('Contact:Result'+siteContactResult);
                //add site related contact into map
                if(! siteContactResult.isEmpty()){
                    for(Contact con : siteContactResult){
                        if (!contactMap.containsKey(con.AccountId)) {
                            contactMap.put(con.AccountId, new List<Contact>());
                        }
                        contactMap.get(con.AccountId).add(con);
                    }
                }
                
                //Certified Site Record loop start...
                for(Certified_Sites__c site : certifiedSiteResult) {
                    gen.writeStartObject();//Certified Site Start Object... 
                    //Certified Site CMD field loop start...
                    for(FSC_Field_Mapping__mdt  field : cmdMap.get('Certified_Sites__c')) {
                        String siteValue = SCS_FSCIntegrationHelper.getFieldValue (site,field.SF_Field_API__c);
                        gen.writeStringField(String.valueOf(field.FSC_Field_API__c), String.valueOf(siteValue));
                    } //Certified Site CMD field loop end...
                    
                    /***************************** Certified Site Related Contact Start Array ****************************/ 
                    gen.writeFieldName('certificates_CLIENTCONTACTSjoin_|id_cert|');                
                    gen.writeStartArray();//Site Contact Start Array...
                    if(! contactMap.isEmpty() && contactMap.containsKey(site.CustomerSite__c) && contactMap.get(site.CustomerSite__c).size() > 0){
                        for(Contact con : contactMap.get(site.CustomerSite__c)) {
                            gen.writeStartObject();//Site Contact Start Object... 
                            //Contact CMD field loop start...
                            for(FSC_Field_Mapping__mdt  field : cmdMap.get('Contact')) {
                                String conValue = SCS_FSCIntegrationHelper.getFieldValue (con,field.SF_Field_API__c);
                                gen.writeStringField(String.valueOf(field.FSC_Field_API__c), String.valueOf(conValue));
                            } //Contact CMD field loop end...
                            gen.writeEndObject();//Site Contact End Object...
                        }   
                    }
                    gen.writeEndArray();//Site Contact End Array... 
                    /***************************** Certified Site Related Contact Start Array ****************************/
                    
                    gen.writeEndObject();//Certified Site End Object...
                } //Certified Site Record loop end...
            }
            gen.writeEndArray();//Certified Site End Array...
            /***************************** Certified Site End Array *********************************************************/
            
            /***************************** Certificates TRANSACT VERIFICATION Start Array **********************************/
            //Create dynamic query for Transact Verification object...
            String transactQuery = SCS_FSCIntegrationHelper.getQuery('Transaction_Verification__c',cmdMap);
            transactQuery = transactQuery.contains(',') ? transactQuery + ' FROM Transaction_Verification__c' : transactQuery + ' Id FROM Transaction_Verification__c';
            transactQuery = transactQuery + ' WHERE Opportunity_Certificate__c = \''+ocIds.get(0)+'\'';
            //Execute query for Transact Verification...
            List<Transaction_Verification__c> transactResult = Database.query(transactQuery);
            gen.writeFieldName('certificates_TRANSACTVERIFICATION_|id_certificate|');
            gen.writeStartArray();// Transact Verification Start Array...
            if(! transactResult.isEmpty()) {
                for(Transaction_Verification__c transct : transactResult ) {
                    gen.writeStartObject();//Transact Verification Start Object... 
                    //Transact Verification CMD field loop start...
                    for(FSC_Field_Mapping__mdt  field : cmdMap.get('Transaction_Verification__c')) {
                        String csValue = SCS_FSCIntegrationHelper.getFieldValue (transct,field.SF_Field_API__c);
                        gen.writeStringField(String.valueOf(field.FSC_Field_API__c), String.valueOf(csValue));
                    } //Transact Verification CMD field loop end...
                    gen.writeEndObject();//Transact Verification End Object...  
                }
            }
            gen.writeEndArray();//Transact Verification End Array... 
            /***************************** Certificates TRANSACT VERIFICATION End Array ***********************************/
            
            /*****************************Standard Start Array ***********************************/
            if(String.isNotBlank(ocResult[0].Opportunity__c)) {
                //Create dynamic query for standard Covered object...
                String standardCoveredQuery = SCS_FSCIntegrationHelper.getQuery('Standard_Covered__c',cmdMap);
                standardCoveredQuery = standardCoveredQuery + '  FROM Standard_Covered__c WHERE Opportunity__c = \''+ocResult[0].Opportunity__c+'\''; 
                List<Standard_Covered__c> standardResult = Database.query(standardCoveredQuery);
                List<String> stdList = new List<String>();
                if( !standardResult.isEmpty()){
                    for(Standard_Covered__c stad : standardResult) {
                        stdList.add(stad.Title__c);
                    }
                }
                gen.writeObjectField('standard', stdList);
            }
            /***************************** Standard End Array ***********************************/
            
            /***************************** Certified Product Start Array ***********************************/
            
            //Create dynamic query for Certified Product object...
            String certifiedProductQuery = SCS_FSCIntegrationHelper.getQuery('CertifiedProducts__c',cmdMap);
            //Create dynamic query for Certified Species object...
            String certifiedSpeciesQuery = SCS_FSCIntegrationHelper.getQuery('Certified_Species__c',cmdMap);
            certifiedProductQuery = certifiedProductQuery + ',('+ certifiedSpeciesQuery +' FROM Certified_Species__r )';
            certifiedProductQuery = certifiedProductQuery + ' FROM CertifiedProducts__c WHERE OpportunityCertificate__c = \''+ocResult[0].Id+'\'';
            //Execute query for Certified product...
            System.debug('CP:'+certifiedProductQuery);
            List<CertifiedProducts__c> certifiedProductResult = Database.query(certifiedProductQuery);
            system.debug('Certified Product:QRY'+certifiedProductQuery);
            system.debug('Certified Product:Result'+certifiedProductResult);
            gen.writeFieldName('CERT_D502_ProdGroup_FSC');
            gen.writeStartArray();// Certified Product Start Array...
            for(CertifiedProducts__c cp : certifiedProductResult) {
                gen.writeStartObject();//Certified Product Start Object... 
                //Certified Product CMD field loop start...
                for(FSC_Field_Mapping__mdt  field : cmdMap.get('CertifiedProducts__c')) {
                    String cpValue = SCS_FSCIntegrationHelper.getFieldValue (cp,field.SF_Field_API__c);
                    if(field.FSC_Field_API__c == 'category') {
                        List<String> catgry = cpValue.split(';');
                        gen.writeObjectField(String.valueOf(field.FSC_Field_API__c), catgry);
                    } else {
                        gen.writeStringField(String.valueOf(field.FSC_Field_API__c), String.valueOf(cpValue));
                    }
                    
                } //Certified Product CMD field loop end...
                
                /***************************** Product Species Start Array ***********************************/
                gen.writeFieldName('PRODUCTSPECIES_Join');
                gen.writeStartArray();// Product Species Start Array...
                for(Certified_Species__c certSpecies :cp.Certified_Species__r) {
                    gen.writeStartObject();//Product Species Start Object... 
                    //Product Species CMD field loop start...
                    for(FSC_Field_Mapping__mdt  field : cmdMap.get('Certified_Species__c')) {
                        String csValue = SCS_FSCIntegrationHelper.getFieldValue (certSpecies,field.SF_Field_API__c);
                        gen.writeStringField(String.valueOf(field.FSC_Field_API__c), String.valueOf(csValue));
                    } //Product Species CMD field loop end...
                    gen.writeEndObject();//Product Species End Object...
                    
                }
                gen.writeEndArray();//Product Species End Array...
                /***************************** Product Species Start Array ***********************************/
                
                gen.writeEndObject();//Certified Product End Object...
            }
            gen.writeEndArray();//Certified Product End Array... 
            /***************************** Certified Product End Array ***********************************/
            
            gen.writeEndObject();//OC End Object...
            gen.writeEndArray();//OC End Array...
            /***************************** OC End Array ********************************************************************/
            //Send request to FSC...
            HttpResponse response = sendRequestToFSC(gen.getAsString());
            system.debug('Response Status Code***'+response.getStatusCode());
            system.debug('Response***'+response.getBody());
            
            Opportunity_Certificate__c ocRecord = new Opportunity_Certificate__c();
            ocRecord.Id = ocIds.get(0);
            ocRecord.FSC_Json_Request__c = gen.getAsString();
            ocRecord.FSC_Response__c = response.getBody();
            ocRecord.Is_SYNC_With_FSC__c = response.getStatusCode() == 201 ? true : false;
            update ocRecord;
            statusCode.add(String.valueOf(response.getStatusCode()));    
        }//oc If end
        return statusCode;
    } 
    
    //Send request to FSC org.
    public static HttpResponse sendRequestToFSC (String resuestJson){
        //Creating http request object...
        httpRequest request = new httpRequest();
        //Get FSC connection details from custom meta data...
        FSC_Connection__mdt connection = FSC_Connection__mdt.getInstance('FSC_Connection');
        //Set endpoint url...
        request.setEndpoint(connection.End_Point_URL__c);
        //Set request time out...
        request.setTimeout(120000); // 2 Minutes
        //Set request header...
        request.setHeader('Content-Type',connection.Content_Type__c);
        request.setHeader('x-functions-key',connection.Function_Key__c);
        //Set method... EXP :POST
        request.setMethod(connection.Method_Name__c);
        //Set request json body...
        request.setBody(resuestJson);
        //Creating http object...
        Http sendRequest = new Http();
        //Send the request...
        HttpResponse response = sendRequest.send(request);
        return response;
    }   
}