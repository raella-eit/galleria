@isTest
private with sharing class UtilityItemReservationScheduler_TEST {
    @isTest
    private static void batchTest(){
        UtilityItemReservationBatchScheduler m= new UtilityItemReservationBatchScheduler();
        Id jobId=system.schedule('Test', m.sched, m);
        System.assertNotEquals(null, jobId);
    }
}