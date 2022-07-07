public with sharing class MyReservationListController {
    @AuraEnabled(cacheable = true)
    public static List<Attendee__c> getAttendeeList(Id contactId){
        return [SELECT Id,
                B2C_Promo_Schedule__r.Day__c,
                B2C_Promo_Schedule__r.end_time__c,
                B2C_Promo_Schedule__r.start_time__c,
                B2C_Promo_Schedule__r.Content_Management__r.Name,
                B2C_Promo_Schedule__r.Content_Management__r.B2C_Promo_Name_Ar__c,
                B2C_Promo_Schedule__r.time_display__c
                FROM Attendee__c
                WHERE Contact__c = : contactId
                AND B2C_Promo_Schedule__r.Day__c >= TODAY
                ORDER BY B2C_Promo_Schedule__r.Day__c DESC, B2C_Promo_Schedule__r.start_time__c DESC
        ];
    }

    @AuraEnabled(cacheable = false)
    public static void deleteAttendee(Id attendeeId){
        try {
            delete new Attendee__c(Id = attendeeId);
        }catch(DmlException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}