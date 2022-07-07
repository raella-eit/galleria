global  with sharing class B2BUserDeactivationBatch implements Database.Batchable<sObject> {
    
    List<User> listOfUsers=new List<User>();
    List<Contract> listOfContracts=new List<Contract>();
    global List<User> start(Database.BatchableContext bc) {


        //getting all contracts that have expired enddate and add there account id
        this.listOfContracts=[SELECT Id,AccountId,End_Date__c 
                              FROM Contract
                               WHERE End_Date__c = :System.today().addDays(-30)];
         Set<Id> accountIdsSet = new Set<Id>();
        for (Contract con : this.listOfContracts) {
            accountIdsSet.add(con.AccountId);
        }                           

        //getting all users of those accounts
        this.listOfUsers=[SELECT Id,AccountId FROM User WHERE AccountId IN :accountIdsSet];
        return listOfUsers;
    }
    global void execute(Database.BatchableContext bc, List<User> usersList){
        //deActivating user's with expired contract date.
        for (User user : usersList) {
            user.IsActive=false;           
        }
        update usersList;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}