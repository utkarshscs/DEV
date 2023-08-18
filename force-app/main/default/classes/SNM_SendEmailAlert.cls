/*
@Author : MAANTIC
@CreatedDate : 27th August 2022
@Description : Call from flow when lead is created send the email to customer.
*/

public with sharing class SNM_SendEmailAlert {
    
    @InvocableMethod(label='When Lead Is Created Send Email To Customer')    
    public static void sendEmailTOCustomer(List<Id> ids) {
        
        Set<String> programNames = new Set<String>();//Program name set...
        Map<String,String> templateMap =new Map<String,String>();//Template map...
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();//list of emails...
        List<Lead> leads = [SELECT Id,Owner.Email,Email,Program__c,Program__r.Name FROM Lead WHERE Id IN :ids];//query lead...
        for(Lead record : leads){
            if(!String.isBlank(record.Program__c)){
                programNames.add(record.Program__r.Name);
            }  
        }
        for(EmailTemplate template :[SELECT Id,Name FROM EmailTemplate WHERE Name IN : programNames]){
            templateMap.put(template.Name,template.Id);
        }
        //using loop create email for each lead...
        for(Lead record : leads){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(record.Id);//Set object record id...
            message.setReplyTo(record.Owner.Email);//Set sender email address...
            message.toAddresses = new String[] {record.Email};//Set to email address...
            if(templateMap.containsKey(record.Program__r.Name)){//check email template is exist...
                message.setTemplateID(templateMap.get(record.Program__r.Name));//set template Id...
                messages.add(message);//add single email object into list...
            }
        }
        //message.setWhatId('0066s000005cHUnAAM'); //This is important for the merge
        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);//send emails...
        }
    } 
}