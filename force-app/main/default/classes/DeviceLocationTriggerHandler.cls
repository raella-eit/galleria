public class DeviceLocationTriggerHandler extends TriggerHandler implements ITriggerHandler {
	private Map<Id, DeviceLocation__c> newMap;
	private Map<Id, DeviceLocation__c> oldMap;
	private List<DeviceLocation__c> triggerNew;
	private List<DeviceLocation__c> triggerOld;

	public DeviceLocationTriggerHandler(){
		this.newMap = (Map<Id, DeviceLocation__c>)Trigger.newMap;
		this.oldMap = (Map<Id, DeviceLocation__c>)Trigger.oldMap;
		this.triggerNew = (List<DeviceLocation__c>)Trigger.New;
		this.triggerOld = (List<DeviceLocation__c>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
        DeviceLocationTriggerHelper.matchContact(triggerNew);
	}

	public override void afterInsert(){
	}

	public override void beforeUpdate(){
	}

	public override void afterUpdate(){
		// DeviceLocationTriggerHelper.sendNotification(triggerNew);
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}