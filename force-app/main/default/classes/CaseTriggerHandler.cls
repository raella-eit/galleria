public class CaseTriggerHandler {
    public static final Id notificationTypeId = [SELECT Id, DeveloperName
                                                 FROM CustomNotificationType
                                                 WHERE DeveloperName = 'GR_Notification']?.get(0).Id;
    public void CaseEntitlementUpdate (List<Case> caseList){
        List<Id> accIds = new List<Id>();
        List<String> level1 = new list<String>();
        List<Id> updateCases = new List<Id>();
        List <Case> caseviolated = new list <Case>();
        for(Case cas : caseList) {
            accIds.add(cas.AccountId);
            if (((cas.isClosed == true)||(cas.Status == 'Closed'))){
                updateCases.add(cas.id);
            }
            
        }
        system.debug('accountid'+accIds);
        List <Entitlement> entls = [Select Id,AccountId From Entitlement Where AccountId in : accIds ];
        system.debug('entitlement id'+entls);
        if(entls.isEmpty()==false){
            for(Case c : caseList) {
                if(c.EntitlementId == null && c.AccountId != null){
                    for(Entitlement e:entls){
                        if(e.AccountId== c.AccountId){
                            c.EntitlementId = e.Id;
                            
                        }
                    }
                }
            }
            
        }
        //Added logic to check if case is not closed with in the SLA.
        List<Case> violatedcaselist = [SELECT id,Not_Closed_with_in_SLA__c,(SELECT Id FROM CaseMilestones WHERE isviolated=true ) FROM case WHERE Id IN :updateCases];
        for(Case cas : caseList) {
            for(case a :violatedcaselist)  {
                if(cas.id==a.id){
                    if(a.CaseMilestones.size()>0){
                        system.debug('insideloop');
                        cas.Not_Closed_with_in_SLA__c=true;
                        
                    }
                    if(a.CaseMilestones.size()==0){
                        system.debug('insideloop1');
                        cas.Closed_with_in_SLA__c=true;
                        
                    }
                    
                    
                } 
            }
        }
    } 
    
    public Void SendFoundNotification(List<Case> FoundAndLostCases, map<id,Case> oldMapCase){
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Lost_Found').getRecordTypeId();
        
        List<String> SuppEmail = new List<String>();
        Set<Id> contactIdList = new Set<Id>();
        List<Case> getCases = new List<Case>();
        Map<Id,Set<String>> contactToUsers = new Map<Id,Set<String>>();
        for(Case cs : FoundAndLostCases)
        {
            if(cs.RecordTypeId == devRecordTypeId && cs.Status == 'Found' &&  oldMapCase.get(cs.Id).Status != 'Found' && cs.ContactId != null)
            {
                getCases.add(cs);
               
                contactIdList.add(cs.ContactId);
                
                
            }else if(cs.RecordTypeId == devRecordTypeId && cs.Status == 'Found' &&  oldMapCase.get(cs.Id).Status != 'Found' && cs.ContactId == null) {
                //send Email
                SuppEmail.add(cs.SuppliedEmail);
                
            }
        }
        
        
        Set<String> userIdList = new Set<String>();
        
        for(User userRec : [SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND ContactId IN: contactIdList]) {
            //associate contact ids to user ids
            if(contactToUsers.containsKey(userRec.ContactId)){
                Set<String> listUsers = contactToUsers.get(userRec.ContactId);
                listUsers.add(userRec.Id);
                contactToUsers.put(userRec.ContactId, listUsers);
            }else{
                contactToUsers.put(userRec.ContactId, new Set<String>{userRec.id});

            }            
            
        }
                        System.debug('userIdList => '+userIdList);

        if(contactToUsers.values().size()>0 )
        {
            for(Case lostCases : getCases){
                System.debug('contactToUsers.get(lostCases.ContactId)=> '+contactToUsers.get(lostCases.ContactId));
                System.debug('lostCases => '+lostCases.id);
                NotificationHelper.constructNotification('Lost And Found', 'we found your item : '+lostCases.Subject,'lost-and-found-record-detail',lostCases.id,null).send(contactToUsers.get(lostCases.ContactId));

            }
            
        }else if(SuppEmail.size()>0 )
        {
            SendEmail(SuppEmail);
        }
        
    }
    
    public void SendEmail(List<String> MailAddress) {
        system.debug('Email addres>>> '+MailAddress);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = (MailAddress);
        message.subject = 'Item Found';
        message.plainTextBody = 'We found your item, please contact or visit us.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    
}
}