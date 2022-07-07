public with sharing class GenericDataCardItem {
    @AuraEnabled
    public Id id {get; set;}
    @AuraEnabled
    public String title {get; set;}
    @AuraEnabled
    public String titleAr {get; set;}
    @AuraEnabled
    public String dates {get; set;}
    @AuraEnabled
    public String parkingDescription {get; set;}
    @AuraEnabled
    public String phone {get; set;}
    @AuraEnabled
    public String description {get; set;}
    @AuraEnabled
    public String descriptionAr {get; set;}
    @AuraEnabled
    public String subDescription {get; set;}
    @AuraEnabled
    public String subDescriptionAr {get; set;}
    @AuraEnabled
    public String imgSrc {get; set;}
    @AuraEnabled
    public String parentId {get; set;}
    @AuraEnabled
    public String parentName {get; set;}
    @AuraEnabled
    public String storeImgSrc {get; set;}
    @AuraEnabled
    public Boolean isVIP {get; set;}
    @AuraEnabled
    public String category {get; set;}
    @AuraEnabled
    public String objectType {get; set;}
    @AuraEnabled
    public String terms{get;set;}

    public GenericDataCardItem(){}

    public GenericDataCardItem(Offer__c offer){
        this.id = offer.Id;
        this.title = offer.Name;
        this.titleAr = offer.OfferNameAR__c;
        this.dates = DateUtils.toDayAndMonth(offer.Start_Date__c) + ' - ' + DateUtils.toDayAndMonth(offer.End_Date__c);
        this.description = String.isNotBlank(offer.Description__c) ? offer.Description__c.replaceAll('\r\n', '<br/>') : '';
        this.descriptionAr = String.isNotBlank(offer.DescriptionAr__c) ? offer.DescriptionAr__c.replaceAll('\r\n', '<br/>') : '';
        this.subDescription = offer.Category__c;
        this.parentId = offer.B2CShop__c;
        this.parentName = offer.B2CShop__r.Name;
        this.isVIP = offer.VIP__c;
        this.objectType = 'Offer';
        this.terms = offer.Terms_Conditions__c;
    }

    public GenericDataCardItem(B2C_Promo__c event){
        this.id = event.Id;
        this.title = event.Name;
        this.titleAr = event.B2C_Promo_Name_Ar__c;
        this.dates = DateUtils.toDayAndMonth(event.Start_Date__c) + ' - ' + DateUtils.toDayAndMonth(event.End_Date__c);
        this.description = String.isNotBlank(event.Description__c) ? event.Description__c.replaceAll('\r\n', '<br/>') : '';
        this.descriptionAr = String.isNotBlank(event.Description_Ar__c) ? event.Description_Ar__c.replaceAll('\r\n', '<br/>') : '';
        this.subDescription = event.Category__c;
        this.parentId = event.Offer__c;
        this.parentName = event.Offer__r.Name;
        this.objectType = 'Event';
    }

    public GenericDataCardItem(ShopHelper.ShopWrapper account){
        this.id = account.shop.Id;
        this.title = account.shop.Name;
        this.subDescription = String.isNotBlank(account.shop.StoreLocation__c) ? account.shop.StoreLocation__c.replaceAll(';', ' - ') : '';
        this.description = String.isNotBlank(account.shop.Description__c) ? account.shop.Description__c.replaceAll('\r\n', '<br/>') : '';
        this.dates = String.isNotBlank(account.shop.OpeningHours__c) ? account.shop.OpeningHours__c.replaceAll(';', ' ; ').capitalize() : '';
        this.parkingDescription = String.isNotBlank(account.shop.ParkNear__c) ? account.shop.ParkNear__c : '';
        this.phone = String.isNotBlank(account.shop.Phone__c) ? account.shop.Phone__c : '';
        this.category = String.isNotBlank(account.shop.Category__c) ? account.shop.Category__c : '';
    }

    public GenericDataCardItem(B2CShop__c shop){
        this.id = shop.Id;
        this.title = shop.Name;
        this.subDescription = String.isNotBlank(shop.StoreLocation__c) ? shop.StoreLocation__c.replaceAll(';', ' - ') : '';
        this.category = String.isNotBlank(shop.Category__c) ? shop.Category__c : '';
        this.imgSrc = String.isNotBlank(shop.LogoDownloadUrl__c) ? shop.LogoDownloadUrl__c : '';
    }
}