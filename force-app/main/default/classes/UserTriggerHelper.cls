/*
@Author : MAANTIC
@CreatedDate : 31th MAY 2022
@Description : This helper control by user trigger to add user in public group

@Revision : Utkarsh(Maantic) : 10th Oct, 2022 - Added IsActive Condition for Update
*/
public class UserTriggerHelper {
    
    //Use to stop the recursion...
    public static Boolean isRecursive = true;
    public static void addUserInPublicGroup(List<User> NewUserList,Map<Id,User> oldUserMap){
        //List use to hold new group member.
        List<GroupMember> listGroupMember =new List<GroupMember>();
        //Map use to hold user id as a key group name as value.
        Map<Id,List<String>> userGroupMap = new Map<Id,List<String>>();
        //Old Map use to hold user id as a key group name as value. 
        Map<Id,List<String>> OldUserGroupMap = new Map<Id,List<String>>();
        //Set of group Name.
        Set<String> groupNames = new Set<String>();
        //Looping all new or old user.
        for(User usr : NewUserList){
            
            
            //Execute when record is insert.
            if(oldUserMap == null && !String.isBlank(usr.Entities__c)){
                List<String> newEntiltyList =usr.Entities__c.split(';');
                userGroupMap.put(usr.id,newEntiltyList);
                groupNames.addAll(newEntiltyList);
            }
            //Execute when record is update.
            if(oldUserMap != null && usr.IsActive && (
                    (oldUserMap.get(usr.Id).Entities__c != usr.Entities__c) ||
                    (oldUserMap.get(usr.Id).IsActive != usr.IsActive)
                )
            ){
                if(!String.isBlank(usr.Entities__c)){
                    List<String> newEntiltyList =usr.Entities__c.split(';');
                    userGroupMap.put(usr.id,newEntiltyList);
                    groupNames.addAll(newEntiltyList);
                }
                //Add old group name in set.
                List<String> oldEntitiesList = oldUserMap.get(usr.Id).Entities__c !=null ? oldUserMap.get(usr.Id).Entities__c.split(';'):null;
                OldUserGroupMap.put(usr.id,oldEntitiesList);
                if(oldEntitiesList !=null && !oldEntitiesList.isEmpty()){
                    groupNames.addAll(oldEntitiesList);
                }
            }
            
        }
        //Check if set is empty or not.
        if(!groupNames.isEmpty()){
            //Query existing group name.
            list<Group> groupList = [SELECT Id,Name FROM Group WHERE Name IN: groupNames];
            //Set to hold group id of deleted user id.
            Set<String> deletedGroupIds = new Set<String>();
            //Set to hold deleted user id.
            Set<String> deletedUserIds = new Set<String>();
            //Looping current users.
            for(User u : NewUserList){
                //Looping current group list.
                for(Group grp : groupList){
                    //Check for new group member
                    if(!userGroupMap.isEmpty() && userGroupMap.containsKey(u.Id) && userGroupMap.get(u.Id).contains(grp.Name)){
                        system.debug('inside***');
                        GroupMember gm= new GroupMember(); 
                        gm.GroupId = grp.id;
                        gm.UserOrGroupId = u.id;
                        listGroupMember.add(gm);
                    } else if(!OldUserGroupMap.isEmpty() && OldUserGroupMap.containsKey(u.Id) && OldUserGroupMap.get(u.Id).contains(grp.Name)){
                        deletedGroupIds.add(grp.id);
                        deletedUserIds.add(u.id);
                        
                    }
                }
            }
            try {
                //Delete the group member from existing group.
                if(!deletedGroupIds.isEmpty() && !deletedUserIds.isEmpty()){
                    List<GroupMember> ListGM  = [SELECT Id FROM GroupMember WHERE UserOrGroupID IN :deletedUserIds AND GroupId IN :deletedGroupIds ];
                    if(!ListGM.isEmpty()){
                        delete ListGM;
                    }
                }
            } catch (Exception e) {
                System.debug('Error : Group Member Failed***'+e);
            }
            try {
                //Add new group member into group
                if(!listGroupMember.isEmpty()){
                    insert listGroupMember;
                }
            } catch (Exception e) {
                System.debug('Error : Group Member Insertion Failed***'+e);
            }
        }
        
    }  
}