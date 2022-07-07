public with sharing class B2CShopTriggerHandler  extends TriggerHandler implements ITriggerHandler {
	private Map<Id, B2CShop__c> newMap;
	private Map<Id, B2CShop__c> oldMap;
	private List<B2CShop__c> triggerNew;
	private List<B2CShop__c> triggerOld;

	public B2CShopTriggerHandler(){
		this.newMap = (Map<Id, B2CShop__c>)Trigger.newMap;
		this.oldMap = (Map<Id, B2CShop__c>)Trigger.oldMap;
		this.triggerNew = (List<B2CShop__c>)Trigger.New;
		this.triggerOld = (List<B2CShop__c>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
	}

	public override void afterInsert(){
        B2CShopTriggerHelper.manageOffers(newMap);
	}

	public override void beforeUpdate(){
	}

	public override void afterUpdate(){
        B2CShopTriggerHelper.manageOffers(newMap);
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}