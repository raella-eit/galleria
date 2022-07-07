trigger B2CShopTrigger on B2CShop__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new B2CShopTriggerHandler().run(); 
}