public without sharing class OfferTriggerHandler extends TriggerHandler implements ITriggerHandler {
	private Map<Id, Offer__c> newMap;
	private Map<Id, Offer__c> oldMap;
	private List<Offer__c> triggerNew;
	private List<Offer__c> triggerOld;

	public OfferTriggerHandler(){
		this.newMap = (Map<Id, Offer__c>)Trigger.newMap;
		this.oldMap = (Map<Id, Offer__c>)Trigger.oldMap;
		this.triggerNew = (List<Offer__c>)Trigger.New;
		this.triggerOld = (List<Offer__c>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
       OfferTriggerHelper.setDefaultAccount(triggerNew);
	  
	}

	public override void afterInsert(){
         OfferTriggerHelper.shareOffer(oldMap,triggerNew);
	}

	public override void beforeUpdate(){
		OfferTriggerHelper.shareOffer(oldMap,triggerNew);
	}

	public override void afterUpdate(){
		OfferTriggerHelper.restrictRecordEdit(newMap, oldMap);
		OfferTriggerHelper.syncOfferPromotion(triggerNew, oldMap);
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}