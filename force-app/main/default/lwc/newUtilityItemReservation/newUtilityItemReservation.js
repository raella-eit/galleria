import { LightningElement, api } from 'lwc';
import { showToast, format, handleError } from 'c/sharedJSCode';
import { NavigationMixin } from 'lightning/navigation';

import UIR_OBJECT from '@salesforce/schema/UtilityItemReservation__c';
import TYPE_FIELD from '@salesforce/schema/UtilityItemReservation__c.Type__c';
import DAY_FIELD from '@salesforce/schema/UtilityItemReservation__c.Day__c';
import FROM_FIELD from '@salesforce/schema/UtilityItemReservation__c.FromTime__c';
import TO_FIELD from '@salesforce/schema/UtilityItemReservation__c.ToTime__c';

import CARD_TITLE from '@salesforce/label/c.NEW_UIR_TITLE';
import NEW_UIR_SUCCESS from '@salesforce/label/c.NEW_UIR_SUCCESS';

import SAVING from '@salesforce/label/c.LOADING_SAVE';
import CANCEL from '@salesforce/label/c.CANCEL';
import SAVE from '@salesforce/label/c.SAVE';
import CLOSE from '@salesforce/label/c.CLOSE';

export default class NewUtilityItemReservation extends NavigationMixin(LightningElement) {
    isModalOpen = false; 
    objectApiName = UIR_OBJECT;
    cardTitle = CARD_TITLE;

    type = TYPE_FIELD;
    day = DAY_FIELD;
    from = FROM_FIELD;
    to = TO_FIELD;
    itemType;

    label_cancel = CANCEL;
    label_save = SAVE;
    label_close = CLOSE;

    isSpinnerVisible;
    loadingText = SAVING;
  
    handleSubmit(event) {
        event.stopPropagation();
        event.preventDefault();
        this.itemType = event.detail.fields.Type__c;
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    }

    handleSuccess(event) {
        this.isSpinnerVisible = false;
        showToast('Success', format(NEW_UIR_SUCCESS, this.itemType), 'Success', this, 'sticky');
        this.dispatchEvent(new CustomEvent('save'));
    }

    handleError(event) {
        this.isSpinnerVisible = false;
        let message = event.detail.detail;
        showToast('Error', message, 'Error', this);
        handleError(message);
    }

    @api openModal() {
        this.isModalOpen = true;
    }

    @api closeModal() {
        this.isModalOpen = false;
    }

}