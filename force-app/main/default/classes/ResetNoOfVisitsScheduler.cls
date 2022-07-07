/* Name : ResetNoOfVisitsScheduler
 * Description : Scheduler class to reset No. of Visits fields on Person Account
 * Test Class : ResetNoOfVisitsSchedulerTest
 * Created By : Praveen
 * */
global class ResetNoOfVisitsScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      Database.executeBatch(new ResetNoOfVisitsBatch(), 200); 
   }
}