@isTest
public class OfferListController_TEST {

    @testSetup static void setup() {
        //Create an User
        User partnerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            }
        }
        //start
        String pathOnClient = 'Logo1.png';
        String versionData = '/services/data/v51.0/sobjects/ContentVersion/0685E000002jz0WQAQ/VersionData';
        Blob versionDataBlob = Blob.valueOf(versionData);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'ContentVersion Test Title';
        contentVersion.Description = 'Test contentVersion Description';
        contentVersion.PathOnClient = pathOnClient;
        contentVersion.VersionData = versionDataBlob;
        insert contentVersion;

        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
        List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'Account', false);

        for(Account acc : accountList) {
            acc.Category__c = 'shop';
            acc.Store_Location__c = 'Level 1';
            acc.ApprovalStatus__c = 'Approved';
            acc.PublicationStatus__c = 'Published';
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
        //Create and Set start and end dates
        date startDate = date.newInstance(2021, 8, 30);
        date endDate = date.newInstance(2052, 9, 30);

        //Create offer List
        System.runAs(partnerUser){
            List<Offer__c> offerList = new List<Offer__c>();
            offerList = TestDataFactoryGR.createOffersList(3, 'Test', false);
            for(Offer__c offer : offerList) {
                offer.Category__c = 'Eat';
                offer.Approval_Status__c = 'Approved';
                offer.Start_Date__c = startDate;
                offer.End_Date__c = endDate;
            }
            insert offerList;
        }
    }
    @isTest
    public static void offerTest(){
        // Create category List and add offers categories
        List<Offer__c> offers = [SELECT id, Category__c FROM Offer__c ];
        List<GenericDataCardItem> itemList = OfferListController.getFutureOfferList(3, 0, true);
        System.assert(offers.size() > 0);
    }
}