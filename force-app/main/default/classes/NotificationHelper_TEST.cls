@isTest
public class NotificationHelper_TEST {
	@testSetup
    public static void makeDate(){
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
        Contact contact = new Contact(FirstName='Galleria',LastName='Mall',Email='galleria@galleria.com.test');
        insert contact;
        Attendee__c attendee = new Attendee__c(B2C_Promo_Schedule__c = schedule.Id, Contact__c = contact.Id);
        insert attendee;
    }
    
    @isTest
    static void sendScheduledEventNotificationTest(){
        Id scheduleId = [SELECT Id FROM B2C_Promo_Schedule__c]?.get(0).Id;
        NotificationHelper.sendScheduledEventNotification(new List<String>{scheduleId});
    }
}