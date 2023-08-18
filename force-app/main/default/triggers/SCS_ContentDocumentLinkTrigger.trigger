trigger SCS_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    //Call Trigger Dispatcher...
    TriggerDispatcher.run(new SCS_ContentDocumentLinkTriggerHandler(), 'ContentDocumentLink_Trigger');
}