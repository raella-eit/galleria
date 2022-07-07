global class GetAccountschedulable implements schedulable
{
    global void execute(SchedulableContext sc)
    {
   
      Database.executeBatch(new GetaccountBatch(), 200); 
    }
}