trigger UserTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new UserTriggerHandler().run();
}