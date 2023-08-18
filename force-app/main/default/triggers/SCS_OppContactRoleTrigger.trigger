/*
@Author         : MAANTIC
@CreatedDate    : 21st November 2022
@Description    : Opportunity Contact Role Trigger Handler
                  To sync the data between the new and old orgs.
@Jira           : https://scsglobalservices.atlassian.net/browse/SF20FA-236  

@HandlerClass   : SCS_OppContactRoleTriggerHandler

*/
trigger SCS_OppContactRoleTrigger on OpportunityContactRole(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    //Call Trigger Dispatcher...
    System.debug('SCS_OppContactRoleTrigger Fired ' );
    TriggerDispatcher.run(new SCS_OppContactRoleTriggerHandler(), 'OppContactRole_Trigger');
    
}