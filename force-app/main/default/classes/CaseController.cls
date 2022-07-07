public with sharing class CaseController {

    @AuraEnabled
    public static void createSupportCase(Case cas){
        cas.recordTypeId = ObjectUtils.getRecordTypeId('Case', 'B2C');
        insert cas;
    }

    @AuraEnabled
    public static void createLostAndFoundCase(Case cas) {
        cas.recordTypeId = ObjectUtils.getRecordTypeId('Case', 'Lost_Found');
        insert cas;
    }
}