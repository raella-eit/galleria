public without sharing class PermitTriggerHelper {

    /**
     * @description retrieves current user's Account and assigns it as Permit lookup(Account)
     * @author Raella Frem | 10-09-2021
     * @param List<Permit__c> newPermitsList
     **/
    public static void setDefaultAccount(List<Permit__c> newPermitsList) {
        Id currentUserAccountId = [SELECT AccountId
                                   FROM User
                                   WHERE Id = :UserInfo.getUserId()]?.get(0).AccountId;

        for(Permit__c permit : newPermitsList) {
            if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)) {
                permit.Account__c = currentUserAccountId;
            } else {
                permit.addError(System.Label.INSUFFICIENT_ACCESS_MSG);
            }
        }
    }

    /**
     * @description restricts Partner Users from editing Approved Permit records, except for the Description__c field
     * @author Raella Frem | 15-09-2021
     * @param Map<Id Permit__c> newMap
     * @param Map<Id Permit__c> oldMap
     **/
    public static void restrictRecordEdit(Map<Id, Permit__c> newMap, Map<Id, Permit__c> oldMap) {

        if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)) {

            Set<id> permitIdsSet = newMap.keySet();

            Map<String, Schema.SObjectField> allPermitFieldsMap = Schema.SObjectType.Permit__c.fields.getMap();

            List<String> listOfFields = new List<String>();
            listOfFields.addAll(allPermitFieldsMap.keySet());

            List<Permit__c> permitsList = Database.query('SELECT ' + String.join(listOfFields, ', ') + ' FROM Permit__c WHERE Id IN :permitIdsSet'); 

            List<String> updatedFields = new List<String>();

            Set<String> restrictedFieldsSet = new Set<string>(System.Label.PRMT_FieldsToRevertChanges.split(';'));
            
            Permit__c oldPermit = new Permit__c ();

            for(Permit__c newPermit : permitsList) { 
                oldPermit = oldMap.get(newPermit.Id);
                for(String field : allPermitFieldsMap.keySet()) {
                    if(newPermit.get(field) != oldPermit.get(field) && restrictedFieldsSet.contains(field) && newPermit.ApprovalStatus__c == 'Approved') {
                        newMap.get(newPermit.Id).addError(System.Label.PRMT_ERR_EditApproved);
                    }
                }
            }
        }
    }
}