@isTest
public class CaseController_TEST {
    @TestSetup
    static void makeData(){
        List<Case> caseList = TestDataFactoryGR.createCaseList(2, false);
        CaseController.createSupportCase(caseList.get(0));
        CaseController.createLostAndFoundCase(caseList.get(1));
    }

    @isTest
    public static void createB2CCasesTest() {
        List<Case> caseList = [SELECT Id, RecordType.DeveloperName
                               FROM Case];

        System.assertEquals(2, caseList.size(), '2 cases should\'ve been created.');
    }
}