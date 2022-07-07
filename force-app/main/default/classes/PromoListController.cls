public with sharing class PromoListController {

    private static Map<String, Schema.RecordTypeInfo> promoRecordTypeMap = ObjectUtils.getRecordTypesMap('B2C_Promo__c');

    @AuraEnabled(cacheable = true)
    public static List<GenericDataCardItem> getCarouselItemList(){
        List<GenericDataCardItem> result = new List<GenericDataCardItem>();
        Set<Id> promoRecordTypeIdSet = new Set<Id>();
        for(Schema.RecordTypeInfo rtInfo : promoRecordTypeMap.values()) {
            promoRecordTypeIdSet.add(rtInfo.getRecordTypeId());
        }
        List<B2C_Promo__c> eventList = new EventHelper.EventHelperWO().getEventWithImageList(5, 0, promoRecordTypeIdSet, true, false);
        result = EventHelper.getGenericDataCardItemMap(eventList).values();

        return result;
    }
}