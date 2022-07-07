@isTest
public class DeviceLocationTrigger_TEST {

    @TestSetup
    static void setupData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account personAccount1 = new Account(LastName = 'Person Account 1', RecordTypeId = recordTypeId, PersonEmail = 'personAccount1@gulf-related.test.com');
        Account personAccount2 = new Account(LastName = 'Person Account 2', RecordTypeId = recordTypeId, PersonEmail = 'personAccount2@gulf-related.test.com');

        List<Account> accounts = new List<Account> {personAccount1, personAccount2};
        insert accounts;
    }

    @isTest
    public static void testMatchContact() {
        //Get Accounts from DB
        List<Account> accounts = [SELECT Id, PersonEmail, PersonContactId FROM Account WHERE PersonEmail IN ('personAccount1@gulf-related.test.com', 'personAccount2@gulf-related.test.com')];
        //linked to Person Account 1
        DeviceLocation__c deviceLoc1 = new DeviceLocation__c (
            Email__c = 'personAccount1@gulf-related.test.com', Name = 'Person Account1',
            Building__c = 'BLDG 1', Floor__c = '1',
            Location__c = '33.33,34.34', MAC__c = '45:4f:eb:4a:3e:62',
            Phone__c = '03123456', Zone__c = 'Zone 1'
        );
        //linked to Person Account 2
        DeviceLocation__c deviceLoc2 = new DeviceLocation__c (
            Email__c = 'personAccount2@gulf-related.test.com', Name = 'Person Account2',
            Building__c = 'BLDG 2', Floor__c = '2',
            Location__c = '33.33,34.34', MAC__c = '45:4f:eb:4a:3e:62',
            Phone__c = '03123456', Zone__c = 'Zone 2'
        );
        //Lead to be created
        DeviceLocation__c deviceLoc3 = new DeviceLocation__c (
            Email__c = 'personAccount3@gulf-related.test.com', Name = 'Person Account3',
            Building__c = 'BLDG 3', Floor__c = '3',
            Location__c = '33.33,34.34', MAC__c = '45:4f:eb:4a:3e:62',
            Phone__c = '03123456', Zone__c = 'Zone 3'
        );
        //Email is blank, Nothing should happen
        DeviceLocation__c deviceLoc4 = new DeviceLocation__c (
            Name = 'Person Account4',
            Building__c = 'BLDG 4', Floor__c = '4',
            Location__c = '33.33,34.34', MAC__c = '45:4f:eb:4a:3e:62',
            Phone__c = '03123456', Zone__c = 'Zone 4'
        );

        List<DeviceLocation__c> deviceLocationList = new List<DeviceLocation__c> {deviceLoc1, deviceLoc2, deviceLoc3, deviceLoc4};

        Test.startTest();
        insert deviceLocationList;
        deviceLoc4.Phone__c = '70123456';
        Update deviceLoc4;
        Test.stopTest();
        List<Lead> leadPerson3List = [SELECT Id FROM Lead WHERE Email = 'personAccount3@gulf-related.test.com'];
        Map<Id, DeviceLocation__c> deviceLocationMap = new Map<Id, DeviceLocation__c>([SELECT Id, PersonId__c
                                                                                      FROM DeviceLocation__c
                                                                                      WHERE Email__c IN ('personAccount1@gulf-related.test.com', 'personAccount2@gulf-related.test.com', 'personAccount3@gulf-related.test.com')
                                                                                      OR Name = 'Person Account4' ]);
        deviceLoc1.PersonId__c = deviceLocationMap.get(deviceLoc1.Id).PersonId__c;
        deviceLoc2.PersonId__c = deviceLocationMap.get(deviceLoc2.Id).PersonId__c;
        deviceLoc3.PersonId__c = deviceLocationMap.get(deviceLoc3.Id).PersonId__c;
        deviceLoc4.PersonId__c = deviceLocationMap.get(deviceLoc4.Id).PersonId__c;

        Id personContactId1;
        Id personContactId2;

        for(Account account : accounts) {
            if(account.PersonEmail == 'personAccount1@gulf-related.test.com') {
                personContactId1 = account.PersonContactId;
            }
            if(account.PersonEmail == 'personAccount2@gulf-related.test.com') {
                personContactId2 = account.PersonContactId;
            }
        }
        //Validate 1st Device Location with 1st person contact
        System.assertEquals(personContactId1, deviceLoc1.PersonId__c, 'Device Location 1 is not linked to Contact 1');

        //Validate 2nd Device Location with 2nd person contact
        System.assertEquals(personContactId2, deviceLoc2.PersonId__c, 'Device Location 2 is not linked to Contact 2');

        //Validate 4th Device Location
        System.assertEquals(null, deviceLoc4.PersonId__c, 'Device Location 4 should not be linked to Contact');
        Delete deviceLoc4;
        Undelete deviceLoc4;
    }
}