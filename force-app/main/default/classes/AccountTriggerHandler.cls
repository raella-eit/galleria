public with sharing class AccountTriggerHandler  extends TriggerHandler implements ITriggerHandler {
	private Map<Id, Account> newMap;
	private Map<Id, Account> oldMap;
	private List<Account> triggerNew;
	private List<Account> triggerOld;

	public AccountTriggerHandler(){
		this.newMap = (Map<Id, Account>)Trigger.newMap;
		this.oldMap = (Map<Id, Account>)Trigger.oldMap;
		this.triggerNew = (List<Account>)Trigger.New;
		this.triggerOld = (List<Account>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
		AccountTriggerHelper.checkDuplicateUnitNumber(oldMap,triggerNew);
	}

	public override void afterInsert(){
	}

	public override void beforeUpdate(){
		AccountTriggerHelper.checkDuplicateUnitNumber(oldMap,triggerNew);
		AccountTriggerHelper.setAccountsAsDraft(oldMap,triggerNew);
	}

	public override void afterUpdate(){
		AccountTriggerHelper.manageAccountApproval(oldMap,newMap);
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}