trigger DeviceLocationTrigger on DeviceLocation__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new DeviceLocationTriggerHandler().run();
}