@isTest
public class UtilityItemReservationTrigger_TEST {
    public static final Integer MAX_ITEMS = UtilityItemReservationTriggerHelper.MAX_ITEMS_PER_DAY;

    @TestSetup
    static void setup(){
        List<User> usersList = TestDataFactoryGR.createCommunityUsersList();
        List<UtilityItem__c> wheelchairsList = TestDataFactoryGR.createUtilityItemsList(2, 'Wheelchair', true);
        List<UtilityItem__c> strollersList = TestDataFactoryGR.createUtilityItemsList(MAX_ITEMS + 2, 'Baby Stroller', true);
    }

    @isTest
    public static void testReserveAvailableUtilityItem() {
        User systemAdministrator;
        User communityUser;

        for(User user : [SELECT Id, Email,AccountId, ContactId FROM User]) {
            
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('customer')) {
                system.debug('Account Id '+user.AccountId);
                communityUser = user;
            }
        }

        Time fromTime = Datetime.now().time().addMinutes(30);
        Time toTime = fromTime.addHours(1);
        // create by community user, expect Contact = current user
        UtilityItemReservation__c reservation1 =
        new UtilityItemReservation__c (
            Type__c = 'Wheelchair',
            Day__c = Date.today(),
            FromTime__c = fromTime,
            ToTime__c = toTime
        );

        // create by sys admin, expect Contact = null
        UtilityItemReservation__c reservation2 =
        new UtilityItemReservation__c (
            Type__c = 'Wheelchair',
            Day__c = Date.today(),
            FromTime__c = fromTime,
            ToTime__c = toTime
        );

        // should not be created, throws error, no available wheelchairs
        UtilityItemReservation__c reservation3 =
        new UtilityItemReservation__c (
            Type__c = 'Wheelchair',
            Day__c = Date.today(),
            FromTime__c = fromTime.addMinutes(15),
            ToTime__c = toTime.addMinutes(15)
        );

        Id userContactId;
        Id userAccountId;
        try {
            Test.startTest();
            //System.runAs(communityUser) {
                insert reservation1;
                reservation1.FromTime__c = Datetime.now().time().addMinutes(35);
                update reservation1;
                userAccountId = [SELECT Customer_Type_Account__c FROM UtilityItemReservation__c LIMIT 1]?.get(0).Customer_Type_Account__c;
            //}
            //System.runAs(systemAdministrator) {
                insert reservation2;
                insert reservation3;
            //}

            Test.stopTest();
        } catch(Exception ex) {
            //System.assert(ex.getMessage().contains('no available Wheelchairs'),
                         // 'Reservation 3 should not be inserted and should throw an error ');
        } finally {
            //System.assertEquals(communityUser.AccountId, userAccountId,
                               // 'Reservation 1 should be linked to communityUser');
            //System.assertEquals(null, reservation2.Customer_Type_Account__c,
                               // 'Reservation 2 should be linked to Test Account');

            List<UtilityItemReservation__c> multipleReservationsPerDay = new List<UtilityItemReservation__c>();
			
            if(MAX_ITEMS != 0) {
                try {
                    //System.runAs(communityUser) {
                        multipleReservationsPerDay
                        = TestDataFactoryGR.createUtilityItemReservationsList(MAX_ITEMS + 1, 'Baby Stroller', communityUser.AccountId, true);
                   // }
                } catch(Exception e) {
                    System.assertEquals(System.Label.MAX_RESERVATIONS_REACHED, e.getMessage(), 'User should be allowed to book a maximum of ' + MAX_ITEMS + ' items per day.');
                }
            } else {
                //System.runAs(communityUser) {
                    multipleReservationsPerDay
                        = TestDataFactoryGR.createUtilityItemReservationsList(2, 'Baby Stroller', communityUser.AccountId, true);
                   
             //   }
                System.assert(multipleReservationsPerDay.get(0).Id != null, 'Number of bookings per day should not be restricted.');
            }
        }
        delete reservation1;
        undelete reservation1;
    }
}