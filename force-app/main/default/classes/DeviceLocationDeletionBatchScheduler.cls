global with sharing class DeviceLocationDeletionBatchScheduler implements Schedulable {

    public String sched = '0 15 0 ? * * *'; // every day at 00:15 AM

    global void execute (SchedulableContext sc) {
        DeviceLocationDeletionBatch batch = new DeviceLocationDeletionBatch();
        Database.executeBatch(batch);
    }
}