import { LightningElement, wire } from 'lwc';
import OFFER_OBJECT from '@salesforce/schema/Offer__c';
import OFFER_CATEGORY_FIELD from '@salesforce/schema/Offer__c.Category__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import TOP_OFFERS_SECTION_TITLE from "@salesforce/label/c.TOP_OFFERS_SECTION_TITLE";
import ALL_OFFERS_BTN_LBL from "@salesforce/label/c.ALL_OFFERS_BTN_LBL";
import { handleError, showToast } from "c/sharedJSCode";
import { NavigationMixin } from 'lightning/navigation';
import getFutureOfferList from "@salesforce/apex/OfferListController.getFutureOfferList";
import IS_GUEST from '@salesforce/user/isGuest';
const step = 4;

export default class TopOffers extends NavigationMixin(LightningElement) {
    labels = {
        TOP_OFFERS_SECTION_TITLE: TOP_OFFERS_SECTION_TITLE,
        ALL_OFFERS_BTN_LBL: ALL_OFFERS_BTN_LBL
    };
    rowLimit = step;
    rowOffSet = 0;
    offerDefaultRecordTypeId = '';
    offerCategoryOptionList = [];
    offerItems = [];

    @wire(getObjectInfo, {
        objectApiName: OFFER_OBJECT
    }) offerObjectInfo({ error, data }) {
        if (data) {
            this.offerDefaultRecordTypeId = data?.defaultRecordTypeId;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    };

    @wire(getPicklistValues, {
        recordTypeId: '$offerDefaultRecordTypeId',
        fieldApiName: OFFER_CATEGORY_FIELD
    }) offerCategoryPicklistValues({ error, data }) {
        if (data) {
            this.offerCategoryOptionList = data.values.map(picklistValue => {
                return picklistValue.value;
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    };

    @wire(getFutureOfferList, {
        limitSize: "$rowLimit",
        offset: "$rowOffSet",
        offerCategoryList: "$offerCategoryOptionList",
        isVIPUser: !IS_GUEST
    }) offerList({ error, data }) {
        if (data) {
            this.offerItems = data;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }

    handleLoadMore(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'offer-list'
            }
        });
    }

    /**
     * Navigate the user to the offer detail page when they select and offer
     */
     handleOfferSelection(event) {
        let id = event.detail.item;
        if (this.offerItems.find(offer => { return offer.id === id; })) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                   pageName: 'offer-detail'
                }, 
                state: {
                    recordId: id
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'shop-detail'
                },
                //Set URL parameters
                state: {
                    recordId: id
                }
            });
        }
    }
}