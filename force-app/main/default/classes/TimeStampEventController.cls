public without sharing class TimeStampEventController {

    @AuraEnabled(cacheable = false)
    public static EventPromo getEventTimes(Id recordId, Id contactId){
        List<Attendee__c> attendeeList = [SELECT B2C_Promo_Schedule__c
                                          FROM Attendee__c
                                          WHERE Contact__c = :contactId
                                          AND B2C_Promo_Schedule__r.Content_Management__c = :recordId
                                          AND B2C_Promo_Schedule__r.Day__c >= TODAY];
        Set<Id> sessionsToExcludeIdSet = new Set<Id>();
        for(Attendee__c attendee : attendeeList) {
            sessionsToExcludeIdSet.add(attendee.B2C_Promo_Schedule__c);
        }
        EventPromo result = new EventPromo();
        List<B2C_Promo_Schedule__c> scheduleList = [SELECT Id,
                                                    Day__c,
                                                    end_time__c,
                                                    start_time__c,
                                                    Content_Management__r.Name,
                                                    Content_Management__r.B2C_Promo_Name_Ar__c,
                                                    Content_Management__r.Description__c,
                                                    Content_Management__r.Description_Ar__c,
                                                    Content_Management__r.MultiDayReservation__c,
                                                    Content_Management__r.WaiverForm__c,
                                                    Content_Management__r.WaiverForm_AR__c,
                                                    time_display__c
                                                    FROM B2C_Promo_Schedule__c
                                                    WHERE Content_Management__c = :recordId
                                                    AND Day__c >= TODAY
                                                    AND Id NOT IN :sessionsToExcludeIdSet
                                                    ORDER BY Day__c ASC];
        if(!scheduleList.isEmpty()) {
            result.days = new List<EventPromoDay>();
            result.name = scheduleList[0].Content_Management__r.Name;
            result.namear = scheduleList[0].Content_Management__r.B2C_Promo_Name_Ar__c;
            result.description = scheduleList[0].Content_Management__r.Description__c;
            result.descriptionar = scheduleList[0].Content_Management__r.Description_Ar__c;
            result.isMultiDate = scheduleList[0].Content_Management__r.MultiDayReservation__c;
            result.waiver = scheduleList[0].Content_Management__r.WaiverForm__c;
            result.waiverar = scheduleList[0].Content_Management__r.WaiverForm_AR__c;
            Map<Date, List<B2C_Promo_Schedule__c>> promoMap = new Map<Date, List<B2C_Promo_Schedule__c>>();
            for(B2C_Promo_Schedule__c schedule : scheduleList) {
                List<B2C_Promo_Schedule__c> promoTime = promoMap.containsKey(schedule.Day__c) ? promoMap.get(schedule.Day__c) : new List<B2C_Promo_Schedule__c>();
                promoTime.add(schedule);
                promoMap.put(schedule.Day__c, promoTime);
            }

            for(Date day : promoMap.keySet()) {
                EventPromoDay eventPromoDay = new EventPromoDay();
                eventPromoDay.day = day;
                eventPromoDay.times = new List<EventPromoDayTime>();
                for(B2C_Promo_Schedule__c schedule : promoMap.get(day)) {
                    EventPromoDayTime promoTime = new EventPromoDayTime();
                    promoTime.start = schedule.start_time__c;
                    promoTime.stop = schedule.end_time__c;
                    promoTime.display = schedule.time_display__c;
                    promoTime.id = schedule.Id;
                    eventPromoDay.times.add(promoTime);
                }
                result.days.add(eventPromoDay);
            }
        }

        return result;
    }

    @AuraEnabled(cacheable = false)
    public static void createAttendee(List<Id> scheduleIdList){
        List<User> userList = [SELECT Id,
                               ContactId
                               FROM User
                               WHERE Id = :UserInfo.getUserId()];
        if(!userList.isEmpty()) {
            User user = userList[0];
            List<Attendee__c> attendeeList = new List<Attendee__c>();
            for(Id scheduleId : scheduleIdList) {
                attendeeList.add(new Attendee__c(Contact__c = user.ContactId,
                                                 Waiver_Accepted__c = true,
                                                 B2C_Promo_Schedule__c = scheduleId));
            }
            try {
                insert attendeeList;
            }catch(DmlException ex) {
                system.debug(LoggingLevel.ERROR, ex.getMessage());
                throw new AuraHandledException(ex.getMessage() + ' - ' + ex.getStackTraceString());
            }
        }

    }

    public class EventPromo {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String namear {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String descriptionar {get; set;}
        @AuraEnabled
        public Boolean isMultiDate {get; set;}
        @AuraEnabled
        public String waiver {get; set;}
        @AuraEnabled
        public String waiverar {get; set;}
        @AuraEnabled
        public List<EventPromoDay> days {get; set;}
    }

    public class EventPromoDay {
        @AuraEnabled
        public Date day {get; set;}
        @AuraEnabled
        public List<EventPromoDayTime> times {get; set;}
    }

    public class EventPromoDayTime {
        @AuraEnabled
        public Id id {get; set;}
        @AuraEnabled
        public Time start {get; set;}
        @AuraEnabled
        public Time stop {get; set;}
        @AuraEnabled
        public String display {get; set;}
    }
}