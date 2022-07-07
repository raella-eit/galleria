import { LightningElement, wire, track, api } from 'lwc';
import save_success_Label from '@salesforce/label/c.User_Profile_Save_Successful';
import profile_Title from '@salesforce/label/c.User_Profile_Title';
import UserDeactivationModalTitle_LBL from "@salesforce/label/c.UserDeactivationModalTitle_LBL";
import UserDeactivationModalText_LBL from "@salesforce/label/c.UserDeactivationModalText_LBL";
import DeactivateAccount_BTN_LBL from "@salesforce/label/c.DeactivateAccount_BTN_LBL";
import DeactivateAccountAgree_BTN_LBL from "@salesforce/label/c.DeactivateAccountAgree_BTN_LBL";
import SAVE from '@salesforce/label/c.SAVE';
import CANCEL from '@salesforce/label/c.CANCEL';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import FNAME_FIELD from '@salesforce/schema/Account.FirstName';
import LNAME_FIELD from '@salesforce/schema/Account.LastName';
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import PHONE_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, showToast } from 'c/sharedJSCode';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import updateUserDeactivationRequest from "@salesforce/apex/UserUtils.updateUserDeactivationRequest";

export default class UserProfile extends NavigationMixin(LightningElement) {
    @api recordId;
    objectApiName = ACCOUNT_OBJECT;
    fname = FNAME_FIELD;
    lname = LNAME_FIELD;
    email = EMAIL_FIELD;
    phone = PHONE_FIELD;
    labels = {
        title: profile_Title,
        save: SAVE,
        cancel: CANCEL,
        deactivate: DeactivateAccount_BTN_LBL,
        deactivationTitle: UserDeactivationModalTitle_LBL,
        deactivationText: UserDeactivationModalText_LBL,
        agree: DeactivateAccountAgree_BTN_LBL
    };

    showModal = false;


    handleSuccess(event) {
        showToast('Success', save_success_Label, 'Success', this);
    }

    handleError(event) {
        showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
        handleError(event?.body);
    }

    handleCancel(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    toggleModal() {
        this.showModal = !this.showModal;
    }

    confirmDeactivation() {
        updateUserDeactivationRequest({ isRequested: true }).then(() => {
            // showToast('Success', save_success_Label, 'Success', this);
            this.toggleModal();
            //navigation mixin has unpredictable behavior when redirecting to a logout page.
            window.location = this.logoutLink;

        }).catch(error => {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
            handleError(error?.body);
        });
    }

    get logoutLink() {
        return window.location.origin + "/b2c/secur/logout.jsp";
    }
}