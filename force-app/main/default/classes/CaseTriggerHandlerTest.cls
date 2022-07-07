@isTest
private class CaseTriggerHandlerTest {
    static testMethod void myUnitTest() {
		Account acc = new Account(Name='testacc');
		insert acc;

		Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id);
		insert ent;

		List<Case> listC = new list<Case>();
		List<Id> newCaseIds = new List<Id>();
		for(Integer i=0;i<2;i++){
			Case c = new Case(AccountId=acc.id, Subject='Test Subject'+i, Origin='Phone',Level_1__c='Price',Level_2__c='Clarity',Level_3__c='Parking',priority='Medium');

            listC.add(c);
            
		}
        insert listC;
        case caseupdate=[select id,Status from case limit 1];
        caseupdate.status='closed';
        try{
        test.startTest();
		Update caseupdate;

		test.stopTest();
        }
        catch(Exception e){
            //System.Assert(e.getMessage().contains('Please provide the reference number as the segment is Serco'));
        }
		for (Case caseObj:listC) {
			newCaseIds.add(caseObj.Id);
		}

		List<Case> caselist = [Select EntitlementId, AccountId,segments__c,Service_Provider__c From Case Where Id in :newCaseIds];
        
		for (Case caseObj:caselist) {

			System.assertEquals(caseObj.EntitlementId, ent.Id);

		}
		
	}
}