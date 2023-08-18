public class sFilesQueableAccount implements Queueable{
    List<Account> accountList;
    public sFilesQueableAccount (List<Account> triggeredAccountList){
        accountList = triggeredAccountList;
    }
    
    public void execute(QueueableContext context){
        System.debug('accountList-8- '+accountList);
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> opptyIdSet = new Set<Id>();
        if(accountList != null && !accountList.isEmpty()){	
            for(Account acc : accountList){
                accIdSet.add(acc.Id);
            }
        }
        
        if(accIdSet != null && !accIdSet.isEmpty()){
            for(Opportunity opp : [SELECT Id FROM Opportunity WHERE AccountId IN:accIdSet AND IsConverted__c = True AND fileforcem1__Sharepoint_Folder_Id__c = null]){
                System.debug('Coming from queable- '+opp.Id);
                opptyIdSet.add(opp.Id);
            }
        }
        
        if(opptyIdSet != null && !opptyIdSet.isEmpty() && !Test.isRunningTest()){	
            sFilesCallout.createOpportunityFolderonSharePoint(opptyIdSet);
        }
    }
}