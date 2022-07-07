global with sharing class UtilityItemReservationBatchScheduler implements Schedulable {

    public  String sched = '0 0 5 * * ? *';  //daily

    global void execute(SchedulableContext sc) {
        UtilityItemReservationDeletionBatch batch = new UtilityItemReservationDeletionBatch();
        Database.executeBatch(batch);           
    }   
}