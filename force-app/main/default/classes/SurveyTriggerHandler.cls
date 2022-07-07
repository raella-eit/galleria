public class SurveyTriggerHandler {
   /* public static void surveyupdate(List<survey__c> surveylist) {
        System.debug('surveyupdate surveyupdate');
        try
        {
            Set<string> chatkey = new Set<string>();
            List<survey__c> surveytoupdate = new List<survey__c>();
            List<LiveChatTranscript> transcript = new List<LiveChatTranscript>();
            if(surveylist.size() > 0) {
                for(survey__c c : surveylist)
                {
                    if(c.chatkey__c!=null){
                    chatkey.add(c.chatkey__c);
                    for (LiveChatTranscript transcript1 : [SELECT Id, CaseID FROM LiveChatTranscript WHERE ChatKey = :c.chatkey__c]) {
					c.Chat_Transcript__c = transcript1.id;
					c.Case__c = transcript1.CaseID;
					update c;
                }
                }
            }
            
            transcript = [SELECT Id, CaseID,ChatKey FROM LiveChatTranscript WHERE ChatKey IN: chatkey];
            if(surveylist.size() > 0 && transcript.size()>0){
                for(survey__c s : surveylist){
                    for(LiveChatTranscript l : transcript){
                        if(s.Chatkey__c==l.ChatKey){
                            s.Case__c=l.CaseId;
                            s.Chat_Transcript__c=l.id;
                            surveytoupdate.add(s);
                        }
                    }
                }
                update surveytoupdate;
            }
            
            
            
        }
        catch(Exception e)
        {
            
        }
    }*/
    public static void matchContact(List<Survey__c> surveylist) {
        try{

            //match survey with existing accounts
            //Match Accounts By Email
            //Create a set of all emails found in the trigger 
            Set<String> emailList = new Set<String>();
            //Create a set of all phones found in the trigger 
            Set<String> phoneList = new Set<String>();
            //Create a set of emails not found in Person Accounts
            Set<String> notMatchingEmailList = new Set<String>();
            Set<String> notMatchingPhoneList = new Set<String>();
            //Add all emails to email list
            for(Survey__c survey : surveylist){
                if(String.isNotBlank(survey.Email_Address__c)){
                    emailList.add(survey.Email_Address__c);
                }
                if(String.isNotBlank(survey.phone__c) ){       
                    phoneList.add(survey.phone__c);              
                }
            }
            
            if(emailList.size() >0 || phoneList.size() >0 ) {
                List<Account> matchingContactsByEmail = new List<Account>();
                List<Account> matchingContactsByPhone = new List<Account>();
                try {
                    matchingContactsByEmail = [SELECT FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId,Id
                                                FROM Account
                                                WHERE isPersonAccount = true 
                                                AND PersonEmail in:emailList
                                                ];
                } catch(QueryException e) {

                    system.debug('Get Matched Contacts By Email Failed:' + e.getMessage());
                    // throw e;
                } 
                try {
                    matchingContactsByPhone = [SELECT FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId,Id
                                                FROM Account
                                                WHERE isPersonAccount = true 
                                                AND Phone in: phoneList];
                } catch(QueryException e) {

                    system.debug('Get Matched Contacts By Phone Failed:' + e.getMessage());
                    // throw e;
                }
                ///OR Phone in : phoneList
                //Add the not found emails to notMatchingEmailList
                if(emailList.size() >0){
                    for(String surveyEmail : emailList) {
                        Boolean isFound = false;
                        for(Account contact: matchingContactsByEmail) {
                            if(contact.PersonEmail == surveyEmail) {
                                isFound = true;
                                break;
                            }
                        }
                        
                        if(isFound == false) {
                            notMatchingEmailList.add(surveyEmail);
                        }
                    }
                }
                
                if(phoneList.size() >0){
                   for(String surveyPhone : phoneList) {
                       Boolean isFound = false;
                       for(Account contact: matchingContactsByPhone) {
                           if(contact.Phone == surveyPhone) {
                               isFound = true;
                               break;
                           }
                       }
                       
                       if(isFound == false) {
                           notMatchingPhoneList.add(surveyPhone);
                       }
                    }  
                }
                
                
                if(matchingContactsByPhone.size() > 0 || matchingContactsByEmail.size() > 0 ) {
                    system.debug('Contact matched!');
                	//Link the survey to an existing personAccount if matched
                    for(Survey__c survey : surveylist){
                        for(Account contact : matchingContactsByPhone){
                            if(contact.Phone == survey.Phone__c){                           
                                survey.Brand__c = contact.Id;
                                survey.Contact__c = contact.PersonContactId;
                                break;
                            }
                        }
                    }
                    
                    for(Survey__c survey : surveylist){
                        for(Account contact : matchingContactsByEmail){
                            if(contact.PersonEmail == survey.Email_Address__c){                           
                                survey.Brand__c = contact.Id;
                                survey.Contact__c = contact.PersonContactId;
                                break;
                            }
                        }
                    }
                }else if(notMatchingEmailList.size() > 0 || notMatchingPhoneList.size() > 0) {
                    system.debug('Contact NOT matched!');
                    //No matching contact found in the database, create a new Lead
                    List<Account> accountsTobeCreated = new List<Account>();
                    Map<String,Survey__c> mapSurvey = new Map<String,Survey__c>();
                    // Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Marketing_Leads').getRecordTypeId();
                    for(Survey__c survey : surveylist){
                        if(String.isNotBlank(survey.Email_Address__c) && notMatchingEmailList.contains(survey.Email_Address__c) || String.isNotBlank(survey.Phone__c) && notMatchingPhoneList.contains(survey.Phone__c) ){
                            if(survey.Email_Address__c != null){
                                mapSurvey.put(survey.Email_Address__c, survey);
                            }else if(survey.Phone__c != null){
                                mapSurvey.put(survey.Phone__c, survey);
                            }
                            Account acc = new Account();
                            acc.FirstName = survey.First_Name__c;
                            acc.LastName = survey.Last_Name__c;
                            acc.PersonEmail = survey.Email_Address__c;
                            acc.Phone = survey.Phone__c;
                            // acc.RecordTypeId = recordTypeId;
                            accountsTobeCreated.add(acc);
                        }                    
                    }
                    insert accountsTobeCreated;
                    List<Survey__c> surverListToUpdate = new List<Survey__c>();
                    //link the survey to the newly created lead
                    for(Account acc: accountsTobeCreated){
                        Survey__c survey = mapSurvey.get(acc.PersonEmail)!=null?mapSurvey.get(acc.PersonEmail):mapSurvey.get(acc.phone);
                        survey.Brand__c = acc.id;
                        surverListToUpdate.add(survey);
                    }
                }       
            }  
        }
        catch(Exception e){
            system.debug('Account creation failed :' + e.getMessage());
            throw e;
        }      
    }
    
    public static void createCase(List<Survey__c> surveylist) {
        try{
            Id caseRT = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Case_RT_Feedback_Record).getRecordTypeId();
            Group cx_queue = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'CX' ];
            List<Case> caseList = new List<Case>();
            Map<Survey__c,Case> surveyCaseMap = new  Map<Survey__c,Case>(); 
            for(Survey__c survey : surveylist){
                if (
                    (
                        (String.isNotBlank(survey.How_Satisfied_are_you_with_our_services__c) 
                            &&  ( survey.How_Satisfied_are_you_with_our_services__c == System.label.Satisfied_of_our_services_Unsatisfied
                            ||
                            survey.How_Satisfied_are_you_with_our_services__c ==System.label.Satisfied_of_our_services_Neutral
                            ||
                            survey.How_Satisfied_are_you_with_our_services__c ==System.label.Satisfied_of_our_services_Very_Unsatisfied
                            ||
                            survey.Were_the_Helpdesk_staff_helpful_in_addre__c =='No'
                            ||
                            survey.Were_the_Helpdesk_staff_able_to_provide__c =='No'
                            ||
                            survey.Were_the_Helpdesk_staff_able_to_guide_yo__c =='No'
                            ||
                            survey.Did_you_find_what_you_were_looking_for_t__c =='No'
                        )
                        )
                            ||(
                            String.isNotBlank(survey.Were_you_happy_with_the_assistance_of_ou__c) 
                            &&  survey.Were_you_happy_with_the_assistance_of_ou__c == 'Hate it'
                            )
                    ) && survey.Would_you_like_us_to_contact_you_to_disc__c == 'Yes'
                    ){
                    Case newCase = new Case();
                    // add fields values
                    newCase.RecordTypeId = caseRT;
                    newCase.Type_of_feedback__c = System.Label.Case_Type_Compaint;
                    newCase.Origin__c = System.Label.Case_Origin_Guest;
                    newCase.Location__c = survey.Location__c; // depending on the survey or get it from the Survey's name
                    newCase.Origin = System.Label.Case_Origin_QuestionPro;
                    newCase.AccountId = survey.Brand__c ;
                    newCase.ContactId = survey.Contact__c ;
                    newCase.OwnerId = cx_queue.Id ;
                    newCase.Survey_Name__c = survey.Survey_Name_from_QuestionPro__c ;
                    caseList.add(newCase);
                    surveyCaseMap.put(survey,newCase);
                }
            }
            insert caseList;
            for(Survey__c survey : surveylist){
                if(surveyCaseMap.containsKey(survey)){
                    survey.Case__c = surveyCaseMap.get(survey).id;
                }
            }
            
        } 
        catch(Exception e){
            system.debug('Case creation failed :' + e.getMessage());
            throw e;
        }   
    }
}