trigger EE_ChatterCommentUpdate on FeedComment (after insert,after update) {
    String FeedPostId,CommentBody;
     for(FeedComment fdcomment:Trigger.new)
     {
        FeedPostId=fdcomment.FeedItemId;
        CommentBody=fdcomment.CommentBody;
     }

    //Case caseObj = new Case();
    List<Case> caseObj = new List<Case>();
    caseObj=[Select Id,Status,Priority,Chatter_Id__c from Case where Chatter_Id__c =:FeedPostId limit 1];
    
    if(caseObj.size() > 0 ){
   // caseObj=[Select Id,Status,Chatter_Id__c from Case where Chatter_Id__c =:FeedPostId];
     
    if(CommentBody.containsIgnoreCase('#reopened'))
    {
        caseObj[0].Status='Reopened';
    }
    if(CommentBody.containsIgnoreCase('#InProgress'))
    {
        caseObj[0].Status='In Progress';
    }
    if(CommentBody.containsIgnoreCase('#closed'))
    {
        caseObj[0].Status='Closed';
    }
     if(CommentBody.containsIgnoreCase('#escalated'))
    {
        caseObj[0].Status='Escalated';
    }
         if(CommentBody.containsIgnoreCase('#high'))
    {
        caseObj[0].Priority='High';
    }
         if(CommentBody.containsIgnoreCase('#medium'))
    {
        caseObj[0].Priority='Medium';
    }
         if(CommentBody.containsIgnoreCase('#low'))
    {
        caseObj[0].Priority='Low';
    }
   
    update caseObj;
    }
}