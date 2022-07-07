@isTest
public class AccountTrigger_TEST {
    static final Id RETAILER_RECORDTYPEID = ObjectUtils.getRecordTypeId('Account', 'Retailer');

    @TestSetup
    static void makeData(){
        List<Account> accountsList = TestDataFactoryGR.createAccountsList(2, 'GR Test Account', false);
        for(Account account : accountsList) {
            account.UnitNumber__c = String.valueOf(accountsList.indexOf(account) + 1);
            account.RecordTypeId = RETAILER_RECORDTYPEID;
        }
        accountsList.get(1).UnitNumber__c += ',978';

        insert accountsList;
    }

    @isTest
    public static void createB2CShopRecordTest() {
        List<Account> accountsList = [SELECT Id, Name, Category__c, Description, OpeningHours__c,
                                      Park_Near__c, Phone, Store_Location__c, Zone__c, ApprovalStatus__c
                                      FROM Account];

        for(Account accountRec : accountsList) {
            accountRec.ApprovalStatus__c = 'Approved';
            accountRec.PublicationStatus__c = 'Published';
            accountRec.Category__c = 'Eat';
            accountRec.Description = 'Description';
            accountRec.OpeningHours__c = 'Closed on Sunday';
            accountRec.Park_Near__c = 'Section A';
            accountRec.Phone = '03123456';
            accountRec.Store_Location__c = 'Level L1';
            accountRec.Zone__c = 'ZwGLnyZ6mlP';
        }

        update accountsList;

        List<B2CShop__c> b2cShopsList = [SELECT Id, Account__c, Name, Category__c, Description__c,
                                         OpeningHours__c, ParkNear__c, Phone__c, StoreLocation__c, Zone__c
                                         FROM B2CShop__c];

        System.assertEquals(2, b2cShopsList.size(), 'the number of approved accounts should be created as b2c shops');

        Account account = accountsList?.get(0);
        B2CShop__c b2cShop = b2cShopsList?.get(0);

        System.assertEquals(account.Id, b2cShop.Account__c, 'shop should be linked to account');
        System.assertEquals(account.Name, b2cShop.Name, 'shop and account Name should be the same');
        System.assertEquals(account.Category__c, b2cShop.Category__c, 'shop and account Category should be the same');
        System.assertEquals(account.Description, b2cShop.Description__c, 'shop and account Description should be the same');
        System.assertEquals(account.OpeningHours__c, b2cShop.OpeningHours__c, 'shop and account Opening Hours should be the same');
        System.assertEquals(account.Park_Near__c, b2cShop.ParkNear__c, 'shop and account Park Near should be the same');
        System.assertEquals(account.Phone, b2cShop.Phone__c, 'shop and account Phone should be the same');
        System.assertEquals(account.Store_Location__c, b2cShop.StoreLocation__c, 'shop and account Location should be the same');
        System.assertEquals(account.Zone__c, b2cShop.Zone__c, 'shop and account Zone should be the same');

        account.Description = 'New description';
        update account;
        account = [SELECT Id, PublicationStatus__c, Description FROM Account WHERE Id = :account.Id]?.get(0);
        System.assertEquals('Draft', account.PublicationStatus__c, 'account publication status should be reverted to Draft if modifications without approval occur');

        account.PublicationStatus__c = 'Published';
        update account;
        String b2cShopDescription = [SELECT Id, Account__c, Description__c FROM B2CShop__c WHERE Account__c = :account.Id]?.get(0).Description__c;
        System.assertEquals(account.Description, b2cShopDescription, 'b2c shop fields should be updated according to account updated fields');
    }

    @isTest
    public static void checkDuplicateUnitNumberTest () {
        List<Account> accountsList = TestDataFactoryGR.createAccountsList(2, 'test-gr', false);
        Account account1 = accountsList.get(0);
        account1.UnitNumber__c = '978 ';
        account1.RecordTypeId = RETAILER_RECORDTYPEID;

        Account account2 = accountsList.get(1);
        account2.UnitNumber__c = '456';
        account2.RecordTypeId = RETAILER_RECORDTYPEID;

        try {
            insert account2;
            insert account1;
        } catch(Exception ex) {
            System.assert(ex.getMessage()
                          .contains(String.format(System.Label.ACT_UNITNUMBER_DUPLICATE_ERR, new String[] {'978'})),
                          'account1 should not be inserted - duplicate detection failed');
        } finally {
            System.assert(account1.Id == null,
                          'account1 should not be inserted - duplicate detection failed');

            System.assert(account2.Id != null,
                          'account2 should be inserted');

            account2.UnitNumber__c = '1';
            try {
                update account2;
            } catch(Exception ex) {
                System.assert(ex.getMessage()
                              .contains(String.format(System.Label.ACT_UNITNUMBER_DUPLICATE_ERR, new String[] {'1'})),
                              'account2 should not be updated - duplicate detection failed');
            }
        }
    }

    @isTest
    public static void accountTriggerHandlerTest() {
        Account account = [SELECT Id, Name FROM Account LIMIT 1]?.get(0);

        account.Name = 'gr-updated-name';

        update account;
        delete account;
        undelete account;

        System.assert(true);

    }
}