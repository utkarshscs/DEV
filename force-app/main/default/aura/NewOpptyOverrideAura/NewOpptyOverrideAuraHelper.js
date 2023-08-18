({
	helperInIt: function(component, event) {
        var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
         
        if ( recordTypeId == $A.get("$Label.c.BundleRecordTypeId")) { 
            var evt = $A.get("e.force:navigateToComponent");  
            evt.setParams({  
                componentDef : "c:fnA_NewBundleOpportunity",  
                componentAttributes: {  
                    recordTypeId : recordTypeId  
                }  
            });  
            evt.fire();  
        } 
        else {  
            var createRecordEvent = $A.get("e.force:createRecord");  
            createRecordEvent.setParams({  
                "entityApiName" : "Opportunity",  
                "recordTypeId" : recordTypeId  
            });  
            createRecordEvent.fire();  
        }  
    }  
})