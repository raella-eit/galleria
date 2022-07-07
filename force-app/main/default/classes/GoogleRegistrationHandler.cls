global class GoogleRegistrationHandler implements Auth.RegistrationHandler {

    global static User createUser(Id portalId, Auth.UserData data){
        String userExistsCustomLabelValue = System.Label.user_exists_label;
        if(doesExist(data)) {
            throw new Auth.DiscoveryCustomErrorException(userExistsCustomLabelValue);

        } else {
            if(data.attributeMap.containsKey('sfdc_networkid')) {

                Id personContactId;
                Id accountOwnerId;
                if (Test.isRunningTest()) {
                    accountOwnerId = [SELECT Id FROM user WHERE username =: 'socialMgr_test@eit-test.gr.com'].Id;
                } else {
                    accountOwnerId = [SELECT Id FROM user WHERE username =: Label.SocialManagerUser].Id;
                }

                Id devRecordTypeId = ObjectUtils.getRecordTypeId('Account', 'PersonAccount');

                List<Account> existingAccount = [SELECT id, PersonEmail, personContactId
                                                 FROM Account
                                                 WHERE PersonEmail =:data.email];
                if(!existingAccount.isEmpty()) {
                    personContactId = existingAccount.get(0).personContactId;
                } else {
                    Account a = new Account(FirstName = data.FirstName, LastName = data.LastName, OwnerId = accountOwnerId, RecordTypeId = devRecordTypeId, PersonEmail = data.email);
                    insert a;

                    List<Account> accountList = [SELECT personContactId FROM Account WHERE id =:a.Id];
                    if(!accountList.isEmpty()) {
                        personContactId = accountList.get(0).personContactId;
                    }
                }

                User user = new User();
                Id customerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER);
                user.username = data.email;
                user.email = data.email;
                user.lastName = data.lastName;
                user.firstName = data.firstName;
                user.languagelocalekey = UserInfo.getLanguage();
                user.localesidkey = UserInfo.getLocale();
                user.emailEncodingKey = 'UTF-8';
                user.timeZoneSidKey = 'Asia/Dubai';
                user.profileId = customerProfileId;
                user.contactId = personContactId;
                String alias = data.firstName + data.lastName;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                user.alias = alias;

                return user;
            } else {

                User user = new User();
                Id stdUserId = ProfileUtils.getProfileIdByName(ProfileUtils.SF_STANDARD_USER);

                user.username = data.email;
                user.email = data.email;
                user.lastName = data.lastName;
                user.firstName = data.firstName;
                user.CommunityNickname = data.firstName;
                String alias = data.username;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                user.alias = alias;
                user.languagelocalekey = UserInfo.getLocale();
                user.localesidkey = UserInfo.getLocale();
                user.emailEncodingKey = 'UTF-8';
                user.timeZoneSidKey = 'Asia/Dubai';
                user.profileId = stdUserId;

                return user;
            }
        }
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User user = new User(id = userId);
        user.username = data.email;
        user.email = data.email;
        user.lastName = data.lastName;
        user.firstName = data.firstName;
        update(user);
    }

    private static Boolean doesExist(Auth.UserData data){
        List<User> usersList = [SELECT id, email
                                FROM User
                                WHERE email = :data.email];

        return !usersList.isEmpty();

    }
}