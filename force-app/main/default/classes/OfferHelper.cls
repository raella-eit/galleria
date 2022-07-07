public with sharing class OfferHelper {
    //INDENT-OFF
    private static String offerQuery =  'SELECT Id,' +
                                        'Name,' +
        								'Terms_Conditions__c,'+
                                        'Category__c,' +
                                        'End_Date__c,' +
                                        'Start_Date__c,' +
                                        'Description__c,' +
                                        'DescriptionAR__c,' +
                                        'OfferNameAR__c,' +
                                        'VIP__c,' +
                                        'B2CShop__c,'+
                                        'B2CShop__r.Name,'+
                                        '(SELECT Id,' +
                                        ' ContentDocument.LatestPublishedVersionId' +
                                        ' FROM ContentDocumentLinks' +
                                        ' WHERE Visibility = \'AllUsers\'' +
                                        ' LIMIT 1)' +
                                        'FROM Offer__c';
    //INDENT-ON

    /**
     * @description transforms a list of offers, each containing a single file attachment, into a wrapper.
     * @author enassif-ext@dlpk.fr | 09-29-2021
     * @param offerList - offers to be transformed
     * @return Map<Id, GenericDataCardItem>
     **/
    public static Map<Id, GenericDataCardItem> getGenericDataCardItemMap(List<Offer__c> offerList){
        Map<Id, GenericDataCardItem> result = new Map<Id, GenericDataCardItem>();
        for(Offer__c offer : offerList) {
            GenericDataCardItem item = new GenericDataCardItem(offer);
            Id resultId = offer.ContentDocumentLinks.isEmpty()? offer.Id : offer.ContentDocumentLinks.get(0).ContentDocument.LatestPublishedVersionId;
            result.put(resultId, item);
        }

        List<ContentDistribution> contentDistributionList = ContentDistributionHelper.getContentDistributionList(result.keySet());

        for(ContentDistribution contentDistribution : contentDistributionList) {
            result.get(contentDistribution.ContentVersionId).imgSrc = contentDistribution.ContentDownloadUrl;
        }

        return result;
    }

    //The account details are not shared with community users.
    public without sharing class OfferHelperWO {
        /**
         * @description Retrieves a subset of offers that did not yet end, and are approved, filtered by categories
         * @author enassif-ext@dlpk.fr | 09-29-2021
         * @param limitSize
         * @param offset
         * @param offerCategoryList
         * @return List<SObject>
         **/
        public List<SObject> getOfferWithImageList(Integer limitSize, Integer offset, Boolean isVIPUser){
            List<String> offerCategoryList = getCategoryPicklistValues();
            String vipCondition = isVIPUser == null || !isVIPUser ? 'AND VIP__c = FALSE ' : ''; 
            String query = offerQuery;
            query += ' WHERE End_Date__c >= TODAY ' +
            'AND B2CShop__c != NULL ' +
            'AND Approval_Status__c = \'Approved\' ' +
            vipCondition +
            'ORDER BY End_Date__c ASC, Start_Date__c ASC ' +
            'LIMIT :limitSize ' +
            'OFFSET :offset';

            return Database.query(query);
        }

        private List<String> getCategoryPicklistValues() {
            List<String> offerCategoryList = new List<String>();
            List<Schema.PicklistEntry> picklistEntries = ObjectUtils.getPicklistOptionsBySObjectName('Offer__c', 'Category__c');
            for (Schema.PicklistEntry entry : picklistEntries) {
                offerCategoryList.add(entry.getLabel());
            }

            return offerCategoryList;
        }

        /**
         * @description retrieves the details of a single offer
         * @author enassif-ext@dlpk.fr | 09-29-2021
         * @param offerId
         * @return List<SObject>
         **/
        public List<SObject> getOfferWithImageListById(Id offerId){
            String query = offerQuery;
            query += ' WHERE Id = :offerId';

            return Database.query(query);
        }
    }
}