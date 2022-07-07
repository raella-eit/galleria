@isTest
public with sharing class DeviceLocationDeletionBatch_TEST {

    @TestSetup
    static void makeData(){
        TestDataFactoryGR.createDeviceLocationsList(3,true);
    }

    @isTest
    public static void deviceLocationDeletionBatchTest() {
        List<DeviceLocation__c> deviceLocationsList = [SELECT Id FROM DeviceLocation__c];
        System.assert(deviceLocationsList.size() == 3, 'records not inserted');

        Test.startTest();

        DeviceLocationDeletionBatch deletionBatch = new DeviceLocationDeletionBatch();
        Id processId = Database.executeBatch(deletionBatch);

        Test.stopTest();

        deviceLocationsList = [SELECT Id FROM DeviceLocation__c];
        System.assert(deviceLocationsList.isEmpty(),'batch did not delete records');
    }
}