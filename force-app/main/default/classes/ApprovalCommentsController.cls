public without sharing class ApprovalCommentsController {

    /**
     * @description retrieves approver Comments given Approval Process Step Id
     * @author Raella Frem | 20-09-2021
     * @param String recordId
     * @return String
     **/
    @AuraEnabled(cacheable = true)
    public static String getApproverComments (String recordId) {
        String comment = System.Label.NO_APRV_COMMENTS;
        List<ProcessInstanceStep> processInstanceStepList = [SELECT Comments
                                                             FROM ProcessInstanceStep
                                                             WHERE Id = :recordId];
        if(!processInstanceStepList.isEmpty() && String.isNotBlank(processInstanceStepList.get(0).Comments)) {
            comment = processInstanceStepList.get(0).Comments;
        }

        return comment;
    }

    /**
     * @description returns true if called from ProcessInstanceStep object
     * @author Raella Frem | 21-09-2021
     * @param Id recordId
     * @return Boolean
     **/
    @AuraEnabled(cacheable = true)
    public static String isProcessInstanceObject(Id recordId){
        String sObjectType = recordId.getSobjectType().getDescribe().getName();
        if(sObjectType.contains('Process') || sObjectType.contains('Approval')) {
            return 'true';
        }

        return null;

    }
}