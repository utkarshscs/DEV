public class LeadGenericTriggerHelper {

    public static void afterInsert(List<Sobject> newList , Map<Id, Sobject> newMap) {
       
        // ------------ LEAD DATA SYNC BLOCK ---------------
        //Convert List<Sobject> into List<Lead>...
        List<Lead> recordList = (List<Lead>) newList;
        //Filter record list...
        List<Lead> leadList = new List<Lead>();
        
        // -------------------- END BLOCK ---------------------
         // Default Campaign member handling block
        List<Lead> lstLeadToCM = new List<Lead>();
        for(Lead ln:(List<Lead>)newList)
        {
            if(ln.Recent_Campaign__c !=null)
            {
                lstLeadToCM.add(ln);
            }
        }																																																																						
        
        //finally push them campaignmember module for simultaneous synching of Lead with campaign member.
        if(!System.isFuture() && !lstLeadToCM.isEmpty()){string jsonString = JSON.serialize(lstLeadToCM);
                                   SCS_HubSpotDuplicateLeadCreator.doAddCapmaignMember(jsonString);
                                  }	
    }
    
    
    //Call before update...
    public static void beforeUpdate(List<Sobject> newList, Map<Id, Sobject> newMap, List<Sobject> oldList, Map<Id, Sobject> oldMap) {
       //check whether this is MQL / HUBSPOT Lead
       List<Lead> newLeadList = new List<Lead>();
        
       Map<String,String> leadOld =  new Map<string,string>();
       Map<String,String> leadOldRecp = new Map<string,string>();
        
       // Prepare map for storing old program / recipient email 
       // for comparing with new record  
      
       for(Lead ldold: (List<Lead>)oldList)
       {
           leadOld.put(ldold.id, ldold.program__c);
           leadOldRecp.put(ldold.id, ldold.Recipient_Email__c);
       }
       //make collection of duplicate hubspot lead with various program
       //if program is different /existing lead gets converted then only create new separate lead for same person with multiple program 
       for(Lead lup:(List<Lead>)newList)
       {
           system.debug('source' +  lup.LeadSource);
           system.debug('STATEP' +  lup.program__c);
           system.debug('STATEPO' +  leadOld.get(lup.id));
           if(leadOld.get(lup.id) !=lup.program__c && leadOld.get(lup.id)!=null  && lup.LastModifiedById == Label.lblHubSpotUser )
           {
               newLeadList.add(lup);
           }
          
           
       }
        
       //always push Lead record  
        
       //system.debug('RECIPIENT' + newLeadList[0].Recipient_Email__c); 
       //finally create duplicate lead with different program
       if(!newLeadList.isEmpty()){string jsbody = JSON.serialize(newLeadList);
                                  
        
       		SCS_HubSpotDuplicateLeadCreator.doCreateDuplicateLead(jsbody);
            //SCS_HubSpotDuplicateLeadCreator.doAddCapmaignMember(jsbody);
                                  
       } 
	
       //finally reset hubspot earlier synched lead program id / recipient email address as Old one
       for(Lead lup:(List<Lead>)newList)
       {
           if(leadOld.get(lup.id) !=lup.program__c && leadOld.get(lup.id)!=null && lup.LastModifiedById == Label.lblHubSpotUser)
                 
           {
              
               lup.Program__c = leadOld.get(lup.id);
               lup.Recipient_Email__c = leadOldRecp.get(lup.id);
               //lup.Program__c = null;
               System.debug('OLD PROGRAM' + leadOld.get(lup.id) );
           }
           
       } 
        
    }
}