public without sharing class OfferTriggerHelper {
    private static Id retailerPromoRecordTypeId = ObjectUtils.getRecordTypeId('B2C_Promo__c', 'Retailer_Offer_Promotion');

    /**
     * @description retrieves current user's Account and assigns it as Offer lookup(Account)
     *             - if account has mirror B2C Shop object, assign Lookup(B2CShop__c) as well
     * @author Raella Frem | 08-09-2021
     * @param List<Offer__c> newOffersList
     **/
    public static void setDefaultAccount(List<Offer__c> newOffersList) {
        Id currentUserAccountId = [SELECT AccountId
                                   FROM User
                                   WHERE Id = : UserInfo.getUserId()]?.get(0).AccountId;
        Id b2cShopId = null;
        List<B2CShop__c> b2cShopList = [SELECT Id
                                        FROM B2CShop__c
                                        WHERE Account__c = :currentUserAccountId];

        if(!b2cShopList.isEmpty()) {
            b2cShopId = b2cShopList.get(0).Id;
        }

        for(Offer__c offerRec : newOffersList) {
            if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)) {
                offerRec.Account__c = currentUserAccountId != null ? currentUserAccountId : null;
                offerRec.B2CShop__c = b2cShopId != null ? b2cShopId : null;
            // } else {
            //     offerRec.addError(System.Label.INSUFFICIENT_ACCESS_MSG);
            }
        }
    }

    /**
     * @description filters Offers to check for sharing and calls handleOfferSharing to manage record sharing
     * @author Raella Frem | 09-09-2021
     * @param Map<Id Offer__c> oldMap
     * @param List<Offer__c> newOffersList
     **/
    public static void shareOffer(Map<Id, Offer__c> oldMap, List<Offer__c> newOffersList) {
        List<Offer__c> offersToManageList = new List<Offer__c>();
        for(Offer__c offer : newOffersList) {
            if((oldMap == null && offer.IsOnAllBranches__c) ||
               (oldMap != null && oldMap.get(offer.Id).IsOnAllBranches__c != offer.IsOnAllBranches__c)) {
                offersToManageList.add(offer);
            }
        }

        if(!offersToManageList.isEmpty()) {
            handleOfferSharing(offersToManageList);
        }
    }

    /**
     * @description shares/hides Offer records with/from sibling users depending on IsOnAllBranches field state/modification
     * @author Raella Frem | 09-09-2021
     * @param List<Offer__c> offersList
     **/
    public static void handleOfferSharing(List<Offer__c> offersList) {
        Id currentUserParentAccountId = [SELECT Account.ParentId
                                         FROM User
                                         WHERE Id = :UserInfo.getUserId()]?.get(0).Account.ParentId;

        List<Id> siblingUsersIdsList =
        new List<Id>(new Map<Id, User>( [SELECT Id
                                         FROM User
                                         WHERE AccountId IN (SELECT Id
                                                             FROM Account
                                                             WHERE ParentId = : currentUserParentAccountId)]).keySet());

        List<Offer__Share> offersToShareList = new List<Offer__Share>();
        Set<Id> offersToHideIdSet = new Set<Id>();

        for(Offer__c offer : offersList) {
            for(Id userId : siblingUsersIdsList) {
                if(offer.IsOnAllBranches__c) {
                    Offer__Share offerShare = new Offer__Share();
                    offerShare.ParentId = offer.Id;
                    offerShare.AccessLevel = 'read';
                    offerShare.RowCause = Schema.Offer__Share.RowCause.ShareAcrossBranches__c;
                    offerShare.UserOrGroupId = userId;
                    offersToShareList.add(offerShare);
                } else {
                    offersToHideIdSet.add(offer.Id);
                }
            }
        }

        List<Offer__Share> offersToHideList = new List<Offer__Share>();
        for(Offer__Share offerShare : [SELECT Id FROM Offer__Share WHERE ParentId IN : offersToHideIdSet AND RowCause = : Schema.Offer__Share.RowCause.ShareAcrossBranches__c]) {
            offersToHideList.add(offerShare);
        }

        try {
            if(!offersToShareList.isEmpty()) {
                insert offersToShareList;
            }
            if(!offersToHideList.isEmpty()) {
                delete offersToHideList;
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description restricts Partner Users from editing Approved Offer records, except for the Comment__c field
     * @author Raella Frem | 15-09-2021
     * @param Map<Id Offer__c> newMap
     * @param Map<Id Offer__c> oldMap
     **/
    public static void restrictRecordEdit(Map<Id, Offer__c> newMap, Map<Id, Offer__c> oldMap) {

        if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)) {

            Set<id> offerIdsSet = newMap.keySet();

            Map<String, Schema.SObjectField> allOfferFieldsMap = Schema.SObjectType.Offer__c.fields.getMap();

            List<String> listOfFields = new List<String>();
            listOfFields.addAll(allOfferFieldsMap.keySet());

            List<Offer__c> offersList = Database.query('SELECT ' + String.join(listOfFields, ', ') + ' FROM Offer__c WHERE Id IN :offerIdsSet');

            List<String> updatedFields = new List<String>();

            Set<String> restrictedFieldsSet = new Set<string>(System.Label.OFFR_FieldsToRevertChanges.split(';'));

            Offer__c oldOffer = new Offer__c ();

            for(Offer__c newOffer : offersList) {
                oldOffer = oldMap.get(newOffer.Id);
                for(String field : allOfferFieldsMap.keySet()) {
                    if(newOffer.get(field) != oldOffer.get(field) && restrictedFieldsSet.contains(field) && newOffer.Approval_Status__c == 'Approved') {
                        newMap.get(newOffer.Id).addError(System.Label.OFFR_ERR_EditApproval);
                    }
                }
            }
        }
    }

    /**
     * @description Synchronizing Push_Notification and Highlight field between Offer and B2C_Promo Objects covering all cases
     * @author Adnan Chamma | 11-10-2021
     * @param List<Offer__c> newOffersList
     * @param Map<Id Offer__c> oldOffersMap
     **/
    public static void syncOfferPromotion(List<Offer__c> newOffersList, Map<Id, Offer__c> oldOffersMap){
        //set of offer id that changed there push notification field
        Set<Id> modifiedOfferIdSet = new Set<Id>();
        //Create a list for the promo that will be created
        List<B2C_Promo__c> promoListToCreate = new List<B2C_Promo__c>();
        //Create a list for the promo that will be updated
        List<B2C_Promo__c> promoListToUpdate = new List<B2C_Promo__c>();
        // Map < offerId, ParentAccount.Zone__c >
        Map<Id, String> offerIdToZoneMap = new Map<Id, String>();
        // Set < parentAccountID >
        Set<Id> accountIdsSet = new Set<Id>();

        for(Offer__c offer : newOffersList) {

            if(offer.Push_Notification__c != oldOffersMap.get(offer.Id).Push_Notification__c || offer.Highlight__c != oldOffersMap.get(offer.Id).Highlight__c) {
                modifiedOfferIdSet.add(offer.id);
                accountIdsSet.add(offer.Account__c);
            }
        }

        if(!modifiedOfferIdSet.isEmpty()) {

            Map<Id, Account> accountIdToZoneIdMap =
            new Map<Id, Account>([SELECT Id, Zone__c FROM Account WHERE Id IN: accountIdsSet]);

            for(Offer__c offerRec : newOffersList) {
                offerIdToZoneMap.put(offerRec.Id,
                                     accountIdToZoneIdMap.get(offerRec.Account__c).Zone__c);
            }
            //map that get promos linked to offers
            Map<Id, Id> offerIdToPromoIdMap = new Map<Id, Id>();
            for(B2C_Promo__c promo : [SELECT Id, Offer__c FROM B2C_Promo__c WHERE Offer__c IN  : modifiedOfferIdSet ]) {
                offerIdToPromoIdMap.put(promo.Offer__c, promo.Id);
            }

            for(Offer__c newOffer : newOffersList) {

                if(newOffer.Push_Notification__c != oldOffersMap.get(newOffer.Id).Push_Notification__c || newOffer.Highlight__c != oldOffersMap.get(newOffer.Id).Highlight__c) {
                    if(offerIdToPromoIdMap.containsKey(newOffer.Id)) {
                        B2C_Promo__c promo = new B2C_Promo__c(Id = offerIdToPromoIdMap.get(newOffer.Id));
                        promo.Push_Notification__c = newOffer.Push_Notification__c;
                        promo.Highlight__c = newOffer.Highlight__c;
                        promo.Active__c = newOffer.Status__c == System.Label.Offer_status_active;
                        promo.Start_Date__c = newOffer.Start_Date__c;
                        promo.End_Date__c = newOffer.End_Date__c;
                        promo.Zone__c = offerIdToZoneMap.get(newOffer.Id);
                        promoListToUpdate.add(promo);
                    } else {
                        B2C_Promo__c promoNew = new B2C_Promo__c();
                        promoNew.Name = newOffer.name;
                        promoNew.Push_Notification__c = newOffer.Push_Notification__c;
                        promoNew.Highlight__c = newOffer.Highlight__c;
                        promoNew.Offer__c = newOffer.Id;
                        promoNew.RecordTypeId = retailerPromoRecordTypeId;
                        promoNew.Start_Date__c = newOffer.Start_Date__c;
                        promoNew.End_Date__c = newOffer.End_Date__c;
                        promoNew.Zone__c = offerIdToZoneMap.get(newOffer.Id);
                        promoNew.Active__c = newOffer.Status__c == System.Label.Offer_status_active;
                        promoListToCreate.add(promoNew);
                    }
                }
            }
            if(!promoListToUpdate.isEmpty()) {
                update promoListToUpdate;
            }
            if(!promoListToCreate.isEmpty()) {
                insert promoListToCreate;
            }
        }
    }

}