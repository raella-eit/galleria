public without sharing class DeviceLocationTriggerHelper {

    public static void matchContact(List<DeviceLocation__c> deviceLocationList) {
        //match deviceLocationRec with existing accounts
        //Match Accounts By Email
        //Create a set of all emails found in the trigger
        Set<String> emailSet = new Set<String>();
        //Add all emails to email list
        for(DeviceLocation__c deviceLocationRec : deviceLocationList) {
            if(String.isNotBlank(deviceLocationRec.email__c))
                emailSet.add(deviceLocationRec.Email__c);
        }

        if(!emailSet.isEmpty()) {
            List<Account> matchingContacts = [SELECT FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId
                                              FROM Account
                                              WHERE isPersonAccount = true
                                              AND PersonEmail IN :emailSet];
            //Add the not found emails to unmatchedEmailSet
            for(String iperaEmail : emailSet) {
                Boolean isFound = false;
                for(Account contact : matchingContacts) {
                    if(contact.PersonEmail == iperaEmail) {
                        isFound = true;
                        break;
                    }
                }
            }

            List<DeviceLocation__c> matchedDeviceLocationsList = new List<DeviceLocation__c>();

            if(!matchingContacts.isEmpty()) {
                //Link the deviceLocationRec to an existing personAccount if matched
                for(DeviceLocation__c deviceLocationRec : deviceLocationList) {
                    for(Account contact : matchingContacts) {
                        if(contact.PersonEmail == deviceLocationRec.Email__c) {
                            deviceLocationRec.PersonId__c = contact.PersonContactId;
                            matchedDeviceLocationsList.add(deviceLocationRec);
                            break;
                        }
                    }
                }
                sendNotification(matchedDeviceLocationsList);
            }

        }

    }

    public static void sendNotification (List<DeviceLocation__c> matchedDeviceLocationsList) {
        Id Retailer_Offer_Promotion = Schema.SObjectType.B2C_Promo__c.getRecordTypeInfosByDeveloperName().get('Retailer_Offer_Promotion').getRecordTypeId();

        Id notificationTypeId = [SELECT Id, DeveloperName
                                 FROM CustomNotificationType
                                 WHERE DeveloperName = 'GR_Notification']?.get(0).Id;

        Set<String> zonesSet = new Set<String>();
        Set<String> personIdsSet = new Set<String>();
        Map<Id, String> personAccountIdToZoneMap = new Map<Id, String>();

        for(DeviceLocation__c deviceLocationRec : matchedDeviceLocationsList) {
            zonesSet.add(deviceLocationRec.Zone_ID__c);
            personIdsSet.add(deviceLocationRec.PersonId__c);
            personAccountIdToZoneMap.put(deviceLocationRec.PersonId__c, deviceLocationRec.Zone_ID__c);
        }

        List<User> currentUsersList = [SELECT Id, Account.PersonContactId
                                       FROM User
                                       WHERE Account.PersonContactId IN: personIdsSet];
        Map<Id, User> personAccountIdToUserMap = new Map<Id, User>();
        for(User user : currentUsersList) {
            personAccountIdToUserMap.put(user.Account.PersonContactId, user);
        }

        List<B2C_Promo__c> nearbyPromosList = [SELECT Id, Name, Description__c, Zone__c, RecordTypeId, Offer__r.Description__c
                                               FROM B2C_Promo__c
                                               WHERE Push_Notification__c = TRUE
                                               AND Status__c = 'Active'
                                               AND Active__c = TRUE
                                               AND (Zone__c IN :zonesSet
                                                    OR Zone__c = NULL)];

        for(Integer i = nearbyPromosList.size() - 1; i >= 0; i--) {
            B2C_Promo__c promo = nearbyPromosList.get(i);
            if(promo.RecordTypeId == Retailer_Offer_Promotion
               && String.isBlank(promo.Zone__c)) {
                nearbyPromosList.remove(i);
            }
        }

        for(Id targetUserPersonAccountId : personAccountIdToUserMap.keySet()) {
            String userZone = personAccountIdToZoneMap.get(targetUserPersonAccountId);
            for(B2C_Promo__c targetPromo : nearbyPromosList) {
                String body = targetPromo.Description__c; String pageName = '\'event-detail\''; 
                if (targetPromo.RecordTypeId == Retailer_Offer_Promotion) {
                    body = targetPromo.Offer__r.Description__c;
                    pageName = '\'offer-detail\'';
                }
                if(userZone == targetPromo.Zone__c) {
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle(targetPromo.Name);
                    notification.setBody(body);
                    notification.setNotificationTypeId(notificationTypeId);
                    notification.setTargetPageRef('{type: \'comm__namedPage\',attributes: {pageName:' + pageName + '},state: {recordId:' + targetPromo.Id + '}}');
                    notification.send(new Set<String> {String.valueOf(personAccountIdToUserMap.get(targetUserPersonAccountId).Id)});
                }
            }
        }

    }
}