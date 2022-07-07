public with sharing class PermitController {
    
    /**
    * @description Returns ID of Event permit record type 
    * @author Raella Frem | 13-09-2021 
    * @return Id 
    **/
    @AuraEnabled(cacheable = true) 
    public static Id getEventRecordTypeId() {
        return Schema.SObjectType.Permit__c.getRecordTypeInfosByDeveloperName().get('PRMT_EventAndInStoreActivation').getRecordTypeId();
    }
}