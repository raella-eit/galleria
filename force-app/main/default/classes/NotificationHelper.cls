public with sharing class NotificationHelper {
    public static final Id notificationTypeId = [SELECT Id, DeveloperName
                                                 FROM CustomNotificationType
                                                 WHERE DeveloperName = 'GR_Notification']?.get(0).Id;
    @InvocableMethod
    public static void sendScheduledEventNotification(List<Id> recordIdList){
        if(!recordIdList.isEmpty()) {
            //get the event and session information
            Map<Id, B2C_Promo_Schedule__c> promoMap = new Map<Id, B2C_Promo_Schedule__c>([SELECT Id, Content_Management__c, Content_Management__r.Name, time_display__c
                                                                                          FROM B2C_Promo_Schedule__c
                                                                                          WHERE Id IN: recordIdList]);
            if(!promoMap.isEmpty()) {
                //retrieve attendees for all sessions
                List<Attendee__c> attendeeList = [SELECT Id, Contact__c, B2C_Promo_Schedule__c
                                                  FROM Attendee__c
                                                  WHERE B2C_Promo_Schedule__c IN :promoMap.keySet()
                                                  AND Waiting_List__c = FALSE];
                List<Id> contactIdList = new List<Id>();
                Map<Id, Set<Id>> promoIdToContactIdsMap = new Map<Id, Set<Id>>();
                for(Attendee__c attendee : attendeeList) {
                    //construct a list to retrieve all user ids
                    contactIdList.add(attendee.Contact__c);
                    //associate the contact ids to the session
                    Set<Id> contactIdSet = promoIdToContactIdsMap.containsKey(attendee.B2C_Promo_Schedule__c) ? promoIdToContactIdsMap.get(attendee.B2C_Promo_Schedule__c) : new Set<Id>();
                    contactIdSet.add(attendee.Contact__c);
                    promoIdToContactIdsMap.put(attendee.B2C_Promo_Schedule__c, contactIdSet);
                }
                //retrieve all recipient users
                List<User> userList = [SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND ContactId IN: contactIdList];
                Map<Id, Id> contactIdToUserIdMap = new Map<Id, Id>();
                for(User user : userList) {
                    //associate contact ids to user ids
                    contactIdToUserIdMap.put(user.ContactId, user.Id);
                }
                //send a notification for each session
                for(Id promoId : promoMap.keySet()) {
                    if(promoIdToContactIdsMap.containsKey(promoId)) {
                        //get the contacts associated to the session
                        Set<Id> contactIdSet = promoIdToContactIdsMap.get(promoId);
                        B2C_Promo_Schedule__c promo = promoMap.get(promoId);
                        Set<String> userIdSet = new Set<String>();
                        //get the user ids of the contacts associated to the session
                        for(Id contactId : contactIdSet) {
                            if(contactIdToUserIdMap.containsKey(contactId)) {
                                userIdSet.add(contactIdToUserIdMap.get(contactId));
                            }
                        }
                        //send the notification to all recipient user ids
                        constructNotification(promo.Content_Management__r.Name, Label.Event_Reminder_Notification, 'event-detail', promo.Content_Management__c, null).send(userIdSet);
                    }
                }
            }
        }
    }

    public static Messaging.CustomNotification constructNotification(String title, String body, String pageName, String recordId, Id notificationId){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        if(String.isNotBlank(title) && String.isNotBlank(body)) {
            notificationId = notificationId != null ? notificationId : notificationTypeId;
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationId);
            if(String.isNotBlank(pageName)) {
                String pageref = '{type: \'comm__namedPage\',attributes: {pageName:"' + pageName + '"}';
                system.debug('page reference>>' +pageref);
                if(String.isNotBlank(recordId)) {
                    pageref += ',state: {recordId:"' + recordId + '"}}';
                }
                notification.setTargetPageRef(pageref);
                system.debug('page reference>>' +pageref);
                
            }
        }

        return notification;
    }
}