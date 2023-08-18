/*
   Author: MAANTIC
   Description: Gneric trigger for lead objects


*/

trigger LeadTriggerGeneric on Lead (before insert,before update, after insert,after update) {

    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            //LeadGenericTriggerHelper.afterInsert(trigger.new,Trigger.newMap);
        }
        if(trigger.isUpdate)
        {
            LeadGenericTriggerHelper.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            LeadGenericTriggerHelper.afterInsert(trigger.new,Trigger.newMap);
        } 
    }

    
}