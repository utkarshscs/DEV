trigger CaseTrigger on Case (after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        system.debug('Inside insert');
        List<Case> toBeCreated = new List<Case>();
        for(Case c : Trigger.new) {
            toBeCreated.add(c);
        }
        JCFS.API.createJiraIssueWithDefaultPostAction(Label.Jira_Project_Id, Label.Jira_Issue_Type_Id, toBeCreated, null);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        system.debug('Inside update');
        JCFS.API.pushUpdatesToJira();
    }
}