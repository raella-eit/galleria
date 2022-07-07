@isTest
public class FeedItemTriggerHelper_TEST {
    
    @isTest
    public static void sendTestEmail(){
        Id partnerProfileId = ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);
        
        Id networkId = [SELECT Id
                        FROM Network
                        WHERE Name = 'B2B Portal'].Id;
        
        CollaborationGroup b2bGroup = TestDataFactoryGr.createCollaborationGroup('TestGroup', 'Public', false);
        b2bGroup.NetworkId = networkId;
        
        insert b2bGroup;
        
        Account partnerUserAccount = new Account(name = 'Test Partner Community Account');
        insert partnerUserAccount;
        
        Contact partnerUserContact = new Contact(LastName = 'Test Partner Community Contact',
                                                 AccountId = partnerUserAccount.Id, Additional_Email__c = 'Tes@test.com');
        insert partnerUserContact;
        
        User partnerUser = new User(
            Alias = 'userPT', Email = 'partnerUser@test-GR.com', LastName = 'PartnerTest',
            ProfileId = partnerProfileId, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'Asia/Beirut',
            Username = 'PartnerTest' + DateTime.now().getTime() + '@test-GR.com',
            ContactId = partnerUserContact.Id);
        
        test.startTest();
        insert partnerUser;
        
        test.stopTest();
        
        List<CollaborationGroupMember> members = [SELECT Member.Name, CollaborationRole
                                                  FROM CollaborationGroupMember
                                                  WHERE CollaborationGroupId =: b2bGroup.id];
        
        FeedItem newFeed = new FeedItem (ParentId = b2bGroup.Id, Body = 'Test', Type = 'TextPost', NetworkScope = networkId);
        System.debug('Feed Test: '+newFeed);
        
        insert newFeed;

		FeedItemTriggerHandler triggerHandler = new FeedItemTriggerHandler();
        triggerHandler.beforeUpdate();
		triggerHandler.afterUpdate();
		triggerHandler.beforeDelete();
		triggerHandler.afterDelete();
		triggerHandler.afterUnDelete();        
    }
}