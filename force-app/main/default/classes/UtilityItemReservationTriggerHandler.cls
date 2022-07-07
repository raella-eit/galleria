public class UtilityItemReservationTriggerHandler extends TriggerHandler implements ITriggerHandler {
	private Map<Id, UtilityItemReservation__c> newMap;
	private Map<Id, UtilityItemReservation__c> oldMap;
	private List<UtilityItemReservation__c> triggerNew;
	private List<UtilityItemReservation__c> triggerOld;

	public UtilityItemReservationTriggerHandler(){
		this.newMap = (Map<Id, UtilityItemReservation__c>)Trigger.newMap;
		this.oldMap = (Map<Id, UtilityItemReservation__c>)Trigger.oldMap;
		this.triggerNew = (List<UtilityItemReservation__c>)Trigger.New;
		this.triggerOld = (List<UtilityItemReservation__c>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
        UtilityItemReservationTriggerHelper.reserveAvailableUtilityItem(triggerNew);
	}

	public override void afterInsert(){
		UtilityItemReservationTriggerHelper.restrictNbOfReservations(triggerNew);
	}

	public override void beforeUpdate(){
	}

	public override void afterUpdate(){
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}