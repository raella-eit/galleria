global with sharing class B2BUserDeactivationBatch_Scheduler implements Schedulable {

    global  String sched = '0 00 00 * * ?';  //Every Day at Midnight 

    global void execute(SchedulableContext sc) {
        B2BUserDeactivationBatch batch = new B2BUserDeactivationBatch();
        Database.executeBatch(batch);           
    }   
}