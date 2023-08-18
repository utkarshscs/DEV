public with sharing class SCS_FSCIntegrationHelper {
    
    //Get Fields record from custom meta data...
    public static Map<String, List <FSC_Field_Mapping__mdt>> getCMDRecord() {
        Map <String, List <FSC_Field_Mapping__mdt>> cmdMap = new Map <String, List <FSC_Field_Mapping__mdt>>();
        for (FSC_Field_Mapping__mdt record : [SELECT FSC_Field_API__c,SF_Field_API__c,Field_Type__c,SF_Object_Name__c FROM FSC_Field_Mapping__mdt WHERE Is_Active__c = true ORDER BY Order__c ASC]) {
            if (!cmdMap.containsKey(record.SF_Object_Name__c)) {
                cmdMap.put(record.SF_Object_Name__c, new List <FSC_Field_Mapping__mdt>());
            }
            cmdMap.get(record.SF_Object_Name__c).add(record); 
        }
        return cmdMap;
    }
    
    //get field value from specific object
    public static String getQuery (String objectName,Map<String, List <FSC_Field_Mapping__mdt>> cmdMap) {
        Set<String> fieldSet = new Set<String> ();
        Set<String> childFieldSet = new Set<String> ();
        if(cmdMap.containsKey(objectName)){
            for(FSC_Field_Mapping__mdt  record : cmdMap.get(objectName)) {
                fieldSet.add(record.SF_Field_API__c);
            }
        }
        String qry = 'SELECT ' + String.join(new List <String> (fieldSet), ', ');
        return qry;
    }
    
    //get field value from specific object
    public static String getConvertedValue (String value,String dataType) {
        value = dataType == 'Date' ? value.removeEnd(' 00:00:00') : value;
        return value;
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