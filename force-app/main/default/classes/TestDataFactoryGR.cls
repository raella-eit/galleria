public without sharing class TestDataFactoryGR {
    
    public static final Id PARENT_ACCOUNT_RECORDTYPE_ID = ObjectUtils.getRecordTypeId('Account', 'ACT_ParentAccount');
    
    public static List<Account> createAccountsList (Integer numberOfAccounts, String accountName, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        List<Account> accountsList = new List<Account>();
        for(Integer i = 0; i < numberOfAccounts; i++) {
            accountsList.add(new Account(Name = accountName + ' ' + i));
        }
        if(isInsert) {
            insert accountsList;
        }
        
        return accountsList;
    }
    
    public static User createTestUser(){
        Profile userProfile = [SELECT id, Name FROM Profile WHERE Name = 'System Administrator'];
        String testUserAlias = 'aads';
        User testUser = new User();
        testUser.alias='p'+testUserAlias;
        testUser.firstName = 'test';
        testUser.email=testUserAlias + '@hot.com';
        testUser.emailencodingkey='UTF-8';
        testUser.lastname='lastName';
        testUser.languagelocalekey='en_US';
        testUser.localesidkey='en_US';
        testUser.profileid = userProfile.Id;
        testUser.timezonesidkey='America/Los_Angeles';
        testUser.username= 'pr'+testUserAlias;
        testUser.username = testUser.username + '@test.com';
        testUser.Title = 'Test';
        return testUser;
    } 
    
    public static List<User> createCommunityUsersList () {
        Id networkId = [SELECT Id
                        FROM Network
                        WHERE Name = 'B2B Portal'].Id;
        
        CollaborationGroup b2bGroup = createCollaborationGroup('TestGroup', 'Public', false);
        b2bGroup.NetworkId = networkId;
        
        insert b2bGroup;
        
        Id partnerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);
        Id customerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER);
        Id adminProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_SYSTEM_ADMIN);
        Id marketingProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_MARKETING_USER);
        
        /* Partner Community User -- with account and contact */
        Account partnerUserAccount = new Account(name = 'Test Partner Community Account');
        insert partnerUserAccount;
        
        Contact partnerUserContact = new Contact(LastName = 'Test Partner Community Contact',
                                                 AccountId = partnerUserAccount.Id);
        insert partnerUserContact;
        
        User partnerUser = new User(
            Alias = 'userPT', Email = 'partnerUser@test-GR.com', LastName = 'PartnerTest',
            ProfileId = partnerProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
            Username = 'PartnerTest' + DateTime.now().getTime() + '@test-GR.com',
            ContactId = partnerUserContact.Id);
        
        /* Partner Community User -- with account and contact */
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account partnerUserAccount1 = new Account(LastName = 'Test Pesrson Account', RecordTypeId = personAccountRecordTypeId);
        insert partnerUserAccount1;       
        
        /* Customer Community User -- with account and contact */
        Account communityUserAccount = new Account(name = 'Test Customer Community Account');
        insert communityUserAccount;
        
        Contact communityUserContact = new Contact(LastName = 'Test Customer Community Contact',
                                                   AccountId = communityUserAccount.Id);
        insert communityUserContact;
        
        User communityUser = new User(
            Alias = 'userCT', Email = 'customerUser@test-GR.com', LastName = 'CustomerTest',
            ProfileId = customerProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
            Username = 'CustomerTest' + DateTime.now().getTime() + '@test-GR.com',
            ContactId = communityUserContact.Id, Deactivation_Requested__c = True);
        
        /* System Admin User */
        User systemAdministrator = new User(
            Alias = 'adminT', Email = 'adminUser@test-GR.com', LastName = 'AdminTest',
            ProfileId = adminProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
            Username = 'testAdmin' + DateTime.now().getTime() + '@test-GR.com');
        
        /* Marketing User */
        User marketingUser = new User(
            Alias = 'userMT', Email = 'marketingUser@test-GR.com', LastName = 'MarketingUserTest',
            ProfileId = marketingProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
            Username = 'testMarketing' + DateTime.now().getTime() + '@test-GR.com');
        
        List<User> usersList = new List<User>();
        usersList.add(partnerUser);
        usersList.add(communityUser);
        usersList.add(systemAdministrator);
        usersList.add(marketingUser);
        insert usersList;
        
        return usersList;
    }
    
    public static List<User> createOfferTestUsersList () {
        List<User> communityUsersList = createCommunityUsersList();
        communityUsersList.addAll(createPartnerUsersWithHierarchy(2));
        
        return communityUsersList;
    }
    
    public static List<User> createPartnerUsersWithHierarchy (Integer numberOfBranches) {
        Id partnerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);
        Account parentAccount = new Account(name = 'Partner Community Parent Account', RecordTypeId = PARENT_ACCOUNT_RECORDTYPE_ID);
        insert parentAccount;
        
        List<Account> branchesAccountsList = createAccountsList(numberOfBranches, 'Branch', true);
        
        List<Contact> branchesContactsList = new List<Contact>();
        for(Account branchAccount : branchesAccountsList) {
            String count = branchAccount.Name.substringAfter('Branch').trim();
            branchAccount.ParentId = parentAccount.Id;
            Contact branchContact = new Contact(LastName = 'Branch ' + count + ' Contact',
                                                AccountId = branchAccount.Id);
            branchesContactsList.add(branchContact);
        }
        update branchesAccountsList;
        
        insert branchesContactsList;
        
        List<User> branchesUsersList = new List<User>();
        for(Contact branchContact : branchesContactsList) {
            String count = branchContact.LastName.substringBetween('Branch', 'Contact').trim();
            User branchPartnerUser = new User(
                Alias = 'userPT' + count,
                Email = 'branchPartnerUser' + count + '@test-GR.com', LastName = 'PartnerBranch' + count,
                ProfileId = partnerProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
                Username = 'PartnerBranch' + count + DateTime.now().getTime() + '@test-GR.com',
                ContactId = branchContact.Id);
            branchesUsersList.add(branchPartnerUser);
        }
        insert branchesUsersList;
        
        return branchesUsersList;
    }
    
    public static List<Offer__c> createOffersList (Integer numberOfOffers, String offerName, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        List<Offer__c> offersList = new List<Offer__c>();
        for(Integer i = 0; i < numberOfOffers; i++) {
            offersList.add(new Offer__c(Name = offerName + '_' + i, SubmitterName__c = 'Partner User',
                                        SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                                        SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                                        Description__c = 'No description',
                                        Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                                        Terms_Conditions__c = 'No terms and conditions apply'));
        }
        if(isInsert) {
            insert offersList;
        }
        
        return offersList;
    }
    
    public static List<Permit__c> createPermitsList (Integer numberOfPermits, String permitName, String recordType, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        Id recordTypeId = Schema.SObjectType.Permit__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        List<Permit__c> permitsList = new List<Permit__c>();
        for(Integer i = 0; i < numberOfPermits; i++) {
            permitsList.add( new Permit__c(SubmitterName__c = 'Partner User', SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                                           SubmitterNumber__c = '03-123456', StartDate__c = Date.today(),
                                           EndDate__c = Date.today() + 2, Description__c = 'No description',
                                           ApprovalStatus__c = 'Approved', RecordTypeId = recordTypeId));
        }
        if(isInsert) {
            insert permitsList;
        }
        
        return permitsList;
    }
    
    public static List<ContentVersion> createRelatedContentVersionsList (Integer numberOfFiles, Id parentId, String type) {
        List<ContentVersion> contentVersionsList = new List<ContentVersion>();
        for(Integer i = 0; i < numberOfFiles; i++) {
            contentVersionsList.add(new ContentVersion(Title = 'Test Content Version', PathOnClient = 'Test',
                                                       VersionData = Blob.valueOf('Test Content Version Body'),
                                                       FirstPublishLocationId = parentId, Type__c = type));
        }
        insert contentVersionsList;
        
        return contentVersionsList;
    }
    
    public static List<UtilityItem__c> createUtilityItemsList (Integer numberOfItems, String type, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        List<UtilityItem__c> itemsList = new List<UtilityItem__c>();
        for(Integer i = 0; i < numberOfItems; i++) {
            itemsList.add( new UtilityItem__c(Type__c = type, IsActive__c = true));
        }
        if(isInsert) {
            insert itemsList;
        }
        
        return itemsList;
    }
    
    public static List<UtilityItemReservation__c> createUtilityItemReservationsList (Integer numberOfReservations, String type, Id accountId, boolean isInsert) {
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account newPersonAccount = new Account(LastName = 'Smith',RecordTypeId = personAccountRecordTypeId);
        insert newPersonAccount;
        isInsert = isInsert != null ? isInsert : false;
        Time fromTime = Datetime.now().time().addMinutes(30);
        Time toTime = fromTime.addHours(1);
        List<UtilityItemReservation__c> reservationsList = new List<UtilityItemReservation__c>();
        for(Integer i = 0; i < numberOfReservations; i++) {
            reservationsList.add( new UtilityItemReservation__c (
                Type__c = type,
                Day__c = Date.today(),
                FromTime__c = fromTime.addHours(i).addMinutes(4 * i),
                ToTime__c = toTime.addHours(i).addMinutes(2 * i),
                Customer_Type_account__c = newPersonAccount.id
            ));
            
        }
        if(isInsert) {
            insert reservationsList;
        }
        
        return reservationsList;
    }
    
    public static CollaborationGroup createCollaborationGroup (String groupName, String collaborationType, boolean isInsert){
        isInsert = isInsert != null ? isInsert : false;
        CollaborationGroup b2bcollaborationGroup = new CollaborationGroup();
        b2bcollaborationGroup.Name = groupName;
        b2bcollaborationGroup.CollaborationType = collaborationType;
        
        if(isInsert) {
            insert b2bcollaborationGroup;
        }
        
        return b2bcollaborationGroup;
    }
    
    public static List<DeviceLocation__c> createDeviceLocationsList (Integer numberOfRecords, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        List<DeviceLocation__c> deviceLocationsList = new List<DeviceLocation__c>();
        List<User> usersList = createCommunityUsersList();
        User b2cUser = new User();
        for(User user : usersList) {
            if(user.Email.contains('customerUser')) {
                b2cUser = user;
            }
        }
        for(Integer i = 0; i < numberOfRecords; i++) {
            DeviceLocation__c devLoc = new DeviceLocation__c();
            devLoc.Name = b2cUser.Name;
            devLoc.Email__c = b2cUser.Email;
            deviceLocationsList.add(devLoc);
        }
        if(isInsert) {
            insert deviceLocationsList;
        }
        
        return deviceLocationsList;
    }
    
    public static List<Case> createCaseList (Integer numberOfRecords, Boolean isInsert) {
        isInsert = isInsert != null ? isInsert : false;
        List<Case> caseList = new List<Case>();
        List<User> usersList = createCommunityUsersList();
        User b2cUser = new User();
        for (User user : usersList) {
            if (User.Email.contains('customerUser')) {
                b2cUser = user;
            }
        }
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            Case cas = new Case();
            cas.SuppliedName = b2cUser.Name;
            cas.SuppliedEmail = b2cUser.Email;
            cas.Subject = 'Test Class Case';
            cas.Description = 'Test Class Case Description';
            //cas.Level_1__c='retailer outlet';
            //cas.Level_2__c='air conditioning';
            caseList.add(cas);
        }
        if (isInsert) {
            insert caseList;
        }
        
        return caseList;
    }
}