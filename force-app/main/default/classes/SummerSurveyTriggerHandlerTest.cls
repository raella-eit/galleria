@isTest
public class SummerSurveyTriggerHandlerTest {
	@TestSetup
    static void setupData() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account personAccount1 = new Account(LastName = 'Person Account 1', RecordTypeId = recordTypeId, PersonEmail = 'personAccount1@test.com'); 
        Account personAccount2 = new Account(LastName = 'Person Account 2', RecordTypeId = recordTypeId, PersonEmail = 'personAccount2@test.com'); 
        
        List<Account> accounts = new List<Account>{personAccount1, personAccount2};
        insert accounts;        
    }
    
   @isTest
   public static void testMatchContact() {
       //Get Accounts from DB
       List<Account> accounts = [SELECT Id, PersonEmail, PersonContactId FROM Account WHERE PersonEmail IN ('personAccount1@test.com','personAccount2@test.com')];
       //linked to Person Account 1
       Summer_Campaign__c summerCamp1 = new Summer_Campaign__c(First_Name__c = 'Person Acc 1', Last_Name__c = 'LN 1', Email__c = 'personAccount1@test.com');
       //linked to Person Account 2
       Summer_Campaign__c summerCamp2 = new Summer_Campaign__c(First_Name__c = 'Person Acc 2', Last_Name__c = 'LN 2', Email__c = 'personAccount2@test.com');
       //Lead to be created
       Summer_Campaign__c summerCamp3 = new Summer_Campaign__c(First_Name__c = 'Person Acc 3', Last_Name__c = 'LN 3', Email__c = 'personAccount3@test.com');
       //Email is blank, Nothing should happen 
       Summer_Campaign__c summerCamp4 = new Summer_Campaign__c(First_Name__c = 'Person Acc 4', Last_Name__c = 'LN 4');
       
       List<Summer_Campaign__c> summerCampainList = new List<Summer_Campaign__c>{summerCamp1, summerCamp2, summerCamp3, summerCamp4};
           
       Test.startTest();
       insert summerCampainList;
       Test.stopTest();
       
       List<Lead> leadPerson3List = [SELECT Id FROM Lead WHERE Email = 'personAccount3@test.com'];
       Map<Id, Summer_Campaign__c> summerCampainMap = new Map<Id, Summer_Campaign__c>([SELECT Id, Contact__c, Lead__c 
                                                                                        FROM Summer_Campaign__c 
                                                                                        WHERE Email__c IN ('personAccount1@test.com','personAccount2@test.com','personAccount3@test.com')
                                                                                           OR Last_Name__c = 'LN 4' ]);
       summerCamp1.Contact__c = summerCampainMap.get(summerCamp1.Id).Contact__c;
       summerCamp2.Contact__c = summerCampainMap.get(summerCamp2.Id).Contact__c;
       summerCamp3.Contact__c = summerCampainMap.get(summerCamp3.Id).Contact__c;
       summerCamp3.Lead__c = summerCampainMap.get(summerCamp3.Id).Lead__c;
       summerCamp4.Contact__c = summerCampainMap.get(summerCamp4.Id).Contact__c;
       summerCamp4.Lead__c = summerCampainMap.get(summerCamp4.Id).Lead__c;
       
       Id personContactId1;
       Id personContactId2;
       
       for(Account account : accounts){
           if(account.PersonEmail == 'personAccount1@test.com') {
               personContactId1 = account.PersonContactId;
           }
           if(account.PersonEmail == 'personAccount2@test.com') {
               personContactId2 = account.PersonContactId;
           }
       }
       //Validate 1st Campain with 1st person contact       
       System.assertEquals(personContactId1, summerCamp1.Contact__c, 'Campain 1 is not linked to Contact 1');
       System.assertEquals(null, summerCamp1.Lead__c, 'Campain 1 should not be linked to a Lead');
       
       //Validate 2nd Campain with 2nd person contact
       System.assertEquals(personContactId2, summerCamp2.Contact__c, 'Campain 2 is not linked to Contact 2');
       System.assertEquals(null, summerCamp2.Lead__c, 'Campain 2 should not be linked to a Lead');
       
       //Validate 3rd Campain with the newly created lead
       System.assertNotEquals(null, leadPerson3List, 'Lead person list should be filled');
       System.assertEquals(1, leadPerson3List.size(), 'Lead person list should be filled with one lead');
       System.assertEquals(null, summerCamp3.Contact__c, 'Campain 3 should not linked to Contact');
       System.assertEquals(leadPerson3List[0].Id, summerCamp3.Lead__c, 'Campain 3 should be linked to a Lead');//leadPerson3
       
       //Validate 4th Campain
       System.assertEquals(null, summerCamp4.Contact__c, 'Campain 4 should not be linked to Contact');
       System.assertEquals(null, summerCamp4.Lead__c, 'Campain 4 should not be linked to Lead');
   }
}