public with sharing class ShopHelper {
    //INDENT-OFF
    private static String shopsQuery = 'SELECT Id, Name, Account__c, ' +
                                        'StoreLocation__c, Category__c, ' +
                                        'OpeningHours__c, ParkNear__c, ' +
                                        'Phone__c, Description__c ' +
                                        'FROM B2CShop__c ';

    private static String imagesQuery = 'SELECT Id, ' +
                                        'ContentDocument.LatestPublishedVersionId, ' +
                                        'ContentDocument.LatestPublishedVersion.Type__c, ' +
                                        'LinkedEntityId ' +
                                        'FROM ContentDocumentLink ' +
                                        'WHERE Visibility = \'AllUsers\' ' +
                                        'AND ContentDocument.LatestPublishedVersion.Type__c IN (\'Logo\', \'Store\') ' +
                                        'AND ContentDocument.LatestPublishedVersion.IsVerified__c = TRUE ' +
                                        'AND LinkedEntityId IN :accountIdSet ' + 
                                        'ORDER BY ContentDocument.LatestPublishedVersion.Type__c ASC';
    //INDENT-ON
    public class ShopWrapper {
        public B2CShop__c shop;
        public List<ContentDocumentLink> shopRelatedImagesList;
    }

    /**
     * @description transforms a list of accounts, each containing a single file attachment, into a wrapper.
     * @author enassif-ext@dlpk.fr | 09-29-2021
     * @param shopWrapperList - accounts to be transformed
     * @return Map<Id, GenericDataCardItem>
     **/
    public static Map<Id, GenericDataCardItem> getGenericDataCardItemMap(List<ShopWrapper> shopWrapperList){
        Map<Id, GenericDataCardItem> result = new Map<Id, GenericDataCardItem>();
        Set<Id> additionalImageIdSet = new Set<Id>();
        Map<Id, Id> storeIdToLogoIdMap = new Map<Id, Id>();

        for(ShopWrapper shopWrapper : shopWrapperList) {
            GenericDataCardItem item = new GenericDataCardItem(shopWrapper);
            Id resultId;
            if(!shopWrapper.shopRelatedImagesList.isEmpty()) {
                for(ContentDocumentLink cdl : shopWrapper.shopRelatedImagesList) {
                    if(cdl.ContentDocument.LatestPublishedVersion.Type__c == 'Logo') {
                        resultId = shopWrapper.shopRelatedImagesList.isEmpty() ? shopWrapper.shop.Account__c : cdl.ContentDocument.LatestPublishedVersionId;
                        result.put(resultId, item);
                    } else if(cdl.ContentDocument.LatestPublishedVersion.Type__c == 'Store') {
                        storeIdToLogoIdMap.put(cdl.ContentDocument.LatestPublishedVersionId, resultId);
                    } else {
                        if(!result.containsKey(resultId) || !storeIdToLogoIdMap.containsKey(cdl.ContentDocument.LatestPublishedVersionId)) {
                            result.put(shopWrapper.shop.Account__c, item);
                        }
                    }
                }
            } else {
                result.put(shopWrapper.shop.Account__c, item);
            }
        }
        additionalImageIdSet.addAll(result.keySet());
        additionalImageIdSet.addAll(storeIdToLogoIdMap.keySet());
        List<ContentDistribution> contentDistributionList = ContentDistributionHelper.getContentDistributionList(additionalImageIdSet);
        for(ContentDistribution contentDistribution : contentDistributionList) {
            if(result.containsKey(contentDistribution.ContentVersionId)) {
                result.get(contentDistribution.ContentVersionId).imgSrc = contentDistribution.ContentDownloadUrl;
            } else if(storeIdToLogoIdMap.containsKey(contentDistribution.ContentVersionId) && storeIdToLogoIdMap.get(contentDistribution.ContentVersionId) != null) {
                result.get(storeIdToLogoIdMap.get(contentDistribution.ContentVersionId)).storeImgSrc = contentDistribution.ContentDownloadUrl;
            }
        }

        return result;
    }

    //The account details are not shared with community users.
    public without sharing class ShopHelperWO {
        /**
         * @description checks if zone and room ID info exist on Device Location record and shop record
         * @author Raella Frem | 17-12-2021
         * @param String userEmail
         * @param Id shopId
         * @return boolean
         **/
        public boolean hasAllLocationInfo(Id shopId) {
            List<DeviceLocation__c> devLocList = [SELECT Id
                                                  FROM DeviceLocation__c
                                                  WHERE Email__c = :UserInfo.getUserEmail()];

            List<B2CShop__c> shopList = [SELECT Id
                                         FROM B2CShop__c
                                         WHERE Id = :shopId
                                         AND Zone__c != NULL
                                         AND RoomID__c != NULL];

            return !shopList.isEmpty();
        }

        /**
         * @description Retrieves a subset of accounts that did not yet end, and are approved, filtered by categories
         * @author enassif-ext@dlpk.fr | 09-29-2021
         * @param limitSize
         * @param offset
         * @param shopCategoryList
         * @return List<SObject>
         **/
        public List<ShopWrapper> getShopWithImageList(Integer limitSize, Integer offset, Boolean isFeaturedFirst){
            String limitCondition = limitSize != -1 ? 'LIMIT :limitSize OFFSET :offset' : '';
            String shopQuery = shopsQuery + 'ORDER BY ';
            shopQuery += isFeaturedFirst ?' Account__r.Featured__c DESC,' : '';
            shopQuery += 'Name ASC ' + limitCondition;
            Map<Id, B2CShop__c> shopsByAccountIdMap = getShopToAccIdMap(Database.query(shopQuery));

            Set<Id> accountIdSet = shopsByAccountIdMap.keySet();

            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            if(!shopsByAccountIdMap.isEmpty()) {
                cdlList = Database.query(imagesQuery);
            }

            return getShopWrapperList(shopsByAccountIdMap, getCDLtoAccIdMap(cdlList));
        }

        /**
         * @description retrieves the details of a single account
         * @author enassif-ext@dlpk.fr | 09-29-2021
         * @param accountId
         * @return List<SObject>
         **/
        public List<ShopWrapper> getShopWithImageListById(Id shopId){
            String shopQuery = shopsQuery + ' WHERE Id = :shopId';
            Map<Id, B2CShop__c> shopsByAccountIdMap = getShopToAccIdMap(Database.query(shopQuery));

            Set<Id> accountIdSet = shopsByAccountIdMap.keySet();

            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            if(!shopsByAccountIdMap.isEmpty()) {
                cdlList = Database.query(imagesQuery);
            }

            return getShopWrapperList(shopsByAccountIdMap, getCDLtoAccIdMap(cdlList));
        }

        private Map<Id, B2CShop__c> getShopToAccIdMap (List<B2CShop__c> shopList) {
            Map<Id, B2CShop__c> shopsByAccountIdMap = new Map<Id, B2CShop__c>();
            for(B2CShop__c shop : shopList) {
                shopsByAccountIdMap.put(shop.Account__c, shop);
            }

            return shopsByAccountIdMap;
        }

        private Map<Id, List<ContentDocumentLink>> getCDLtoAccIdMap (List<ContentDocumentLink> cdlList) {
            Map<Id, List<ContentDocumentLink>> cdlByAccountIdMap = new Map<Id, List<ContentDocumentLink>>();
            for(ContentDocumentLink cdl : cdlList) {
                if(cdlByAccountIdMap.containsKey(cdl.LinkedEntityId)) {
                    if(cdlByAccountIdMap.get(cdl.LinkedEntityId).size() < 2) {
                        cdlByAccountIdMap.get(cdl.LinkedEntityId).add(cdl);
                    }
                } else {
                    cdlByAccountIdMap.put(cdl.LinkedEntityId, new List<ContentDocumentLink> {cdl});
                }
            }

            return cdlByAccountIdMap;
        }

        private List<ShopWrapper> getShopWrapperList (Map<Id, B2CShop__c> shopsByAccountIdMap, Map<Id, List<ContentDocumentLink>> cdlByAccountIdMap) {
            List<ShopWrapper> shopWrapperList = new List<ShopWrapper>();
            for(Id accountId : shopsByAccountIdMap.keySet()) {
                ShopWrapper wrapper = new ShopWrapper();
                wrapper.shop = shopsByAccountIdMap.get(accountId);
                wrapper.shopRelatedImagesList = cdlByAccountIdMap.containsKey(accountId) ? cdlByAccountIdMap.get(accountId) : new List<ContentDocumentLink>();
                shopWrapperList.add(wrapper);
            }

            return shopWrapperList;
        }

        public List<B2CShop__c> getB2CShopList(Integer limitSize, Integer offset){
            return [SELECT Id, Name, StoreLocation__c, Category__c, LogoDownloadUrl__c, Account__c FROM B2CShop__c where IsActive__c = True ORDER BY Name ASC LIMIT : limitSize OFFSET : offset ];
        }
    }
}