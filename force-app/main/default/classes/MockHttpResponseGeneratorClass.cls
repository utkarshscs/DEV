/*
    Description : Test Class for SCS_ProductTrigger, SCS_ProductTriggerHandler
    Author      : Utkarsh Goswami(Maantic)
    Date        : 22nd September, 2022

    Please add @Revisions below
*/
@isTest
global class MockHttpResponseGeneratorClass implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseVal = '{"id":"external-Id"}';
        res.setBody(responseVal);
        res.setStatusCode(200);
        return res;
    }
}