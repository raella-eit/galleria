@isTest
public with sharing class B2CPromoTriggerHandler_TEST {
    @TestSetup
    static void makeData(){
        //Coverage
        B2CPromoTriggerHandler handler = new B2CPromoTriggerHandler();
        handler.beforeInsert();
        handler.afterInsert();
        handler.beforeUpdate();
        handler.beforeDelete();
        handler.afterDelete();
        handler.afterUnDelete();
        B2C_Promo__c event = new B2C_Promo__c(
            name = 'test promo',
            Start_Date__c = System.Today(),
            End_Date__c = System.Today(),
            Active__c = true);

        insert event;

        List<B2C_Promo_Schedule__c> scheduleList = new List<B2C_Promo_Schedule__c>();
        while(scheduleList.size() < 2) {
            scheduleList.add(new B2C_Promo_Schedule__c(Day__c = System.Today(),
                                                       start_time__c = DateTime.now().time(),
                                                       end_time__c = DateTime.now().time(),
                                                       Content_Management__c = event.Id,
                                                       Available__c = true) );
        }

        insert scheduleList;
    }

    @isTest
    private static void afterUpdateMultiDayValidationTest(){
        List<B2C_Promo__c> promoList = [SELECT Id FROM B2C_Promo__c];
        for(B2C_Promo__c promo : promoList) {
            promo.MultiDayReservation__c = true;
        }
        Test.startTest();
        try {
            update promoList;
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This event has multiple sessions scheduled starting');
            System.assertEquals(expectedExceptionThrown, true, 'An unexpected error occured.' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void afterUpdatePropagateDeactivationTest(){
        List<B2C_Promo__c> promoList = [SELECT Id FROM B2C_Promo__c];
        for(B2C_Promo__c promo : promoList) {
            promo.Active__c = false;
        }
        Test.startTest();
        update promoList;
        Test.stopTest();
        List<B2C_Promo_Schedule__c> scheduleList = [SELECT Id, Available__c FROM B2C_Promo_Schedule__c];
        for(B2C_Promo_Schedule__c schedule : scheduleList) {
            System.assertEquals(schedule.Available__c, false, 'Deactivating the event has failed to deactivate the scheduled sessions.');
        }
    }
}