@isTest
public class Parking_Mapper_Test {
    @testSetup 
    static void setup(){
        //User
        User testUser = TestDataFactoryGR.createTestUser();
        insert testUser;
        System.runAs(testUser){
            //URLs cust sett
            URLs__c sett1 = new URLs__c();
            sett1.Name = 'AmcparkingInfo';
            sett1.URL__c = 'http://151.253.59.13:3000/amcparkingInfo?token=wtvr';
            Insert sett1;    
        }
    } 
    

    @isTest
    public static void shopDetailTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            List<ParkingWrapper> items = Parking_Mapper.getGeneralParkingInfo();
            Test.stopTest();
            System.assertNotEquals(Null, items);
        }
    }
    
    @isTest
    public static void generalInfoTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            ParkingWrapper.GRParking wrpGRP = Parking_Mapper.getGeneralParkingInfoNew();
            Test.stopTest();
            System.assertNotEquals(Null, wrpGRP);
        }
    }
    
    @isTest
    public static void GetParkingInfoTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            List<ParkingWrapper> items = Parking_Mapper.getParkingInfo();
            Test.stopTest();
            System.assertNotEquals(Null, items);
        }
    }
    
    @isTest
    public static void getEastDetailsTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            List<ParkingWrapper.ParkingDetail> items = Parking_Mapper.getEastDetails();
            Test.stopTest();
            System.assertNotEquals(Null, items);
        }
    }
    
    @isTest
    public static void getWestDetailsTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            Test.setMock(HttpCalloutMock.class, new MockParkingInfoSlotsAvailable());
            Test.startTest();
            List<ParkingWrapper.ParkingDetail> items = Parking_Mapper.getWestDetails();
            Test.stopTest();
            System.assertNotEquals(Null, items);
        }
    }
}