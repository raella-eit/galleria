global with sharing class DeviceLocationDeletionBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM DeviceLocation__c WHERE LastModifiedDate <= TODAY');
    }

    global void execute (Database.BatchableContext bc, List<DeviceLocation__c> locationsList) {
        delete locationsList;
    }

    global void finish (Database.BatchableContext bc) {
        // do nothing
    }
}