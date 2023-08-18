/*
@Author : MAANTIC
@CreatedDate : 11th JUly 2022
@Description : Opportunity Object Trigger Helper use to update opportunity and goal object..
Date: 27/10/2022
Added by pass logic for CVENT INTEGRATION USER
30th March, 2023 - Utkarsh G : Added logic to update child opportunities stage when bundle is closed won
*/
public with sharing class SCS_OpportunityTriggerHelper {
    
    //Use to stop the recursion...
    public static Boolean isRecursive = true;   
    
    public static final String INITIAL = 'Initial';
    public static final String EVALUTAION = 'Evaluation';
    public static final String OPP_Existing_Business = 'Existing Business';
    
    //Create standard covered.
    public static void createStandardCovered(List<Opportunity> newTrigger){
        Set<String> programSet =new Set<String>();
        Set<String> languageSet =new Set<String>();
        for(Opportunity oppRecord : newTrigger){
            if(oppRecord.Type == 'New Business'){
                if(String.isNotBlank(oppRecord.Programc__c)){
                    programSet.add(oppRecord.Programc__c);
                }
                if(String.isNotBlank(oppRecord.Language__c)){
                    languageSet.add(oppRecord.Language__c);
                }
            }
        }
        system.debug('programSet='+programSet);
        if(!programSet.isEmpty()){
            Map<String,List<Standard__c>> standardMap = new Map<String,List<Standard__c>>();
            //Query program default standard.
            system.debug('programSet=1'+programSet);
            for(Standard__c stndardRecord :[SELECT Id,Name,Program__c FROM Standard__c WHERE Program__c IN : programSet AND DefaultStandard__c = true AND Language__c IN : languageSet WITH SECURITY_ENFORCED]){
                if (!standardMap.containsKey(stndardRecord.Program__c)) {
                    standardMap.put(stndardRecord.Program__c, new List <Standard__c>());
                }
                standardMap.get(stndardRecord.Program__c).add(stndardRecord);
                system.debug('standardMap='+standardMap);
            }
            if(!standardMap.isEmpty()){
                List<Standard_Covered__c> standardCoveredList = new List<Standard_Covered__c>();
                //Create standard covered.
                for(Opportunity oppRecord : newTrigger){
                    if(String.isNotBlank(oppRecord.Programc__c) && standardMap.containsKey(oppRecord.Programc__c) && !standardMap.get(oppRecord.Programc__c).isEmpty()){
                        for(Standard__c stndardRecord : standardMap.get(oppRecord.Programc__c)){
                            standardCoveredList.add(new Standard_Covered__c(/*Name =stndardRecord.Name,*/Opportunity__c = oppRecord.Id,Standard__c = stndardRecord.Id));
                        }
                    }
                }
                system.debug('standardCoveredList='+standardCoveredList);
                if(!standardCoveredList.isEmpty()){
                    try{
                        insert standardCoveredList;
                    } catch (Exception e){
                        System.debug('Standard Covered creation failed :'+e);
                    }  
                }
            }
        }
    }
    
    public static void updateBundledOpptyAmount(List<Opportunity> newTrigger,Map<Id,Opportunity> oldTrigger){
        Set<Id> bundleOpptyIdSet = new Set<Id>();
        List<Opportunity> bundleOpptyListToUpdate = new List<Opportunity>();
        Map<Id, Decimal> mapBundleAmt = new Map<Id, Decimal>();
        
        for(Opportunity oppRecord : newTrigger){
            if(oppRecord.TotalAmount__c != oldTrigger.get(oppRecord.Id).TotalAmount__c || 
               oppRecord.Bundle_Opportunity__c != oldTrigger.get(oppRecord.Id).Bundle_Opportunity__c)
            {
                if(oppRecord.Bundle_Opportunity__c != null){
                    bundleOpptyIdSet.add(oppRecord.Bundle_Opportunity__c);
                }
                if(oldTrigger.get(oppRecord.Id).Bundle_Opportunity__c != null){
                    bundleOpptyIdSet.add(oldTrigger.get(oppRecord.Id).Bundle_Opportunity__c);
                }
            }
        }
        
        if(bundleOpptyIdSet != null && !bundleOpptyIdSet.isEmpty()){
            for(Opportunity opp : [SELECT Id, Bundle_Opportunity__c, TotalAmount__c FROM Opportunity WHERE Bundle_Opportunity__c IN:bundleOpptyIdSet]){
                if(!mapBundleAmt.containsKey(opp.Bundle_Opportunity__c)){
                    mapBundleAmt.put(opp.Bundle_Opportunity__c, opp.TotalAmount__c);
                }
                else{
                    mapBundleAmt.put(opp.Bundle_Opportunity__c, mapBundleAmt.get(opp.Bundle_Opportunity__c) + opp.TotalAmount__c);
                }
            }
            for(Id bundleOpptyId : bundleOpptyIdSet){
                Opportunity opp = new Opportunity();
                opp.Id = bundleOpptyId;
                opp.TotalAmount__c = mapBundleAmt.containsKey(bundleOpptyId) ? mapBundleAmt.get(bundleOpptyId) : 0;
                bundleOpptyListToUpdate.add(opp);
            }
        }                
        if(bundleOpptyListToUpdate != null && !bundleOpptyListToUpdate.isEmpty()){
            try{ 
                update bundleOpptyListToUpdate;
            }catch (Exception e){
                System.debug('Bundle Opportunity update failed :'+e);
            }
        }
    }
    
    /*
Author  :   Utkarsh Goswami (Maantic)
Description : To assign program list on opportunity
JIRA        :   S20SM-528
Conditions  :   Update Program_List__c value on opportunity based on Program__c name
This Program_List__c value will populate Engagement Type picklist(Dependent Picklist)
Program_List__c is not restricted picklist new value will be added and Default Engagement Type Will be Initial
Params      : Called from Opportunity Trigger (Before Insert and Update) OldMap, NewMap
*/
    public static void updateProgramListInsertOrUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        
        Map<Id,Id> mapOfProgramIdAndProgramId = new Map<Id,Id>();
        Map<Id,Program__c> programMap = new Map<Id,Program__c>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        List<Standard_Covered__c> stdCovList = new List<Standard_Covered__c>();
        
        if(oldMap == null){
            
            System.debug('$$$$$$ oldMap If ' + oldMap);
            
            for( Opportunity opp : newList){
                
                System.debug('$$$$$$ oldMap If opp Programc__c ' + opp.Programc__c);
                //if(String.isNotBlank(opp.Programc__c ) && opp.RecordTypeId != SCS_ConstantRTypeReference.standard_RTId){ 
                //For FnA deployment we need to comment line no 536 and un comment line no :538
                if(String.isNotBlank(opp.Programc__c ) && opp.RecordTypeId != SCS_ConstantRTypeReference.standard_RTId && opp.Previous_Opportunity__c == null){ 
                    //&& opp.RecordTypeId != SCS_ConstantRTypeReference.standard_RTId
                    mapOfProgramIdAndProgramId.put(opp.Programc__c, opp.Programc__c);
                }
            }
            
        }
        else{
            
            System.debug('$$$$$$ oldMap else ' + oldMap);
            
            for(Opportunity opp : newList){
                
                System.debug('$$$$$$ oldMap else opp Programc__c ' + opp.Programc__c);
                if(String.isNotBlank(opp.Programc__c) && opp.RecordTypeId != SCS_ConstantRTypeReference.standard_RTId){
                    if(opp.Programc__c != oldMap.get(opp.Id).Programc__c){
                        mapOfProgramIdAndProgramId.put(opp.Programc__c, opp.Programc__c);    
                    }
                    //Added by Sohit on 14/10/2022
                    if(opp.Programc__c != oldMap.get(opp.Id).Programc__c || opp.Language__c != oldMap.get(opp.Id).Language__c){
                        opportunityMap.put(opp.Id, opp);
                    }
                }
                else{
                    opp.Program_List__c = '';
                }
            }
        }
        
        System.debug('$$$$$$ oldMap mapOfOppIdAndProgram ' + mapOfProgramIdAndProgramId);
        if(mapOfProgramIdAndProgramId.size() > 0 )
            updateProgramList(mapOfProgramIdAndProgramId, newList);
        
        //Added by Sohit on 14/10/2022
        if(opportunityMap != null){
            for(Standard_Covered__c std : [SELECT Id FROM Standard_Covered__c WHERE Opportunity__c IN : opportunityMap.keySet()]){
                stdCovList.add(new Standard_Covered__c(Id = std.Id));
            }
            createStandardCovered(opportunityMap.values());
        }
        
        if(stdCovList != null && !stdCovList.isEmpty()){
            Delete stdCovList;
        }
        
    }
    
    /*
Author  :   Utkarsh Goswami (Maantic)
Description : Actual Logic to update Program List
Called from updateProgramListInsertOrUpdate
*/
    public static void updateProgramList(Map<Id,Id> mapOfProgramIdAndProgramId, List<Opportunity> newList){
        
        System.debug('$$$$$$ updateProgramList called');
        Map<Id,Program__c> programMap = new Map<Id,Program__c>([Select Id, Name FROM Program__c WHERE Id IN :mapOfProgramIdAndProgramId.values()]);  
        for(Opportunity opp : newList){
            if(mapOfProgramIdAndProgramId.containsKey(opp.Programc__c) && 
               programMap.containsKey(mapOfProgramIdAndProgramId.get(opp.Programc__c)) 
              ){
                  System.debug('$$$$$$ main if ' + opp.Program_List__c);
                  opp.Program_List__c = programMap.get(mapOfProgramIdAndProgramId.get(opp.Programc__c)).Name;
                  System.debug('$$$$$$ main if opp.Program_List__c' + opp.Program_List__c);
                  if(String.isBlank(opp.Engagement_Type__c) && opp.Type != OPP_Existing_Business ){
                      opp.Engagement_Type__c = INITIAL;
                      If(opp.Program_List__c ==Label.Fair_Trade_USA){
                          opp.Engagement_Type__c = EVALUTAION;
                      }
                  }
              }
        }
    }
    
    public static void sFilesCreateOpportunityFolder(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity opp : newList){
            if(oldMap == null){
                if(opp.createdById != System.Label.SCS_CVENT_USER_Id && opp.DMS_Project_ID__c == null){
                    opptyIdSet.add(opp.Id);
                }
            }
            else{
                if(opp.Create_Sharepoint_Folder__c != oldMap.get(opp.Id).Create_Sharepoint_Folder__c && opp.Create_Sharepoint_Folder__c == true){
                    opptyIdSet.add(opp.Id);
                }
            }
        }
        
        if(opptyIdSet != null && !opptyIdSet.isEmpty() && !(Test.isRunningTest()) ){
            system.debug('inside callout to sfiles');
            sFilesCallout.createFoldersonSharePoint(opptyIdSet);
        }
    }
    
    public static void addOppContactRoles(List<Opportunity> newList){
        
    }
    
    /*
Author  :   Utkarsh Goswami (Maantic)
Description : Update child opportunities to closed won/lost when bundle is closed won/lost
Issue while closing Child Opp - There are custom validation rules which fires on opp closing
if we are closing child opp directly then custom validation may fire.
*/
    public static void updateChildOpportuityStage(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        
        // Record type for Bundle Opportunity
        Id bundle_Rt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Bundle_Opportunity').getRecordTypeId();
        String Error_Message = 'Please check all child opportunities, one of your child opportunity may have following error ->';
        
        List<Opportunity> childOpportunity = new List<Opportunity>();
        Set<Id> filteredOpportunity = new Set<Id>();
        Map<Id,String> errorMap = new Map<Id,String>();
        Map<Id,Id> childAndBundleIdMap = new Map<Id,Id>();
        
        // filtering for bundle opportunity only
        for(Opportunity filtOpp : newMap.values()){
            if(filtOpp.RecordTypeId == bundle_Rt &&
                filtOpp.StageName != oldMap.get(filtOpp.Id).StageName &&
                (filtOpp.StageName == 'Closed Won' || filtOpp.StageName == 'Closed Lost')
            )
                filteredOpportunity.add(filtOpp.Id);
        }
        
        // check if bundle opportunty is present
        if(filteredOpportunity.size() > 0){
            
            // querying all the child opportunties for the Bundles present in filteredOpportunity
            for(Opportunity opp : [Select StageName, Id, Bundle_Opportunity__c From Opportunity Where Bundle_Opportunity__c In :filteredOpportunity]){
                
                //child opp stage update
                opp.StageName = newMap.get(opp.Bundle_Opportunity__c).StageName;
                childOpportunity.add(opp);
                // this map holds child opportunity id and its Bundle opportunity Id
                childAndBundleIdMap.put(opp.Id,opp.Bundle_Opportunity__c);
            }
            
            // check if there are child opportunitied to be updated
            if(childOpportunity.size() > 0){
                
                // Using Database update as we want to update the once not having any issues
                // we only need to block the once having issues
                List<Database.SaveResult> updateResults = Database.update(childOpportunity, false);
                
                // Check for success and failed records.
                // We are only concerned about failed records - to show error
                for(Database.SaveResult r : updateResults){
                    if(!r.isSuccess()){
                        for(Database.Error e : r.getErrors()){
                            // map of child opportunity id and Errormessage
                            errorMap.put(r.getId(), e.getMessage());  
                        }
                    }
                }
            }
            System.debug('%%%%%% errorMap ' + errorMap);
            if(errorMap.size()>0){
                for(Id childId : errorMap.keySet()){
                    if(childAndBundleIdMap.containsKey(childId) && String.isNotBlank(childAndBundleIdMap.get(childId))){
                        
                        //getting bundle opportunity from the newmap and adding the error message
                        newMap.get(childAndBundleIdMap.get(childId)).addError(Error_Message + errorMap.get(childId));
                    }
                }
            }
        }
    }
    
    /*
Author  :   Farhan Khan (Maantic)
Description : Introduced as part of Case:00001499. User should not be able to change the Opportunity Amount or Close
Date of Closed Won new Business type Opportunities. If they do then capture the Reason for change.
*/
    public static void requireReasonForChangeValidation(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        for(Opportunity opp: newList){
            Opportunity oldOpp = oldMap.get(opp.Id);
            Double closeDateQuarter = Math.Ceil(oldOpp.CloseDate.Month()/3);
            Double currentQuarter = Math.Ceil(Date.today().Month()/3);
            if(opp.Reason_for_change__c ==null && opp.Type == 'New Business' && opp.StageName == 'Closed Won' &&
               (opp.CloseDate != oldOpp.CloseDate) && 
               ((oldOpp.CloseDate.Year() == Date.today().Year()) && (closeDateQuarter < currentQuarter) ||
                (oldOpp.CloseDate.Year() < Date.today().Year()))){
                    opp.Reason_for_change__c.addError('Please provide Reason for Change');                   
                }
        }
    }
}