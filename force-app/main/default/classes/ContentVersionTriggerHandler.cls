public with sharing class ContentVersionTriggerHandler extends TriggerHandler {
    private Map<Id, ContentVersion> newMap;
    private Map<Id, ContentVersion> oldMap;
    private List<ContentVersion> triggerNew;
    private List<ContentVersion> triggerOld;

    public ContentVersionTriggerHandler(){
        this.newMap = (Map<Id, ContentVersion>)Trigger.newMap;
        this.oldMap = (Map<Id, ContentVersion>)Trigger.oldMap;
        this.triggerNew = (List<ContentVersion>)Trigger.New;
        this.triggerOld = (List<ContentVersion>)Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public override void afterInsert(){
        this.updateShopLogo();
    }

    public override void afterUpdate(){
        this.updateShopLogo();
    }

    private void updateShopLogo(){
        Map<Id, Id> cvIdToUseMap = new Map<Id, Id>();
        for(ContentVersion cv : this.triggerNew) {
            if(cv.Type__c == 'Logo' && cv.IsVerified__c == true && cv.ContentDocumentId != null) {
                cvIdToUseMap.put(cv.Id, cv.ContentDocumentId);
            }
        }

        if(!cvIdToUseMap.isEmpty()) {
            List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                                                 FROM ContentDocumentLink
                                                 WHERE ContentDocumentId IN :cvIdToUseMap.values()];

            Map<Id, Id> cvIdToAccountIdMap = new Map<Id, Id>();

            for(ContentDocumentLink cdl : cdlList) {
                if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Account') {
                    cvIdToAccountIdMap.put(cdl.ContentDocument.LatestPublishedVersionId, cdl.LinkedEntityId);
                }
            }

            List<ContentDistribution> distributionList = ContentDistributionHelper.getContentDistributionList(cvIdToAccountIdMap.keySet());
            Map<Id, String> accountIdToLinkMap = new Map<Id, String>();
            for(ContentDistribution distribution : distributionList) {
                accountIdToLinkMap.put(cvIdToAccountIdMap.get(distribution.ContentVersionId), distribution.ContentDownloadUrl);
            }

            List<B2CShop__c> shopToUpdateList = [SELECT Id, LogoDownloadUrl__c, Account__c
                                                 FROM B2CShop__c
                                                 WHERE Account__c IN :accountIdToLinkMap.keySet()];
            for(B2CShop__c shop : shopToUpdateList) {
                shop.LogoDownloadUrl__c = accountIdToLinkMap.get(shop.Account__c);
            }

            update shopToUpdateList;
        }
    }
}