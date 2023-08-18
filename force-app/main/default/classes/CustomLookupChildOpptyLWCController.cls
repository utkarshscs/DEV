/*
@Author : MAANTIC
@CreatedDate : 20th March 2023
@Description : This class is used to add product in bundle opportunity lightning web component.
@CreatedBy : Sohit Tripathi
*/
/****************************** New ORG CODE *****************************************************/
public without sharing class CustomLookupChildOpptyLWCController {
    
    @AuraEnabled(cacheable=true)
    public static list<sObject> searchLookupData(String searchKey , String sObjectApiName, String pricebookId) {   
        List < sObject > returnList = new List < sObject > ();
        String sWildCardText = '%' + searchKey + '%';
        String sQuery = '';
        String pricebook2Id = pricebookId;
        if(sObjectApiName == 'pricebookentry'){
            if(String.isNotBlank(searchKey)){
                sQuery = 'Select Product2.Name, Product2Id From ' + sObjectApiName + ' Where Pricebook2Id =:pricebook2Id AND IsActive = true AND Product2.Name Like : sWildCardText order by createdDate DESC';
            }
            else{
                sQuery = 'Select Product2.Name, Product2Id From ' + sObjectApiName + ' Where Pricebook2Id =:pricebook2Id AND IsActive = true order by createdDate DESC';
            }
        }
        else{
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        }
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject searchDefaultRecord(String recordId , String sObjectApiName) {
        String sRecId = recordId;    
        String sQuery = 'Select Product2.Name, Product2Id From ' + sObjectApiName + ' Where Product2Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}