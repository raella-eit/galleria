@isTest
public class TimeStampEventController_TEST {
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
    }

    @isTest
    private static void getEventTimesTest(){
        B2C_Promo__c event = [SELECT Id from B2C_Promo__c LIMIT 1];
        TimeStampEventController.EventPromo promo =  null;
        Test.startTest();
        promo = TimeStampEventController.getEventTimes(event.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, promo, 'No event schedule was retrieved');
        System.assertEquals(1, promo.days.size(), 'Event schedule day was not contructed');
        System.assertEquals(1, promo.days[0].times.size(), 'Event schedule day times were not constructed');
    }

    @isTest
    private static void createAttendeeTest(){
        B2C_Promo_Schedule__c schedule = [SELECT Id FROM B2C_Promo_Schedule__c LIMIT 1];
        UserUtils.getContactId();
        Test.startTest();
        try {
            TimeStampEventController.createAttendee(new List<Id> {schedule.Id});
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception');
            System.assertEquals(expectedExceptionThrown, true, 'An unexpected error occured.' + ex.getMessage());
        }
        Test.stopTest();
    }
}