/*
@Author : MAANTIC
@CreatedDate : 5th AUG 2022
@Description : Lead Trigger Handler For Hubspot.
*/

public class SCS_HubSpotDuplicateLeadCreator 
{
	@future
    public static void doCreateDuplicateLead(string JsonBody)
    {
        List<Lead> lstNewLead = new List<Lead>();
        List<Lead> newduplLead = new List<Lead>();
        lstNewLead = (List<Lead>)JSON.deserialize(JsonBody,List<Lead>.class );
        if(!lstNewLead.isEmpty()){
        for(Lead old:lstNewLead)
        {
            Lead ln = new Lead();
            ln.Program__c = old.program__c;
            ln.FirstName = old.firstname;
            ln.LastName = old.lastname;
            ln.Status = old.status;
            ln.Title = old.title;
            ln.Email = old.email;
            ln.LeadSource = old.leadsource;
            ln.Recent_Campaign__c = old.recent_campaign__c;
            ln.Company = old.Company;
            ln.Recipient_Email__c = old.Recipient_Email__c;
            newduplLead.add(ln);
            
        }
            
        Database.upsert(newduplLead,true);}
    }
    
    @future
    public static void doAddCapmaignMember(string jsonBody)
    {
        List<Lead> lstNewLead = new List<Lead>();
        List<campaignMember> newduplLead = new List<CampaignMember>();
        lstNewLead = (List<Lead>)JSON.deserialize(JsonBody,List<Lead>.class );
        if(!lstNewLead.isEmpty()){
        for(Lead old:lstNewLead)
        {
            Campaignmember cm = new Campaignmember();
            cm.CampaignId = old.Recent_Campaign__c;
            cm.Status = 'Sent';
            cm.LeadId = old.Id;
            newduplLead.add(cm);
            
        }
            
        Database.insert(newduplLead,false);}
        
        
    }
}