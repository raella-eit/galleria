@isTest
public class Parking_Manager_Test {

    @testSetup
    static void setup(){
        //User
        User testUser = TestDataFactoryGR.createTestUser();
        insert testUser;
        System.runAs(testUser){
            //URLs cust sett
            List<URLs__c> urlList = new List<URLs__c>();
            urlList.add(new URLs__c(
                            Name = 'AmcparkingInfo',
                            URL__c = 'http://151.253.59.13:3000/amcparkingInfo?token=wtvr&'
            ));
            urlList.add(new URLs__c(name = 'ParkingService_URL', URL__c = 'http://151.253.59.13:3000/amcparkingInfo?token=facilityIdValue&'));
            Insert urlList;
        }
    }

    @isTEST
    public static void testgetAmcParkingInfo (){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            ParkingWrapper pM_Wrp = Parking_Manager.getAmcParkingInfo();
            Test.stopTest();
            System.assertNotEquals(Null, pM_Wrp);
        }
    }

    @isTEST
    public static void testgetParkingSlotsAvailable (){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){
            Test.setMock(HttpCalloutMock.class, new MockXMLParkingInfoSlotsAvailable());
            Test.startTest();
            ParkingWrapper pM_Wrp = Parking_Manager.getAmiParkingInfo();
            Test.stopTest();
            System.assertNotEquals(Null, pM_Wrp);
        }
    }
}