global class GetaccountBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        DateTime startbatch=Datetime.now();
        system.debug('startbatch'+startbatch);
        Integer offset = UserInfo.getTimezone().getOffset(startbatch);
        DateTime d1=startbatch.addHours(-12);
        DateTime d2=d1.addHours(+12);
        system.debug('d1'+d1);
        system.debug('d2'+d2);
        //system.debug('d3'+d3);
        //system.debug('d4'+d4);
        String query;
        if(startbatch.hourGmt()==17||test.isRunningTest()){
         query = 'SELECT Id,personemail FROM Account WHERE Last_Login_Date_Time__pc >:d1 AND Last_Login_Date_Time__pc <=:d2';
        }
        else if(startbatch.hourGmt()==5||test.isRunningTest()){
             query = 'SELECT Id,personemail FROM Account WHERE Last_Login_Date_Time__pc >:d1 AND Last_Login_Date_Time__pc <=:d2';
        
        }
            return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        
        try {
            system.debug('acclist'+accList);
            Questionprojsongenerator questpro= new Questionprojsongenerator();
            questpro.jsonGeneratorSample(accList);
        
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}