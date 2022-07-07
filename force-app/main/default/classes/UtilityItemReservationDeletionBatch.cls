global with sharing class UtilityItemReservationDeletionBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC){

       
        return Database.getQueryLocator([SELECT Id,Day__c,ToTime__c 
                              FROM UtilityItemReservation__c
                               WHERE Day__c <=  LAST_YEAR]);
    }
    /**
    * @description Delete all utilityItemReservation that has expired (more than one year)  
    * @author 
    * @param Database.BatchableContext bc,List<UtilityItemReservation__c> reservationList
    **/
    global void execute(Database.BatchableContext bc, List<UtilityItemReservation__c> reservationList){
        delete reservationList;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}