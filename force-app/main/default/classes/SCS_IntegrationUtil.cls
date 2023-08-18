/*
@Author : MAANTIC
@CreatedDate : 28th JULY 2022
@Description : Product Object Trigger Handler.
*/

public with sharing class SCS_IntegrationUtil {
    
    //Get Fields record from custom meta data...
    public static Map<String, List <SF_TO_SF_FIELD_MAPPING__mdt>> getCustomMetaDataRecord(String objectName) {
        Map <String, List <SF_TO_SF_FIELD_MAPPING__mdt>> cmdRecordMap = new Map <String, List <SF_TO_SF_FIELD_MAPPING__mdt>>();
        for (SF_TO_SF_FIELD_MAPPING__mdt cmdRecord : [SELECT SF_Field_API_Name__c,External_Field_Data_Type__c,External_Field_API_Name__c,External_Object_Name__c FROM SF_TO_SF_FIELD_MAPPING__mdt WHERE External_Object_Name__c =: objectName]) {
            if (!cmdRecordMap.containsKey(cmdRecord.External_Object_Name__c)) {
                cmdRecordMap.put(cmdRecord.External_Object_Name__c, new List <SF_TO_SF_FIELD_MAPPING__mdt>());
            }
            cmdRecordMap.get(cmdRecord.External_Object_Name__c).add(cmdRecord); 
        }
        return cmdRecordMap;
    }
    
    //get field value from specific object
    public static String getFieldValue (SObject record, String fieldName) {
        String valueToReturn = '';
        List<String> objRelList = fieldName.replace('.', '@@').split('@@');
        SObject tempObj = record;
        for (Integer k = 0; k < objRelList.size() - 1; k++){
            tempObj = tempObj.getSObject(objRelList[k]);
        }
        if(tempObj != null && objRelList != null && objRelList.size() > 0){
            if (tempObj.get(objRelList[objRelList.size()-1]) != null) {
                valueToReturn = String.valueOf(tempObj.get (objRelList[objRelList.size()-1]));
            }
        }
        return valueToReturn;
    }
    
}