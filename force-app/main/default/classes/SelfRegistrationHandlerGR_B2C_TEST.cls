@isTest
private class SelfRegistrationHandlerGR_B2C_TEST {
    @TestSetup
    static void makeData(){
        List<User> usersList = TestDataFactoryGR.createCommunityUsersList();
        Account acc = new Account(recordtypeid = objectutils.getRecordTypeId('Account', 'PersonAccount'),
                                  FirstName = 'test',
                                  LastName = 'Test',
                                  PersonEmail = 'GRtster@grrtest.com',
                                  PersonMobilePhone = '+971 1111');
        insert acc;
    }
    static testMethod void testCreateAndUpdateUser() {
        try {
            Pagereference pageReference = new Pagereference('CommunityRegistrationVFP');
            pageReference.getParameters().put('id', '123');
            pageReference.getParameters().put('callback', 'otherpage');
            Test.setCurrentPage(pageReference);
            SelfRegistrationHandlerGR_B2C ctrl = new SelfRegistrationHandlerGR_B2C();
            ctrl.firstname = 'test';
            ctrl.lastname = 'test';
            ctrl.username = 'customerUser@test-GR.com';
            ctrl.mobilePhone = '00971123123';
            ctrl.confirmPassword = 'C0mpl3xP@ssword';
            ctrl.password = ctrl.confirmPassword;
            ctrl.registerUser();
            system.assertEquals(null, ctrl.registerUser());
            ctrl.username = null;
            system.assertEquals(null, ctrl.registerUser());
            ctrl.username = 'customerUser@test-GR.com';
            ctrl.mobilePhone = null;
            system.assertEquals(null, ctrl.registerUser());
            ctrl.mobilePhone = '00971123123';
            ctrl.password = null;
            system.assertEquals(null, ctrl.registerUser());
            ctrl.username = 'new@test-GR.com';
            ctrl.mobilePhone = '00971123122';
            ctrl.password = ctrl.confirmPassword;
            ctrl.registerUser();
            ctrl.firstname = 'test';
            ctrl.lastname = 'test';
            ctrl.username = 'GRtster@grrtest.com';
            ctrl.mobilePhone = '+971 1111';
            ctrl.confirmPassword = 'C0mpl3xP@ssword';
            ctrl.password = ctrl.confirmPassword;
        }catch(Exception e) {}
        // User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];

    }
}