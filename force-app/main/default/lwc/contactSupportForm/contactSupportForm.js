import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_SUBMIT_SUCCESS_TITLE from '@salesforce/label/c.CASE_SUBMIT_SUCCESS_TITLE';
import CASE_SUBMIT_SUCCESS_MESSAGE from '@salesforce/label/c.CASE_SUBMIT_SUCCESS_MESSAGE';
import CONTACT_SUPPORT_TITLE from '@salesforce/label/c.CONTACT_SUPPORT_TITLE';
import CONTACT_SUPPORT_SUBTITLE from '@salesforce/label/c.CONTACT_SUPPORT_SUBTITLE';
import B2C_CONTACT_US from '@salesforce/label/c.B2C_CONTACT_US';
import SUBMIT from '@salesforce/label/c.SUBMIT';
import CANCEL from '@salesforce/label/c.CANCEL';
import CASE_OBJECT from '@salesforce/schema/Case';
import NAME_FIELD from '@salesforce/schema/Case.SuppliedName';
import PHONE_FIELD from '@salesforce/schema/Case.SuppliedPhone';
import EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import SUBJ_CATEGORY_FIELD from '@salesforce/schema/Case.Subject_Category__c';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, showToast } from 'c/sharedJSCode';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import createSupportCase from "@salesforce/apex/CaseController.createSupportCase";
import isGuest from "@salesforce/user/isGuest";
import LIVE_CHAT from '@salesforce/label/c.LIVE_CHAT';
import isAgentLive from "@salesforce/apex/CommunityUtilities.isAgentLive";

export default class ContactSupportForm extends NavigationMixin(LightningElement) {
    isGuestUser = isGuest;
    objectApiName = CASE_OBJECT;
    recordTypeId = '';
    labels = {
        title: CONTACT_SUPPORT_TITLE,
        subtitle: CONTACT_SUPPORT_SUBTITLE,
        help: B2C_CONTACT_US,
        save: SUBMIT,
        cancel: CANCEL,
        liveChat: LIVE_CHAT
    };

    name = NAME_FIELD;
    phone = PHONE_FIELD;
    email = EMAIL_FIELD;
    subjectCategory = SUBJ_CATEGORY_FIELD;
    subject = SUBJECT_FIELD;
    description = DESCRIPTION_FIELD;
    recordInputForCreate = { fields: {} };

    showLiveChatBtn = false;


    onFieldChange(event) {
        event.preventDefault();
        event.stopPropagation();
        let field = event.currentTarget.dataset.id;
        this.recordInputForCreate.fields[field] = event.currentTarget.value;
    }

    onSubmit(event) {
        event.preventDefault();
        event.stopPropagation();
        createSupportCase({ cas: this.recordInputForCreate.fields }).then(() => {
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
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'B2C');
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    };

    connectedCallback(){
        isAgentLive().then(result=>{
            this.showLiveChatBtn = result;
        }).catch(()=>{
            this.showLiveChatBtn = false;
        })
    }

    openChat(event) {
        event.preventDefault();
        event.stopPropagation();
        let chatEvent = new CustomEvent(
            'chatEvent',
            {
                detail: {
                    startChat: true
                },
                bubbles: true,
                cancelable: true
            }
        );
        this.dispatchEvent(chatEvent);
    }

}