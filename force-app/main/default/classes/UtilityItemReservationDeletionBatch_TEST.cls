@isTest
private with sharing class UtilityItemReservationDeletionBatch_TEST {
   
    @TestSetup
    static void setup(){
        //Create Utility Item
        UtilityItem__c item =new UtilityItem__c();
        item.Type__c='Baby Stroller';
        item.IsActive__c=true;
        insert item;
        //Create UtilityItemReservation with day greater than 1 year
        UtilityItemReservation__c reservation = new UtilityItemReservation__c();
        reservation.Day__c = date.parse('06/07/2021');
        reservation.Type__c='Baby Stroller';
        reservation.FromTime__c=Datetime.now().time()-3;
        reservation.ToTime__c=Datetime.now().time();
        insert reservation;
    }


    @isTest
    private static void batchTest(){
        Time myTime=Datetime.now().time();
        List<UtilityItemReservation__c> item=[SELECT Id,Day__c,ToTime__c 
                                              FROM UtilityItemReservation__c ];
        Test.StartTest();
        UtilityItemReservationDeletionBatch batch = new UtilityItemReservationDeletionBatch();
        ID batchprocessid = Database.executeBatch(batch);
        
        Test.StopTest();
    }

}