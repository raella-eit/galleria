@isTest
public class B2CShopTrigger_TEST {

    @TestSetup
    static void setup(){
        User partnerUser;
        for(User user : TestDataFactoryGR.createCommunityUsersList()) {
            if(user.Email.contains('partner')) {
                partnerUser = user;
            }
        }

        Account partnerAccount = [SELECT ApprovalStatus__c, PublicationStatus__c
                                  FROM Account
                                  WHERE Name LIKE '%Partner%']?.get(0);

        System.runAs(partnerUser) {
            List<Offer__c> offersList = TestDataFactoryGR.createOffersList(1, 'GR Test Offer', false);
            offersList.get(0).Account__c = partnerAccount.Id;
            insert offersList;
        }

        partnerAccount.ApprovalStatus__c = 'Approved';
        partnerAccount.PublicationStatus__c = 'Published';
        update partnerAccount;
    }

    @isTest
    public static void manageOffersTest () {
        List<Offer__c> offersList = [SELECT Id, Account__c, B2CShop__c FROM Offer__c];
        B2CShop__c shop = [SELECT Id, Account__c, Description__c FROM B2CShop__c]?.get(0);

        System.assertEquals(shop.Id, offersList.get(0).B2CShop__c,
                            'offer should be linked to  shop on account approval');

        shop.Description__c = 'Updated description';
        update shop;
        delete shop;
        undelete shop;
    }
}