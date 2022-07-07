global class AppleRegistrationHandler implements Auth.RegistrationHandler {
    global boolean canCreateUser(Auth.UserData data) {
        //TODO: Check whether we want to allow creation of a user with this data
        //Set<String> s = new Set<String>{'usernamea', 'usernameb', 'usernamec'};
        //if(s.contains(data.username)) {
        //return true;
        //}
        return true;
    }

    global User createUser(Id portalId, Auth.UserData data){
        User user = new User();
        String userExistsCustomLabelValue = System.Label.user_exists_label;
        if(!canCreateUser(data) || doesExist(data)) {
            throw new Auth.DiscoveryCustomErrorException(userExistsCustomLabelValue);
        } else if(data.attributeMap.containsKey('sfdc_networkid')) {
            Id personContactId;
            Id accountOwnerId = [SELECT Id FROM user WHERE username =: Label.SocialManagerUser]?.Id;
            //We have a community id, so create a user with community access

            Id devRecordTypeId = ObjectUtils.getRecordTypeId('Account', 'PersonAccount');

            List<Account> existingAccountsList = [SELECT Id, PersonEmail, PersonContactId
                                                  FROM Account
                                                  WHERE PersonEmail = :data.email];

            if(!existingAccountsList.isEmpty()) {
                personContactId = existingAccountsList.get(0).PersonContactId;
            } else {
                Account personAccount = new Account(
                    FirstName = data.firstName,
                    LastName = data.lastName,
                    OwnerId = accountOwnerId,
                    RecordTypeId = devRecordTypeId,
                    PersonEmail = data.email
                );

                insert personAccount;

                List<Account> accountsList = [SELECT PersonContactId
                                              FROM Account
                                              WHERE Id = :personAccount.Id];

                if(!accountsList.isEmpty()) {
                    personContactId = accountsList.get(0).PersonContactId;
                }
            }

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

        }

        return user;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User user = new User(id = userId);
        user.username = data.email != null ? data.email : user.username;
        user.email = data.email != null ? data.email : user.email;
        update(user);
    }

    private static Boolean doesExist(Auth.UserData data){
        List<User> usersList = [SELECT id, email
                                FROM User
                                WHERE email = : data.email];

        return !usersList.isEmpty();

    }
}