public with sharing class ShopDetailController {
    /**
     * @description Retrieve the details of a specific account.
     * @author enassif-ext@dlpk.fr | 09-29-2021
     * @param shopId - the Id of the offer to be retrieved
     * @return GenericDataCardItem
     **/
    @AuraEnabled(cacheable = true)
    public static GenericDataCardItem getShop(Id shopId){
        GenericDataCardItem result = new GenericDataCardItem();
        if(shopId != null) {

            List<ShopHelper.ShopWrapper> shopList = new ShopHelper.ShopHelperWO().getShopWithImageListById(shopId);
            Map<Id, GenericDataCardItem> itemMap = ShopHelper.getGenericDataCardItemMap(shopList);
            result = itemMap.isEmpty() ? null : itemMap.values().get(0);
        }
        return result;
    }

    /**
     * @description checks if exists all needed location info for user and shop
     *                 used for conditional rendering of wayFinding (Direction) button
     * @author Raella Frem | 17-12-2021
     * @param Id shopId
     * @return boolean
     **/
    @AuraEnabled(cacheable = true)
    public static boolean existsLocationIfo(Id shopId) {
        return new ShopHelper.ShopHelperWO().hasAllLocationInfo(shopId);
    }
}