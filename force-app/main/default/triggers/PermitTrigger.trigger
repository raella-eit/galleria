trigger PermitTrigger on Permit__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new PermitTriggerHandler().run();
}