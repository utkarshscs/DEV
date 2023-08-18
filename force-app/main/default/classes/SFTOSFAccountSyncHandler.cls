/*
@Author : MAANTIC
@CreatedDate : 19th JULY 2022
@Description : Account Trigger Handler.
*/
/****************************** NEW ORG CODE *****************************************************/
public with sharing class SFTOSFAccountSyncHandler implements ITriggerHandler {
    
    //Call before insert...
    public void beforeInsert(List<Sobject> newList) {
		//Convert List<Sobject> into List<Account>...
        List<Account> recordList = (List<Account>)newList;
        for(Account record : recordList){
               if(record.isClone()){
	             record.External_Record_Id__c = null;
	           }
            }
		/*
		Id accCustRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		
		for(Account acc : newAccList){
			if(acc.DMS_Client_Id__c != null && acc.DMS_Site_Id__c != null && acc.ParentId == null){
				//Get Account(s) for the DMS client_id
				List<Account> getAccList = [SELECT Id FROM Account WHERE DMS_Client_Id__c =: acc.DMS_Client_Id__c AND DMS_Site_Id__c = null AND RecordTypeId =: accCustRecTypeId];
				
				if(getAccList != null && getAccList.Size() > 0){
					acc.ParentId = getAccList[0].Id; 
				}
			}
        }        */
    }
    //Call after insert...
    public void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
        //Use to store object name...
        String objectName = '';
        //Convert List<Sobject> into List<Account>...
        List<Account> recordList =(List<Account>)newList;
        //Check current record type is equal to customersite...
        if(recordList[0].RecordTypeId == SCS_ConstantRTypeReference.customerSite_Account_RTId) {
            objectName = 'Project_Site__c';
            //Check current record type is equal to account...
        } else if(recordList[0].RecordTypeId == SCS_ConstantRTypeReference.account_Account_RTId){
            objectName = 'Account';
        }
        //Add filter record into list...
        List<Account> accountList = new List<Account>();
        //Looping each record...
        for(Account acc : recordList){
            //Check last modified user not equal to web integrater user...
            if(acc.LastModifiedById != System.Label.Web_Integrator && acc.LastModifiedById != System.Label.SCS_CVENT_USER_Id){
                accountList.add(acc); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && objectName !='' && !accountList.isEmpty()){
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(accountList),objectName,'PATCH',''); 
        }
        
    }
    //Call before update...
    public void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {}
    //Call after update...
    public void afterUpdate(List<Sobject> newList,Map<Id,Sobject> newMap,List<Sobject> oldList, Map<Id,Sobject> oldMap) {
        //Add filter record into list...
        List<Sobject> accountList = new List<Sobject>();
        //Use to store object name...
        String objectName ='';
        //Convert List<Sobject> into List<Account>...
        List<Account> recordList =(List<Account>)newList;
        //Check current record type is equal to customersite...
        if(recordList[0].RecordTypeId == SCS_ConstantRTypeReference.customerSite_Account_RTId) {
            objectName = 'Project_Site__c';
            //Check current record type is equal to account...
        } else if(recordList[0].RecordTypeId == SCS_ConstantRTypeReference.account_Account_RTId){
            objectName = 'Account';
        }
        //Looping each record...
        for(Account acc : recordList){
            //Check last modified user not equal to web integrater user...
            if(acc.LastModifiedById != System.Label.Web_Integrator && acc.LastModifiedById != System.Label.SCS_CVENT_USER_Id){
                accountList.add(acc); 
            }
        }
        //Call sf connector to sync data from new org to old org...
        if(!System.isFuture() && objectName != '' && !accountList.isEmpty() ){ 
            SCS_SFToSFConnector.sFToSFConnector(JSON.serialize(accountList),objectName,'PATCH','');
        }
    }
    //Call before Delete...
    public void beforeDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after Delete...
    public void afterDelete(List<Sobject> oldList , Map<Id, Sobject> oldMap) {
        
    }
    //Call after UnDelete...
    public void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap) {
        
    }
    
}