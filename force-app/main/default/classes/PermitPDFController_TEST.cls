@isTest
private with sharing class PermitPDFController_TEST {

    @isTest
    private static void PermitPDFController_TEST() {

        User partnerUser;
        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
                break;
            }
        }
        List<Permit__c> permitList = new List<Permit__c>();
        System.runAs(partnerUser) {
            permitList = TestDataFactoryGR.createPermitsList(1, 'permit','PRMT_EventAndInStoreActivation', true);
            System.debug('LIST: '+permitList);
            ApexPages.StandardController sc = new ApexPages.standardController(permitList?.get(0)); 
        
            PageReference testPage = Page.PermitPDF;
            testPage.getParameters().put('permitId', permitList?.get(0).id);
            Test.setCurrentPage(testPage);
     
            PermitPDFController ppc=new PermitPDFController(sc);
        }

        // ApexPages.StandardController sc = new ApexPages.standardController(permitList?.get(0)); 
        
        // PageReference testPage = Page.PermitPDF;
        // testPage.getParameters().put('permitId', permitList?.get(0).id);
        // Test.setCurrentPage(testPage);
 
        // PermitPDFController ppc=new PermitPDFController(sc);             
    }
}