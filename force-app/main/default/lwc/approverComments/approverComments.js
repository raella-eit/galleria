import { LightningElement, api, track, wire } from 'lwc';

import getApproverComments from '@salesforce/apex/ApprovalCommentsController.getApproverComments';
import isProcessInstanceObject from '@salesforce/apex/ApprovalCommentsController.isProcessInstanceObject'
import APRV_COMMENTS_LABEL from '@salesforce/label/c.APRV_COMMENTS_LABEL';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';

export default class ApproverComments extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track comment;
    @track isProcessInstanceStep;
    error;
    title = APRV_COMMENTS_LABEL;

    @wire(getApproverComments, { recordId: '$recordId' })
    approverComments({ error, data }) {
        if (data) {
            this.comment = data;
            this.error = undefined;
        } else if (error) {
            this.error = GENERIC_ERROR_MESSAGE;
            this.comment = undefined;
        }
    }

    @wire(isProcessInstanceObject, {recordId : '$recordId'})
    verifyObject({error, data}) {
        if (data) {
            this.isProcessInstanceStep = true;
        } else {
            this.isProcessInstanceStep = false;
        }
    }

}