import { LightningElement, api, wire, track } from 'lwc';
import getOffer from "@salesforce/apex/OfferDetailController.getOffer";
import LANG from '@salesforce/i18n/lang';
import { handleError, showToast } from 'c/sharedJSCode';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import SEE_MORE_FROM_BTN_LBL from "@salesforce/label/c.SEE_MORE_FROM_BTN_LBL";
import TERMS_AND_CONDITIONS_LBL from "@salesforce/label/c.TERMS_AND_CONDITIONS_LBL";
import { NavigationMixin } from 'lightning/navigation';
export default class OfferDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    labels = {
        SEE_MORE_FROM_BTN_LBL: SEE_MORE_FROM_BTN_LBL,
				TERMS_AND_CONDITIONS_LBL:TERMS_AND_CONDITIONS_LBL
    };
    @track offer = {};
    @wire(getOffer, { offerId: "$recordId" }) wiredOffer({ error, data }) {
        if (data) {
            if (LANG === "ar") {
                this.offer = {
                    title: data.titleAr ? data.titleAr : data.title,
                    description: data.descriptionAr ? data.descriptionAr : data.description,
                    dates: data.dates,
                    store: data.parentId,
                    storeName: data.parentName,
                    imgSrc: data.imgSrc,
										terms:data.terms
                };
            } else {
                this.offer = {
                    title: data.title,
                    description: data.description,
                    dates: data.dates,
                    store: data.parentId,
                    storeName: data.parentName,
                    imgSrc: data.imgSrc,
										terms:data.terms
                };
            }

        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }


    redirect(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'shop-detail'
            },
            //Set URL parameters
            state: {
                recordId: this.offer.store,
                shop: this.offer.storeName
            }
        });

    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }
}