@isTest
public class ContentDocumentLinkTrigger_TEST {

    @isTest
    public static void setVisibilityTest () {
        User marketingUser;
        User partnerUser;

        for(User user : TestDataFactoryGR.createCommunityUsersList()) {
            if(user.Email.contains('marketingUser')) {
                marketingUser = user;
            } else if(user.Email.contains('partner')) {
                partnerUser = user;
            }
        }

        Id eventRecordTypeId = PermitController.getEventRecordTypeId();

        Permit__c permitRec =
        new Permit__c(SubmitterName__c = 'Partner User', SubmitterEmail__c = partnerUser.Email, SubmitterNumber__c = '03-123456',
                      StartDate__c = Date.today(), EndDate__c = Date.today() + 2, Description__c = 'No description', ApprovalStatus__c = 'Approved',
                      RecordTypeId = eventRecordTypeId);

        System.runAs(partnerUser) {
            insert permitRec;
        }

        Blob fileBlob = Blob.valueOf('Unit Test File Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';
        cv.PathOnClient = 'test';
        cv.VersionData = fileBlob;
        cv.FirstPublishLocationId = permitRec.Id;

        System.runAs(marketingUser) {
            insert cv;
        }

        ContentVersion cv1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]?.get(0);

        System.runAs(partnerUser) {
            ContentDocumentLink cdl = [SELECT Id, ShareType, Visibility
                                       FROM ContentDocumentLink
                                       WHERE ContentDocumentId = :cv1.ContentDocumentId
                                       LIMIT 1]?.get(0);

            System.assert(cdl != null, 'Partner User should be able to see Files created by admin');
            System.assertEquals('I', cdl.ShareType, 'File ShareType should be set to \'I\' -> Inferred');
            System.assertEquals('AllUsers', cdl.Visibility, 'File visibility shoulf be set to \'AllUsers\'');
            
            update cdl;
            delete cdl;
        }
    }
    
    @isTest
    public static void createConterDistributionTest(){
        Id recId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
        List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'Account', false);

        for(Account acc : accountList) {
            acc.Category__c = 'shop';
            acc.RecordTypeId = recId;
            acc.Store_Location__c = 'Level 1';
        }
        insert accountList;

        Blob fileBlob = Blob.valueOf('Unit Test File Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';
        cv.PathOnClient = 'test';
        cv.VersionData = fileBlob;
        insert cv;

        ContentDocument cd1 = [SELECT Id, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cd1.Id;
        cdl.LinkedEntityId = accountList.get(0).Id;
        insert cdl;

        System.assert(cd1 != null);
        //TO-DO test class for helper and for handlers apart;
        update cdl;
        delete cdl;
    }
}