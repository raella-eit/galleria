@isTest
private with sharing class B2BUserDeactivationBatch_TEST {

    @TestSetup
    static void setup(){
        
        //Create an User
        User partnerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            } 
        }
        List<User>usersList=[SELECT Id,AccountId,Email FROM User WHERE Email LIKE '%partner%' ];
        
        //Create a contract
        date startDate = date.newInstance(2021,7 , 24);

        Contract contract=new Contract();
        contract.Name='Contract1';
        contract.AccountId=usersList?.get(0).AccountId;
        contract.StartDate=startDate;
        contract.End_Date__c=startDate.addMonths(1);
        insert contract;
    }


    @isTest
    private static void batchTest(){
        List<User> partnerUsers=[SELECT Id,Email,ContactId FROM User WHERE Email LIKE '%partner%'  ];
        Test.StartTest();
        B2BUserDeactivationBatch batch = new B2BUserDeactivationBatch();
        ID batchprocessid = Database.executeBatch(batch);
        batch.execute(null,partnerUsers);
        System.assertEquals(false, partnerUsers?.get(0).IsActive);
        Test.StopTest();
    }
}