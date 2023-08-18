global class sfilesBatchToHideAuthComp implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful, schedulable{
    
    global void execute(SchedulableContext sc){
        sfilesBatchToHideAuthComp batch = new sfilesBatchToHideAuthComp();
        Database.executeBatch(batch, 100);
    }
    
    global database.querylocator start(database.batchableContext bc){
        String query = 'SELECT Id, User.Name,IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ExternalDataSourceId, UserId, Protocol, Username, Password, AuthProviderId FROM ExternalDataUserAuth';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc, List<ExternalDataUserAuth> authenticatedUsersList){
        System.debug('authenticatedUsersList Size Batch-- '+authenticatedUsersList.size());
        Set<Id> userIdSet = new Set<Id>();
        List<User> userListToUpdate = new List<User>();
        List<Integration_Log__c>  integrationLogs = new List<Integration_Log__c>();
        
        for(ExternalDataUserAuth extAuth : authenticatedUsersList){
            userIdSet.add(extAuth.UserId);
        }
        
        if(userIdSet != null && !userIdSet.isEmpty()){
            for(User u : [SELECT Id, Name, sFiles_Authenticated__c FROM User WHERE Id IN:userIdSet]){
                if(!u.sFiles_Authenticated__c){
                    u.sFiles_Authenticated__c = true;
                    userListToUpdate.add(u);
                }
            }
        }
        
        if(userListToUpdate != null && !userListToUpdate.isEmpty()){
            List<Database.SaveResult> dsrs = Database.Update(userListToUpdate, false);
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    
                    Integration_Log__c log = new Integration_Log__c(Account__c = userListToUpdate[index].Id, Integration_Status__c = 'DML Exception', Error_Message__c = errMsg);
                    integrationLogs.add(log);
                }
                index++;
            }
        }
        
         //Capturing Exception logs
        if(integrationLogs != null && !integrationLogs.isEmpty()){
            insert integrationLogs;
        }
        
    }
    
    global void finish(database.batchableContext bc){
        
    }
    
    
}