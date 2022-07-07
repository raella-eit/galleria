public with sharing class EventListController {
    /**
     * @description Retrieves the list of events to be shown.
     * @author Adnan Chamma | 13-10-2021
     * @param limitSize - maximum number of items per page
     * @param offset - the current number of items displayed
     * @return List<GenericDataCardItem>
     **/
    @AuraEnabled(cacheable = true)
    public static List<GenericDataCardItem> getFutureEventList(Integer limitSize, Integer offset){
        List<GenericDataCardItem> result = new List<GenericDataCardItem>();
        limitSize = limitSize != null ? limitSize : 0;
        offset = offset != null ? offset : 0;

        List<B2C_Promo__c> eventList = new EventHelper.EventHelperWO().getEventWithImageList(limitSize, offset, null, false, true);
        result = EventHelper.getGenericDataCardItemMap(eventList).values();

        return result;

    }
}