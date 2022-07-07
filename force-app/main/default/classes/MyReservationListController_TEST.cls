@isTest
public class MyReservationListController_TEST {
    @TestSetup
    static void makeData(){
        B2C_Promo__c event = new B2C_Promo__c(
            name = 'test promo',
            Start_Date__c = System.Today(),
            End_Date__c = System.Today());

        insert event;

        B2C_Promo_Schedule__c schedule = new B2C_Promo_Schedule__c(Day__c = System.Today(),
                                                                   start_time__c = DateTime.now().time(),
                                                                   end_time__c = DateTime.now().time(),
                                                                   Content_Management__c = event.Id,
                                                                   Available__c = true);
        insert schedule;

        Contact contact = new Contact(FirstName = 'Gulf', LastName = 'Tester');

        insert contact;

        Attendee__c attendee = new Attendee__c(Contact__c = contact.Id, B2C_Promo_Schedule__c = schedule.Id);

        insert attendee;
    }

    @isTest
    private static void getAttendeeListTest(){
        Id contactId = [SELECT Id FROM Contact LIMIT 1]?.get(0).Id;
        Test.startTest();
        System.AssertEquals(1, MyReservationListController.getAttendeeList(contactId).size(), 'The reservations made were not found.');
        Test.stopTest();
    }

    @isTest
    private static void deleteAttendeeTest(){
        Id attendeeId = [SELECT Id FROM Attendee__c LIMIT 1]?.get(0).Id;
        Test.startTest();
        MyReservationListController.deleteAttendee(attendeeId);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Attendee__c].size(), 'The reservations were not deleted.');
    }

    @isTest
    private static void deleteAttendeeExceptionTest(){
        delete [SELECT Id FROM Attendee__c];
        Test.startTest();
        try {
            MyReservationListController.deleteAttendee(null);
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Invalid id');
            System.assertEquals(expectedExceptionThrown, true, 'An unexpected error occured.' + ex.getMessage());
        }
        Test.stopTest();
    }
}