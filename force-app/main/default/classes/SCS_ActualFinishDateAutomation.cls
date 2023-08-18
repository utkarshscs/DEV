/****************************************************New ORG CODE ***************************************************************** 
* Class  Name       : SCS_ActualFinishDateAutomation
* Division          : Food and Agriculture
* Version           : 1.1
* Code reviewed By  : N/A
* JIRA Ticket       : SF20FA-1325
* Functionality     : This class use in scs_ProjectTaskHandler and scs_opportunityHandler to update Actual Finish Date on project Task.

* Modification Log  :
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        14-04-2023                          Initial version 
************************************************************************************************************************************/




public with sharing class SCS_ActualFinishDateAutomation {
    
    //call from SCS_Project Task Trigger handler on before event when record is created...
    public static void assignActualFinishDateOnProjectTask( List<inspire1__Project_Tasks__c> newTrigger){
        Set<Id> projectIdSet = new Set<Id>();
        for (inspire1__Project_Tasks__c record : newTrigger) {            
            if(record.Task_Category__c != null && record.inspire1__Project__c != null){
                projectIdSet.add(record.inspire1__Project__c);  
            } 
        }
        //If project id set in not empty...
        if(! projectIdSet.isEmpty()){
            Map<Id,inspire1__Project__c> projectMap = new Map<Id,inspire1__Project__c>([SELECT Id,inspire1__Opportunity1__c,inspire1__Opportunity1__r.WO_Sent_Date_Time__c,
            inspire1__Opportunity1__r.WO_Signed_Date_Time__c,inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c,inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c,
            inspire1__Opportunity1__r.Final_Invoice_Send_Date__c,inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c,inspire1__Opportunity1__r.Final_Invoice_Amount__c,
            inspire1__Opportunity1__r.Final_Invoice_Paid_Amount__c,inspire1__Opportunity1__r.Initial_Invoice_Amount__c,inspire1__Opportunity1__r.Initial_Invoice_Paid_Amount__c FROM inspire1__Project__c WHERE inspire1__Opportunity1__c !=null AND Id IN : projectIdSet]);
            for (inspire1__Project_Tasks__c record : newTrigger) {            
                if(record.Task_Category__c != null && record.inspire1__Project__c != null){
                    inspire1__Project__c project = projectMap.containsKey(record.inspire1__Project__c) ? projectMap.get(record.inspire1__Project__c) : null;  
                    if(project != null && project.inspire1__Opportunity1__c != null){
                        //If work order is send to client then complete the task...
                        if(record.Task_Category__c == 'WO Sent' && record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.WO_Sent_Date_Time__c != null){
                            record.inspire1__Status__c = 'Completed';
                            record.inspire1__Done__c = 100;
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.WO_Sent_Date_Time__c;
                            //If work order is signed by client then complete the task...
                        } else if(record.Task_Category__c == 'WO Signed' && record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.WO_Signed_Date_Time__c != null){
                            record.inspire1__Status__c = 'Completed';
                            record.inspire1__Done__c = 100;
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.WO_Signed_Date_Time__c;
                            //If initial invoice is send to client then complete the task...
                        } else if(record.Task_Category__c == 'Initial Invoice Sent' && record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c != null){
                            record.inspire1__Status__c = 'Completed';
                            record.inspire1__Done__c = 100;
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c;
                            //If initial invoice paid by client then complete the task...
                        } else if(record.Task_Category__c == 'Initial Payment Received' && record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c != null){
                            if(record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.Initial_Invoice_Amount__c == project.inspire1__Opportunity1__r.Initial_Invoice_Paid_Amount__c){
                                record.inspire1__Status__c = 'Completed';
                                record.inspire1__Done__c = 100;
                            }
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c;
                            //If final invoice is send to client then complete the task...
                        } else if(record.Task_Category__c == 'Final Invoice Sent' && project.inspire1__Opportunity1__r.Final_Invoice_Send_Date__c != null){
                            if(record.inspire1__Status__c != 'Completed'){
                                record.inspire1__Status__c = 'Completed' ;
                                record.inspire1__Done__c = 100;
                            }
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.Final_Invoice_Send_Date__c;
                            //If final invoice paid by client then complete the task...
                        } else if(record.Task_Category__c == 'Final Payment Received' && project.inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c != null){
                            if(record.inspire1__Status__c != 'Completed' && project.inspire1__Opportunity1__r.Final_Invoice_Amount__c == project.inspire1__Opportunity1__r.Final_Invoice_Paid_Amount__c){
                                record.inspire1__Status__c = 'Completed';
                                record.inspire1__Done__c = 100;
                            }
                            record.inspire1__Actual_Finish_Date__c = project.inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c;
                        }
                    }
                } 
            }
            
        }
    }
    //call from SCS_Opportunity Trigger handler after when record is update...
    public static void updateActualFinishDateOnProjectTask(List<Opportunity> newList,Map<Id,Opportunity> oldMap){
        Set<Id> oppoIdSet = new Set<Id>(); 
        for (Opportunity record : newList) { 
            Boolean  isWOSent = record.WO_Sent_Date_Time__c != oldMap.get(record.Id).WO_Sent_Date_Time__c ? true : false;
            Boolean  isWOSigned = record.WO_Signed_Date_Time__c != oldMap.get(record.Id).WO_Signed_Date_Time__c ? true : false;
            Boolean  isInitialInvoiceSent = record.Initial_Invoice_Send_Date__c != oldMap.get(record.Id).Initial_Invoice_Send_Date__c ? true : false;
            Boolean  isInitialInvoicePaid = record.Initial_Invoice_Payment_Date__c != oldMap.get(record.Id).Initial_Invoice_Payment_Date__c ? true : false;
            Boolean  isFinalInvoiceSent = record.Final_Invoice_Send_Date__c != oldMap.get(record.Id).Final_Invoice_Send_Date__c ? true : false;
            Boolean  isFinalInvoicePaid = record.Final_Invoice_Payment_Date__c != oldMap.get(record.Id).Final_Invoice_Payment_Date__c ? true : false;  
            if(isWOSent ||isWOSigned || isInitialInvoiceSent || isInitialInvoicePaid || isFinalInvoiceSent || isFinalInvoicePaid){
                oppoIdSet.add(record.Id);
            } 
        }
        //If opportunity id set in not empty...
        if(! oppoIdSet.isEmpty()){
            Map<Id,inspire1__Project__c> projectMap = new Map<Id,inspire1__Project__c>([SELECT Id FROM inspire1__Project__c WHERE inspire1__Opportunity1__c IN :oppoIdSet]);
            if(! projectMap.isEmpty()){
                List<inspire1__Project_Tasks__c> updatedTask = new List<inspire1__Project_Tasks__c>();
                List<inspire1__Project_Tasks__c> taskList = [SELECT Id,Task_Category__c,inspire1__Actual_Finish_Date__c,inspire1__Status__c,inspire1__Project__c,
                inspire1__Project__r.inspire1__Opportunity1__c,inspire1__Project__r.inspire1__Opportunity1__r.WO_Sent_Date_Time__c,inspire1__Project__r.inspire1__Opportunity1__r.WO_Signed_Date_Time__c,
                inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c,inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c,
                inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Send_Date__c,inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c,
                inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Amount__c,inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Paid_Amount__c,
                inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Amount__c,inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Paid_Amount__c FROM inspire1__Project_Tasks__c WHERE inspire1__Project__c IN : projectMap.keySet()];
                if(! taskList.isEmpty()){
                    for(inspire1__Project_Tasks__c record : taskList){
                        if(record.Task_Category__c != null && record.inspire1__Project__c != null && record.inspire1__Project__r.inspire1__Opportunity1__c != null){
                            //If work order is send to client then complete the task...
                            if(record.Task_Category__c == 'WO Sent' && record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.WO_Sent_Date_Time__c != null){
                                record.inspire1__Status__c = 'Completed';
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.WO_Sent_Date_Time__c;
                                //If work order is signed by client then complete the task...
                            } else if(record.Task_Category__c == 'WO Signed' && record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.WO_Signed_Date_Time__c != null){
                                record.inspire1__Status__c = 'Completed';
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.WO_Signed_Date_Time__c;
                                //If initial invoice is send to client then complete the task...
                            } else if(record.Task_Category__c == 'Initial Invoice Sent' && record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c != null){
                                record.inspire1__Status__c = 'Completed';
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Send_Date__c;
                                //If initial invoice paid by client then complete the task...
                            } else if(record.Task_Category__c == 'Initial Payment Received' && record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c != null){
                                if(record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Amount__c == record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Paid_Amount__c){
                                    record.inspire1__Status__c = 'Completed';
                                }
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.Initial_Invoice_Payment_Date__c;
                                //If final invoice is send to client then complete the task...
                            } else if(record.Task_Category__c == 'Final Invoice Sent' && record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Send_Date__c != null){
                                if(record.inspire1__Status__c != 'Completed'){ 
                                    record.inspire1__Status__c = 'Completed';
                                }
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Send_Date__c;
                                //If final invoice paid by client then complete the task...
                            } else if(record.Task_Category__c == 'Final Payment Received' && record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c != null){
                                if(record.inspire1__Status__c != 'Completed' && record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Amount__c == record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Paid_Amount__c){
                                    record.inspire1__Status__c = 'Completed';
                                }
                                record.inspire1__Actual_Finish_Date__c = record.inspire1__Project__r.inspire1__Opportunity1__r.Final_Invoice_Payment_Date__c;
                            }
                            updatedTask.add(record); 
                        }  
                    }
                }
                //update task with Actual Finish Date...
                if(! updatedTask.isEmpty()){
                    update  updatedTask;  
                }
            }
        }
    }
}