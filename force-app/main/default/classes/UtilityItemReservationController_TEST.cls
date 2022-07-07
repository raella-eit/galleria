@isTest
public class UtilityItemReservationController_TEST {
    @TestSetup
    static void makeData(){
        List<User> usersList = TestDataFactoryGR.createCommunityUsersList();
        User communityUser;
        for (User user : usersList) {
            if (user.Email.contains('customer')) {
                communityUser = user;
            }
        }
        List<UtilityItem__c> utilityItemsList = TestDataFactoryGR.createUtilityItemsList(4, 'Wheelchair', true);
        List<UtilityItemReservation__c> communityReservationsList = TestDataFactoryGR.createUtilityItemReservationsList(2, 'Wheelchair', communityUser.AccountId, true);
        List<UtilityItemReservation__c> adminReservationsList = TestDataFactoryGR.createUtilityItemReservationsList(1, 'Wheelchair', null, true);
    }

    @isTest
    public static void getReservationsListTest() {
        User systemAdministrator;
        User communityUser;

        for(User user : [SELECT Id, Email FROM User]) {
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('customer')) {
                communityUser = user;
            }
        }

        List<UtilityItemReservationController.UtilityItemReservationWrapper> communityReservationsListView = new List<UtilityItemReservationController.UtilityItemReservationWrapper>();
        List<UtilityItemReservationController.UtilityItemReservationWrapper> adminReservationsListView = new List<UtilityItemReservationController.UtilityItemReservationWrapper>();

        System.runAs(communityUser) {
            communityReservationsListView = UtilityItemReservationController.getReservationsList(false);
        }

        //System.assertEquals(0, communityReservationsListView.size(), 'community user should only see his own reservations');
    }

    @isTest
    public static void deleteReservationTest() {
        List<UtilityItemReservation__c> reservationsList = [SELECT Id
                                                            FROM UtilityItemReservation__c];
        Integer initNumberOfReservations = reservationsList.size();

        UtilityItemReservationController.deleteReservation(reservationsList?.get(0).Id);

        List<UtilityItemReservation__c> newReservationsList = [SELECT Id
                                                               FROM UtilityItemReservation__c];
        System.assert(initNumberOfReservations == newReservationsList.size() + 1,
                      'item booking should be deleted.');
    }
}