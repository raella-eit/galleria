public with sharing class PermitPDFController {

    public String permitId {get; set;}
    public Permit__c permit {get; set;}
    public boolean isEventPermit {get; set;}
    public boolean isApproved {get; set;}
    public boolean isPending {get; set;}
    public boolean isRejected {get; set;}
    public boolean generatePDF {get; set;}
    ApexPages.StandardController sc;

    public PermitPDFController(ApexPages.StandardController sc) {
        this.permitId = System.currentPageReference().getParameters().get('permitId');
        isEventPermit = isApproved = isRejected = isPending = false;
        
        this.permit = [SELECT Id,
                       SubmitterName__c,
                       SubmitterEmail__c,
                       SubmitterNumber__c,
                       Description__c,
                       ApprovalStatus__c,
                       StartDate__c,
                       EndDate__c,
                       EventName__c,
                       EventLocation__c,
                       Invitees__c,
                       SetUpTime__c,
                       DismantleTime__c,
                       Catering__c,
                       Entertainment__c,
                       Photography__c,
                       FoodSamplingAndMascots__c,
                       RecordTypeId,
                       Account__r.Name,
                       Account__r.UnitNumber__c,
                       Account__r.Park_Near__c,
                       Account__r.Store_Location__c,
                       Account__r.Phone,
                       Category__c,
                       Name,
                       Submission_Date__c,
                       Reviewer_Name__c
                       FROM Permit__C
                       WHERE Id =:this.permitId
        ];
        generatePDF = (UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)
                       && (permit.ApprovalStatus__c == 'Approved' || permit.ApprovalStatus__c == 'Rejected')) 
            || UserInfo.getProfileId() != ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER);

        if(permit.RecordTypeId == ObjectUtils.getRecordTypeId('Permit__c',
                                                              'PRMT_EventAndInStoreActivation')) {
            isEventPermit = true;
        }
        if(permit.ApprovalStatus__c == 'Approved') {
            isApproved = true;
        }else if(permit.ApprovalStatus__c == 'Rejected'){
            isRejected=true;
        }else if(permit.ApprovalStatus__c == 'Pending'){
            isPending=true;
        }
        this.sc = sc;
    }

}