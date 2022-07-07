public class SummerSurveyTriggerHandler {
	public static void matchContact(List<Summer_Campaign__c> surveylist) {
    	//match survey with existing accounts
    	//Match Accounts By Email
    	//Create a set of all emails found in the trigger 
        Set<String> emailList = new Set<String>();
        //Create a set of emails not found in Person Accounts
        Set<String> notMatchingEmailList = new Set<String>();
        //Add all emails to email list
        for(Summer_Campaign__c survey : surveylist){
            if(String.isNotBlank(survey.email__c))
                emailList.add(survey.Email__c);         
        }
        
        if(emailList.size() != null) {
            System.debug('Getting all matched person accounts');
            List<Account> matchingContacts = [Select   FirstName, LastName, Phone, PersonMobilePhone, PersonEmail, PersonContactId
                                              From Account
                                              Where isPersonAccount = true 
                                              AND PersonEmail in:emailList];
            //Add the not found emails to notMatchingEmailList
             for(String surveyEmail : emailList) {
                 Boolean isFound = false;
                 for(Account contact: matchingContacts) {
                     if(contact.PersonEmail == surveyEmail) {
                         isFound = true;
                         break;
                     }
                 }
                 if(isFound == false) {
                     notMatchingEmailList.add(surveyEmail);
                 }
             }
            
            if(matchingContacts.size() > 0 ) {
              //Link the survey to an existing personAccount if matched
                for(Summer_Campaign__c survey : surveylist){
                    for(Account contact: matchingContacts){
                        if(contact.PersonEmail == survey.Email__c){                           
                            survey.Contact__c = contact.PersonContactId;
                            break;
                        }
                    }
                }
            }
            if(notMatchingEmailList.size() > 0) {
                //No matching contact found in the database, create a new Lead
                System.debug('No match found, creating a new lead');
                List<Lead> leadsTobeCreated = new List<Lead>();
                Map<String,Summer_Campaign__c> mapSurvey = new Map<String,Summer_Campaign__c>();
                Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Marketing_Leads').getRecordTypeId();
                for(Summer_Campaign__c survey : surveylist){
                    if(String.isNotBlank(survey.email__c) && notMatchingEmailList.contains(survey.email__c)){
                        if(survey.email__c!=null){
                            mapSurvey.put(survey.Email__c, survey);
                        }
                        Lead lead = new Lead();
                        lead.FirstName = survey.First_Name__c;
                        lead.LastName = survey.Last_Name__c;
                        lead.Email = survey.Email__c;
                        lead.Phone = survey.Phone__c;
                        lead.RecordTypeId = recordTypeId;
                        leadsTobeCreated.add(lead);
                    }                    
                }
                try{
                    system.debug('before insert');
                    insert leadsTobeCreated;
                    //link the survey to the newly created lead
                    for(Lead lead: leadsTobeCreated){
                        Summer_Campaign__c survey = mapSurvey.get(lead.Email);
                        survey.Lead__c = lead.id;
                        system.debug('servey: ' + survey); 
                    }
                }catch(Exception e){
                    system.debug('LEad creation failed :' + e.getMessage());
                    throw e;
                }
            }
            
        }
        
    }
}