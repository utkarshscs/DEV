/**************************************************** OLD ORG CODE ****************************************************************************************************************
* Apex Class Name   : FnA_ScopeTriggerHandlerTest
* Related Class Name: FnA_ScopeTriggerHandler
* Version           : 1.0
* Functionality     : This is Test class to cover FnA_ScopeTrigger, FnA_ScopeTriggerHandler, SCS_ConstantRTypeReference
*/
@isTest
public class FnA_ScopeTriggerHandlerTest {
	//Setup data...
    @testSetup static void setup() {     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass()); 
        
        List<Program__c> proList = SCS_TestDataFactory.createPrograms(1);        
        insert proList; 
        
        List<Scope__c> scopeList = SCS_TestDataFactory.createScope(2); 
        scopeList[0].Program__c = proList[0].Id;
        scopeList[0].RecordTypeId = SCS_ConstantRTypeReference.scope_SubScopeRTId;
        scopeList[1].RecordTypeId = SCS_ConstantRTypeReference.scope_opportunityRTId;
        scopeList[1].Program__c = proList[0].Id;
        insert scopeList; 
    }
    
    @isTest static void testInvoiceLine() {
        Test.startTest();        
        //Set Mock response...
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorClass()); 
        //Get records ...
        List<Scope__c> recordList =[SELECT Id, Name FROM Scope__c];
        recordList[1].Sub_Scope__c = recordList[0].Id;
        //Update records...
        update recordList;        
        Test.stopTest();  
        delete recordList;
    }
}