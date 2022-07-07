public without sharing class EventHelper {
    private static Id retailerPromoRecordTypeId = ObjectUtils.getRecordTypeId('B2C_Promo__c', 'Retailer_Offer_Promotion');

    //INDENT-OFF
    private static String eventQuery =  'SELECT Id,' +
                                        'Name,' +
                                        'Category__c,' +
                                        'End_Date__c,' +
                                        'Start_Date__c,' +
                                        'Description__c,' +
                                        'Description_Ar__c,' +
                                        'RecordTypeId,' +
                                        'B2C_Promo_Name_Ar__c,' +
                                        'Offer__c,'+
                                        'Offer__r.Name,'+
                                        'Offer__r.Category__c,' +
                                        'Offer__r.End_Date__c,' +
                                        'Offer__r.Start_Date__c,' +
                                        'Offer__r.Description__c,' +
                                        'Offer__r.DescriptionAR__c,' +
                                        'Offer__r.OfferNameAR__c,' +
                                        'Offer__r.VIP__c,' +
                                        'Offer__r.B2CShop__c,'+
                                        'Offer__r.B2CShop__r.Name,'+
        								'Offer__r.Terms_Conditions__c,'+
                                        '(SELECT Id,' +
                                        ' ContentDocument.LatestPublishedVersionId' +
                                        ' FROM ContentDocumentLinks' +
                                        ' WHERE Visibility = \'AllUsers\'' +
                                        ' LIMIT 1)' +
                                        'FROM B2C_Promo__c';
    //INDENT-ON

    /**
     * @description transforms a list of Events, each containing a single file attachment, into a wrapper.
     * @author Adnan Chamma | 11/10/2021
     * @param eventsList - events to be transformed
     * @return Map<Id, GenericDataCardItem>
     **/
    public static Map<Id, GenericDataCardItem> getGenericDataCardItemMap(List<B2C_Promo__c> eventList){
        Map<Id, GenericDataCardItem> result = new Map<Id, GenericDataCardItem>();
        Map<Id, Offer__c> offerMap = new Map<Id, Offer__c>();
        for(B2C_Promo__c event : eventList) {
            if(event.RecordTypeId != retailerPromoRecordTypeId) {
                GenericDataCardItem item = new GenericDataCardItem(event);
                Id resultId = event.ContentDocumentLinks.isEmpty()? event.Id : event.ContentDocumentLinks.get(0).ContentDocument.LatestPublishedVersionId;
                result.put(resultId, item);
            } else {
                offerMap.put(event.Offer__c, event.Offer__r);
            }
        }

        if(!offerMap.isEmpty()) {
            List<ContentDocumentLink> offerDocumentList = [SELECT Id,
                                                           ContentDocument.LatestPublishedVersionId,
                                                           LinkedEntityId
                                                           FROM ContentDocumentLink
                                                           WHERE Visibility = 'AllUsers'
                                                           AND LinkedEntityId IN :offerMap.keySet()
                                                           LIMIT 1];

            for(ContentDocumentLink offerDocument : offerDocumentList) {
                result.put(offerDocument.ContentDocument.LatestPublishedVersionId, new GenericDataCardItem(offerMap.get(offerDocument.LinkedEntityId)));
            }
        }

        List<ContentDistribution> contentDistributionList = ContentDistributionHelper.getContentDistributionList(result.keySet());

        for(ContentDistribution contentDistribution : contentDistributionList) {
            result.get(contentDistribution.ContentVersionId).imgSrc = contentDistribution.ContentDownloadUrl;
        }

        return result;
    }

//The Event details are not shared with community users.
    public without sharing class EventHelperWO {

        /**
         * @description Retrieves active events
         * @author Adnan Chamma | 13-10-2021
         * @param limitSize
         * @param offset
         * @return List<SObject>
         **/
        public List<SObject> getEventWithImageList(Integer limitSize, Integer offset, Set<Id> eventRecordTypeIdSet, Boolean isHighlight, Boolean isListed){
            String query = eventQuery;
            String highlightCondition = isHighlight == null || !isHighlight ? '' : 'AND Highlight__c = true ';
            String listedCondition = isListed == null || !isListed ? '' : 'AND Event_Listed__c = true ';
            eventRecordTypeIdSet = eventRecordTypeIdSet != null ? eventRecordTypeIdSet : new Set<Id> {ObjectUtils.getRecordTypeId('B2C_Promo__c', 'Event_Galleria_Offer_Promotion')};
            query += ' WHERE Active__c = true AND RecordTypeId IN :eventRecordTypeIdSet ' +
            'AND (End_Date__c >= TODAY OR (Offer__c != null AND Offer__r.End_Date__c >= TODAY)) ' +
            highlightCondition + listedCondition +
            'ORDER BY Start_Date__c ASC ' +
            'LIMIT :limitSize ' +
            'OFFSET :offset';
            System.debug(query);
            return Database.query(query);
        }

        /**
         * @description retrieves the details of a single event
         * @author Adnan Chamma | 11/10/12021
         * @param eventId
         * @return List<SObject>
         **/
        public List<SObject> getEventWithImageListById(Id eventId){
            String query = eventQuery;
            query += ' WHERE Id = :eventId';// AND RecordType.DeveloperName=\'Event_Galleria_Offer_Promotion\'';

            return Database.query(query);
        }
    }

}