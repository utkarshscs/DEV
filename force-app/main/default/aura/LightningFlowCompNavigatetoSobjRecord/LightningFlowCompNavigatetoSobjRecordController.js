({
	 invoke : function(component, event, helper) {
		   // Get the record ID attribute
	        //var navService = component.find('navService');

   var record = component.get("v.recordId");
         console.log("testing");
   console.log(record);
       
         
   // Get the Lightning event that opens a record in a new tab
   var redirect = $A.get("e.force:navigateToSObject");
   
   // Pass the record ID to the event
  redirect.setParams({
      "recordId": record
   });
        
   // Open the record
   redirect.fire();

	}
})