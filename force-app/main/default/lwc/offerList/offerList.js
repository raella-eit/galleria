import { LightningElement, wire, api, track } from 'lwc';
import { handleError, showToast } from "c/sharedJSCode";
import getFutureOfferList from "@salesforce/apex/OfferListController.getFutureOfferList";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OFFER_OBJECT from '@salesforce/schema/Offer__c';
import OFFER_CATEGORY_FIELD from '@salesforce/schema/Offer__c.Category__c';
import { NavigationMixin } from 'lightning/navigation';
import lang from '@salesforce/i18n/lang';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import LOADING from '@salesforce/label/c.LOADING';
import IS_GUEST from '@salesforce/user/isGuest';
import FILTER_LABEL from '@salesforce/label/c.FILTER_LABEL';
import OFFERS_TITLE from '@salesforce/label/c.OFFERS_TITLE';
import NO_RESULT_FOUND_MSG from "@salesforce/label/c.NO_RESULT_FOUND_MSG";

const step = 10;
export default class OfferList extends NavigationMixin(LightningElement) {
    labels = {
        TITLE: OFFERS_TITLE,
        FILTER: FILTER_LABEL,
        NO_RESULT_FOUND_MSG: NO_RESULT_FOUND_MSG,
        LOADING: LOADING
    };
    @api offerCategory = '';
    offerItems = [];
    initialOffers = [];
    offersByCategory = [];
    offerDefaultRecordTypeId = '';
    offerCategoryOptionList = [];
    selectedCategoryValues = [];

    rowLimit = step;
    rowOffSet = 0;

    isLoading = true;

    appLanguage = lang;

    //variable to align titles based on language
    alignClass = 'd-flex flex-row bd-highlight mb-3';
    offerClass = 'p-2 flex-grow-1 bd-highlight';
    sortClass = 'p-2 bd-highlight';
    isAr = false;

    connectedCallback() {
        if (this.appLanguage == 'ar') {
            this.alignClass = 'd-flex flex-row-reverse bd-highlight';
            this.offerClass = 'p-2 bd-highlight';
            this.sortClass = 'p-2 flex-grow-1 bd-highlight';
            this.isAr = true;
        }
    }


    /**
     * Retrieve information about the offer object in order to identify the default recordtype
     */
    @wire(getObjectInfo, {
        objectApiName: OFFER_OBJECT
    }) offerObjectInfo({ error, data }) {
        if (data) {
            this.offerDefaultRecordTypeId = data?.defaultRecordTypeId;
        } else if (error) {
            showToast('Error', "Something went wrong while fetching filter data", 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    };
    /**
     * Retrieve picklist values for the ategory field on offer available for the default
     * record type.
     */
    @wire(getPicklistValues, {
        recordTypeId: '$offerDefaultRecordTypeId',
        fieldApiName: OFFER_CATEGORY_FIELD
    }) offerCategoryPicklistValues({ error, data }) {
        if (data) {
            this.offerCategoryOptionList = data.values.map(picklistValue => {
                return {
                    value: picklistValue.value,
                    label: picklistValue.label,
                    isChecked: !this.offerCategory || this.offerCategory === picklistValue.value
                };
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    };
    /**
     * Retrieve the list of offers to be displayed by category + pagination
     */
    @wire(getFutureOfferList, {
        limitSize: "$rowLimit",
        offset: "$rowOffSet",
        isVIPUser: !IS_GUEST
    }) upcommingOfferList({ error, data }) {
        if (data) {
            var loadMore = data.length <= this.rowLimit && data.length != 0;
            data.map(element => {
                let titleAR = element.titleAr ? element.titleAr : element.title;
                let descriptionAR = element.descriptionAr ? element.descriptionAr : element.description; 
                this.initialOffers =
                    [...this.initialOffers,
                    {
                        id: element.id,
                        imgSrc: element.imgSrc,
                        title: this.isAr ? titleAR : element.title,
                        isVIP: element.isVIP,
                        subDescription: element.subDescription,
                        parentName: element.parentName,
                        dates: element.dates,
                        description: this.isAr ?  descriptionAR : element.description,
                        parentId: element.parentId,
                        parentName: element.parentName,
                        objectType: element.objectType 
                    }
                    ]
            });
            this.offerItems = this.initialOffers;
            if (loadMore) {
                this.rowOffSet += this.rowLimit;
            }
            this.isLoading = false;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    }

    /**
     * Handle the category change - if it does, reset the pagination.
     */
    handleCategoryChange(event) {
        if (this.selectedCategoryValues !== event.detail) {
            let category = event.detail;
            this.offerItems = [];
            this.offersByCategory = [];
            this.initialOffers.map(elem => {
                if (category.includes(elem.subDescription)) {
                    this.offersByCategory.push(elem);
                }
            });
            this.offerItems = this.offersByCategory;
        }
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