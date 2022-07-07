public with sharing class PermitTriggerHandler extends TriggerHandler implements ITriggerHandler {
    private Map<Id, Permit__c> newMap;
    private Map<Id, Permit__c> oldMap;
    private List<Permit__c> triggerNew;
    private List<Permit__c> triggerOld;

    public PermitTriggerHandler() {
        this.newMap = (Map<Id, Permit__c>)Trigger.newMap;
        this.oldMap = (Map<Id, Permit__c>)Trigger.oldMap;
        this.triggerNew = (List<Permit__c>)Trigger.New;
        this.triggerOld = (List<Permit__c>)Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public override void beforeInsert(){
        PermitTriggerHelper.setDefaultAccount(triggerNew);
    }

    public override void afterInsert(){}

    public override void beforeUpdate(){
        // PermitTriggerHelper.restrictRecordEdit(triggerNew, oldMap);
    }

    public override void afterUpdate(){
        // System.debug('afterUpdate');
        PermitTriggerHelper.restrictRecordEdit(newMap, oldMap);
    }

    public override void beforeDelete(){}

    public override void afterDelete(){}

    public override void afterUnDelete(){}
}