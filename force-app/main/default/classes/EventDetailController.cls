public without sharing class EventDetailController {
    
    /**
    * @description Retrieve the details of a specific event.
    * @author Adnan Chamma | 11/10/2021 
    * @param eventId - the Id of the event to be retrieved
    * @return GenericDataCardItem 
    **/
    @AuraEnabled(cacheable = true)
    public static GenericDataCardItem getEvent(Id eventId){
        GenericDataCardItem result = new GenericDataCardItem();
        if(eventId != null) {

            List<B2C_Promo__c> eventList = new EventHelper.EventHelperWO().getEventWithImageListById(eventId);
            Map<Id, GenericDataCardItem> itemMap = EventHelper.getGenericDataCardItemMap(eventList);
            result = itemMap.isEmpty()? null : itemMap.values().get(0);
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isEventScheduled(Id eventId){
        return ![SELECT Id FROM B2C_Promo_Schedule__c WHERE Content_Management__c =: eventId AND Available__c = true].isEmpty();
    }
}