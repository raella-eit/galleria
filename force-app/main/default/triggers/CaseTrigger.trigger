trigger CaseTrigger on Case (Before Insert, Before Update) {
    if(trigger.isBefore && trigger.isInsert){
        CaseTriggerHandler casehandler = new  CaseTriggerHandler();
        casehandler.CaseEntitlementUpdate(Trigger.new);
    }

    if(trigger.isAfter && trigger.isInsert){
        
    }
    if(trigger.isbefore && trigger.isupdate){
        CaseTriggerHandler casehandler = new  CaseTriggerHandler();
      casehandler.CaseEntitlementUpdate(Trigger.new);
      casehandler.SendFoundNotification(Trigger.new,Trigger.oldMap);
        
    }
    if(trigger.isbefore && trigger.isDelete){
      
    }
    if (Trigger.isAfter && Trigger.isDelete){
        
    }
    if (Trigger.isAfter && Trigger.isupdate){
      
    }
}