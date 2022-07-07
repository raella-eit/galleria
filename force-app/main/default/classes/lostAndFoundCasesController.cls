public without sharing class lostAndFoundCasesController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getLostAndFoundCases(Integer limitSize) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Found').getRecordTypeId();
    
        User currentUser = [SELECT id, name ,contactId FROM user WHERE id =: UserInfo.getUserId()];
        
        return [SELECT Id, CaseNumber,ContactId,Contact.Name,Subject, Status 
                FROM Case 
                WHERE RecordTypeId = : devRecordTypeId
                AND ContactId =: currentUser.contactId 
                ORDER BY CreatedDate DESC
                LIMIT :limitSize
                ];
                                                                
        
    }
    @AuraEnabled(cacheable=true)
    public static Case getLostAndFoundCase(Id caseId) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Found').getRecordTypeId();
    
        User currentUser = [SELECT id, name ,contactId FROM user WHERE id =: UserInfo.getUserId()];
        
        system.debug('Entered');
        return [SELECT Home_Address__c
                    ,Subject
                    ,Where_Lost__c
                    ,When_Lost__c
                    ,Item_Full_Description__c
                FROM Case 
                WHERE Id =: caseId LIMIT 1
                ];
                                                                
        
    }
}