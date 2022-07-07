import { LightningElement, api } from 'lwc';
import SUB_NAME from '@salesforce/schema/Offer__c.SubmitterName__c';
import SUB_EMAIL from '@salesforce/schema/Offer__c.SubmitterEmail__c';
import SUB_NUMBER from '@salesforce/schema/Offer__c.SubmitterNumber__c';
import IS_ALL_BRANCHES from '@salesforce/schema/Offer__c.IsOnAllBranches__c';
import IS_EXCLUSIVE from '@salesforce/schema/Offer__c.IsExclusive__c';
import KEYWORDS from '@salesforce/schema/Offer__c.Keywords__c';
import KEYWORDS_AR from '@salesforce/schema/Offer__c.KeywordsAR__c';
import NAME from '@salesforce/schema/Offer__c.Name';
import CAMPAIGN from '@salesforce/schema/Offer__c.Campaign__c';
import NAME_AR from '@salesforce/schema/Offer__c.OfferNameAR__c';
import CATEGORY from '@salesforce/schema/Offer__c.Category__c';
import DESCRIPTION from '@salesforce/schema/Offer__c.Description__c';
import DESCRIPTION_AR from '@salesforce/schema/Offer__c.DescriptionAR__c';
import START_DATE from '@salesforce/schema/Offer__c.Start_Date__c';
import END_DATE from '@salesforce/schema/Offer__c.End_Date__c';
import TERMS_AND_CONDITIONS from '@salesforce/schema/Offer__c.Terms_Conditions__c';
import COMMENT from '@salesforce/schema/Offer__c.Comment__c';
import OFFER_IMG_LABEL from '@salesforce/label/c.OFFER_IMG_LABEL';
import { showToast, format } from 'c/sharedJSCode';
import saveFiles from '@salesforce/apex/FilesManagerController.saveFiles';
import NEW_OFFER_SUCCESS from '@salesforce/label/c.NEW_OFFER_SUCCESS';
import SAVING from '@salesforce/label/c.LOADING_SAVE';
import CARD_TITLE from '@salesforce/label/c.NEW_OFFER';
import { NavigationMixin } from 'lightning/navigation';


export default class NewOffer extends NavigationMixin(LightningElement) {
    @api objectApiName;
    name = NAME;
    nameAR = NAME_AR;
    category = CATEGORY;
    description = DESCRIPTION;
    descriptionAR = DESCRIPTION_AR;
    startDate = START_DATE;
    endDate = END_DATE;
    termsAndConditions = TERMS_AND_CONDITIONS;
    comment = COMMENT;
    OFFER_IMG_LABEL = OFFER_IMG_LABEL;
    submitterName = SUB_NAME;
    submitterEmail = SUB_EMAIL;
    submitterNumber = SUB_NUMBER;
    allBranches = IS_ALL_BRANCHES;
    exclusive = IS_EXCLUSIVE;
    keywords = KEYWORDS;
    campaign = CAMPAIGN;
    keywordsAR = KEYWORDS_AR;
    cardTitle = CARD_TITLE;

    recordId;
    acceptedFormats = ['image/png', 'image/jpg', 'image/jpeg'];
    files = [];
    isSpinnerVisible;
    loadingText = SAVING;
    offerName;

    handleChooseImages(event) {
        let file = {
            name: event.detail.name,
            filesByType: event.detail.filesToUpload
        };
        let index = this.files.findIndex((object => object.name == file.name));
        index == -1 ? this.files.push(file) : this.files[index] = file;
    }

    // handleSubmit(event) {
    //     event.stopPropagation();
    //     event.preventDefault();
    //     /*  if (this.files.length > 0) {
    //          this.isSpinnerVisible = true;
    //          this.offerName = event.detail.fields.Name;
    //          this.template.querySelector('lightning-record-edit-form ').submit(event.detail.fields);
    //      } else {
    //          this.isSpinnerVisible = false;
    //          showToast('Error', IMG_REQUIRED_MSG, 'Error', this);
    //      } */
    //     this.isSpinnerVisible = true;
    //     this.offerName = event.detail.fields.Name;
    //     this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    // }

    handleSuccess(event) {
        let recordId = event.detail.id;
        if (this.files.length > 0) {
            saveFiles({ idParent: recordId, filesList: this.files })
                .then(data => {
                    this.successRedirect(recordId);
                })
                .catch(error => {
                    this.handleError();
                })
        } else {
            this.successRedirect(recordId);
        }
    }

    handleError(event) {
        this.isSpinnerVisible = false;
        let message = event.detail.detail;
        // let errorMessage = (message.includes('sufficient access') ?
        //     message : NEW_OFFER_ERROR);
        showToast('Error', message, 'Error', this);
    }

    handleCancel(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Offer__c",
                "actionName": "home"
            }
        });
    }

    successRedirect(record) {
        this.isSpinnerVisible = false;
        showToast('Success', format(NEW_OFFER_SUCCESS, this.offerName), 'Success', this);
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": record,
                "objectApiName": "Offer__c",
                "actionName": "view"
            }
        });
    }
}