@isTest
public with sharing class ShopDetailController_TEST {

    @testSetup static void setup() {
        //Create an User
        User partnerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            }
        }

        String link = 'https://gulfrelated--grproject.my.salesforce.com/sfc/p/5E000000DiML/a/5E0000009R8O/CA5c9Aa2wIccw4kmRCVrKaDh0NNlkUWqwajAt.8ynsk';
        Blob dataBlob = Blob.valueof(link);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'ContentVersion Test Title';
        contentVersion.Description = 'Test contentVersion Description';
        contentVersion.PathOnClient = 'Adidas logo';
        contentVersion.VersionData = dataBlob;
        contentVersion.type__c = 'logo';
        insert contentVersion;

        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
        List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'Account', false);

        for(Account acc : accountList) {
            acc.Name = 'Adidas';
            acc.Category__c = 'shop';
            acc.Store_Location__c = 'Level 1';
            acc.Description = 'Description description description';
        }
        insert accountList;

        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.Name = 'Content Distribution Test';
        insert contentDistribution;

        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = accountList?.get(0).Id,
                                                          ContentDocumentId = doc.Id,
                                                          Visibility = 'AllUsers');
        insert cdl;

    }
    @isTest
    public static void shopDetailTest(){
        //Get Accounts
        List<Account> account = [SELECT id, Name, Store_Location__c, Description FROM Account ];
        GenericDataCardItem item = ShopDetailController.getShop(account?.get(0).Id);
        ShopDetailController.existsLocationIfo(account?.get(0).Id);
        //System.assertEquals(account?.get(0).Id, item.Id);
        //System.assertEquals(account?.get(0).Name, item.title);
        //System.assertEquals(account?.get(0).Store_Location__c, item.subDescription);
        //System.assertEquals(account?.get(0).Description, item.description);
    }
}