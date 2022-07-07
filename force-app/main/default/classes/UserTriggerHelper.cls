public class UserTriggerHelper {
    private static final Id partnerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);
    public static void addUserToGroup(List<User> usersList){
        
        List <String> usersIdsList = new List<String>();
        
        for(User user : usersList){
            if(user.ProfileId == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)){
                usersIdsList.add(user.Id);
            }
        }
        
        if(!usersIdsList.isEmpty()){
            addGroupMember(usersIdsList);
        }
    }

    public static void addUserNickName(List<User> usersList){
        Set<id> userContactIdSet =new Set<id>();
        Map<id,String> contactToNameMap =new Map<id,String>();
        Map<String,Id> nameToContactMap =new Map<String,Id>();
        Map<id,User> contactToUserMap =new Map<id,User>();

        for(User partUser : usersList){
            contactToUserMap.put(partUser.ContactId, partUser);
        }

        for(Contact partUser : [SELECT Id, Account.Name FROM Contact WHERE Id in :contactToUserMap.keySet()]){
            contactToNameMap.put(partUser.Id, partUser.Account.Name);
            nameToContactMap.put(partUser.Account.Name, partUser.Id);
        }
        for(User userWithSameAccName : [SELECT Id, Account.Name,contactId FROM User WHERE CommunityNickname in :contactToNameMap.values()]){
            if(nameToContactMap.containsKey(userWithSameAccName.Account.Name)){
                contactToNameMap.put(nameToContactMap.get(userWithSameAccName.Account.Name), userWithSameAccName.Account.Name + ' '+contactToUserMap.get(nameToContactMap.get(userWithSameAccName.Account.Name)).LastName);
            }                                
        }
        for(User partUser : usersList){
            if(partUser.profileId == partnerProfileId && partUser.ContactId != null ){ 
                String nickname = (!String.isBlank(contactToNameMap.get(partUser.ContactId))  ? contactToNameMap.get(partUser.ContactId) : '');
                if(nickname.length() > 40){
                    nickname = nickname.substring(0, 40);
                }
                partUser.CommunityNickname = nickname;   
            } 
        }           
    }
    
    @future
    private static void addGroupMember(List<Id> userIdList){
        CollaborationGroup b2bCommunityGroup;
        
        if(test.isRunningTest()){
            b2bCommunityGroup = [SELECT Id
                                 FROM CollaborationGroup
                                 WHERE Name = 'TestGroup'];
        }
        else{
            b2bCommunityGroup = [SELECT Id
                                 FROM CollaborationGroup
                                 WHERE Name =: Label.CollaborationGroup];
        }
        List<CollaborationGroupMember> collaborationGroupMemberList = new List <CollaborationGroupMember>();
        
        for(Id userId : userIdList)
        {
            if(userId != null)
            {
                CollaborationGroupMember gm = new CollaborationGroupMember();
                gm.collaborationGroupId = b2bCommunityGroup.id;
                gm.memberId = userId;
                gm.NotificationFrequency = 'P';
                collaborationGroupMemberList.add(gm);
            }
        }
        
        insert collaborationGroupMemberList;
    }
}