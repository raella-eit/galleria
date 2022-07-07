public without sharing class wayFinding {

    @AuraEnabled(cacheable = false)
    public static fromToDestination findStore(Id storeId, Boolean isGuest) {
        isGuest = isGuest != null ? isGuest : false;
        fromToDestination retVal = new fromToDestination();
        List<B2CShop__c> shopsList = new List<B2CShop__c>();

        if(!isGuest) {
            List<DeviceLocation__c> locationList = [SELECT Zone_ID__c
                                                    FROM DeviceLocation__c
                                                    WHERE email__c = :UserInfo.getUserEmail()
                                                    Order By LastModifiedDate Desc NULLS LAST Limit 1];

            //Get roomId for the choosed account(Store)
            if(!locationList.isEmpty()) {
                String fetchedDeviceZone = locationList[0].Zone_ID__c;
                shopsList = [SELECT roomID__c, zone__c FROM B2CShop__c WHERE Id =: storeId or (zone__c = :fetchedDeviceZone AND roomID__c != null) ];
            } else {
                return findStore(storeId, true);
            }
        } else {
            shopsList = [SELECT roomID__c, zone__c
                         FROM B2CShop__c
                         WHERE Id =: storeId];
        }

        for(B2CShop__c shop : shopsList) {
            if(shop.Id == storeId) {
                retVal.toId = shop.roomID__c;
                if(String.isNotBlank(retVal.fromId)) {
                    break;
                }
            } else {
                retVal.fromId = shop.roomID__c;
                if(String.isNotBlank(retVal.toId)) {
                    break;
                }
            }
        }

        return retVal;
    }

    public class fromToDestination {
        @AuraEnabled
        public String fromId;
        @AuraEnabled
        public String toId;
    }
}