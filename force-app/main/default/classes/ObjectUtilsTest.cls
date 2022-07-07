/**
 * @company name      : EI Technologies - MENA
 * @author            : 
 * @created on        : 
 * @description       : 
 * @last modified on  : 11-08-2021
 * @last modified by  : Raella Frem
**/
@isTest
public class ObjectUtilsTest {

    public class TestObject {
        private String field1 = 'v1';
        public String field2 = 'v2';
        protected String field3 = 'v3';

        public void testFunction() {}
    }

    public static testMethod void getClassByClassName(){
        test.startTest();
        Type classe = ObjectUtils.getClassByClassName('ObjectUtilsTest.TestObject');
        System.assertEquals(TestObject.class, classe);
        test.stopTest();
    }

    public static testMethod void getClassNameByInstance(){
        TestObject testObject = new TestObject();
        test.startTest();
        String classe = ObjectUtils.getClassNameByInstance(testObject);
        System.assertEquals('TestObject', classe);
        test.stopTest();
    }

    public static testMethod void getClassAttributeSet(){
        test.startTest();
        Set<string> fields = ObjectUtils.getClassAttributeSet(TestObject.class);

        System.assertEquals(3, fields.size());

        Integer index = 3;
        for(String field : fields) {
            System.assertEquals('field' + index, field);
            --index;
        }
        test.stopTest();
    }

    @IsTest
    static void getRecordTypeIdTest() {
        Id recordTypeId = null;
        recordTypeId = ObjectUtils.getRecordTypeId('Survey__c', 'Case_survey');

        System.assertEquals(recordTypeId != null, true, 'Case_survey Record Type Id is NULL');
    }

    @IsTest
    static void getRecordTypesMap() {
        Map<String, Schema.RecordTypeInfo> recordTypesMap = null;
        recordTypesMap = ObjectUtils.getRecordTypesMap('Survey__c');

        System.assertEquals(recordTypesMap.isEmpty(), false, 'Parcours Client Record Types Map is empty');
    }

    @IsTest
    static void getPicklistOptionsBySObjectNameTest() {
        List<Schema.PicklistEntry> picklistEntries = ObjectUtils.getPicklistOptionsBySObjectName('Account', 'Industry');
        System.assertEquals(picklistEntries.isEmpty(), false, 'No picklist values available in Account.Industry');
    }

    @isTest
    static void getMimeTypeTest() {
        Test.startTest();
        String stringPDF = ObjectUtils.getMimeType('JVBERi0egghtjgbfhfh');
        String stringPNG = ObjectUtils.getMimeType('iVBORw0KGgodgdjdjdifgj');
        String stringJPG = ObjectUtils.getMimeType('/9j/4AAQSkgdhdhdhf');
        String stringTIF = ObjectUtils.getMimeType('SUkqAgdgfgggdgvdbb');
        Test.stopTest();
        System.assertEquals('pdf', stringPDF, 'Unexpected type of document');
        System.assertEquals('png', stringPNG, 'Unexpected type of document');
        System.assertEquals('jpg', stringJPG, 'Unexpected type of document');
        System.assertEquals('tif', stringTIF, 'Unexpected type of document');

    }

    @isTest
    static void deleteSobjectListTest(){
        List<Account> accountNbList = [SELECT Id FROM Account];
        List<Account> accountList = TestDataFactoryGR.createAccountsList(2, 'TestAccount',true);

        Test.startTest();
        new ObjectUtils.ObjectUtilsWoSharing().deleteSobjectList(accountList);
        Test.stopTest();

        System.assertEquals(accountNbList, [SELECT Id FROM Account], 'The number of accounts does not match');
    }
    
    @isTest
    static void getRandomElementInListOfStringTest(){
        System.assertNotEquals(ObjectUtils.getRandomElementInListOfString(new List<String>{'1','2','3'}),null);
    }
    
    @isTest
    static void getAllFieldsObjectsForCloneTest(){
        System.assertNotEquals(ObjectUtils.getAllFieldsObjectsForClone('Account'),null);
    }
    
    @isTest
    static void isSandboxOrgTest(){
        System.assertNotEquals(ObjectUtils.isSandboxOrg(),null);
    }
}