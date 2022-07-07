import { LightningElement, wire, api, track } from 'lwc';
import { showToast } from 'c/sharedJSCode';
import { NavigationMixin } from 'lightning/navigation';

import getEventRecordTypeId from '@salesforce/apex/PermitController.getEventRecordTypeId';
/* import saveFiles from '@salesforce/apex/FilesManagerController.saveFiles'; */

import CATERING_FIELD from '@salesforce/schema/Permit__c.Catering__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Permit__c.Description__c';
import DISMANTLE_TIME_FIELD from '@salesforce/schema/Permit__c.DismantleTime__c';
import END_DATE_FIELD from '@salesforce/schema/Permit__c.EndDate__c';
import START_DATE_FIELD from '@salesforce/schema/Permit__c.StartDate__c';
import EVENT_LOCATION from '@salesforce/schema/Permit__c.EventLocation__c';
import EVENT_NAME_FIELD from '@salesforce/schema/Permit__c.EventName__c';
import FOOD_SAMPLING_FIELD from '@salesforce/schema/Permit__c.FoodSamplingAndMascots__c';
import INVITEES_FIELD from '@salesforce/schema/Permit__c.Invitees__c';
import PHOTOGRAPHY_FIELD from '@salesforce/schema/Permit__c.Photography__c';
import ENTERTAINMENT_FIELD from '@salesforce/schema/Permit__c.Entertainment__c';
import SETUP_TIME from '@salesforce/schema/Permit__c.SetUpTime__c';
import SUB_EMAIL_FIELD from '@salesforce/schema/Permit__c.SubmitterEmail__c';
import SUB_NAME_FIELD from '@salesforce/schema/Permit__c.SubmitterName__c';
import SUB_NUMBER_FIELD from '@salesforce/schema/Permit__c.SubmitterNumber__c';

/* import PERMIT_FILES_LABEL from '@salesforce/label/c.PERMIT_FILES_LABEL'; */
import NEW_PERMIT_SUCCESS from '@salesforce/label/c.NEW_PERMIT_SUCCESS';
import CARD_TITLE from '@salesforce/label/c.NEW_PERMIT_TITLE';
/* import FILE_REQUIRED_MSG from '@salesforce/label/c.FILE_REQUIRED_MSG'; */
import PRMT_ERR_GetRecordType from '@salesforce/label/c.PRMT_ERR_GetRecordType';
/* import PERMIT_FILE_UPLOAD_HELP_TEXT from '@salesforce/label/c.PERMIT_FILE_UPLOAD_HELP_TEXT'; */

import SAVING from '@salesforce/label/c.LOADING_SAVE';

export default class NewPermit extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordTypeId;
    @track cardTitle = CARD_TITLE;

    options = [];
    value = '';

    catering = CATERING_FIELD;
    description = DESCRIPTION_FIELD;
    dismantleTime = DISMANTLE_TIME_FIELD;
    endDate = END_DATE_FIELD;
    startDate = START_DATE_FIELD;
    eventLocation = EVENT_LOCATION;
    eventName = EVENT_NAME_FIELD;
    foodSampling = FOOD_SAMPLING_FIELD;
    invitees = INVITEES_FIELD;
    photography = PHOTOGRAPHY_FIELD;
    entertainment = ENTERTAINMENT_FIELD;
    setupTime = SETUP_TIME;
    subEmail = SUB_EMAIL_FIELD;
    subName = SUB_NAME_FIELD;
    subNumber = SUB_NUMBER_FIELD;

    isEvent;

    recordId;
   /*  acceptedFormats = ['All'];
    files = []; */
    isSpinnerVisible;
    loadingText = SAVING;
   /*  label = PERMIT_FILES_LABEL;
    helpText = PERMIT_FILE_UPLOAD_HELP_TEXT; */

    @wire(getEventRecordTypeId)
    wiredEventRecordTypeId({ error, data }) {
        if (data) {
            this.isEvent = data == this.recordTypeId ? true : false;
        } 
        // error is handled in handleSubmit()
    }

    handleCancel(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Permit__c",
                "actionName": "home"
            }
        });
    }

  /*   handleChooseImages(event) {
        let file = {
            name: event.detail.name,
            filesByType: event.detail.filesToUpload
        };
        let index = this.files.findIndex((object => object.name == file.name));
        index == -1 ? this.files.push(file) : this.files[index] = file;
    } */

   /*  handleSubmit(event) {
        event.stopPropagation();
        event.preventDefault();
        if (this.files.length > 0) {
            this.isSpinnerVisible = true;
            this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        } else {
            this.isSpinnerVisible = false;
            showToast('Error', FILE_REQUIRED_MSG, 'Error', this);
        }
        if (this.isEvent == undefined) {
            this.isSpinnerVisible = false;
            showToast('Error', PRMT_ERR_GetRecordType, 'Error', this);
        }
    } */

    handleSuccess(event) {
        let recordId = event.detail.id;
        this.successRedirect(recordId);
        /* saveFiles({ idParent: recordId, filesList: this.files })
            .then(data => {
                this.successRedirect(recordId);
            })
            .catch(error => {
                this.handleError();
            }) */
    }

    handleError(event) {
        this.isSpinnerVisible = false;
        let message = event.detail.detail;
        showToast('Error', message, 'Error', this);
    }

    successRedirect(record) {
        this.isSpinnerVisible = false;
        showToast('Success', NEW_PERMIT_SUCCESS, 'Success', this);
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": record,
                "objectApiName": "Permit__c",
                "actionName": "view"
            }
        });
    }

}