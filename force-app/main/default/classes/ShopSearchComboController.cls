public without sharing class ShopSearchComboController {
    @AuraEnabled(cacheable = true)
    public static List<B2CShop__c> getShopList(String name){
        List<List<SObject>> sobjectList = [FIND :name IN NAME FIELDS RETURNING
                                           B2CShop__c(id, name, RoomID__c WHERE RoomID__c != null)];

        return sobjectList[0];
    }

    @AuraEnabled(cacheable = true)
    public static B2CShop__c getShop(String roomId){
        return [SELECT Id, Name, RoomID__c
                FROM B2CShop__c
                WHERE RoomID__c = : roomId]?.get(0);
    }
}