/*
@Author : MAANTIC
@CreatedDate : Sept 2022
@Description : Test Class for UserTrigger.
*/

@isTest
public class UserTrigger_Test {
    
    @testSetup static void setup() {
        //Create SCS users...
        List<User> userList = SCS_TestDataFactory.createUsers(SCS_TestDataFactory.getSystemIntegratorProfile(),5);
        List<User> newUserList = new List<User>();
        for(Integer i=0;i<userList.size();i++) {
            User usr = userList[i];
            usr.Email = 'sys.admin@gmail.com';
            usr.Alias = 'sysadmuk';
            newuserList.add(usr);      
        }   
        insert newUserList;
    }
    
    @isTest static void testUserEntity() {
        Test.startTest();
        //Updated users list...
        List<User> UpdatedUsers = new List<User>();
        //Set of user ids...
        Set<String> usrIds = new Set<String>();
        //Query all inserted user...
        for(User obj :[SELECT Id,Entities__c FROM User WHERE Alias = 'sysadmuk' AND Email = 'sys.admin@gmail.com']){
            obj.Entities__c ='Food and Agriculture;Natural Resources';
            UpdatedUsers.add(obj);
            usrIds.add(obj.Id);
        }
        //Update users entity...
        if(!UpdatedUsers.isEmpty()){
            update UpdatedUsers;
        }
        //Set of unique group...
        Set<String> groupNames = new Set<String>();
        groupNames.add('Food and Agriculture');
        groupNames.add('Natural Resources');
        //Query the group id...
        Map<ID, Group> groupMap = new Map<ID, Group>([SELECT id,name FROM Group WHERE Name IN: groupNames]);
        //Query the inserted user from group...
        List<GroupMember> ListGM  = [SELECT Id FROM GroupMember WHERE UserOrGroupID IN :usrIds AND GroupId  IN :groupMap.keySet()];
        System.assertNotEquals(0,ListGM.size(),'Group Member should not be null');
        
        //Call un-use method 
        UserTriggerHandler uth =new UserTriggerHandler();
        uth.beforeDelete(null,null);
        uth.afterDelete(null,null);
        uth.afterUnDelete(null,null);
        Test.stopTest();  
    }  
}