trigger B2CPromoTrigger on B2C_Promo__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new B2CPromoTriggerHandler().run();
}