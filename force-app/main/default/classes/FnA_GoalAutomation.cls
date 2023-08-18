/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : FnA_GoalAutomation
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1242
* Functionality     : This helper use in SCS_OpportunityTriggerHandler class to create or update user goal or program goal on opportunity.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        11-07-2022                          Initial version 
* Umesh Kumar                        24-03-2023                          Code refinement and apply automation on type change.
************************************************************************************************************************************/

public with sharing class FnA_GoalAutomation {
    
    //Create or update goal when opportunity is created from scs_opportunityTriggerHandler...
    public static void createUserAndProgramGoal(List<Opportunity> newTrigger){
        //Define Set...
        Set<String> yearSet = new Set<String>();
        Set<String> ownerSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> quarterSet = new Set<String>();
        Map<String,Goal__c> newGoalMap = new Map<String,Goal__c>();
        Map<String,Goal__c> userGoalMap = new Map<String,Goal__c>();
        Map<String,Goal__c> programGoalMap = new Map<String,Goal__c>();
        
        for(Opportunity oppRecord : newTrigger){
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Name) && oppRecord.Name.endsWith('-')){
                oppRecord.Name = oppRecord.Name.removeEnd('-');
            }
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                yearSet.add(oppRecord.Year__c);
                ownerSet.add(oppRecord.OwnerId);
                quarterSet.add(oppRecord.Quarter__c);
                programSet.add(oppRecord.Programc__c);   
            }
        }
        
        if(!programSet.isEmpty()){
            programGoalMap.putAll(getProgramGoal(programSet,quarterSet,yearSet));
            userGoalMap.putAll(getUserGoal(programSet,quarterSet,yearSet,ownerSet));
            for(Opportunity oppRecord : newTrigger) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is program Goal Exist.
                    Boolean isProgramGoalExist = programGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    //Is user Goal Exist.
                    Boolean isUserGoalExist = userGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    if(isProgramGoalExist == false) {
                        newGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,createNewGoal(oppRecord,false));
                    }
                    if(isUserGoalExist == false) {
                        newGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,createNewGoal(oppRecord,true));
                    }
                }
            }
            programGoalMap.clear();
            userGoalMap.clear();
            //Create new goal.......
            if(!newGoalMap.isEmpty()){
                insert newGoalMap.values();
            }
            programGoalMap.putAll(getProgramGoal(programSet,quarterSet,yearSet));
            userGoalMap.putAll(getUserGoal(programSet,quarterSet,yearSet,ownerSet));
            Map<String,Goal__c> updatedGoalMap = new Map<String,Goal__c>();
            for(Opportunity oppRecord : newTrigger) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is program Goal Exist.
                    Boolean isProgramGoalExist = programGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    //Is user Goal Exist.
                    Boolean isUserGoalExist = userGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    //Update program goal amount...
                    if(isProgramGoalExist == true) {
                        oppRecord.Program_Goal__c = programGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c).Id;
                        Goal__c programGoal;
                        if(updatedGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c)){
                            programGoal = updatedGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        } else {
                            programGoal = programGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        }
                        updatedGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,addAmountOnExistingGoal(oppRecord,programGoal));   
                    }
                    //Update user goal amount...
                    if(isUserGoalExist == true) {
                        oppRecord.User_Goal__c = userGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c).Id;
                        Goal__c userGoal;
                        if(updatedGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c)){
                            userGoal = updatedGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        } else {
                            userGoal = userGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        }
                        updatedGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,addAmountOnExistingGoal(oppRecord,userGoal));   
                    }
                    
                    
                }
            }
            //Update user or program goal...
            if(! updatedGoalMap.isEmpty()){
                update updatedGoalMap.values();
            }
        }
    }
    
    //Execute when opportunity update...
    public static void updateUserAndProgramGoal(List<Opportunity> newTrigger,Map<Id,Opportunity> oldTrigger){
        //Is Amount change ...
        Set<String> goalIdWhenAmountChange = new Set<String>();
        List<Opportunity> newOppoWhenAmountChange = new List<Opportunity>();
        
        //If Quarter or Year or Program is change...
        Set<String> oldGoalIdProgramYQChange = new Set<String>();
        List<Opportunity> newProgramYearQuarterChange = new List<Opportunity>();
        List<Opportunity> oldProgramYearQuarterChange = new List<Opportunity>();
        
        //If Owner is change...
        Set<String> oldGoalIdWhenOwnerChange = new Set<String>();
        List<Opportunity> newOppoWhenOwnerChange = new List<Opportunity>();
        List<Opportunity> oldOppoWhenOwnerChange = new List<Opportunity>();
        
        //If Stage or Type is change...
        Set<String> goalIdWhenStageOrTypeChange = new Set<String>();
        List<Opportunity> newOppoWhenStageOrTypeChange = new List<Opportunity>();
        
        //If User goal is blank...
        List<Opportunity> oppoWithoutUserGoal = new List<Opportunity>();
        
        //If User and Program goal is blank on opportunity...
        List<Opportunity> oppoWithoutUserAndProgramGoal = new List<Opportunity>();
        
        //If Program goal is blank on opportunity...
        List<Opportunity> oppoWithoutProgramGoal = new List<Opportunity>();
        
        for(Opportunity oppRecord : newTrigger){
            Opportunity oldRecord = oldTrigger.get(oppRecord.Id);
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                //If amount is change...
                if(oppRecord.TotalAmount__c != oldRecord.TotalAmount__c){
                    newOppoWhenAmountChange.add(oppRecord);
                    goalIdWhenAmountChange.add(oppRecord.Program_Goal__c);
                    goalIdWhenAmountChange.add(oppRecord.User_Goal__c);
                }
                //If Quarter or Year or Program is change...
                if(oppRecord.Quarter__c != oldRecord.Quarter__c || oppRecord.Year__c != oldRecord.Year__c || oppRecord.Programc__c != oldRecord.Programc__c){
                    newProgramYearQuarterChange.add(oppRecord);
                    oldProgramYearQuarterChange.add(oldRecord);
                    oldGoalIdProgramYQChange.add(oldRecord.Program_Goal__c);
                    oldGoalIdProgramYQChange.add(oldRecord.User_Goal__c);
                }
                //If Owner is change...
                if(oppRecord.OwnerId != oldRecord.OwnerId){
                    newOppoWhenOwnerChange.add(oppRecord);
                    oldOppoWhenOwnerChange.add(oldRecord);
                    oldGoalIdWhenOwnerChange.add(oldRecord.User_Goal__c);
                }
                //If Stage is change...
                Boolean yearNoChange = oppRecord.Quarter__c == oldRecord.Quarter__c && oppRecord.Year__c == oldRecord.Year__c && oppRecord.Programc__c == oldRecord.Programc__c ? true : false;
                if(yearNoChange == true && (oppRecord.Type != oldRecord.Type || (oppRecord.StageName != oldRecord.StageName && (oppRecord.StageName == 'Closed Won' || oppRecord.StageName == 'Closed Lost' || oldRecord.StageName == 'Closed Won' || oldRecord.StageName == 'Closed Lost')))){
                    newOppoWhenStageOrTypeChange.add(oppRecord);
                    goalIdWhenStageOrTypeChange.add(oppRecord.Program_Goal__c);
                    goalIdWhenStageOrTypeChange.add(oppRecord.User_Goal__c);
                }
                //If User and program goal is blank on opportunity...
                if(oppRecord.Program_Goal__c == null && oppRecord.User_Goal__c == null){
                    oppoWithoutUserAndProgramGoal.add(oppRecord);
                }
                //If User goal is blank on opportunity...
                if(oppRecord.Program_Goal__c != null && oppRecord.User_Goal__c == null){
                    oppoWithoutUserGoal.add(oppRecord);
                }
                //If program goal is blank on opportunity...
                if(oppRecord.Program_Goal__c == null && oppRecord.User_Goal__c != null){
                    oppoWithoutProgramGoal.add(oppRecord);
                }
            }
        }
        //Run when amount is change on opportunity...
        if(! newOppoWhenAmountChange.isEmpty() && ! goalIdWhenAmountChange.isEmpty()){
            amountChangeOnOpportunity(newOppoWhenAmountChange,goalIdWhenAmountChange,oldTrigger);
        }
        //If Quarter or Year or Program is change...
        if(! newProgramYearQuarterChange.isEmpty() && ! oldProgramYearQuarterChange.isEmpty()){
            //Create or update user or program goal...
            createUserAndProgramGoal(newProgramYearQuarterChange);
            //Subtract amount from goal when Quarter or Year or Program is change...
            subtractAmountFromOldGoal(oldProgramYearQuarterChange,oldGoalIdProgramYQChange,true,true);
        }
        //if Owner is change...
        if(! newOppoWhenOwnerChange.isEmpty() && ! oldOppoWhenOwnerChange.isEmpty()){
            //Create or update user or program goal...
            createUserGoalOnUpdate(newOppoWhenOwnerChange);
            //Subtract amount from goal when owner is change...
            subtractAmountFromOldGoal(oldOppoWhenOwnerChange,oldGoalIdWhenOwnerChange,false,true);
        }
        //Run when Stage or Type is change on opportunity...
        if(! newOppoWhenStageOrTypeChange.isEmpty() && ! goalIdWhenStageOrTypeChange.isEmpty()){
            changeTypeOrStageOnOpportunity(newOppoWhenStageOrTypeChange,goalIdWhenStageOrTypeChange,oldTrigger);
        }
        //Create or update user or program goal...
        if(! oppoWithoutUserAndProgramGoal.isEmpty()){
            createUserAndProgramGoal(oppoWithoutUserAndProgramGoal);  
        }
        //Create or update user goal...
        if(! oppoWithoutUserGoal.isEmpty()){
            createUserGoalOnUpdate(oppoWithoutUserGoal);  
        }
        //Create or update program goal when program goal is missing on opportunity...
        if(! oppoWithoutProgramGoal.isEmpty()){
            createProgramGoalOnUpdate(oppoWithoutProgramGoal);
        }
    }
    //Start-Subtract amount from goal when opportunity is deleted...
    public static void subtractGoalAmountOnDelete(List<Opportunity> newTrigger){
        Set<String> userGoalIds = new Set<String>();
        Set<String> programGoalIds = new Set<String>();
        Set<String> userAndProgramGoalIds = new Set<String>();
        List<Opportunity> deletedOppoList = new List<Opportunity>();
        for(Opportunity oppRecord : newTrigger){
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                //If user and program goal exist...
                if(oppRecord.Program_Goal__c !=null && oppRecord.User_Goal__c !=null){
                    deletedOppoList.add(oppRecord);
                    userAndProgramGoalIds.add(oppRecord.Program_Goal__c);
                    userAndProgramGoalIds.add(oppRecord.User_Goal__c);
                    //If program goal exist...
                } else if(oppRecord.Program_Goal__c !=null && oppRecord.User_Goal__c ==null){
                    deletedOppoList.add(oppRecord);
                    programGoalIds.add(oppRecord.Program_Goal__c);
                    //If user goal exist...
                } else if(oppRecord.Program_Goal__c == null && oppRecord.User_Goal__c !=null){
                    deletedOppoList.add(oppRecord);
                    userGoalIds.add(oppRecord.User_Goal__c);
                }
            }
        }
        //Subtract amount from user and program goal when opportunity is deleted...
        if(! deletedOppoList.isEmpty() && ! userAndProgramGoalIds.isEmpty()){
            subtractAmountFromOldGoal(deletedOppoList,userAndProgramGoalIds,true,true);
        }
        //Subtract amount from program goal when opportunity is deleted...
        if(! deletedOppoList.isEmpty() && ! programGoalIds.isEmpty()){
            subtractAmountFromOldGoal(deletedOppoList,programGoalIds,true,false);
        }
        //Subtract amount from user goal when opportunity is deleted...
        if(! deletedOppoList.isEmpty() && ! userGoalIds.isEmpty()){
            subtractAmountFromOldGoal(deletedOppoList,userGoalIds,false,true);
        }  
    }
    //Run when amount is change on opportunity...
    public static void amountChangeOnOpportunity(List<Opportunity> oppoList,Set<String> setGoalIds,Map<Id,Opportunity> oldTrigger){
        if(! setGoalIds.isEmpty()){
            Map<Id,Goal__c> allGoals = getGoalsById(setGoalIds);
            for(Opportunity oppRecord : oppoList){
                Opportunity oldRecord = oldTrigger.get(oppRecord.Id);
                if(oppRecord.Program_Goal__c !=null){
                    Goal__c programGoal = changeAmountOnExistingGoal(oppRecord,allGoals.get(oppRecord.Program_Goal__c),oldRecord);
                    allGoals.put(oppRecord.Program_Goal__c,programGoal);
                }
                if(oppRecord.User_Goal__c !=null){
                    Goal__c userGoal = changeAmountOnExistingGoal(oppRecord,allGoals.get(oppRecord.User_Goal__c),oldRecord);
                    allGoals.put(oppRecord.User_Goal__c,userGoal);
                }
            }
            //Update goal amount...
            if(!allGoals.isEmpty()){
                update allGoals.values();
            }
        } 
    }
    
    //Subtract amount from goal when Quarter or Year or Program or Owner is change...
    public static void subtractAmountFromOldGoal(List<Opportunity> oldOpportunity,Set<String> setGoalIds ,Boolean isOwnerChangeNo,Boolean isOwnerChangeYes){
        if(! setGoalIds.isEmpty()){
            Map<Id,Goal__c> oldGoals = getGoalsById(setGoalIds);
            for(Opportunity oldRecord : oldOpportunity){
                if(oldRecord.Program_Goal__c !=null && isOwnerChangeNo == true){
                    Goal__c programGoal = subtractAmountFromGoal(oldRecord,oldGoals.get(oldRecord.Program_Goal__c));
                    oldGoals.put(oldRecord.Program_Goal__c,programGoal);
                }
                if(oldRecord.User_Goal__c !=null && isOwnerChangeYes == true){
                    Goal__c userGoal = subtractAmountFromGoal(oldRecord,oldGoals.get(oldRecord.User_Goal__c));
                    oldGoals.put(oldRecord.User_Goal__c,userGoal);
                }
            }
            //Update goal amount...
            if(!oldGoals.isEmpty()){
                update oldGoals.values();
            }
        } 
    }
    
    //Run when Type or Stage change on opportunity...
    public static void changeTypeOrStageOnOpportunity(List<Opportunity> oppoList,Set<String> goalIds,Map<Id,Opportunity> oldTrigger){
        if(! goalIds.isEmpty()){
            Map<Id,Goal__c> allGoals = getGoalsById(goalIds);
            for(Opportunity oppRecord : oppoList){
                Opportunity oldRecord = oldTrigger.get(oppRecord.Id);
                if(oppRecord.Program_Goal__c !=null){
                    Goal__c programGoal = changeAmountOnGoalWhenTypeOrStageChange(oppRecord,allGoals.get(oppRecord.Program_Goal__c),oldRecord);
                    allGoals.put(oppRecord.Program_Goal__c,programGoal);
                }
                if(oppRecord.User_Goal__c !=null){
                    Goal__c userGoal = changeAmountOnGoalWhenTypeOrStageChange(oppRecord,allGoals.get(oppRecord.User_Goal__c),oldRecord);
                    allGoals.put(oppRecord.User_Goal__c,userGoal);
                }
            }
            //Update goal amount...
            if(!allGoals.isEmpty()){
                update allGoals.values();
            }
        } 
    }
    
    //Create or update goal when program goal is missing on opportunity...
    public static void createProgramGoalOnUpdate(List<Opportunity> oppoList){
        //Define Set...
        Set<String> yearSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> quarterSet = new Set<String>();
        Map<String,Goal__c> newGoalMap = new Map<String,Goal__c>();
        Map<String,Goal__c> programGoalMap = new Map<String,Goal__c>();
        
        for(Opportunity oppRecord : oppoList){
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                yearSet.add(oppRecord.Year__c);
                quarterSet.add(oppRecord.Quarter__c);
                programSet.add(oppRecord.Programc__c);   
            }
        }
        
        if(!programSet.isEmpty()){
            programGoalMap.putAll(getProgramGoal(programSet,quarterSet,yearSet));
            for(Opportunity oppRecord : oppoList) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is program Goal Exist.
                    Boolean isProgramGoalExist = programGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    if(isProgramGoalExist == false) {
                        newGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,createNewGoal(oppRecord,false));
                    }
                }
            }
            programGoalMap.clear();
            //Create new goal.......
            if(!newGoalMap.isEmpty()){
                insert newGoalMap.values();
            }
            programGoalMap.putAll(getProgramGoal(programSet,quarterSet,yearSet));
            Map<String,Goal__c> updatedGoalMap = new Map<String,Goal__c>();
            for(Opportunity oppRecord : oppoList) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is program Goal Exist.
                    Boolean isProgramGoalExist = programGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    //Update program goal amount...
                    if(isProgramGoalExist == true) {
                        oppRecord.Program_Goal__c = programGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c).Id;
                        Goal__c programGoal;
                        if(updatedGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c)){
                            programGoal = updatedGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        } else {
                            programGoal = programGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        }
                        updatedGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,addAmountOnExistingGoal(oppRecord,programGoal));   
                    }     
                }
            }
            //Update user or program goal...
            if(! updatedGoalMap.isEmpty()){
                update updatedGoalMap.values();
            }
        }
    }
    
    //Create or update user goal when Owner is change or user goal is missing on opportunity...
    public static void createUserGoalOnUpdate(List<Opportunity> oppoList){
        //Define Set...
        Set<String> yearSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> quarterSet = new Set<String>();
        Set<String> ownerSet = new Set<String>();
        Map<String,Goal__c> newGoalMap = new Map<String,Goal__c>();
        Map<String,Goal__c> userGoalMap = new Map<String,Goal__c>();
        
        for(Opportunity oppRecord : oppoList){
            if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                programSet.add(oppRecord.Programc__c);
                ownerSet.add(oppRecord.OwnerId);
                quarterSet.add(oppRecord.Quarter__c);
                yearSet.add(oppRecord.Year__c); 
            }
        }
        
        if(!programSet.isEmpty()){
            userGoalMap.putAll(getUserGoal(programSet,quarterSet,yearSet,ownerSet));
            for(Opportunity oppRecord : oppoList) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is user Goal Exist.
                    Boolean isUserGoalExist = userGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    if(isUserGoalExist == false) {
                        newGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,createNewGoal(oppRecord,true));
                    }
                }
            }
            userGoalMap.clear();
            //Create new goal.......
            if(!newGoalMap.isEmpty()){
                insert newGoalMap.values();
            }
            userGoalMap.putAll(getUserGoal(programSet,quarterSet,yearSet,ownerSet));
            Map<String,Goal__c> updatedGoalMap = new Map<String,Goal__c>();
            for(Opportunity oppRecord : oppoList) {
                if(String.isBlank(oppRecord.DMS_Project_ID__c) && String.isNotBlank(oppRecord.Programc__c) && oppRecord.Record_Type_Name__c !='Bundle_Opportunity'){
                    //Is user Goal Exist.
                    Boolean isUserGoalExist = userGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c) ? true :false;
                    //Update user goal amount...
                    if(isUserGoalExist == true) {
                        oppRecord.User_Goal__c = userGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c).Id;
                        Goal__c userGoal;
                        if(updatedGoalMap.containsKey(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c)){
                            userGoal = updatedGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        } else {
                            userGoal = userGoalMap.get(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c);
                        }
                        updatedGoalMap.put(oppRecord.Programc__c+'@'+oppRecord.OwnerId+'@'+oppRecord.Quarter__c+'@'+oppRecord.Year__c,addAmountOnExistingGoal(oppRecord,userGoal));   
                    }
                    
                    
                }
            }
            //Update user or program goal...
            if(! updatedGoalMap.isEmpty()){
                update updatedGoalMap.values();
            }
        }
    }
    
    //Add and subtract amount when type change on opportunity...
    public static Goal__c changeAmountOnGoalWhenTypeOrStageChange(Opportunity newRecord,Goal__c recordGoal,Opportunity oldRecord){
        System.debug('Goal Record :'+recordGoal);
        //For New Business add amount...
        if(newRecord.Type == 'New Business') {
            if(newRecord.StageName != 'Closed Won' && newRecord.StageName != 'Closed Lost') {
                recordGoal.New_Pipeline__c = recordGoal.New_Pipeline__c != null ? recordGoal.New_Pipeline__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;  
            } else if(newRecord.StageName == 'Closed Won') {
                recordGoal.New_Closed__c = recordGoal.New_Closed__c != null ? recordGoal.New_Closed__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;
            } else if(newRecord.StageName == 'Closed Lost') {
                recordGoal.New_Closed_Lost__c = recordGoal.New_Closed_Lost__c != null ? recordGoal.New_Closed_Lost__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;
            } 
            //For Existing Business add amount...
        } else if(newRecord.Type == 'Existing Business') {
            if(newRecord.StageName == 'Closed Won'){
                recordGoal.Renewal_Closed__c = recordGoal.Renewal_Closed__c != null ? recordGoal.Renewal_Closed__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;
            } else if(newRecord.StageName == 'Closed Lost'){
                recordGoal.Renewal_Closed_Lost__c = recordGoal.Renewal_Closed_Lost__c != null ? recordGoal.Renewal_Closed_Lost__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;
            } else if(newRecord.StageName != 'Closed Won' && newRecord.StageName != 'Closed Lost'){
                recordGoal.Renewal_Pipeline__c = recordGoal.Renewal_Pipeline__c != null ? recordGoal.Renewal_Pipeline__c + newRecord.TotalAmount__c : newRecord.TotalAmount__c;
            }
        }
        //For New Business subtract amount...
        if(oldRecord.Type == 'New Business') {
            if(oldRecord.StageName != 'Closed Won' && oldRecord.StageName != 'Closed Lost') {
                recordGoal.New_Pipeline__c = recordGoal.New_Pipeline__c - oldRecord.TotalAmount__c;  
            } else if(oldRecord.StageName == 'Closed Won') {
                recordGoal.New_Closed__c = recordGoal.New_Closed__c - oldRecord.TotalAmount__c;
            } else if(oldRecord.StageName == 'Closed Lost') {
                recordGoal.New_Closed_Lost__c = recordGoal.New_Closed_Lost__c - oldRecord.TotalAmount__c;
            } 
            //For Existing Business subtract amount...
        } else if(oldRecord.Type == 'Existing Business') {
            if(oldRecord.StageName == 'Closed Won'){
                recordGoal.Renewal_Closed__c = recordGoal.Renewal_Closed__c - oldRecord.TotalAmount__c;
            } else if(oldRecord.StageName == 'Closed Lost'){
                recordGoal.Renewal_Closed_Lost__c = recordGoal.Renewal_Closed_Lost__c - oldRecord.TotalAmount__c;
            } else if(oldRecord.StageName != 'Closed Won' && oldRecord.StageName != 'Closed Lost'){
                recordGoal.Renewal_Pipeline__c = recordGoal.Renewal_Pipeline__c - oldRecord.TotalAmount__c;
            }
        }
        return recordGoal;
    } 
    
    //Subtract amount from old goal...
    public static Goal__c subtractAmountFromGoal(Opportunity oppRecord,Goal__c recordGoal){
        //For New Business
        if(oppRecord.Type == 'New Business') {
            if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost') {
                recordGoal.New_Pipeline__c = recordGoal.New_Pipeline__c - oppRecord.TotalAmount__c;  
            } else if(oppRecord.StageName == 'Closed Won') {
                recordGoal.New_Closed__c = recordGoal.New_Closed__c - oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost') {
                recordGoal.New_Closed_Lost__c = recordGoal.New_Closed_Lost__c - oppRecord.TotalAmount__c;
            } 
            //For Existing Business
        } else if(oppRecord.Type == 'Existing Business') {
            if(oppRecord.StageName == 'Closed Won'){
                recordGoal.Renewal_Closed__c = recordGoal.Renewal_Closed__c - oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost'){
                recordGoal.Renewal_Closed_Lost__c = recordGoal.Renewal_Closed_Lost__c - oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost'){
                recordGoal.Renewal_Pipeline__c = recordGoal.Renewal_Pipeline__c - oppRecord.TotalAmount__c;
            }
        }
        return recordGoal;
    } 
    
    //Change existing goal...
    public static Goal__c changeAmountOnExistingGoal(Opportunity oppRecord,Goal__c recordGoal,Opportunity oldOpp){
        //For New Business
        if(oppRecord.Type == 'New Business') {
            if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost') {
                recordGoal.New_Pipeline__c = recordGoal.New_Pipeline__c != null ? recordGoal.New_Pipeline__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;  
            } else if(oppRecord.StageName == 'Closed Won') {
                recordGoal.New_Closed__c = recordGoal.New_Closed__c != null ? recordGoal.New_Closed__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost') {
                recordGoal.New_Closed_Lost__c = recordGoal.New_Closed_Lost__c != null ? recordGoal.New_Closed_Lost__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } 
            //For Existing Business
        } else if(oppRecord.Type == 'Existing Business') {
            if(oppRecord.StageName == 'Closed Won'){
                recordGoal.Renewal_Closed__c = recordGoal.Renewal_Closed__c != null ? recordGoal.Renewal_Closed__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost'){
                recordGoal.Renewal_Closed_Lost__c = recordGoal.Renewal_Closed_Lost__c != null ? recordGoal.Renewal_Closed_Lost__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost'){
                recordGoal.Renewal_Pipeline__c = recordGoal.Renewal_Pipeline__c != null ? recordGoal.Renewal_Pipeline__c - oldOpp.TotalAmount__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            }
        }
        return recordGoal;
    } 
    
    //Create new goal with 0 value...
    public static Goal__c createNewGoal(Opportunity oppRecord,Boolean isUserGoal){
        Goal__c newGoal = new Goal__c ();
        newGoal.Quarter__c = oppRecord.Quarter__c;
        newGoal.Year__c = oppRecord.Year__c;
        newGoal.Goal_Amount__c = 0;
        newGoal.New_Pipeline__c =0;
        newGoal.New_Closed__c =0;
        newGoal.New_Closed_Lost__c =0;
        newGoal.Renewal_Pipeline__c =0;
        newGoal.Renewal_Closed__c =0;
        newGoal.Renewal_Closed_Lost__c =0;
        newGoal.User__c = isUserGoal ? oppRecord.OwnerId :null;
        newGoal.Programc__c =  oppRecord.Programc__c ;
        newGoal.RecordTypeId = isUserGoal ? SCS_ConstantRTypeReference.userGoal_Goal_RTId : SCS_ConstantRTypeReference.programGoal_Goal_RTId;
        return newGoal;
    } 
    
    //Add TotalAmount__c to existing goal...
    public static Goal__c addAmountOnExistingGoal(Opportunity oppRecord,Goal__c recordGoal){
        //For New Business
        if(oppRecord.Type == 'New Business') {
            if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost') {
                recordGoal.New_Pipeline__c = recordGoal.New_Pipeline__c != null ? recordGoal.New_Pipeline__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;  
            } else if(oppRecord.StageName == 'Closed Won') {
                recordGoal.New_Closed__c = recordGoal.New_Closed__c != null ? recordGoal.New_Closed__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost') {
                recordGoal.New_Closed_Lost__c = recordGoal.New_Closed_Lost__c != null ? recordGoal.New_Closed_Lost__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } 
            //For Existing Business
        } else if(oppRecord.Type == 'Existing Business') {
            if(oppRecord.StageName == 'Closed Won'){
                recordGoal.Renewal_Closed__c = recordGoal.Renewal_Closed__c != null ? recordGoal.Renewal_Closed__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName == 'Closed Lost'){
                recordGoal.Renewal_Closed_Lost__c = recordGoal.Renewal_Closed_Lost__c != null ? recordGoal.Renewal_Closed_Lost__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            } else if(oppRecord.StageName != 'Closed Won' && oppRecord.StageName != 'Closed Lost'){
                recordGoal.Renewal_Pipeline__c = recordGoal.Renewal_Pipeline__c != null ? recordGoal.Renewal_Pipeline__c + oppRecord.TotalAmount__c : oppRecord.TotalAmount__c;
            }
        }
        return recordGoal;
    }
    
    //User or program goal...
    public static Map<Id,Goal__c> getGoalsById(Set<String> goalsId){
        Map<Id,Goal__c> goalMap = new Map<Id,Goal__c>([SELECT Id,Name,Programc__c,Quarter__c,Year__c,New_Pipeline__c,Renewal_Pipeline__c,New_Closed__c,Renewal_Closed__c,New_Closed_Lost__c,Renewal_Closed_Lost__c,User__c,RecordTypeId FROM Goal__c WHERE Id IN :goalsId WITH SECURITY_ENFORCED]);
        return goalMap; 
    }
    
    //Query all program goal based on program id, quarter and year...
    public static Map<String,Goal__c> getProgramGoal(Set<String> programSet,Set<String> quarterSet,Set<String> yearSet){
        //Map use  to hold new record program id as a key and goal object as a value..
        Map<String,Goal__c> progGoalMap =new Map<String,Goal__c>();
        for(Goal__c record :[SELECT Id,Name,Programc__c,Quarter__c,Year__c,New_Pipeline__c,Renewal_Pipeline__c,New_Closed__c,Renewal_Closed__c,New_Closed_Lost__c,Renewal_Closed_Lost__c,User__c,RecordTypeId FROM Goal__c WHERE Programc__c IN :programSet AND  Quarter__c IN : quarterSet AND Year__c IN : yearSet AND RecordTypeId =: SCS_ConstantRTypeReference.programGoal_Goal_RTId WITH SECURITY_ENFORCED]) {
            if(String.isNotBlank(record.Programc__c)){
                progGoalMap.put(record.Programc__c+'@'+record.Quarter__c+'@'+record.Year__c,record);
            }
        }
        return progGoalMap; 
    }
    
    //Query all user goal based on program id, quarter,year and owner id...
    public static Map<String,Goal__c> getUserGoal(Set<String> programSet,Set<String> quarterSet,Set<String> yearSet , Set<String> ownerSet ){
        //Map use  to hold new record program id as a key and goal object as a value..
        Map<String,Goal__c> usrGoalMap =new Map<String,Goal__c>();
        for(Goal__c record :[SELECT Id,Name,Programc__c,Quarter__c,Year__c,New_Pipeline__c,Renewal_Pipeline__c,New_Closed__c,Renewal_Closed__c,New_Closed_Lost__c,Renewal_Closed_Lost__c,User__c,RecordTypeId FROM Goal__c WHERE Programc__c IN :programSet AND User__c IN : ownerSet AND  Quarter__c IN : quarterSet AND Year__c IN : yearSet AND RecordTypeId =:SCS_ConstantRTypeReference.userGoal_Goal_RTId  WITH SECURITY_ENFORCED]) {
            if(String.isNotBlank(record.User__c) && String.isNotBlank(record.Programc__c)){
                usrGoalMap.put(record.Programc__c+'@'+record.User__c+'@'+record.Quarter__c+'@'+record.Year__c,record);
            }
        }
        return usrGoalMap; 
    } 
}