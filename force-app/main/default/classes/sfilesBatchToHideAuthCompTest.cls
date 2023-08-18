/************************************************************************************************************************************************
Apex Class Name : sfilesBatchToHideAuthCompTest
Version         : 1.0
Created Date    : 
Function        : This test class is used to cover the 'sfilesBatchToHideAuthComp' batch class.
Modification Log:
-------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                                 Date                                Description
* -----------------------------------------------------------------------------------------------------------------------------------------------
Sohit Tripathi                          20/01/2023                            Initial version
**************************************************************************************************************************************************/
@isTest
public class sfilesBatchToHideAuthCompTest {
    
    @isTest 
    static void testHidesFilesComp() {
        Test.startTest();
        List<ExternalDataUserAuth> authenticatedUsersList = [SELECT Id, User.Name,IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ExternalDataSourceId, UserId, Protocol, Username, Password, AuthProviderId FROM ExternalDataUserAuth];
        
        sfilesBatchToHideAuthComp obh = new sfilesBatchToHideAuthComp();
        DataBase.executeBatch(obh); 
        
        sfilesBatchToHideAuthComp sh1 = new sfilesBatchToHideAuthComp();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Batch', sch, sh1); 
        Test.stopTest();
    }
}