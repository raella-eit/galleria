global class SelfRegistrationHandlerGR_B2C {

    public User user {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String phoneCode {get; set;}
    public String username {get;  set {username = value == null ? value : value.trim(); } }
    public String firstname {get; set {firstname = value == null ? value : value.trim(); } }
    public String lastname {get; set {lastname = value == null ? value : value.trim(); } }
    public String mobilePhone {get; set {mobilePhone = value == null ? value : value.trim(); } }

    private final Long CURRENT_TIME = Datetime.now().getTime();
    private final String[] UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    private final String[] LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz'.split('');
    private final String[] NUMBER_CHARS = '1234567890'.split('');
    private final String[] SPECIAL_CHARS = '!#$%-_=+<>'.split('');
    private final Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    public SelfRegistrationHandlerGR_B2C(){
        this.user = new User();
    }

    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
        this.user = new User(FirstName = firstname, lastname = lastname, email = username, MobilePhone = mobilePhone);
        if(String.isBlank(user.Alias)) {
            user.Alias = generateAlias();
        }
        if(String.isBlank(user.CommunityNickname)) {
            user.CommunityNickname = generateCommunityNickname();
        }
        user.ProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER);
        // it's okay if password is null - we'll send the user a random password in that case
        if(!isValidPassword() || String.isBlank(password) || String.isBlank(confirmPassword)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match));

            return null;
        }
        if(!Pattern.matches('[0-9(),./\\-]+', user.MobilePhone)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The phone number can only contain numeric characters.'));

            return null;
        }
        try {
            Id userId = this.createUser(ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER));
            PageReference currentPage = ApexPages.currentPage();
            String urlSuffix = '';
            if(currentPage.getParameters().containsKey('callback')) {
                urlSuffix += '/' + currentPage.getParameters().get('callback');
                if(currentPage.getParameters().containsKey('id')) {
                    urlSuffix += '?recordId=' + currentPage.getParameters().get('id');
                }
            }
            if(userId != null) {

                return Site.login(username, password, '/b2c/s' + urlSuffix);
            }
        }catch(Auth.DiscoveryCustomErrorException e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);

            return null;
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Internal Error');
            ApexPages.addMessage(msg);
        }

        return null;
    }

    // This method is called once after verification (if any was configured)
    // This method should create a user and insert it
    // Password can be null
    // Return null or throw an exception to fail creation Schema.User.
    private Id createUser(Id profileId) {
        Id accountOwnerId = [SELECT Id FROM user WHERE username =: Label.SocialManagerUser].Id;
        Account accountToInsert = new Account();
        list<User> matchingUsername = [SELECT ID FROM User WHERE Username =: username];
        if(matchingUsername.size() != 0) {
            throw new Auth.DiscoveryCustomErrorException ('Email already exists');
        }
        if(user.contactId == null) {
            List<Account> matchingContactsByEmail = new List<Account>();
            List<Account> matchingContactsByPhone = new List<Account>();

            try {
                matchingContactsByEmail = [SELECT FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId, Id
                                           FROM Account
                                           WHERE isPersonAccount = true
                                           AND PersonEmail =: username];
            } catch(QueryException e) {

                system.debug('Get Matched Contacts By Email Failed:' + e.getMessage());
                //throw new Auth.DiscoveryCustomErrorException('There has been error while verifying your information.');
            }
            try {
                String tmpphone = '+' + this.phoneCode + ' ' + user.MobilePhone.replaceAll(' ', '');
                matchingContactsByPhone = [SELECT FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId, Id
                                           FROM Account
                                           WHERE isPersonAccount = true
                                           AND PersonMobilePhone =: tmpphone];
            }catch(QueryException e) {

                system.debug('Get Matched Contacts By Phone Failed:' + e.getMessage());
                //throw new Auth.DiscoveryCustomErrorException('There has been error while verifying your information.');
            }
            String errorMsg = '';
            Set<Account> allMatchingAccounts = new Set<Account>();
            allMatchingAccounts.addAll(matchingContactsByPhone);
            allMatchingAccounts.addAll(matchingContactsByEmail);
            List<Account> allMatchingAccList = new List<Account>();
            allMatchingAccList.addAll(allMatchingAccounts);
            Map<Id, Account> matchingAccountsMap = new Map<Id, Account>(allMatchingAccList);
            Set<Id> allMatchingAccountsIds = matchingAccountsMap.keySet();
            List<Id> allMatchingAccountsIdsList = new List<id>();

            if(allMatchingAccountsIds.size() > 0) {
                if(matchingContactsByPhone.size() > 0 && matchingContactsByEmail.size() > 0) {
                    errorMsg = 'Email and Phone Number already exist';
                } else if(matchingContactsByPhone.size() > 0) {
                    errorMsg = 'Phone Number already exists';
                } else if(matchingContactsByEmail.size() > 0) {
                    errorMsg = 'Email already exists';
                }

                for(User userRelatedToExistingAccounts : [SELECT id, contactId, accountId
                                                          FROM User
                                                          WHERE AccountId IN : allMatchingAccountsIds and isActive = True
                                                          ORDER BY Account.PersonEmail NULLS LAST, Account.PersonMobilePhone NULLS LAST]) {

                    allMatchingAccountsIds.remove(userRelatedToExistingAccounts.accountId);
                }

                allMatchingAccountsIdsList.addAll(allMatchingAccountsIds);

                if(allMatchingAccountsIds.size() > 0) {
                    user.ContactId  = matchingAccountsMap.get(allMatchingAccountsIdsList[0]).PersonContactId;
                    Account accountToUpdate = new Account(id = allMatchingAccountsIdsList[0]);
                    if(matchingContactsByPhone.contains(accountToUpdate) && !matchingContactsByEmail.contains(accountToUpdate) || Test.isRunningTest()) {
                        try {
                            accountToUpdate.PersonEmail =  user.Email; //adjust the email
                            accountToUpdate.OwnerId = accountOwnerId;
                            update accountToUpdate;
                        } catch(DmlException e) {
                            System.debug('Update Account failed: ' + e.getMessage());
                        }
                    } else if(!matchingContactsByPhone.contains(accountToUpdate)  && matchingContactsByEmail.contains(accountToUpdate)) {
                        try {
                            accountToUpdate.PersonMobilePhone =  user.MobilePhone;
                            accountToUpdate.OwnerId = accountOwnerId;
                            update accountToUpdate;
                        } catch(DmlException e) {
                            System.debug('Update Account failed: ' + e.getMessage());
                        }
                    }
                    user.languagelocalekey = 'en_US';
                    user.localesidkey = UserInfo.getLocale();
                    user.emailEncodingKey = 'UTF-8';
                    user.timeZoneSidKey = UserInfo.getTimezone().getID();
                    user.username = username;
                    user.Email = username;

                    return site.createExternalUser(user, accountToUpdate.id, password);

                } else {
                    throw new Auth.DiscoveryCustomErrorException (errorMsg);
                }
            } else {
                try {

                    accountToInsert.FirstName =  user.FirstName;
                    accountToInsert.LastName =  user.LastName;
                    accountToInsert.RecordTypeId =  personAccountRecordTypeId;
                    accountToInsert.PersonEmail =  user.Email;
                    accountToInsert.PersonMobilePhone =  '+' + this.phoneCode + ' ' + user.MobilePhone.replaceAll(' ', '');
                    accountToInsert.OwnerId = accountOwnerId;
                    insert accountToInsert;

                    Account accountContact = [SELECT Id, PersonContactId FROM Account WHERE ID =:accountToInsert.id];
                    user.ContactId = accountContact.PersonContactId;
                    user.languagelocalekey = 'en_US';
                    user.localesidkey = UserInfo.getLocale();
                    user.emailEncodingKey = 'UTF-8';
                    user.timeZoneSidKey = UserInfo.getTimezone().getID();
                    user.username = username;
                    user.Email = username;

                    return site.createExternalUser(user, accountToInsert.id, password);
                } catch(DmlException e) {
                    System.debug('Insert Account failed: ' + e.getMessage());
                    throw e;
                }

            }
        }

        return null;
    }

    // Default implementation to try to provide uniqueness
    private String generateAlias() {
        String timeString = String.valueOf( Datetime.now().getTime());

        return timeString.substring(timeString.length() - 8);
    }

    // Default implementation to try to provide uniqueness
    private String generateCommunityNickname() {
        return 'ExternalUser' + Datetime.now().getTime();//CURRENT_TIME;
    }
}