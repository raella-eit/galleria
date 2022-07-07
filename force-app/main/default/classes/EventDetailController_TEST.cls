@isTest
public with sharing class EventDetailController_TEST {

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
        date startDate = date.newInstance(2021, 8, 30);
        date endDate = date.newInstance(2022, 9, 30);

        List<Offer__c> offerList=new List<Offer__c>();
         offerList=TestDataFactoryGR.createOffersList(1,'Test',false);
         for (Offer__c offer : offerList) {
          offer.Account__c=accountList.get(0).Id;
         }
         insert offerList;

       List<B2C_Promo__c> promoList=new List<B2C_Promo__c>();
       B2C_Promo__c promo=new B2C_Promo__c();
       promo.name='test promo';
       promo.Start_Date__c=startDate;
       promo.End_Date__c=endDate;
       promo.Offer__c=offerList.get(0).Id;
       promoList.add(promo);
       insert promoList;
    }
   }

   @isTest
   public static void eventDetailTest(){
     //Get promo 
     Test.startTest();
     List<B2C_Promo__c> promos=[SELECT id,Name FROM B2C_Promo__c ];
     GenericDataCardItem item = EventDetailController.getEvent(promos?.get(0).Id);
     System.assertEquals(promos?.get(0).name, item.title);
     Test.stopTest();
   }
}