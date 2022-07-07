trigger SurveyTrigger on Survey__c (before Insert) {
    if(trigger.isBefore && trigger.isInsert){
        // SurveyTriggerHandler.Surveyupdate(trigger.new);
        SurveyTriggerHandler.matchContact(trigger.new);
        SurveyTriggerHandler.createCase(trigger.new);
    }
}