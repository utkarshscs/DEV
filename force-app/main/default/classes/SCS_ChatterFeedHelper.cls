/*
    Description    :  Helper class for EE_ChatterFeed  
    Author         :  Maantic
*/

public without sharing Class SCS_ChatterFeedHelper{
	// Private member variable
    @TestVisible private static boolean isTest = false;

    
    /*
        Description : This method creates a case when a chatter is posted with @SFDC_Support
        Params      : List<FeedItem>
    */
    
    public static void updateOrInsertCase(List<FeedItem> feedItems){
    
        Case caseObj;
        List<Case> caseList = new List<Case>();
        
        FeedComment fcomment;
        List<FeedComment> fcommentList = new List<FeedComment>();
        
        Id SupportRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Salesforce Support').getRecordTypeId();
        
        List<CollaborationGroup> cgp= [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' and name='SFDC Support'];
        List<Group> SupportSaleforce= [SELECT Id FROM Group where Type='Queue' AND Name='SFDCSupport' Limit 1];
        
        if(isTest || (cgp.size() > 0 && SupportSaleforce.size() > 0)){
        	string cgGroup = isTest == true ? '@SFDC Support' : '@'+cgp[0].Name;
            for(FeedItem item:feedItems){
                String postBody = item.Body;
                if(string.isNotBlank(item.Body) && item.Body.contains(cgGroup)){
                    string trimString;
                    if(item.Body.length()>250){
                        trimString= postBody.substring(0,250);
                        trimString = trimString.remove('@SFDC Support');
                    }
                    else{
                        trimString = item.Body.remove('@SFDC Support');
                    }
                    if(trimString.contains('<p>') || trimString.contains('</p>')){
                        trimString = trimString.remove('<p>');
                        trimString = trimString.remove('</p>');
                    } 
                    postBody=postBody.replaceAll('<[/a-zAZ0-9]*>','');
                    
                    caseObj = new Case();
                    caseObj.Description=postBody;
                    caseObj.OwnerId = isTest ? system.UserInfo.getUserId() : SupportSaleforce[0].Id;
                    caseObj.Chatter_Id__c = item.id;
                    caseObj.ChatterURL__c= URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ item.Id;
                    CaseObj.RecordTypeId = SupportRTId;
                    caseObj.Subject = trimString;                   
                    caseObj.Status='New';
                    caseList.add(caseObj);                   
                    
                    fcomment = new FeedComment();
                    fcomment.FeedItemId = item.Id;
                    fcomment.CommentBody = 'A new case has been created with SFDC Support. Link for the case : '+URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ caseObj.Id;
                    fcommentList.add(fcomment);
                }
            }
            if(caseList.size() > 0)
                insert caseList;
            if(fcommentList.size() > 0)
                insert fcommentList;
        }
        
        
    }
    
}