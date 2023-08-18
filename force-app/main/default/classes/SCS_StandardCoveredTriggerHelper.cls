/**************************************************** NEW ORG CODE ***************************************************************** 
* Apex Class Name   : SCS_StandardCoveredTriggerHelper
* Related Class Name: SCS_StandardCoveredTriggerTest
* Version           : 1.0
* Description     	: Standard Covered Object Trigger Handler
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Sohit Tripathi                    21-06-2023                          Initial version 
************************************************************************************************************************************/
public with sharing class SCS_StandardCoveredTriggerHelper {

    //Update comma seperated title of standard covered on opportunity
    public static void updateTitleonOppty(List<Standard_Covered__c> recordList){
        Map<Id, String> mapOpptyANDTitle = new Map<Id, String>();
        List<Opportunity> opptyListToUpdate = new List<Opportunity>();
        Set<Id> opptyIdSet = new Set<Id>();
        
        //Loop on inserted/deleted record list
        for(Standard_Covered__c std : recordList){
            if(std.Opportunity__c != null && String.isNotBlank(std.Title__c)){
                opptyIdSet.add(std.Opportunity__c);
            }
        }
        
        //Fetching all standard covereds related to the opportunity
        if(!opptyIdSet.isEmpty()){
            for(Standard_Covered__c std: [SELECT Id, Title__c, Opportunity__c FROM Standard_Covered__c WHERE Opportunity__c IN:opptyIdSet]){
                if(String.isNotBlank(std.Title__c)){
                    if(!mapOpptyANDTitle.containsKey(std.Opportunity__c)){
                        mapOpptyANDTitle.put(std.Opportunity__c, std.Title__c);
                    }
                    else{
                        String title = mapOpptyANDTitle.get(std.Opportunity__c) + ', ' + std.Title__c;
                        mapOpptyANDTitle.put(std.Opportunity__c, title);
                    }
                }
            }
        }
        
        //Updating opportunity's standard covered title field with the comma seperared title of all standard covered
        if(!mapOpptyANDTitle.isEmpty()){
            for(Id oppId : mapOpptyANDTitle.keySet()){
                String title = mapOpptyANDTitle.containsKey(oppId) && String.isNotBlank(mapOpptyANDTitle.get(oppId)) ? mapOpptyANDTitle.get(oppId) : '';
                title = title.removeEnd(', ');
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Standard_Covered_Titles__c = title;
            	opptyListToUpdate.add(opp);
            }
        }
        
        //Updating opportunity
        if(!opptyListToUpdate.isEmpty()){
            update opptyListToUpdate;
        }
    }
}