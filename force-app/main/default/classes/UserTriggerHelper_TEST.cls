@isTest
public class UserTriggerHelper_TEST {

    @testSetup
    public static void createData(){
        List<User> usersList = TestDataFactoryGR.createCommunityUsersList();

        Account partnerUserAccount = [SELECT id FROM Account WHERE Name Like '%Partner Community%' LIMIT 1];

        Contact partnerUserContact = new Contact(LastName = 'Test Partner Community Created',
                                                 AccountId = partnerUserAccount.Id);
        insert partnerUserContact;
    }

    @isTest
    public static void addUserToGroup() {

        test.startTest();

        User communityUser;

        for(User user : [SELECT Id, Email FROM User]) {
            if(user.Email.contains('partner')) {
                communityUser = user;
            }
        }
        test.stopTest();
        UserTriggerHandler triggerHandler = new UserTriggerHandler();
        triggerHandler.beforeUpdate();
        triggerHandler.afterUpdate();
        triggerHandler.beforeDelete();
        triggerHandler.afterDelete();
        triggerHandler.afterUnDelete();
    }
    @isTest
    public static void addUserNickNameTest() {
        Id partnerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);

        test.startTest();
        
        Contact contactPartnerCommunity = [SELECT id FROM Contact WHERE Name Like '%Partner Community Created%' LIMIT 1];

        User partnerUser = new User(
            Alias = 'uPT', Email = 'partnerUserTest@test-GR.com', LastName = 'PartnerUser',
            ProfileId = partnerProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',Username = 'PartnerTest' + DateTime.now().getTime() + '@test-GR.com',
            ContactId=contactPartnerCommunity.id);
        insert partnerUser;
        
        test.stopTest();
    }
}