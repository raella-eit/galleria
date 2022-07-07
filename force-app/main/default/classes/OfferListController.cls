public with sharing class OfferListController {
    /**
     * @description Retrieves the list of offers to be shown based on category and pagination.
     * @author enassif-ext@dlpk.fr | 09-29-2021
     * @param limitSize - maximum number of items per page
     * @param offset - the current number of items displayed
     * @param offerCategoryList - the categories to be included in the result
     * @return List<GenericDataCardItem>
     **/
    @AuraEnabled(cacheable = true)
    public static List<GenericDataCardItem> getFutureOfferList(Integer limitSize, Integer offset, Boolean isVIPUser){
        List<GenericDataCardItem> result = new List<GenericDataCardItem>();
        limitSize = limitSize != null ? limitSize : 0;
        offset = offset != null ? offset : 0;
        List<Offer__c> offerList = new OfferHelper.OfferHelperWO().getOfferWithImageList(limitSize, offset, isVIPUser);
        result = OfferHelper.getGenericDataCardItemMap(offerList).values();

        return result;

    }
}