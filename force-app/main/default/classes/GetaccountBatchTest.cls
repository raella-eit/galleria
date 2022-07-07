@isTest 
public class GetaccountBatchTest {
    static testMethod void testMethod1() 
    {
        List<Account> lstAccount= new List<Account>();
        Id RecordTypeIdaccount = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount').getRecordTypeId();
        system.debug('recortypeid'+RecordTypeIdaccount);
        for(Integer i=0 ;i <200;i++)
        {
            Account acc = new Account();
            acc.RecordTypeId=RecordTypeIdaccount;
            acc.LASTName ='Name'+i;
            acc.personemail='test@test'+i+'.com';
            acc.PersonMobilePhone='971764324'+i;
            acc.Gender__pc='MALE';
            acc.Last_Login_Date_Time__pc=Datetime.now();
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        Test.startTest();
            GetaccountBatch obj = new GetaccountBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }

}