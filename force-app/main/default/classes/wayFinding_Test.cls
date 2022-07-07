@isTest
private with sharing class wayFinding_Test {

    @testSetup static void setup() {
        User customerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('customer')) {
                customerUser = userRec;
            }
        }
        List<B2CShop__c> shopList = new List<B2CShop__c>();
        shopList.add(new B2CShop__c(
                         StoreLocation__c = 'Level L2',
                         description__c = 'ddd',
                         OpeningHours__c = 'Daily: 10 AM - 1 AM',
                         ParkNear__c = 'Section A',
                         phone__c = '035678',
                         category__c = 'Eat',
                         Name = 'GR 1',
                         RoomID__c = '1'));
        shopList.add(new B2CShop__c(
                         StoreLocation__c = 'Level L2',
                         description__c = 'ddd',
                         OpeningHours__c = 'Daily: 10 AM - 1 AM',
                         ParkNear__c = 'Section A',
                         phone__c = '035678',
                         category__c = 'Eat',
                         Name = 'GR 2',
                         RoomID__c = '2'));
        insert shopList;

        DeviceLocation__c devLoc = new DeviceLocation__c(Zone__c = 'D7FDE8E3-8AC5-6735-991C-129A6D83D561', Email__c = customerUser.Email );
        insert devLoc;
    }

    @isTest
    private static void storeTest() {

        List<B2CShop__c> shopList = [SELECT id, name, RoomId__c FROM B2CShop__c WHERE RoomId__c = '1'];
        Id shopId = shopList[0].Id;

        List<User> customerUser = [SELECT id, ContactId FROM User where Email LIKE '%customer%'];

        System.runAs(customerUser.get(0)) {
            wayFinding.fromToDestination dest = new wayFinding.fromToDestination();

            dest = wayFinding.findStore(shopId, true);
            dest = wayFinding.findStore(shopId, false);

            //    System.assertEquals(devLoc.get(0).Zone__c, dest.fromId, 'invalid From Id location');
            //     System.assertEquals(accountsList?.get(0).RoomId__c, dest.toId, 'invalid To Id location');
        }
    }

}