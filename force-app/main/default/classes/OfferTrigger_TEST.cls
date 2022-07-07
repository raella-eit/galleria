@isTest
public class OfferTrigger_TEST {

    @testSetup static void setup() {
        List<User> offerTestUsersList = TestDataFactoryGR.createOfferTestUsersList();
        User partnerUser;

        for(User user : offerTestUsersList) {
          if(user.Email.contains('partner')) {
                partnerUser = user;
          } 
        }

        List<Offer__c> offersList =new List<Offer__c>();

        Offer__c offerRec2= TestDataFactoryGR.createOffersList(1,'Offer 1',false).get(0);
        offerRec2.Start_Date__c=Date.Today()+2;
        offerRec2.End_Date__c=Date.Today()+5;
        offerRec2.Push_Notification__c=true;
        offersList.add(offerRec2);

        Offer__c offerRec3= TestDataFactoryGR.createOffersList(1,'Offer 3',false).get(0);
        offerRec3.Start_Date__c=Date.Today()+2;
        offerRec3.End_Date__c=Date.Today()+5;
        offerRec3.Push_Notification__c=false;
        offersList.add(offerRec3);

        Offer__c offerRec4= TestDataFactoryGR.createOffersList(1,'Offer 4',false).get(0);
        offerRec4.Start_Date__c=Date.Today();
        offerRec4.End_Date__c=Date.Today()+5;
        offerRec4.Push_Notification__c=true;
        offersList.add(offerRec4);

        Offer__c offerRec5= TestDataFactoryGR.createOffersList(1,'Offer 5',false).get(0);
        offerRec5.Start_Date__c=Date.Today();
        offerRec5.End_Date__c=Date.Today()+5;
        offerRec5.Push_Notification__c=false;
        offersList.add(offerRec5);
        
        System.runAs(partnerUser) {
            insert offersList;
        }
    }

    @isTest
    public static void setDefaultAccountTest () {
        User systemAdministrator;
        User partnerUser;

        for(User userRec : [SELECT Id, Email, ContactId FROM User]) {
            if(userRec.Email.contains('admin')) {
                systemAdministrator = userRec;
            } else if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            }
        }
        // should be created and Account field should be User's Account Id
        Offer__c offer1 =
        new Offer__c(Name = 'Offer 1', SubmitterName__c = 'Partner User',
                     SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                     SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                     Description__c = 'No description',
                     Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                     Terms_Conditions__c = 'No terms and conditions apply');

        // should not be created
        Offer__c offer2 =
        new Offer__c(Name = 'Offer 2', SubmitterName__c = 'Sys admin',
                     SubmitterEmail__c = 'adminuser@test-GR.com',
                     SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                     Description__c = 'No description',
                     Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                     Terms_Conditions__c = 'No terms and conditions apply');

        Id offerAccountId;
        Contact partnerUserContact = [SELECT Id, AccountId
                                      FROM Contact
                                      WHERE Id = :partnerUser.ContactId]?.get(0);
        Id partnerUserAccountId = partnerUserContact.AccountId;
        try {
            Test.startTest();
            System.runAs(partnerUser) {
                insert offer1;
                offerAccountId = [SELECT Account__c
                                  FROM Offer__c
                                  LIMIT 1]?.get(0).Account__c;
            }
            System.runAs(systemAdministrator) {
                insert offer2;
            }
            Test.stopTest();
        } catch(Exception ex) {
            // System.assert(ex.getMessage().contains('sufficient access'),
            //               'Offer 2 should not be inserted.');
        } finally {
            System.assertEquals(partnerUserAccountId, offerAccountId,
                                'Offer 1 should be linked to the user\'s partner account');

        delete offer1;
        undelete offer1;
        }
    }

    @isTest
    public static void manualSharingTest(){

        List<User> usersList = [SELECT Id FROM User WHERE Username LIKE '%PartnerBranch%'];
        Id branch1UserId = usersList.get(0).Id;
        Id branch2UserId = usersList.get(1).Id;

        // should be visible to all branch users (IsOnAllBranches__c = true)
        Offer__c offer1 =
        new Offer__c(Name = 'Offer 1', SubmitterName__c = 'Partner User',
                     SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                     SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                     Description__c = 'No description',
                     Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                     Terms_Conditions__c = 'No terms and conditions apply',
                     IsOnAllBranches__c = true);

        // should only be visible to Branch 1 User
        Offer__c offer2 =
        new Offer__c(Name = 'Offer 2', SubmitterName__c = 'Partner User',
                     SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                     SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                     Description__c = 'No description',
                     Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                     Terms_Conditions__c = 'No terms and conditions apply',
                     IsOnAllBranches__c = false);

        List<Offer__c> offersList = new List<Offer__c> {offer1, offer2};
        System.runAs(usersList?.get(0)) {
            insert offersList;
        }

        Offer__Share offer1SharingRec = [SELECT Id, UserOrGroupId, AccessLevel, RowCause
                                         FROM Offer__Share
                                         WHERE ParentId = : offersList.get(0).Id
                                         AND UserOrGroupId = : branch2UserId]?.get(0);

        System.assert(offer1SharingRec != null, 'Offer 1 should have an associated Offer__Share record');
        System.assertEquals(offer1SharingRec.AccessLevel, 'Read', '\'Read\' access level should be defined');
        System.assertEquals(offer1SharingRec.RowCause, Schema.Offer__Share.RowCause.ShareAcrossBranches__c, '\'Sharing reason\' should be defined');
        System.assertEquals(offer1SharingRec.UserOrGroupId, branch2UserId,  'Offer 1 should be shared with branch 2 user');

        List<Offer__Share> offer2SharingRec = [SELECT Id, UserOrGroupId, AccessLevel, RowCause
                                               FROM Offer__Share
                                               WHERE ParentId = :offersList.get(1).Id
                                               AND UserOrGroupId = :branch2UserId];

        System.assert(offer2SharingRec.isEmpty(), 'Offer 2 should not have an associated Offer__Share record');

        offersList.get(0).IsOnAllBranches__c = false;
        offersList.get(1).IsOnAllBranches__c = true;
        System.runAs(usersList?.get(0)) {
            update offersList;
        }

        List<Offer__Share> offer1SharingRecAfterUpdate = [SELECT Id, UserOrGroupId, AccessLevel, RowCause
                                                          FROM Offer__Share
                                                          WHERE ParentId = : offersList.get(0).Id
                                                          AND UserOrGroupId = : branch2UserId];

        System.assert(offer1SharingRecAfterUpdate.isEmpty(), 'Offer 1 should no longer have an associated Offer__Share record');

        Offer__Share offer2SharingRecAfterUpdate = [SELECT Id, UserOrGroupId, AccessLevel, RowCause
                                                    FROM Offer__Share
                                                    WHERE ParentId = :offersList.get(1).Id
                                                    AND UserOrGroupId = :branch2UserId]?.get(0);

        System.assert(offer2SharingRecAfterUpdate != null, 'Offer 2 should now have an associated Offer__Share record');
        System.assertEquals(offer2SharingRecAfterUpdate.AccessLevel, 'Read', '\'Read\' access level should be defined');
        System.assertEquals(offer2SharingRecAfterUpdate.RowCause, Schema.Offer__Share.RowCause.ShareAcrossBranches__c, '\'Sharing reason\' should be defined');
        System.assertEquals(offer2SharingRecAfterUpdate.UserOrGroupId, branch2UserId,  'Offer 2 should now be shared with branch 1 user');
    }

    @isTest
    public static void restrictRecordEditTest() {
        User systemAdministrator;
        User partnerUser;

        for(User user : [SELECT Id, Email FROM User]) {
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('partner')) {
                partnerUser = user;
            }
        }

        Offer__c offerRec =
        new Offer__c(Name = 'Offer 1', SubmitterName__c = 'Partner User',
                     SubmitterEmail__c = 'partnerUserTest@test-GR.com',
                     SubmitterNumber__c = '03-123456', Category__c = 'Eat',
                     Description__c = 'No description',
                     Start_Date__c = Date.today(), End_Date__c = Date.today() + 2,
                     Terms_Conditions__c = 'No terms and conditions apply',
                     Approval_Status__c = 'Approved');

        System.runAs(partnerUser) {
            insert offerRec;
        }

        Offer__c offer = [SELECT SubmitterName__c, Description__c, Approval_Status__c FROM Offer__c WHERE Id = :offerRec.Id]?.get(0);

        try {
            Test.startTest();

            System.runAs(systemAdministrator) {
                offer.SubmitterName__c = 'New Admin Name';
                update offer;
            }
            System.runAs(partnerUser) {
                offer.Description__c = 'new description';
                update offer;
                offer.SubmitterName__c = 'New Partner Name';
                update offer;
            }
            Test.stopTest();
        } catch(Exception ex) {
           // System.assert(ex.getMessage().contains('already approved'), 'Partner should not be able to edit fields if offer is approved.');
        } finally {
           // System.assertEquals('New Admin Name', offer.SubmitterName__c, 'Admin should be able to edit record regardless of approval status');
           // System.assertEquals('new description', offer.Description__c, 'Partner should be able to edit description if offer is approved.');
        }
    }

    @isTest
    public static void syncOfferPromotionTEST() {

        List<Offer__c> offersToUpdate=new List<Offer__c>();

        User partnerUser = [SELECT Id,LastName FROM User WHERE LastName='PartnerTest'];

        Offer__c offerRec = [SELECT Name,
                                 Category__c,
                                 Start_date__c,
                                 End_date__c,
                                 Push_Notification__c,
                                 Status__c
                                 FROM Offer__c 
                                 WHERE Name='Offer 1_0']?.get(0);
 
         System.runAs(partnerUser) {  
            offerRec.Push_Notification__c=false;
            update offerRec;
         }
         B2C_Promo__c promo = [SELECT Name,
                              Category__c,
                              Start_date__c,
                              End_date__c,
                              Push_Notification__c,
                              Offer__c
                              FROM B2C_Promo__c 
                              WHERE Offer__c = :offerRec.Id]?.get(0);

         Offer__c offerRec3 = [SELECT Name,
                                 Category__c,
                                 Start_date__c,
                                 End_date__c,
                                 Push_Notification__c,
                                 Status__c
                                 FROM Offer__c 
                                 WHERE Name='Offer 3_0']?.get(0);

         System.runAs(partnerUser) {  
            offerRec3.Push_Notification__c=true;
            update offerRec3;
         }

         Offer__c offerRec6 = [SELECT Name,
         Category__c,
         Start_date__c,
         End_date__c,
         Push_Notification__c,
         Status__c
         FROM Offer__c 
         WHERE Name='Offer 3_0']?.get(0);

       System.runAs(partnerUser) {  
        offerRec6.Push_Notification__c=false;
        update offerRec6;
       }

         // Active offers
         Offer__c offerRec4 = [SELECT Name,
                                 Category__c,
                                 Start_date__c,
                                 End_date__c,
                                 Push_Notification__c,
                                 Status__c
                                 FROM Offer__c 
                                 WHERE Name='Offer 4_0']?.get(0);

        System.runAs(partnerUser) {  
            offerRec4.Push_Notification__c=false;
            update offerRec4;
        }

         Offer__c offerRec5 = [SELECT Name,
                                 Category__c,
                                 Start_date__c,
                                 End_date__c,
                                 Push_Notification__c,
                                 Status__c
                                 FROM Offer__c 
                                 WHERE Name='Offer 5_0']?.get(0);

         System.runAs(partnerUser) {  
            offerRec5.Push_Notification__c=true;
            update offerRec5;
         }
         
         integer numberOfOffers=[SELECT COUNT() FROM Offer__c WHERE Push_Notification__c = true];
         integer numberOfPromos=[SELECT COUNT() FROM B2c_Promo__c WHERE Push_Notification__c = true];

         System.assertEquals(numberOfOffers,numberOfPromos);
         
         
    }
}