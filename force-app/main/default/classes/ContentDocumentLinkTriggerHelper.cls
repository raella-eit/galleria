public with sharing class ContentDocumentLinkTriggerHelper {
    private static final Id RETAILER_RECTYPE_ID = ObjectUtils.getRecordTypeId('Account', 'Retailer');
    private static final Id EVENT_RECTYPE_ID = ObjectUtils.getRecordTypeId('B2C_Promo__c', 'Event_Galleria_Offer_Promotion');
    
    /**
     * @description shares files created by Internal Users with Partner Users
     * @author Raella Frem | 20-09-2021
     * @param List<ContentDocumentLink> newList
     **/
    public static void setVisibility (List<ContentDocumentLink> newList) {
        for(ContentDocumentLink cdlRec : newList) {
            if(cdlRec.LinkedEntityId.getSObjectType() == Account.sObjectType 
                || cdlRec.LinkedEntityId.getSObjectType() == Offer__c.sObjectType
                || cdlRec.LinkedEntityId.getSObjectType() == B2C_Promo__c.sObjectType
                || cdlRec.LinkedEntityId.getSObjectType() == Permit__c.sObjectType ){
                cdlRec.ShareType = 'I';
                cdlRec.Visibility = 'AllUsers';
            }
        }
    }

    /**
     * @description Create content distribution for each newly created contentDocumentLink
     * @author Adnan Chamma | 28-09-2021
     * @param List<ContentDocumentLink> newList
     **/
    public static void createContentDistribution(List<ContentDocumentLink> newList){
        //Create sets of account/offer Id's and list of contentVersion and list of contentdistribution
        Set<id> linkedEntityIdSet = new Set<id>();
        List<ContentDocument> contentVersionList = new List<ContentDocument>();
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        Set<Id> contentDocumentSetId = new Set<Id>();
        //iterate on trigger.new to get all accounts/offers id
        for(ContentDocumentLink related_rec : newList) {
            if(related_rec.LinkedEntityId.getSObjectType() == Account.sObjectType 
            || related_rec.LinkedEntityId.getSObjectType() == Offer__c.sObjectType
            || related_rec.LinkedEntityId.getSObjectType() == B2C_Promo__c.sObjectType) {
                linkedEntityIdSet.add(related_rec.LinkedEntityId);
                contentDocumentSetId.add(related_rec.Id);
            }
        }
        //Get all account's of type retailer and offers and events and create a record in content distribution
        if(!linkedEntityIdSet.isEmpty()) {
            Map<Id, ContentDocumentLink> cdlMap =
            new Map<Id, ContentDocumentLink>([SELECT Id, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                                                FROM ContentDocumentLink
                                                WHERE Id IN: contentDocumentSetId]);

            Map<Id, Account> accountsMap =
            new Map<Id, Account>([SELECT Id, RecordType.DeveloperName, RecordType.Name
                                    FROM Account
                                    WHERE Id IN: linkedEntityIdSet
                                    AND RecordTypeId = :RETAILER_RECTYPE_ID]);
            Map<Id, Offer__c> offersMap =
            new Map<Id, Offer__c>([SELECT Id, Name
                                    FROM Offer__c
                                    WHERE Id IN: linkedEntityIdSet]);

            Map<Id, B2C_Promo__c> eventsMap =
            new Map<Id, B2C_Promo__c>([SELECT Id, Name,RecordType.DeveloperName, RecordType.Name
                                       FROM B2C_Promo__c
                                       WHERE Id IN: linkedEntityIdSet
                                       AND RecordTypeId = :EVENT_RECTYPE_ID]);

            for(ContentDocumentLink cdl : newList) {
                if(offersMap.containsKey(cdl.LinkedEntityId) 
                        || accountsMap.containsKey(cdl.LinkedEntityId) 
                        || eventsMap.containsKey(cdl.LinkedEntityId)) {
                    ContentDistribution contentDist = new ContentDistribution ();
                    contentDist.Name = cdlMap.get(cdl.Id).contentDocument.Title;
                    contentDist.ContentVersionId = cdlMap.get(cdl.Id).contentDocument.LatestPublishedVersionId;
                    contentDist.RelatedRecordId = cdl.LinkedEntityId;
                    contentDist.PreferencesNotifyOnVisit = false;
                    contentDistributionList.add(contentDist);
                }

            }
            insert contentDistributionList;
        }
    }

}