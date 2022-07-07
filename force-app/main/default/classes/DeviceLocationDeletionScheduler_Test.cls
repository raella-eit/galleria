@isTest
public class DeviceLocationDeletionScheduler_Test {

    @isTest public static void deleteDeviceLocationTest (){
        DeviceLocationDeletionBatchScheduler schd = new DeviceLocationDeletionBatchScheduler(); 
        String cron ='0 0 8-20 ? * * *'; 
        Id jobId = System.schedule('Update TCCT', cron,schd);
        
        // Get the CronTrigger info prior to the run
        CronTrigger cronTrigger_after = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Assert that the cron job has run once
        System.assertEquals(0, cronTrigger_after.TimesTriggered);
    }
}