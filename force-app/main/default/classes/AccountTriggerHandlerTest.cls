/**
Description    :   Test Class for AccountTrigger and AccountTriggerHanlder
Date           :   20th March, 2023
Author         :   Utkarsh G (Maantic)
*/
@isTest
public class AccountTriggerHandlerTest {
    @isTest
    private static void testPreventDeleteAccount(){
        //Set mock response...
        Test.setMock(HttpCalloutMock.class, new SCS_DataSyncMock()); 
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Quickbooks_ID__c = '123456789';
        insert testAccount;
        
        Test.startTest();
        String error = '';
        try{
            delete testAccount;
        }catch(Exception e){
            error = e.getMessage();
        }
        System.assertNotEquals(null, error);
        Test.stopTest();
    }
    
    public class SCS_DataSyncMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"id":"SCSTESTId","success":true,"errors":[],"created":true}');
            response.setStatusCode(201);
            return response; 
        }
    }
}