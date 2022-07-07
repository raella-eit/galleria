trigger SummerCampaignBeforeInsert on Summer_Campaign__c (before insert) {
	SummerSurveyTriggerHandler.matchContact(trigger.new);
}