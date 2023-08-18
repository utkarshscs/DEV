/*
@Author : MAANTIC(Kumar Umesh)
@CreatedDate : 13th Oct 2022
@Description : This class use to delete record in target org.
*/

/****************************** NEW ORG CODE *****************************************************/

public with sharing class SCS_DeleteRecord {
     //Call future method from trigger...
    @future(callout=true)
    public static void sFToSFConnectorDeletion(String externalIds,String methodName){
        makeRequest(externalIds,methodName);
    }
    //Send request to target org.
    public static void makeRequest(String externalIds,String methodName){
        //Creating http request object...
        httpRequest request = new httpRequest();
        //Get connection details from custom meta data...
        SF_TO_SF_CONNECTION__mdt connection = SF_TO_SF_CONNECTION__mdt.getInstance('SFTOSF_CONNECTION');
        //Remove comma from end of json string...
        externalIds = externalIds.removeEnd(',');
        //Set endpoint URL...
        String requestURL = connection.CONNECTION__c.substringBefore('sobjects') +'composite/sobjects?ids='+externalIds+'&allOrNone=false';
        request.setEndpoint(requestURL);
        //Set request time out...
        request.setTimeout(120000); // 2 Minutes
        //Set request header...
        request.setHeader('Content-Type', 'application/json');
        //Set method... EXP :DELETE
        request.setMethod(methodName);
        System.debug('Request URL **** '+request.getEndpoint());
        Http sendRequest = new Http();
        //Send the request...
        HttpResponse response = sendRequest.send(request);
        system.debug('Response***'+response.getBody());
    }

}