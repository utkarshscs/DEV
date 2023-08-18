/**************************************************** New ORG CODE ***************************************************************** 
* Class Name        : SCS_SchedularDeleteAttributeAssignment
* Related class     : SCS_DeleteAttributeAssignment
* Version           : 1.0
* Code reviewed By  : Amitava Dutta
* Functionality     : 

* Modification Log  : This schedular Runs Daily at 1:00 AM to delete attribute assignment where end date or expire date yesterday
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer Name                     Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Umesh Kumar                        08-06-2023                          Initial version 
************************************************************************************************************************************/

// This schedular Runs Daily at 1:00 AM.
public with sharing class SCS_SchedularDeleteAttributeAssignment implements Schedulable {
    
    public void execute(SchedulableContext sc){
        //Execute batch class...
        Database.executebatch(new SCS_DeleteAttributeAssignment(),200);
    }
}