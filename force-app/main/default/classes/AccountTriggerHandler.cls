/**
 Description    :   Handler for Account Trigger
 Date           :   20th March, 2023
 Author         :   Utkarsh G (Maantic)
 Test Class     :   AccountTriggerHandlerTest
 */
public  class AccountTriggerHandler {
    /**
     * Prevent to Delete Account with DMS or Quickbooks related
     * @param oldAccounts to be validated
     */
    public static void preventDeleteAccount(List<Account> oldAccounts){
        //test github
        Boolean hasPermission = FeatureManagement.checkPermission('Bypass_Permission');

        for (Account account : oldAccounts) {
            if((account.DMS_Client_ID__c != null || account.Quickbooks_ID__c != null) && !hasPermission){
                account.addError('This Account can not be deleted');
            }
        }
    }
}