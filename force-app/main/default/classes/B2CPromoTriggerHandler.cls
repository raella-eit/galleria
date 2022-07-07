public with sharing class B2CPromoTriggerHandler extends TriggerHandler implements ITriggerHandler {
    private Map<Id, B2C_Promo__c> newMap;
    private Map<Id, B2C_Promo__c> oldMap;
    private List<B2C_Promo__c> triggerNew;
    private List<B2C_Promo__c> triggerOld;

    public B2CPromoTriggerHandler(){
        this.newMap = (Map<Id, B2C_Promo__c>)Trigger.newMap;
        this.oldMap = (Map<Id, B2C_Promo__c>)Trigger.oldMap;
        this.triggerNew = (List<B2C_Promo__c>)Trigger.New;
        this.triggerOld = (List<B2C_Promo__c>)Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public override void beforeInsert(){}

    public override void afterInsert(){}

    public override void beforeUpdate(){}

    public override void afterUpdate(){
        Set<Id> promoDeactivationIdSet = new Set<Id>();
        Set<Id> promoValidateMultiDayIdSet = new Set<Id>();
        for(B2C_Promo__c promo : triggerNew) {
            if(promo.MultiDayReservation__c) {
                promoValidateMultiDayIdSet.add(promo.Id);
            }
            if(promo.Active__c != oldMap.get(promo.Id).Active__c && promo.Active_Sessions__c > 0) {
                promoDeactivationIdSet.add(promo.Id);
            }
        }
        //No need to imlement this on child records because the roll-up summary will launch an update on promos
        if(!promoValidateMultiDayIdSet.isEmpty()) {
            List<AggregateResult> schedulesByDayResult = [SELECT Day__c, Content_Management__c, COUNT(Id) sessionCount
                                                          FROM B2C_Promo_Schedule__c
                                                          WHERE Content_Management__c IN :promoValidateMultiDayIdSet
                                                          AND Available__c = TRUE
                                                          GROUP BY Day__c, Content_Management__c];
            for(AggregateResult schedulesByDay : schedulesByDayResult) {
                if(Integer.valueOf(schedulesByDay.get('sessionCount')) > 1) {
                    Id promoId = Id.valueOf(schedulesByDay.get('Content_Management__c').toString());
                    newMap.get(promoId).addError('This event has multiple sessions scheduled starting ' + schedulesByDay.get('Day__c') + '. Either cancel these sessions or delete them before attempting to allow multiple days reservation.');
                }
            }
        }
        if(!promoDeactivationIdSet.isEmpty()) {
            List<B2C_Promo_Schedule__c> scheduleList = [SELECT Id, Available__c
                                                        FROM B2C_Promo_Schedule__c
                                                        WHERE Content_Management__c IN :promoDeactivationIdSet
                                                        AND Available__c = TRUE];
            for(B2C_Promo_Schedule__c schedule : scheduleList) {
                schedule.Available__c = false;
            }
            update scheduleList;
        }
    }

    public override void beforeDelete(){}

    public override void afterDelete(){}

    public override void afterUnDelete(){}
}