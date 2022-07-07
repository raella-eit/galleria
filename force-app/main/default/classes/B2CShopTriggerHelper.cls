public without sharing class B2CShopTriggerHelper {
    public static void manageOffers (Map<Id, B2CShop__c> newMap) {
        Map<Id, B2CShop__c> shopsByAccountIdMap = new Map<Id, B2CShop__c>();
        for(Id shopId : newMap.keySet()) {
            shopsByAccountIdMap.put(newMap.get(shopId).Account__c, newMap.get(shopId));
        }

        List<Offer__c> offersList = [SELECT Id, Account__c, B2CShop__c
                                     FROM Offer__c
                                     WHERE Account__c IN :shopsByAccountIdMap.keySet()];

        for(Offer__c offer : offersList) {
            Id newShopId = shopsByAccountIdMap.get(offer.Account__c).Id;
            if(offer.B2CShop__c != newShopId){
            	offer.B2CShop__c = newShopId;
            }
        }
        update offersList;

    }
}