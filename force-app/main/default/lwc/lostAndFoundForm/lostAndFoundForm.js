import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, showToast } from 'c/sharedJSCode';
import CASE_SUBMIT_SUCCESS_TITLE from '@salesforce/label/c.CASE_SUBMIT_SUCCESS_TITLE';
import CASE_SUBMIT_SUCCESS_MESSAGE from '@salesforce/label/c.CASE_SUBMIT_SUCCESS_MESSAGE';
import LOST_FOUND_TITLE from '@salesforce/label/c.LOST_FOUND_TITLE';
import B2C_CONTACT_US from '@salesforce/label/c.B2C_CONTACT_US';
import SUBMIT from '@salesforce/label/c.SUBMIT';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import NAME_FIELD from '@salesforce/schema/Case.SuppliedName';
import PHONE_FIELD from '@salesforce/schema/Case.SuppliedPhone';
import EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import ADDRESS_FIELD from '@salesforce/schema/Case.Home_Address__c';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import WHERE_LOST_FIELD from '@salesforce/schema/Case.Where_Lost__c';
import WHEN_LOST_FIELD from '@salesforce/schema/Case.When_Lost__c';
import ITEM_DESC_FIELD from '@salesforce/schema/Case.Item_Full_Description__c';

import createLostAndFoundCase from "@salesforce/apex/CaseController.createLostAndFoundCase";
import isGuest from "@salesforce/user/isGuest";

export default class LostAndFoundForm extends NavigationMixin(LightningElement) {
    isGuestUser = isGuest;
    objectApiName = CASE_OBJECT;
    recordTypeId = '';
    labels = {
        title: LOST_FOUND_TITLE,
        help: B2C_CONTACT_US,
        save: SUBMIT,
    };

    name = NAME_FIELD;
    phone = PHONE_FIELD;
    email = EMAIL_FIELD;
    address = ADDRESS_FIELD;
    subject = SUBJECT_FIELD;
    whereLost = WHERE_LOST_FIELD;
    whenLost = WHEN_LOST_FIELD;
    itemDesc = ITEM_DESC_FIELD;
    recordInputForCreate = {fields:{}};

    onFieldChange(event) {
        event.preventDefault();
        event.stopPropagation();
        let field = event.currentTarget.dataset.id;
        this.recordInputForCreate.fields[field] = event.currentTarget.value;
    }

    onSubmit(event) {
        event.preventDefault();
        event.stopPropagation();
        createLostAndFoundCase({ cas: this.recordInputForCreate.fields }).then(() => {
            showToast(CASE_SUBMIT_SUCCESS_TITLE, CASE_SUBMIT_SUCCESS_MESSAGE, 'success', this);
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'home'
                }
            });
        }).catch(error => {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        });
    }

    @wire(getObjectInfo, {
        objectApiName: CASE_OBJECT
    }) caseObjectInfo({ error, data }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'LOST_FOUND');
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    };

}