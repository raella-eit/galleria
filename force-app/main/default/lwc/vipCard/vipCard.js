import { LightningElement, wire } from 'lwc';
import TermsAndConditions from '@salesforce/label/c.VIPCARD_TERMS_AND_CONDITIONS';
import Inquiries_Label from '@salesforce/label/c.VIPCard_Inquiries';
import VIP_Pass_Label from '@salesforce/label/c.VIPCard_VIP_Pass';
import VIPCard_btn_label from '@salesforce/label/c.VIPCard_shops_btn';
import VIP_url from '@salesforce/label/c.VIPCard_shops_url';
import VIPCard_Logo from '@salesforce/resourceUrl/VIPCard_Logo';
import { NavigationMixin } from 'lightning/navigation';
import lang from '@salesforce/i18n/lang';
import VIP_Number from '@salesforce/schema/User.VIP_Card_Number__c';
import FirstName from '@salesforce/schema/User.FirstName';
import LastName from '@salesforce/schema/User.LastName';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import VIP_PAGE_TITLE from '@salesforce/label/c.VIP_PAGE_TITLE';
import VIP_PAGE_DESCRIPTION from '@salesforce/label/c.VIP_PAGE_DESCRIPTION';

const fields = [VIP_Number,FirstName,LastName];

export default class VipCard extends NavigationMixin(LightningElement) {
    labels = {
        pageTitle: VIP_PAGE_TITLE,
        Inquiries_Label: Inquiries_Label,
        VIP_Pass_Label: VIP_Pass_Label,
        VIPCard_btn_label: VIPCard_btn_label
    }

    VIPCard_Logo = VIPCard_Logo;

    appLanguage = lang;

    get alignClass() {
        if(this.appLanguage == 'ar'){
            return 'card-title align-end';
        }
        else{
            return 'card-title';
        }
    }

    @wire(getRecord, { recordId: userId, fields })
    user;

    get VIPNumber() {
        return getFieldValue(this.user.data, VIP_Number);
    }
    get FirstName() {
        return getFieldValue(this.user.data, FirstName);
    }
    get LastName() {
        return getFieldValue(this.user.data, LastName);
    }

    get termsAndConditions() {
        var splitRule_TermsAndConds = /\d\./;
        var splitArray_TermsAndConds = TermsAndConditions.split(splitRule_TermsAndConds);
        var formattedTermsAndConditions = "";
        for (let i = 0; i < splitArray_TermsAndConds.length; i++) {
            switch (i) {
                case 0:
                    formattedTermsAndConditions += splitArray_TermsAndConds[i] + "<br>";
                    break;
                case splitArray_TermsAndConds.length - 1:
                    formattedTermsAndConditions += i + "." + splitArray_TermsAndConds[i];
                    break;
                default:
                    formattedTermsAndConditions += i + "." + splitArray_TermsAndConds[i] + "<br>";
                    break;
            }
        }
        return formattedTermsAndConditions;
    }

    get pageDescription() {
        var splitRule_Description = /\r/;
        var formattedDescription = "";
        var splitArray_Description = VIP_PAGE_DESCRIPTION.split(splitRule_Description);
        for (let i = 0; i < splitArray_Description.length; i++) {
            switch (i) {
                case 0:
                    formattedDescription += splitArray_Description[i] + "<br>";
                    break;
                case splitArray_Description.length - 1:
                    formattedDescription += splitArray_Description[i];
                    break;
                default:
                    formattedDescription += splitArray_Description[i] + "<br>";
                    break;
            }
        }
        return formattedDescription;
    }

    animateCard(event) {
        event.currentTarget.classList.toggle("flipped");
    }

    navigateToVIPList() {
        window.open(VIP_url);
    }

}