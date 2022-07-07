@isTest
public class ApprovalCommentsController_TEST {
    @isTest
    public static void getApproverCommentsTest() {
        User partnerUser;

        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
                break;
            }
        }

        List<Offer__c> offersList = new List<Offer__c>();
        System.runAs(partnerUser) {
            offersList = TestDataFactoryGR.createOffersList(1, 'Offer', true);
        }

        Approval.ProcessSubmitRequest req1 =
        new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(offersList?.get(0).Id);
        req1.setSubmitterId(partnerUser.Id);
        req1.setProcessDefinitionNameOrId('Offer_Approval_Process');
        req1.setSkipEntryCriteria(true);

        Approval.ProcessResult result = Approval.process(req1);

        ProcessInstanceStep processStep = [SELECT Id
                                           FROM ProcessInstanceStep]?.get(0);

        System.assert(result.isSuccess(), 'Offer not properly submitted for approval');

        System.assertEquals('Submitting request for approval.',
                            ApprovalCommentsController.getApproverComments(processStep.Id),
                            'Approver Comments aren\'t properly retrieved.');

        System.assertEquals('true',ApprovalCommentsController.isProcessInstanceObject(processStep.Id), 'Approval Step is not of ProcessInstanceStep type.');
        System.assertEquals(null, ApprovalCommentsController.isProcessInstanceObject(offersList?.get(0).Id), 'Offer is not of ProcessInstanceStep type.');
    }
}