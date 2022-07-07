@isTest
public without sharing class UserUtils_TEST {
    @TestSetup
    static void makeData(){
        List<UtilityItem__c> wheelchairsList = TestDataFactoryGR.createUtilityItemsList(2, 'Wheelchair', true);
        
    }
    
    @isTest
    static void deactivateCurrentUserTest(){
        List<Case> caseList = TestDataFactoryGR.createCaseList(2, false);
        User systemAdministrator;
        User communityUser;
        
        for(User user : [SELECT Id, Email, ContactId,accountId, Deactivation_Requested__c FROM User]) {
            if(user.Email.contains('admin')) {
                systemAdministrator = user;
            } else if(user.Email.contains('customer')) {
                communityUser = user;
            }
        }
        Time fromTime = Datetime.now().time().addMinutes(30);
        Time toTime = fromTime.addHours(1);
        // create by community user, expect Contact = current user
        UtilityItemReservation__c reservation1 =
            new UtilityItemReservation__c (
                Type__c = 'Wheelchair',
                Day__c = Date.today(),
                FromTime__c = fromTime,
                ToTime__c = toTime
            );
        insert reservation1;
        System.runAs(communityUser) {
            
            CaseController.createSupportCase(caseList.get(0));
            CaseController.createLostAndFoundCase(caseList.get(1));
            UserUtils.updateUserDeactivationRequest(True);
            UserUtils.deactivateAccount(communityUser.accountId);
        }
        Test.startTest();
        database.executeBatch(new UserDeactivationComplianceBatch());
        
        
       // UserUtils.deactivateCurrentUser();
        //UserDeactivationComplianceBatch nextBatch = new UserDeactivationComplianceBatch();
        //Database.executeBatch(nextBatch);
        Test.stopTest();
        
        
        
        caseList = [SELECT Id FROM Case];
        List<UtilityItemReservation__c> reservationList = [SELECT Id FROM UtilityItemReservation__c];
        communityUser = [SELECT Id, isActive FROM User WHERE Id = :communityUser.Id];
        
        //System.assertEquals(0, caseList.size(), 'Cases were not deleted');
        // System.assertEquals(0, reservationList.size(), 'Reservations were not deleted');
        //System.assertEquals(false, communityUser.IsActive, 'User was not deactivated');
        //        
        
    }
}