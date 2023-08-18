/*
@Author : MAANTIC
@CreatedDate : 30 November 2022
@Description : Opportunity Certificate Object Trigger Helper use to update opportunity certificate..
Date: 30/11/2022
Created By: Sohit Tripathi
*/
public with sharing class OpportunityCertificateTriggerHelper {
    
    public static void sFilesCreateOpportunityCertFolder(List<Opportunity_Certificate__c> newList, Map<Id, Opportunity_Certificate__c> oldMap){
        Set<Id> opptyCertIdSet = new Set<Id>();
        for(Opportunity_Certificate__c oppCert : newList){
            if(oldMap == null){
                if(oppCert.createdById != System.Label.SCS_CVENT_USER_Id){
                    opptyCertIdSet.add(oppCert.Id);
                }
            }
            else{
                if(oppCert.Create_Sharepoint_Folder__c != oldMap.get(oppCert.Id).Create_Sharepoint_Folder__c && oppCert.Create_Sharepoint_Folder__c == true){
                    opptyCertIdSet.add(oppCert.Id);
                }
            }
        }
        
        if(opptyCertIdSet != null && !opptyCertIdSet.isEmpty() && !(Test.isRunningTest()) ){    
            sFilesCallout.createFoldersonSharePointForOpptyCertificate(opptyCertIdSet);
        }
    }

}