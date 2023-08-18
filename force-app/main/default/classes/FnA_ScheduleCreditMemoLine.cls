/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : FnA_ScheduleCreditMemoLine
* Related Class Name: FnA_SyncCreditMemoLine
* Division          : FnA
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : This schedular use to sync fw1__Credit_Memo_Line__c in evey 20 minutes from new org to old org.And batch size must be 1.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        14-03-2023                          Initial version 
************************************************************************************************************************************/


public with sharing class FnA_ScheduleCreditMemoLine implements Schedulable {
    
    public void execute(SchedulableContext sc){
        Database.executebatch(new FnA_SyncCreditMemoLine(),1);
    }
}