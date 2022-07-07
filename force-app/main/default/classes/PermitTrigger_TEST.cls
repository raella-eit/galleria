@isTest
public class PermitTrigger_TEST {    
    @isTest
    public static void setDefaultAccountTest () {
        User systemAdministrator;
        User partnerUser;
        
        for(User user : TestDataFactoryGR.createCommunityUsersList()) {
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('partner')) {
                partnerUser = user;
            }
        }
        
        // should be created and Account field should be the same as the User's Account Id
        Permit__c permit1 =
            new Permit__c(SubmitterName__c = 'Partner User', SubmitterEmail__c = partnerUser.Email, SubmitterNumber__c = '03-123456',
                          StartDate__c = Date.today(), EndDate__c = Date.today() + 2, Description__c = 'No description');
        
        // should not be created
        Permit__c permit2 =
            new Permit__c(SubmitterName__c = 'System Admin', SubmitterEmail__c = systemAdministrator.Email, SubmitterNumber__c = '03-123456',
                          StartDate__c = Date.today(), EndDate__c = Date.today() + 2, Description__c = 'No description');
        
        Id permitAccount;
        Contact partnerUserContact  = [SELECT Id, AccountId
                                       FROM Contact
                                       WHERE Id = :partnerUser.ContactId]?.get(0);
        Id partnerUserAccountId = partnerUserContact.AccountId;
        
        try {
            Test.startTest();
            System.runAs(partnerUser) {
                insert permit1;
                permitAccount = [SELECT Account__c
                                 FROM Permit__c
                                 LIMIT 1]?.get(0).Account__c;
            }
            System.runAs(systemAdministrator) {
                insert permit2;
            }
            Test.stopTest();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('sufficient access'), 'Permit 2 should not be inserted');
        } finally {
            System.assertEquals(partnerUserAccountId, permitAccount, 'Permit 1 should be linked to the user\'s partner account' );
        }
    }
    
    @isTest
    public static void restrictRecordEditTest() {
        User systemAdministrator;
        User partnerUser;
        
        for(User user : TestDataFactoryGR.createCommunityUsersList()) {
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('partner')) {
                partnerUser = user;
            }
        }
        Id eventRecordTypeId = PermitController.getEventRecordTypeId();

        Permit__c permitRec =
            new Permit__c(SubmitterName__c = 'Partner User', SubmitterEmail__c = partnerUser.Email, SubmitterNumber__c = '03-123456',
                          StartDate__c = Date.today(), EndDate__c = Date.today() + 2, Description__c = 'No description', ApprovalStatus__c = 'Approved',
                          RecordTypeId = eventRecordTypeId);

        System.runAs(partnerUser) {
            insert permitRec;
        }
        
        Permit__c permit = [SELECT SubmitterName__c, Description__c, ApprovalStatus__c FROM Permit__c WHERE Id = :permitRec.Id]?.get(0);

        try {
            Test.startTest();
            
            System.runAs(systemAdministrator) {
                permit.SubmitterName__c = 'New Admin Name';
                update permit;
            }
            System.runAs(partnerUser) {
                permit.Description__c = 'new description';
                update permit;
                permit.SubmitterName__c = 'New Partner Name';
                update permit;
            }
            Test.stopTest();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('already approved'), 'Partner should not be able to edit fields if permit is approved.');
        } finally {
            System.assertEquals('New Admin Name', permit.SubmitterName__c, 'Admin should be able to edit record regardless of approval status');
            System.assertEquals('new description', permit.Description__c, 'Partner should be able to edit description if permit is approved.');
        	delete permit;
        }
    }
}