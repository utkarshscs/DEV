trigger EE_ChatterFeed on FeedItem (after insert,after update) {

System.debug(' !!!! EE_Chatter Trigger Entry');
    SCS_ChatterFeedHelper.updateOrInsertCase(Trigger.new);
    System.debug(' !!!! EE_Chatter Trigger Exit'); 
}