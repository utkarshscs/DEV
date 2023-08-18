/**************************************************** NEW ORG CODE ****************************************************************************************************************
* Apex Class Name   : SCS_SFToSFConnector
* Related Class Name: SCS_IntegrationUtil
* Division          : Sales and marketing
* Version           : 1.0
* Total Function    : 7
* Code reviewed By  : Amitava Dutta
* Functionality     : This is common connector to sync data using trigger from new org to old org on after insert or after update.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        26-07-2022                          Initial version 
* Umesh Kumar                        21-10-2022                          Added Site covered sync functionality to update external record id and create integration log in line no 225,306.
* Umesh Kumar                        31-10-2022                          Added Standard and standard covered functionality to update external record id and create integration log in line no 229,316.
* Utkarsh Goswami                    05-12-2022                          Added logic to Sync OpportunityContactRoles
* Umesh Kumar                        16-12-2022                          Added scope sync functionality...
*************************************************************************************************************************************************************************************/

public with sharing class SCS_SFToSFConnector {
    
    //Call future method from trigger...
    @future(callout=true)
    public static void sFToSFConnector(String newJSONRecord,String objectName,String methodName,String recordTypeName){
        System.debug('objectName 1*********'+objectName);
        //Deserialize the json string into list of sobject...
        List<Sobject> recordList =(List<Sobject>)JSON.deserialize(newJSONRecord,List<Sobject>.class);
        //Make call out...
        makeFutureCallout(recordList,objectName,methodName,recordTypeName);
    }
    //Make future callout...
    public static void makeFutureCallout(List<Sobject> recordList,String objectName,String methodName,String recordTypeName) {
        //Add target record ids into source record list...
        List<Sobject>  updateRecords = new List<Sobject>();
        //Add Created integration log into list...
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        //Get fields from custom meta data using object name...
        Map<String,List<SF_TO_SF_FIELD_MAPPING__mdt>> cmdMap = SCS_IntegrationUtil.getCustomMetaDataRecord(objectName);
        System.debug('cmdMap*********'+cmdMap);
        //Loop each record...
        
        for(Sobject record : recordList) {
            System.debug('record*********'+record);
            //Add target field value mapping in map...
            Map<String,String> fieldValMap = new Map<String,String> ();
            //Loop each field record and map value with target fields...
            for(SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : cmdMap.get(objectName)){
                //Get field value based on record type from custom meta data or field value from record...
                String fValue = cmdRecord.External_Field_API_Name__c =='RecordTypeId' && String.isNotBlank(recordTypeName) ? SF_RECORD_TYPE__mdt.getInstance(recordTypeName).External_Record_Type_Id__c :SCS_IntegrationUtil.getFieldValue(record,cmdRecord.SF_Field_API_Name__c);
                //Convert value based on field data type or assign value...
                String fieldValue = String.isBlank(cmdRecord.External_Field_Data_Type__c) ? fValue : parseDate(fValue,cmdRecord.External_Field_Data_Type__c);
                //Map the value for external field...
                if(!String.isBlank(fieldValue)){
                    fieldValMap.put(cmdRecord.External_Field_API_Name__c,fieldValue.trim().replaceAll('\\s+',' ').replace('"','\\"'));
                }
                system.debug('DT'+String.isBlank(cmdRecord.External_Field_Data_Type__c));
                system.debug(cmdRecord.External_Field_API_Name__c+' =*'+fieldValue+' data type ='+cmdRecord.External_Field_Data_Type__c);
            }
            //Make request for end point...
            httpRequest request = makeRequest(record,fieldValMap,objectName,methodName);
            //Create response object...
            HttpResponse response = new HttpResponse();
            //Creating http object...
            Http sendRequest = new Http();
            //Send the request...
            response = sendRequest.send(request);
            system.debug('Response***'+response.getBody());
            //Use to store error message...
            String errorMessage = '';
            //Use to store error code...
            String errorCode = '';
            //If status code is 200 the it will update the external record id in current record...
            if(response.getStatusCode() == 201 || response.getStatusCode() == 200 ){
                //if(objectName != 'fw1__Payment__c') {
                    updateRecords.addAll(updateTargetRecordId(record,response,objectName));
                    //}
                } 
                else if(response.getStatusCode() == 204){
                    updateRecords.add(new OpportunityContactRole(Id = record.Id,External_Sync_Response__c ='Record Synced Successfully, Status code - '+204)); 
                }
                else {
                    //If error occure...
                    system.debug('Response error***');
                    List<ErrorWrapper> errors = (List<ErrorWrapper>)JSON.deserialize(response.getBody(),List<ErrorWrapper>.class);   
                    errorMessage = errors[0].message;
                    errorCode = errors[0].errorCode;
                    if(objectName == 'PricebookEntry'){
                        updateRecords.add(new PricebookEntry(Id = record.Id,JSON_Response__c ='Sync Failed -Error Code :'+errorCode+',Error Message :'+errorMessage));
                    } else if(objectName == 'CampaignMember'){
                        updateRecords.add(new CampaignMember(Id = record.Id,External_Sync_Response__c ='Sync Failed -Error Code :'+errorCode+',Error Message :'+errorMessage)); 
                    } else if(objectName == 'Task'){ 
                        errorMessage = errorMessage.length() > 254 ? errorMessage.Substring(0,253) : errorMessage;
                        updateRecords.add(new Task(Id = record.Id,External_Sync_Response__c ='Error Message :'+errorMessage)); 
                    }
                    else if(objectName == 'OpportunityContactRole'){
                        updateRecords.add(new OpportunityContactRole(Id = record.Id,External_Sync_Response__c ='Sync Failed -Error Code :'+errorCode+',Error Message :'+errorMessage)); 
                    }
                }
                //Create integration log for each record...
                if(objectName != 'PricebookEntry' && objectName != 'CampaignMember' && objectName != 'Task'){
                    integrationLogs.add(createLogs(record,response,objectName,errorMessage,errorCode,request.getEndpoint()));
                }
            }
            
            //Update record with external record Id...
            if(!updateRecords.isEmpty()){
                Database.update(updateRecords,false);
                System.debug('Update record **** '+updateRecords);
            }
            //Create log...
            if(!integrationLogs.isEmpty()){
                insert integrationLogs;
                //Database.insert(integrationLogs,false); 
                System.debug('integration Logs record **** '+integrationLogs);
            }
            
        }
        //Send request to target org.
        public static httpRequest makeRequest(Sobject record,Map<String,String> fieldValMap,String objectName,String methodName){
            //Creating http request object...
            httpRequest request = new httpRequest();
            //Creating request json to send endpoint...
            String resuestJson = makeRequestJSON(fieldValMap);
            //Get connection details from custom meta data...
            SF_TO_SF_CONNECTION__mdt connection = SF_TO_SF_CONNECTION__mdt.getInstance('SFTOSF_CONNECTION');
            //Set endpoint URL...
            if(objectName != 'OpportunityContactRole')
            request.setEndpoint(connection.CONNECTION__c+'/'+objectName+'/'+connection.Marge_Field__c+'/'+record.Id);
            else if(record != null){  
                
                if(methodName == 'POST' || String.isBlank(((OpportunityContactRole)record).External_Record_Id__c)){
                    methodName = 'POST';
                    request.setEndpoint(connection.CONNECTION__c+'/'+objectName);  
                }
                else
                //  request.setEndpoint(connection.CONNECTION__c+'/'+objectName+'/'+record.External_Record_Id__c);
                request.setEndpoint(connection.CONNECTION__c+'/'+objectName+'/'+((OpportunityContactRole)record).External_Record_Id__c);
            }
            //Set request time out...
            request.setTimeout(120000); // 2 Minutes
            //Set request header...
            request.setHeader('Content-Type', 'application/json');
            //Set method... EXP :PATCH
            request.setMethod(methodName);
            //Set request json body...
            request.setBody(resuestJson);
            System.debug('Request URL **** '+request.getEndpoint());
            //return request...
            return request;
        }
        
        //Generate dynamic json string...
        public static String makeRequestJSON(Map<String,String> fieldValMap){
            //Store json string...
            String requestJson ='';
            //Loop each fields...
            for(String fieldName :fieldValMap.keySet()){
                if(fieldValMap.containskey('External_Record_Id__c') && !String.isBlank(fieldValMap.get('External_Record_Id__c'))){
                    if(fieldName !='TaskSubtype' && fieldName !='External_Record_Id__c' && fieldName !='OwnerId' && fieldName != 'OpportunityId' && fieldName !='Master_Invoice_Number__c'){
                        requestJson = requestJson +' "'+fieldName+'" : "'+fieldValMap.get(fieldName)+'" ,';
                    }
                } else if(fieldName !='External_Record_Id__c') {
                    //Add field and field value in json string...
                    requestJson = requestJson +' "'+fieldName+'" : "'+fieldValMap.get(fieldName)+'" ,';
                }
            }
            //Remove comma from end of json string...
            requestJson =requestJson.removeEnd(',');
            //Marge the json string...
            requestJson ='{'+requestJson+'}';
            System.debug('RequestJson **** '+requestJson);
            return requestJson;
        } 
        
        //Update target record id in created record...
        public static  List<Sobject> updateTargetRecordId(Sobject record,HttpResponse response,String objectName){
            //Updated record list...
            List<Sobject>  updateRecords = new List<Sobject>();
            //Deserialize json response in map...
            Map<String,Object> result =(Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            //Object assignment...
            objectName = objectName == 'Project_Site__c' ? 'Account' : objectName;
            //If object name is lead update external record id in lead record...
            if(objectName == 'Lead'){
                updateRecords.add(new Lead(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Account update external record id in Account record...
            } else if(objectName == 'Account'){
                updateRecords.add(new Account(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Contact update external record id in Contact record...
            } else if(objectName == 'Contact'){
                updateRecords.add(new Contact(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Opportunity update external record id in Opportunity record...
            } else if(objectName == 'Opportunity'){
                updateRecords.add(new Opportunity(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is OpportunityLineItem update external record id in OpportunityLineItem record...
            } else if(objectName == 'OpportunityLineItem'){
                updateRecords.add(new OpportunityLineItem(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Product2 update external record id in Product2 record...
            } else if(objectName == 'Product2'){
                updateRecords.add(new Product2(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Program__c update external record id in Program__c record...
            } else if(objectName == 'MPM4_BASE__Milestone1_Program__c'){
                updateRecords.add(new Program__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Pricebook2 update external record id in Pricebook2 record...
            } else if(objectName == 'Pricebook2'){
                updateRecords.add(new Pricebook2(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Certificate__c update external record id in Certificate__c record...
            } else if(objectName == 'Certificate__c'){
                updateRecords.add(new Certificate__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is PricebookEntry update external record id in PricebookEntry record...
            } else if(objectName == 'PricebookEntry'){
                updateRecords.add(new PricebookEntry(Id = record.Id,JSON_Response__c = response.getBody(),External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Credit Memo update external record id in  Credit Memo record...
            }  else if(objectName == 'fw1__Credit_Memo__c'){
                updateRecords.add(new fw1__Credit_Memo__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Credit_Memo_Line__c update external record id in fw1__Credit_Memo_Line__c record...
            } else if(objectName == 'fw1__Credit_Memo_Line__c'){
                updateRecords.add(new fw1__Credit_Memo_Line__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Entity__c update external record id in fw1__Entity__c record...
            } else if(objectName == 'fw1__Entity__c'){
                updateRecords.add(new fw1__Entity__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Invoice_Line__c update external record id in fw1__Invoice_Line__c record...
            } else if(objectName == 'fw1__Invoice_Line__c'){
                updateRecords.add(new fw1__Invoice_Line__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__PaymentProfile__c update external record id in fw1__PaymentProfile__c record...
            } else if(objectName == 'fw1__PaymentProfile__c'){
                updateRecords.add(new fw1__PaymentProfile__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Invoice__c update external record id in fw1__Invoice__c record...
            } else if(objectName == 'fw1__Invoice__c'){
                updateRecords.add(new fw1__Invoice__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Payment_Activity__c update external record id in fw1__Payment_Activity__c record...
            } else if(objectName == 'fw1__Payment_Activity__c'){
                updateRecords.add(new fw1__Payment_Activity__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is fw1__Payment__c update external record id in fw1__Payment__c record...
            }else if(objectName == 'fw1__Payment__c'){
                updateRecords.add(new fw1__Payment__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Campaign update external record id in Campaign record...
            } else if(objectName == 'Campaign'){
                updateRecords.add(new Campaign(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is CampaignMember update external record id in CampaignMember record...
            } else if(objectName == 'CampaignMember'){
                updateRecords.add(new CampaignMember(Id = record.Id,External_Sync_Response__c = response.getBody(),External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Opportunity_Certificate__c update external record id in Opportunity_Certificate__c record...
            } else if(objectName == 'Opportunity_Certificate__c'){
                updateRecords.add(new Opportunity_Certificate__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Task update external record id in Task record...
            } else if(objectName == 'Task'){
                updateRecords.add(new Task(Id = record.Id,External_Sync_Response__c = response.getBody(),External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Site_Covered__c update external record id in Site_Covered__c record...
            } else if(objectName == 'Opportunity_Site__c'){
                updateRecords.add(new Site_Covered__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Standards__c update external record id in Standards__c record...
            }  else if(objectName == 'Standards__c'){
                updateRecords.add(new Standard__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
                //If object name is Standard_Covered__c update external record id in Standard_Covered__c record...
            }  else if(objectName == 'Standard_Covered__c'){
                updateRecords.add(new Standard_Covered__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
            }  else if(objectName == 'Client_Activity__c' || objectName == 'OpportunityClientActivity__c' ){
                updateRecords.add(new Scope__c(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id'))));
            }
            else if(objectName == 'OpportunityContactRole'){
                updateRecords.add(new OpportunityContactRole(Id = record.Id,External_Record_Id__c = String.valueOf(result.get('id')), External_Sync_Response__c = response.getBody()));
            }
            return  updateRecords;
        }
        
        //Create integration log under created record...
        public static Integration_Log__c createLogs(Sobject record,HttpResponse response,String objectName,String errorMsg,String errorCode ,String endPoint){
            objectName = objectName == 'Project_Site__c' ? 'Account' : objectName;
            //Create integration log object...
            Integration_Log__c createLog = new Integration_Log__c ();
            //Assign status code...
            createLog.Status_Code__c = String.valueOf(response.getStatusCode());
            //Assign response body...
            createLog.JSON_Body__c = response.getBody();
            //Assign status...
            createLog.Integration_Status__c = response.getStatus();
            //Assign error code...
            createLog.Error_Code__c = errorCode;
            //Assign error message...
            createLog.Error_Message__c = errorMsg;
            //Assign endpoint url...
            createLog.End_Point_URL__c = endPoint;
            //If object name is lead then associate integration log with lead object...
            if(objectName == 'Lead'){
                createLog.Lead__c = record.Id;
                //If object name is Account then associate integration log with Account object...
            } else if(objectName == 'Account'){
                createLog.Account__c = record.Id;
                //If object name is Contact then associate integration log with Contact object...
            } else if(objectName == 'Contact'){
                createLog.Contact__c = record.Id;
                //If object name is Opportunity then associate integration log with Opportunity object...
            } else if(objectName == 'Opportunity'){
                createLog.Opportunity__c = record.Id;
                //If object name is OpportunityLineItem then associate integration log with OpportunityLineItem object...
            } else if(objectName == 'OpportunityLineItem'){
                createLog.Opportunity_Product__c = record.Id;
                //If object name is Product2 then associate integration log with Product2 object...
            } else if(objectName == 'Product2'){
                createLog.Product__c = record.Id;
                //If object name is Program then associate integration log with Program object...
            } else if(objectName == 'MPM4_BASE__Milestone1_Program__c'){
                createLog.Program__c = record.Id;
                //If object name is Pricebook2 then associate integration log with Pricebook2 object...
            } else if(objectName == 'Pricebook2'){
                createLog.Price_Book__c = record.Id;
                //If object name is Certificate__c then associate integration log with Certificate__c object...
            } else if(objectName == 'Certificate__c'){ 
                createLog.Certificate__c = record.Id;
                //If object name is fw1__Credit_Memo__c then associate integration log with fw1__Credit_Memo__c object...
            } else if(objectName == 'fw1__Credit_Memo__c'){
                createLog.Credit_Memo__c = record.Id;
                
            }else if(objectName == 'fw1__Credit_Memo_Line__c'){
                createLog.Credit_Memo_Line__c = record.Id;
                //If object name is fw1__Entity__c then associate integration log with fw1__Entity__c object...
            } else if(objectName == 'fw1__Entity__c'){
                createLog.Entity__c = record.Id;
                //If object name is fw1__Invoice_Line__c then associate integration log with fw1__Invoice_Line__c object...
            } else if(objectName == 'fw1__Invoice_Line__c'){
                createLog.Invoice_Line__c = record.Id;
                //If object name is fw1__PaymentProfile__c then associate integration log with fw1__PaymentProfile__c object...
            } else if(objectName == 'fw1__PaymentProfile__c'){
                createLog.Payment_Profile__c = record.Id;
                //If object name is fw1__Invoice__c then associate integration log with fw1__Invoice__c object...
            } else if(objectName == 'fw1__Invoice__c'){
                createLog.Invoice__c = record.Id;
                //If object name is fw1__Payment_Activity__c then associate integration log with fw1__Payment_Activity__c object...
            } else if(objectName == 'fw1__Payment_Activity__c'){
                createLog.Payment_Activity__c = record.Id;
                //If object name is fw1__Payment__c then associate integration log with fw1__Payment__c object...
            } else if(objectName == 'fw1__Payment__c'){
                createLog.Payment__c = record.Id;
                //If object name is Campaign then associate integration log with Campaign object...
            } else if(objectName == 'Campaign'){
                createLog.Campaign__c = record.Id;
                //If object name is Opportunity_Certificate__c then associate integration log with Opportunity_Certificate__c object...
            } else if(objectName == 'Opportunity_Certificate__c'){
                createLog.Opportunity_Certificate__c = record.Id;
                //If object name is Site_Covered__c then associate integration log with Site_Covered__c object...
            } else if(objectName == 'Opportunity_Site__c'){
                createLog.Site_Covered__c = record.Id;
                //If object name is Standards__c then associate integration log with Standards__c object...
            } else if(objectName == 'Standards__c'){
                createLog.Standard__c = record.Id;
                //If object name is Standard_Covered__c then associate integration log with Standard_Covered__c object...
            } else if(objectName == 'Standard_Covered__c'){
                createLog.Standard_Covered__c = record.Id;
            } else if(objectName == 'Client_Activity__c' || objectName == 'OpportunityClientActivity__c' ){
                createLog.Scope__c = record.Id;
            }  
            return  createLog;
        }
        //Parse date or dateTime...
        public static String parseDate(String dateString,String dataType){
            if(!String.isBlank(dateString)){
                dateString = dataType == 'DateTime' ? dateString.replace(' ','T') : String.valueOf(Date.valueOf(dateString));
            }
            return dateString;
        }
        //Wrapper class to wrap the error code and error message...
        public class ErrorWrapper{
            //Error code...
            Public String errorCode;
            //Error message...
            Public String message;
        }
    }