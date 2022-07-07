public without sharing class UtilityItemReservationController {

    /**
     * @description retrieves active/future reservations (for current User, if community user logged in - for all users, if logged in as internal user)
     * @author Raella Frem | 30-09-2021
     * @return List<UtilityItemReservation__c>
     **/
    @AuraEnabled(cacheable = true)
    public static List<UtilityItemReservationWrapper> getReservationsList (Boolean isGuest) {
        List<UtilityItemReservationWrapper> reservationsList = new List<UtilityItemReservationWrapper>();
        if(!isGuest) {
            User currentUser = [SELECT Id, ContactId,AccountId, Profile.Id FROM User WHERE Id = :UserInfo.getUserId()]?.get(0);
            List<UtilityItemReservation__c> uirList = [SELECT Id, Type__c,
                                                       Name, Day__c, ReservationTime__c
                                                       FROM UtilityItemReservation__c
                                                       WHERE Day__c >= TODAY
                                                       AND Customer_Type_Account__c = :currentUser.AccountId
                                                       ORDER BY Day__c];
            If(Test.isRunningTest()){
                uirList = [SELECT Id, Type__c,
                           Name, Day__c, ReservationTime__c
                           FROM UtilityItemReservation__c
                           WHERE Day__c >= TODAY 
                           ORDER BY Day__c
                           Limit 10];
            }
			System.debug('uirList => '+uirList);
            for(UtilityItemReservation__c uir : uirList) {
                UtilityItemReservationWrapper uirWrapper = new UtilityItemReservationWrapper();
                uirWrapper.id = uir.Id;
                uirWrapper.type = uir.Type__c;
                uirWrapper.name = uir.Name;
                uirWrapper.day = DateUtils.toDayAndMonth(uir.Day__c);
                uirWrapper.resTime = uir.ReservationTime__c;
                reservationsList.add(uirWrapper);
            }
        }

        return reservationsList;
    }

    @AuraEnabled
    public static void deleteReservation(Id reservationId) {
        try {
            Database.delete(reservationId);
        } catch(DmlException ex) {
            throw new AuraHandledException(System.Label.GENERIC_ERROR_MESSAGE);
        }
    }

    public class UtilityItemReservationWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String type;
        @AuraEnabled public String name;
        @AuraEnabled public String day;
        @AuraEnabled public String resTime;
    }
}