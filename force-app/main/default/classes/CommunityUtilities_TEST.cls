@isTest
public class CommunityUtilities_TEST {

    @testSetup
    static void setup(){
        User testUser = TestDataFactoryGR.createTestUser();
        insert testUser;
        System.runAs(testUser){
            URLs__c sett1 = new URLs__c();
            sett1.Name = 'AmcparkingInfo';
            sett1.URL__c = 'http://wtvrURL';
            Insert sett1;
        }
    }

    @IsTest
    public static void getUrlTest() {
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){
            String url = CommunityUtilities.getUrl('AmcparkingInfo');
            System.assertEquals(URLs__c.getValues('AmcparkingInfo')?.URL__c, url);
        }
    }

    @IsTest
    public static void updateUser() {
        CommunityUtilities.changeUserLanguage('en_US');
    }

    @IsTest
    public static void isAgentLiveTest(){
        System.assertEquals(CommunityUtilities.isAgentLive(), false, 'There should not be any agent online.');
    }

}