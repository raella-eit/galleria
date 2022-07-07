@isTest
public class ShopListController_TEST {

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
    public static void getAccountList_Test(){
        //Get Accounts
        List<Account> account = [SELECT id, Name, Store_Location__c, Description FROM Account ];
        List<GenericDataCardItem> itemsList = ShopListController.getAccountList(50, 10, true);
        //System.assertEquals(account?.get(0).Id, item.Id);
        //System.assertEquals(account?.get(0).Name, item.title);
        //System.assertEquals(account?.get(0).Store_Location__c, item.subDescription);
        //System.assertEquals(account?.get(0).Description, item.description);
    }

    @isTest
    public static void getGenericDataCardItemMapTest(){
        Account acc = [Select id from Account where Name = 'Adidas' limit 1];
        ContentDocumentLink cdl = [Select id, ContentDocument.LatestPublishedVersion.Type__c
                                   from ContentDocumentLink where LinkedEntityId = : acc.Id limit 1];
        B2CShop__c bShop = new B2CShop__c();
        bShop.Name = 'Roadster Diner';
        bShop.StoreLocation__c = 'Level L2';
        bShop.description__c = 'ddd';
        bShop.OpeningHours__c = 'Daily: 10 AM - 1 AM';
        bShop.ParkNear__c = 'Section A';
        bShop.phone__c = '035678';
        bShop.category__c = 'Eat';
        insert bShop;
        ShopHelper.ShopWrapper s = new ShopHelper.ShopWrapper();
        List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>();
        listCdl.add(cdl);
        s.shopRelatedImagesList = listCdl;
        s.shop = bShop;
        List<ShopHelper.ShopWrapper> shopWrapperList = new List<ShopHelper.ShopWrapper>();
        shopWrapperList.add(s);
        Map<Id, GenericDataCardItem> testMap = new  Map<Id, GenericDataCardItem>();
        system.debug('shopWrapperList Test' + shopWrapperList);
        testMap = ShopHelper.getGenericDataCardItemMap(shopWrapperList);
    }
    @isTest
    public static void getGenericDataCardItemMapElseTest(){
        B2CShop__c bShop = new B2CShop__c();
        bShop.Name = 'Roadster Diner';
        bShop.StoreLocation__c = 'Level L2';
        bShop.description__c = 'ddd';
        bShop.OpeningHours__c = 'Daily: 10 AM - 1 AM';
        bShop.ParkNear__c = 'Section A';
        bShop.phone__c = '035678';
        bShop.category__c = 'Eat';
        insert bShop;
        ShopHelper.ShopWrapper s = new ShopHelper.ShopWrapper();
        List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>();
        s.shopRelatedImagesList = listCdl;
        s.shop = bShop;
        List<ShopHelper.ShopWrapper> shopWrapperList = new List<ShopHelper.ShopWrapper>();
        shopWrapperList.add(s);
        Map<Id, GenericDataCardItem> testMap = new  Map<Id, GenericDataCardItem>();
        ContentVersion cvUpdate = [Select id from ContentVersion limit 1 ];
        cvUpdate.type__c = 'Permit';
        update cvUpdate;
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.ContentVersionId = cvUpdate.Id;
        contentDistribution.Name = 'Content Distribution Test';
        insert contentDistribution;
        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
        List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'Account', false);

        for(Account acc : accountList) {
            acc.Name = 'Adidas';
            acc.Category__c = 'shop';
            acc.Store_Location__c = 'Level 1';
            acc.Description = 'Description description description';
        }
        insert accountList;
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = accountList?.get(0).Id,
                                                          ContentDocumentId = doc.Id,
                                                          Visibility = 'AllUsers');
        insert cdl;

        listCdl.add(cdl);
        testMap = ShopHelper.getGenericDataCardItemMap(shopWrapperList);
    }

    @isTest
    public static void getGenericDataCardItemMapEmtyRelatedListTest(){
        Account acc = [Select id from Account where Name = 'Adidas' limit 1];
        B2CShop__c bShop = new B2CShop__c();
        bShop.Name = 'Roadster Diner';
        bShop.StoreLocation__c = 'Level L2';
        bShop.description__c = 'ddd';
        bShop.OpeningHours__c = 'Daily: 10 AM - 1 AM';
        bShop.ParkNear__c = 'Section A';
        bShop.phone__c = '035678';
        bShop.category__c = 'Eat';
        insert bShop;
        ShopHelper.ShopWrapper s = new ShopHelper.ShopWrapper();
        List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>();
        s.shopRelatedImagesList = listCdl;
        s.shop = bShop;
        List<ShopHelper.ShopWrapper> shopWrapperList = new List<ShopHelper.ShopWrapper>();
        shopWrapperList.add(s);
        Map<Id, GenericDataCardItem> testMap = new  Map<Id, GenericDataCardItem>();
        system.debug('shopWrapperList Test' + shopWrapperList);
        testMap = ShopHelper.getGenericDataCardItemMap(shopWrapperList);
    }

    @isTest
    public static void getAllShopsTest() {
        ShopListController.getShopList(null, null);
    }
}