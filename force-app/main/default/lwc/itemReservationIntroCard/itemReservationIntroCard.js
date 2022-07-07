import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import UIR_BOOKING_TITLE from '@salesforce/label/c.UIR_BOOKING_TITLE';
import UIR_INTRO_SHORT_DESC from '@salesforce/label/c.UIR_INTRO_SHORT_DESC';
import UIR_INTRO_DESC from '@salesforce/label/c.UIR_INTRO_DESC';
import UIR_LOGIN_MSG from '@salesforce/label/c.UIR_LOGIN_MSG';
import UIR_BUTTON_BOOK from '@salesforce/label/c.UIR_BUTTON_BOOK';
import LOGIN from '@salesforce/label/c.LOGIN';

import UIR_PLACEHOLDER_IMG from '@salesforce/resourceUrl/UIR_PLACEHOLDER_IMG';

export default class ItemReservationIntroCard extends NavigationMixin(LightningElement) {
    @api hideImage;
    @api isGuest;
    image = UIR_PLACEHOLDER_IMG;

    labels = {
        title: UIR_BOOKING_TITLE,
        shortDescription: UIR_INTRO_SHORT_DESC,
        description: UIR_INTRO_DESC,
        loginMessage: UIR_LOGIN_MSG
    };

    get buttonLabel() {
        return this.isGuest ? LOGIN : UIR_BUTTON_BOOK;
    }

    handleClick(event) {
        if (this.isGuest) {
            this.gotoLogin();
        } else {
            this.openModal();
        }
    }

    openModal() {
        this.dispatchEvent(new CustomEvent('openmodal'));
    }

    gotoLogin() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            },
        });
    }

    get cardColCls() {
        return this.hideImage ? "col-12 col-md-12" : "col-12 col-md-8";
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }
}