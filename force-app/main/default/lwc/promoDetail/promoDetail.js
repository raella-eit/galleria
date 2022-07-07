import { LightningElement, api, wire, track } from 'lwc';
import getEvent from "@salesforce/apex/EventDetailController.getEvent";
import isEventScheduled from "@salesforce/apex/EventDetailController.isEventScheduled";
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import EventRegistration_BTN_LBL from "@salesforce/label/c.EventRegistration_BTN_LBL";
import LANG from '@salesforce/i18n/lang';
import { handleError, showToast } from 'c/sharedJSCode';
import { NavigationMixin } from 'lightning/navigation';
import isguest from "@salesforce/user/isGuest";
export default class PromoDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    @track event = {};

    btnLbl = EventRegistration_BTN_LBL;
    showReservationButton = false;

    @wire(getEvent, { eventId: "$recordId" }) wiredEvent({ error, data }) {
        if (data) {
            if (LANG === "ar") {
                this.event = {
                    title: data.titleAr ? data.titleAr : data.title,
                    description: data.descriptionAr ? data.descriptionAr : data.description,
                    dates: data.dates,
                    store: data.parentId,
                    parentName: data.parentName,
                    imgSrc: data.imgSrc
                };
            } else {
                this.event = {
                    title: data.title,
                    description: data.description,
                    dates: data.dates,
                    parentId: data.parentId,
                    parentName: data.parentName,
                    imgSrc: data.imgSrc
                };
            }

        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }

    @wire(isEventScheduled, { eventId: "$recordId" }) wiredEventScheduled({ error, data }) {
        if (data) {
            this.showReservationButton = !!data;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }

    handleClickButton() {
        if (isguest) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/b2c/CommunityRegistrationVFP?callback=events-reservation&id=' + this.recordId
                }
            }).then((generatedUrl) => {
                window.open(generatedUrl, "_self");
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'events-reservation'
                },
                state: {
                    recordId: this.recordId,
                }
            });
        }
    }

}