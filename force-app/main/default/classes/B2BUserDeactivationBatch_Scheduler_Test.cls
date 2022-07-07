@isTest
private with sharing class B2BUserDeactivationBatch_Scheduler_Test {
    @isTest
    private static void batchTest(){
        B2BUserDeactivationBatch_Scheduler m= new B2BUserDeactivationBatch_Scheduler();
        Id jobId=system.schedule('Test', m.sched, m);
        System.assertNotEquals(null, jobId);
    }
}