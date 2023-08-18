/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : Trigger Dispatcher.
*/
public with sharing class TriggerDispatcher {
    
    /*
    @Description : It will invoke the appropriate methods on the handler depending on the trigger context.
    @Parameters : ITriggerHandler handler
    */
    public static void run(ITriggerHandler handler, String trigger_Name){
        
        //Get the trigger active information from custom meta data by trigger name
        Boolean isActive = Trigger_Setting__mdt.getInstance(trigger_Name).Is_Active__c;
        
        if(isActive){
            //Check trigger context from trigger operation type
            switch on Trigger.operationType {
                
                when BEFORE_INSERT {
                    //Invoke before insert trigger handler
                    handler.beforeInsert(Trigger.new);
                }
                when AFTER_INSERT {
                    //Invoke after insert trigger handler
                    handler.afterInsert(Trigger.new, Trigger.newMap);
                }
                when BEFORE_UPDATE {
                    //Invoke before update trigger handler
                    handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                when AFTER_UPDATE {
                    //Invoke after update trigger handler
                    handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                when BEFORE_DELETE {
                    //Invoke before delete trigger handler
                    handler.beforeDelete(Trigger.old, Trigger.oldMap);
                }
                when AFTER_DELETE {
                    //Invoke after delete trigger handler
                    handler.afterDelete(Trigger.old, Trigger.oldMap);
                }
                when AFTER_UNDELETE {
                    //Invoke after undelete trigger handler
                    handler.afterUnDelete(Trigger.new, Trigger.newMap);
                }
            }
        }
    }
}