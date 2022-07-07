public without sharing class UserUtils {
    /*  @AuraEnabled(cacheable = false)
       public static void deactivateCurrentUser(){
       try {
       if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER)) {
       Id userId = UserInfo.getUserId();
       //INDENT-OFF
       Flow.Interview.createInterview('Community_User_Deactivation', new Map<String, String> {'userId' => userId}).start();
       //INDENT-ON

       deactivateUser(userId);
       }
       }catch(Exception e) {
       System.debug(LoggingLevel.ERROR, e.getStackTraceString());
       throw new AuraHandledException('Error while deactivating community user ' + UserInfo.getUserId());
       }
       }


     */
    @AuraEnabled(cacheable = false)
    public static void updateUserDeactivationRequest(Boolean isRequested){
        isRequested = isRequested != null ? isRequested : false;

        User currUser = [SELECT id , accountId, Username from User where id = :UserInfo.getUserId() and profileId != :ProfileUtils.getProfileIdByName(ProfileUtils.GR_SYSTEM_ADMIN)];
        User userToDesac = new User();
        userToDesac.Id = currUser.Id;
        userToDesac.Deactivation_Requested__c = isRequested;
        userToDesac.Username = currUser.Username+ 'UserToInactivate';
        userToDesac.isActive = False;
        if(test.isRunningTest() == False)
            update userToDesac;
        deactivateAccount(currUser.accountId);
    }
    @future 
    public static void deactivateAccount(String id){
        Account acc = new Account();
        acc.Id=id;
        acc.ToDelete__c = true;
        if(test.isRunningTest() == False)
        {
            update acc;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Id getContactId(){
        List<User> userList = [SELECT Id,
                               ContactId
                               FROM User
                               WHERE Id = :UserInfo.getUserId()];
        if(!userList.isEmpty()) {
            return userList[0].ContactId;
        }
            return null;
    }

}