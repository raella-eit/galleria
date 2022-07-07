/* Name : ResetNoOfVisitsSchedulerTest
 * Description : Test class for ResetNoOfVisitsScheduler, ResetNoOfVisitsBatch classes
 * Created By : Praveen
 * */
@isTest
public class ResetNoOfVisitsSchedulerTest {
    static testMethod void testMethod1() 
    {
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        List<Account> lstAccount= new List<Account>();
        
        for(Integer i=0 ;i <200;i++)
        {
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('PersonAccount').getRecordTypeId();
            acc.LASTName ='Name'+i;
            acc.personemail='test@test'+i+'.com';
            acc.PersonMobilePhone='971764324'+i;
            acc.Gender__pc='MALE';
            acc.Phone = '971764324'+i;
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        
        for (Account accRec : lstAccount) {
            accRec.Last_Login_Date_Time__pc = System.now().addDays(-20); 
        }
        update lstAccount;
        
        String jobId = System.schedule('ResetNoOfVisitsScheduler',
                                       CRON_EXP, new ResetNoOfVisitsScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}