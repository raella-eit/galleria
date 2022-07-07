public with sharing class OfferDetailController {
    /**
    * @description Retrieve the details of a specific offer.
    * @author enassif-ext@dlpk.fr | 09-29-2021 
    * @param offerId - the Id of the offer to be retrieved
    * @return GenericDataCardItem 
    **/
    @AuraEnabled(cacheable = true)
    public static GenericDataCardItem getOffer(Id offerId){
        GenericDataCardItem result = new GenericDataCardItem();
        if(offerId != null) {

            List<Offer__c> offerList = new OfferHelper.OfferHelperWO().getOfferWithImageListById(offerId);
            Map<Id, GenericDataCardItem> itemMap = OfferHelper.getGenericDataCardItemMap(offerList);
            result = itemMap.isEmpty()? null : itemMap.values().get(0);
        }

        return result;
    }
}