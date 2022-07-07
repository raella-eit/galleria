@isTest
public class OfferDetailController_TEST {
    @testSetup static void setup() {
        //Create an User
        User partnerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            } 
        }

         String pathOnClient='Logo1.png';
         String versionData='/services/data/v51.0/sobjects/ContentVersion/0685E000002jz0WQAQ/VersionData';
         Blob versionDataBlob=Blob.valueOf(versionData);
 
         ContentVersion contentVersion=new ContentVersion();
         contentVersion.title='ContentVersion Test Title';
         contentVersion.Description='Test contentVersion Description';  
         contentVersion.PathOnClient=pathOnClient;
         contentVersion.VersionData=versionDataBlob;  
         insert contentVersion;
         
         ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
         List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'Account',false);
 
         for (Account acc : accountList) {
             acc.Category__c='shop';
             acc.Store_Location__c='Level 1';     
           }
         insert accountList;
         
         ContentDistribution contentDistribution=new ContentDistribution();
         contentDistribution.ContentVersionId=contentVersion.Id;
         contentDistribution.Name='Content Distribution Test';
         insert contentDistribution;
 
         ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = accountList?.get(0).Id,
                                                           ContentDocumentId = doc.Id,
                                                           Visibility = 'AllUsers');
         insert cdl;

       System.runAs(partnerUser){

       List<Offer__c> offerList=new List<Offer__c>();
       offerList=TestDataFactoryGR.createOffersList(1,'Test',false);
       for (Offer__c offer : offerList) {
        offer.Account__c=accountList.get(0).Id;
       }
       insert offerList;
       } 
   }
   @isTest
   public static void offerDetailTest(){
     //Get offers 
     List<Offer__c> offers=[SELECT id FROM Offer__c ];
     GenericDataCardItem item = OfferDetailController.getOffer(offers?.get(0).Id);
     System.assertEquals(offers?.get(0).Id, item.Id);
   }
    
   @isTest
    public static void getOfferWithImageListTest(){
        List<SObject> lstObj = new List<SObject>();
        OfferHelper.OfferHelperWO o = new OfferHelper.OfferHelperWO();
        lstObj = o.getOfferWithImageList(1,0,true);
    }
}