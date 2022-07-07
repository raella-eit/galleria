@isTest
public with sharing class ShopSearchComboController_TEST {
    @TestSetup
    static void makeData(){
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

        
    }

    @isTest
    static void getShopListTest(){
        List<B2CShop__c> shopList = [SELECT Id FROM B2CShop__c];
        List<Id> resultId = new List<Id>();
        for(B2CShop__c shop:shopList){
            resultId.add(shop.Id);
        }
        Test.setFixedSearchResults(resultId);
        Test.startTest();
        System.assertEquals(2, ShopSearchComboController.getShopList('GR').size(), 'Expected 2 results');
        Test.stopTest();
    }

    @isTest
    static void getShopTest(){
        Test.startTest();
        System.assertNotEquals(null, ShopSearchComboController.getShop('1'), 'Expected 1 result');
        Test.stopTest();
    }
}