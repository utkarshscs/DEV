/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : Project Comment Object Trigger Helper use to Insert Contact,Stakeholder,AccountContactRelation
and Update Stakeholder.
*/
public with sharing class ProjectCommentTriggerHelper {
    
    //Use to stop the recursion...
    public static Boolean isRecursive = true;
    public static void createStakeholderAndContact(List<Project_Comments__c> newTrigger){
        
        system.debug('createStakeholderAndContact called from project comment');
        
        //List use to hold new contact.
        List<Contact> contactList = new List<Contact>();
        //List use to hold existing email and Contact relationship.
        Map<String,Contact> mapOfEmailConRelation = new Map<String,Contact>();
        //List use to hold email and ContactID relationship.
        Map<String,Id> mapOfEmailConIdRelation = new Map<String,Id>();
        //Map use to hold AccountContactRelation...
        Map<String,AccountContactRelation> mapOfConAccRelation = new Map<String,AccountContactRelation>();
        //Set use to hold project comment email.
        ////List use to hold new account contact relationship..
        List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();
        Set<String> emails =new Set<String>();
        //Get account id from project object using project id.
        String projectAccountId = [ SELECT id,inspire1__Account__c from inspire1__Project__c WHERE Id =:newTrigger[0].Project__c].inspire1__Account__c;
        system.debug('projectAccountId-->'+projectAccountId);
        system.debug('comment.Project__c ID-->'+newTrigger[0].Project__c);
        
        system.debug('newTrigger-->'+newTrigger);
        
        //Get All account contact relation using account id.
        for(AccountContactRelation accConRelation :[SELECT Id,AccountId,ContactId FROM AccountContactRelation WHERE AccountId =:projectAccountId]){
            if(!String.isBlank(accConRelation.ContactId)){
                mapOfConAccRelation.put(accConRelation.ContactId,accConRelation);
            } 
        }
        
        //Loop use to set unique email into emails set.
        for(Project_Comments__c pcObj : newTrigger){
            if(!String.isBlank(pcObj.Email__c)){
                emails.add(pcObj.Email__c);  
            }
        }
        
            system.debug('emails-->'+emails);
        
        //Check if ACR exist for exsisting contact, If not then create ACR
        if(!emails.isEmpty()){
            for(Contact conObj :[SELECT Id,FirstName,LastName,Email FROM Contact WHERE Email IN :emails]){
                mapOfEmailConRelation.put(conObj.Email,conObj);
                
                //Add new Account contact relation into list.
                if(!mapOfConAccRelation.containsKey(conObj.Id) && !String.isBlank(projectAccountId)){
                    
                    accountContactRelList.add(new AccountContactRelation(
                    AccountId = projectAccountId,
                    ContactId = conObj.Id,
                    Roles = System.Label.SCS_Roles,
                    Entity__c = System.Label.SCS_Entity
                    )); 
                }
                
            }
        }
        system.debug('accountContactRelList-->'+accountContactRelList);
        
        try {
            //Insert new Account contact relation record if it doesn't exist..
            if(!accountContactRelList.isEmpty()){
                insert  accountContactRelList;
            } 
        } catch (Exception e) {
            System.debug('Error : Account Contact Relationship Creation Failed ***'+e);
        }
        
        system.debug('mapOfEmailConRelation-->'+mapOfEmailConRelation);
        
        //Loop use to set unique email into emails set.
        //create new contact if not there in system
        emails =new Set<String>();
        for(Project_Comments__c pcObj : newTrigger){
            if(!String.isBlank(pcObj.Email__c)){
                if( !(mapOfEmailConRelation.containsKey(pcObj.Email__c)) && !String.isBlank(projectAccountId) ){
                    if(!emails.contains(pcObj.Email__c)){
                        contactList.add(new Contact(
                            FirstName = pcObj.FirstName__c,
                            LastName = pcObj.LastName__c,
                            Email = pcObj.Email__c,
                            AccountId = projectAccountId  
                        ));
                        emails.add(pcObj.Email__c);
                    }                  
                }                
            }
        }
        
        system.debug('contactList null check -->'+contactList);
        
        try {
            //Insert new contact.
            if(!contactList.isEmpty()){
                insert contactList;
            }
            system.debug('contactList with id-->'+contactList);
            
        } catch(Exception e){
            System.debug('Error : Contact Creation Failed***'+e);
        }
        
        for(Contact con : contactList){
            mapOfEmailConIdRelation.put(con.Email,con.Id);
        }
        
        //assign stakeholder for exsisting/newly created contact to each Project comment record.
        for(Project_Comments__c pcObj : newTrigger){
            system.debug('pcObj-->'+pcObj);
            if(!String.isBlank(pcObj.Email__c)){
                if( mapOfEmailConRelation.containsKey(pcObj.Email__c) ){
                    system.debug('mapOfEmailConRelation.get(pcObj.Email__c)-->'+mapOfEmailConRelation.get(pcObj.Email__c));
                    pcObj.Stakeholder__c = mapOfEmailConRelation.get(pcObj.Email__c).id;
                    pcObj.FirstName__c = mapOfEmailConRelation.get(pcObj.Email__c).FirstName;
                    pcObj.LastName__c = mapOfEmailConRelation.get(pcObj.Email__c).LastName;
                }else if( mapOfEmailConIdRelation.containsKey(pcObj.Email__c) ){
                    pcObj.Stakeholder__c = mapOfEmailConIdRelation.get(pcObj.Email__c);
                    system.debug('mapOfEmailConIdRelation.get(pcObj.Email__c)-->'+mapOfEmailConIdRelation.get(pcObj.Email__c));
                }
                else{
                    system.debug('nothing found');
                }
            }
        }          
    } 
}