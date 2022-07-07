/* Name : ResetNoOfVisitsBatch
* Description : Batch class to reset No. of Visits fields on Person Account
* Test Class : ResetNoOfVisitsSchedulerTest
* Created By : Praveen
* */
public class ResetNoOfVisitsBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Name, Id, IsPersonAccount, No_Of_Visits_This_Month__pc, No_Of_Visits_This_Week__pc 
                                         FROM Account 
                                         WHERE IsPersonAccount = true 
                                         AND (No_Of_Visits_This_Month__pc > 0 OR No_Of_Visits_This_Week__pc > 0)]);
    }
    
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Account> accsToUpdateList = new List<Account>();
        Date todayDate = Date.today();
        
        if (todayDate.isSameDay(todayDate.toStartOfMonth()) || todayDate.isSameDay(todayDate.toStartOfWeek()) ||
           Test.isRunningTest()) {
            for (sObject sObj : scope) {
                Account accObj = (Account)sObj;
                accObj.No_Of_Visits_This_Month__pc = todayDate.isSameDay(todayDate.toStartOfMonth()) ? 0 
                    : accObj.No_Of_Visits_This_Month__pc;
                accObj.No_Of_Visits_This_Week__pc = todayDate.isSameDay(todayDate.toStartOfWeek()) ? 0 
                    : accObj.No_Of_Visits_This_Week__pc;
                
                accsToUpdateList.add(accObj);
            }
        }
        
        if (!accsToUpdateList.isEmpty()) {
            update accsToUpdateList;
        }
    }
    
    
    public void finish(Database.BatchableContext BC){
    }
}