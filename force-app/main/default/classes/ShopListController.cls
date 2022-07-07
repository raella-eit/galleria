public with sharing class ShopListController {

    /**
     * @description returns Accounts of type retailer with category in categoryList
     * @author Adnan Chamma | 27-09-2021
     * @param limitSize - maximum number of items per page
     * @param offset - the current number of items displayed
     * @param List<String> storeCategoryList
     * @return List<GenericDataCardItem>
     **/
    @AuraEnabled(cacheable = true)
    public static List<GenericDataCardItem> getAccountList(Integer limitSize, Integer offset, Boolean isFeaturedFirst){
        isFeaturedFirst = isFeaturedFirst != null ? isFeaturedFirst : false;
        List<GenericDataCardItem> result = new List<GenericDataCardItem>();
        limitSize = limitSize != null ? limitSize : -1;
        offset = offset != null ? offset : 0;
        List<ShopHelper.ShopWrapper> accountList = new ShopHelper.ShopHelperWO().getShopWithImageList(limitSize, offset, isFeaturedFirst);
        result = ShopHelper.getGenericDataCardItemMap(accountList).values();

        return result;

    }

    @AuraEnabled(cacheable = true)
    public static List<GenericDataCardItem> getShopList(Integer limitSize, Integer offset){
        limitSize = limitSize != null ? limitSize : 50000;
        offset = offset != null ? offset : 0;
        List<B2CShop__c> b2cShopList = new ShopHelper.ShopHelperWO().getB2CShopList(limitSize, offset);

        List<GenericDataCardItem> genericDataCardItempList = new List<GenericDataCardItem>();

        Map<Id, Id> cvIdToAccountIdMap = new Map<Id, Id>();
        for(B2CShop__c b2cShop : b2cShopList) {
            genericDataCardItempList.add(new GenericDataCardItem(b2cShop));
        }

        return genericDataCardItempList;
    }
}