public with sharing class AccountTriggerHelper {
    private static final Id RETAILER_RECTYPE_ID = ObjectUtils.getRecordTypeId('Account', 'Retailer');
    /**
     * @description checks for Unit Number field duplication
     * @author Raella Frem | 22-10-2021
     * @param Map<Id Account> oldMap
     * @param List<Account> newList
     **/
    public static void checkDuplicateUnitNumber (Map<Id, Account> oldMap, List<Account> newList) {
        List<String> newUnitNumbersList = new List<String>();
        for(Account newAccount : newList) {
            if(String.isNotBlank(newAccount.UnitNumber__c) && newAccount.RecordTypeId == RETAILER_RECTYPE_ID) {
                newUnitNumbersList.add(newAccount.UnitNumber__c);
            }
        }
        newUnitNumbersList = parseUnitNumbersList(newUnitNumbersList);

        List<String> conflictingUnitNumbersList = new List<String>();

        for(Account existingAccount : [SELECT Id, UnitNumber__c, FormattedUnitNumber__c
                                       FROM Account
                                       WHERE RecordTypeId = : RETAILER_RECTYPE_ID
                                       AND UnitNumber__c != null
                                       AND FormattedUnitNumber__c LIKE : newUnitNumbersList]) {
            conflictingUnitNumbersList.add(existingAccount.UnitNumber__c);
        }
        if(!conflictingUnitNumbersList.isEmpty()) {
            conflictingUnitNumbersList = parseUnitNumbersList(conflictingUnitNumbersList);
            for(Account accountRec : newList) {
                if(oldMap == null ||
                   (oldMap != null && oldMap.get(accountRec.Id).UnitNumber__c != accountRec.UnitNumber__c)) {
                    for(String newUnitNumber : formatUnitNumber(accountRec.UnitNumber__c)) {
                        if(conflictingUnitNumbersList.contains(newUnitNumber)) {
                            accountRec.UnitNumber__c.addError(String.format(System.Label.ACT_UNITNUMBER_DUPLICATE_ERR, new String[] {newUnitNumber.replaceAll('%', '').replaceAll(',', '')}));
                        }
                    }
                }
            }
        }
    }

    /**
     * @description manages b2c shop records if account is approved and to be published.
     *  If B2C Shop records already exists -> update
     *  Else -> create B2C record
     * @author Raella Frem | 03-11-2021
     * @param Map<Id Account> oldMap
     * @param Map<Id Account> newMap
     **/
    public static void manageAccountApproval (Map<Id, Account> oldMap, Map<Id, Account> newAccountsMap) {
        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.putAll(newAccountsMap);
        Set<Id> accountIdsSet = new Set<Id>();
        for(Id accountId : newMap.keySet()) {
            if(newMap.get(accountId).ApprovalStatus__c == 'Approved' && newMap.get(accountId).PublicationStatus__c == 'Published'
               && (oldMap == null
                   || (oldMap != null &&
                       (oldMap.get(accountId).ApprovalStatus__c != newMap.get(accountId).ApprovalStatus__c
                        || oldMap.get(accountId).PublicationStatus__c != newMap.get(accountId).PublicationStatus__c)))) {
                accountIdsSet.add(accountId);
            } else {
                newMap.remove(accountId);
            }
        }

        // update and approve account related images
        approveRelatedImages(accountIdsSet);

        Map<Id, Account> accountsToCopyMap = new Map<Id, Account>();

        // b2c shops to update
        List<B2CShop__c> b2cShopsToUpdateList = [SELECT Id, Account__c, Name, Category__c, Description__c, RoomId__c,
                                                 OpeningHours__c, ParkNear__c, Phone__c, StoreLocation__c, Zone__c
                                                 FROM B2CShop__c
                                                 WHERE Account__c IN :accountIdsSet];

        if(!b2cShopsToUpdateList.isEmpty()) {
            for(B2CShop__c b2cShop : b2cShopsToUpdateList) {
                accountsToCopyMap.put(b2cShop.Account__c, newMap.get(b2cShop.Account__c));
                newMap.remove(b2cShop.Account__c);
            }
            updateB2CShopRecords(b2cShopsToUpdateList, accountsToCopyMap);
        }

        // b2c shops to create
        if(!newMap.isEmpty()) {
            createB2CShopRecords(newMap.values());
        }
    }

    /**
     * @description changes account publication status to Draft if published account was updated
     * @author Raella Frem | 03-11-2021
     * @param List<Account> accountList
     **/
    public static void setAccountsAsDraft (Map<Id, Account> oldMap, List<Account> newList) {
        for(Account account : newList) {
            if(oldMap.get(account.Id).PublicationStatus__c == 'Published' && account.PublicationStatus__c == 'Published'
               && oldMap.get(account.Id).ApprovalStatus__c == account.ApprovalStatus__c) {
                account.PublicationStatus__c = 'Draft';
            }
        }
    }

    /**
     * @description Approves accounts' related images after account approval and publication
     * @author Raella Frem | 05-11-2021
     * @param Set<Id> parentIdSet
     **/
    private static void approveRelatedImages(Set<Id> parentIdSet) {
        if(!parentIdSet.isEmpty()) {
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN :parentIdSet];

            Set<Id> cdIds = new Set<Id>();
            for(ContentDocumentLink cdl : cdlList) {
                cdIds.add(cdl.ContentDocumentId);
            }

            List<ContentVersion> cvList = [SELECT IsVerified__c
                                           FROM ContentVersion
                                           WHERE ContentDocumentId IN :cdIds
                                           AND IsVerified__c = FALSE];

            for(ContentVersion cv : cvList) {
                cv.IsVerified__c = true;
            }
            update cvList;
        }
    }

    /**
     * @description updates existing b2c records based on parent accounts
     * @author Raella Frem | 03-11-2021
     * @param List<B2CShop__c> b2cShopList
     * @param Map<Id Account> accountMap
     **/
    private static void updateB2CShopRecords (List<B2CShop__c> b2cShopList, Map<Id, Account> accountMap) {
        for(B2CShop__c b2cShop : b2cShopList) {
            Account account = accountMap.get(b2cShop.Account__c);
            b2cShop.Name = account.Name;
            b2cShop.Category__c = account.Category__c;
            b2cShop.Description__c = account.Description;
            b2cShop.OpeningHours__c = account.OpeningHours__c;
            b2cShop.ParkNear__c = account.Park_Near__c;
            b2cShop.Phone__c = account.Phone;
            b2cShop.StoreLocation__c = account.Store_Location__c;
            b2cShop.Zone__c = account.Zone__c;
            b2cShop.RoomID__c = account.RoomID__c;
            b2cShop.IsActive__c = True;
        }
        AccountTriggerHelperWOSharing wocls = new AccountTriggerHelperWOSharing();
        wocls.updateB2CShop(b2cShopList);
    }

    /**
     * @description creates list of b2c shops based on accounts
     * @author Raella Frem | 03-11-2021
     * @param List<Account> accountList
     **/
    private static void createB2CShopRecords (List<Account> accountList){
        List<B2cShop__c> b2cShopList = new List<B2CShop__c>();
        for(Account account : accountList) {
            B2CShop__c b2cShop = new B2CShop__c();
            b2cShop.Account__c = account.Id;
            b2cShop.Name = account.Name;
            b2cShop.Category__c = account.Category__c;
            b2cShop.Description__c = account.Description;
            b2cShop.OpeningHours__c = account.OpeningHours__c;
            b2cShop.ParkNear__c = account.Park_Near__c;
            b2cShop.Phone__c = account.Phone;
            b2cShop.StoreLocation__c = account.Store_Location__c;
            b2cShop.Zone__c = account.Zone__c;
            b2cShop.RoomID__c = account.RoomID__c;
            b2cShop.IsActive__c = True;
            b2cShopList.add(b2cShop);
        }
        AccountTriggerHelperWOSharing wocls = new AccountTriggerHelperWOSharing();
        wocls.createB2CShop(b2cShopList);
    }

    /**
     * @description parses incoming unit numbers and formats data for cleaner comparison
     * @author Raella Frem | 22-10-2021
     * @param List<String> stringList
     * @return List<String>
     **/
    private static List<String> parseUnitNumbersList (List<String> stringList) {
        List<String> formattedStringList = new List<String>();
        for(String unitNumber : stringList) {
            formattedStringList = formatUnitNumber(unitNumber);
        }

        return formattedStringList;
    }

    /**
     * @description formats new Unit Number field to compare with existing ones
     * @author Raella Frem | 22-10-2021
     * @param String unitNumber
     * @return List<String>
     **/
    private static List<String> formatUnitNumber (String unitNumber) {
        List<String> formattedStringList = new List<String>();
        List<String> tempStringList = new List<String>();
        unitNumber = unitNumber.deleteWhitespace();
        if(unitNumber.contains(',')) {
            tempStringList = unitNumber.split(',');
        } else {
            tempStringList.add(unitNumber);
        }

        for(String str : tempStringList) {
            str = '%,' + str + ',%';
            formattedStringList.add(str);
        }

        return formattedStringList;
    }
    
    private without sharing class AccountTriggerHelperWOSharing {
        public void updateB2CShop(List<B2CShop__c> listToUpdate){
            update listToUpdate;
        }
        public void createB2CShop(List<B2CShop__c> listToCreate){
            insert listToCreate;
        }
    }
}