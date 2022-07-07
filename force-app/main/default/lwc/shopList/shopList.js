import { LightningElement, api, wire, track } from 'lwc';
import getShopList from "@salesforce/apex/ShopListController.getShopList";
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import { handleError, showToast } from 'c/sharedJSCode';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_CATEGORY_FIELD from '@salesforce/schema/B2CShop__c.Category__c';
import ACCOUNT_OBJECT from '@salesforce/schema/B2CShop__c';
import SHOW_MORE_BTN_LBL from "@salesforce/label/c.SHOW_MORE_BTN_LBL";
import SHOPS_TITLE from "@salesforce/label/c.SHOPS_TITLE";
import FILTER_LABEL from "@salesforce/label/c.FILTER_LABEL";
import SEARCH_LABEL from "@salesforce/label/c.Search_By_Name_Label";
import LOGO_IMG from '@salesforce/resourceUrl/ACT_LogoPlaceholder';
import { NavigationMixin } from 'lightning/navigation';
import lang from '@salesforce/i18n/lang';
import LOADING from '@salesforce/label/c.LOADING';
import NO_RESULT_FOUND_MSG from "@salesforce/label/c.NO_RESULT_FOUND_MSG";

const p2_bdhighlight = 'p-2 bd-highlight';
const p2_flex_bdhighlight = 'p-2 flex-grow-1 bd-highlight';
export default class ShopList extends NavigationMixin(LightningElement) {
    @track shops = [];
    @track isSearchBarVisible = false;
    @api shopCategory = '';
    objectApiName;
    initialShops = [];
    shopDefaultRecordTypeId = '';
    shopCategoryOptionList = [];
    selectedCategoryValues = [];
    searchTerm = '';
    isLoading = true;
    appLang = lang;

    labels = {
        SHOW_MORE_BTN_LBL: SHOW_MORE_BTN_LBL,
        TITLE: SHOPS_TITLE,
        FILTER: FILTER_LABEL,
        LOADING: LOADING,
        SEARCH_LABEL: SEARCH_LABEL,
        NO_RESULT_FOUND_MSG: NO_RESULT_FOUND_MSG
    };

    //variable to align titles based on language
    get rtlSupp() {
        if (this.appLang == 'ar') {
            return {
                alignClass: 'd-flex flex-row-reverse bd-highlight',
                shopClass: p2_bdhighlight,
                searchClass: p2_bdhighlight,
                sortClass: p2_flex_bdhighlight,
                isAr: true
            };
        }
        else {
            return {
                alignClass: 'd-flex flex-row bd-highlight',
                shopClass: p2_flex_bdhighlight,
                searchClass: p2_bdhighlight,
                sortClass: p2_bdhighlight,
                isAr: false
            };
        }
    }

    @wire(getObjectInfo, {
        objectApiName: ACCOUNT_OBJECT
    }) offerObjectInfo({ error, data }) {
        if (data) {
            this.shopDefaultRecordTypeId = data?.defaultRecordTypeId;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    };

    /**
    * Retrieve picklist values for the category field on B2CShop__c 
    */
    @wire(getPicklistValues, {
        recordTypeId: '$shopDefaultRecordTypeId',
        fieldApiName: ACCOUNT_CATEGORY_FIELD
    }) shopCategoryPicklistValues({ error, data }) {
        if (data) {
            this.shopCategoryOptionList = data.values.map(picklistValue => {
                return {
                    value: picklistValue.value,
                    label: picklistValue.label,
                    isChecked: !this.shopCategory || this.shopCategory === picklistValue.value
                };
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    };

    @wire(getShopList)
    wiredShop({ error, data }) {
        if (data) {
            this.initialShops = data.map(element => {
                return {
                    id: element.id,
                    title: element.title,
                    subDescription: element.subDescription,
                    category: element.category,
                    imgSrc: element.imgSrc ? element.imgSrc : LOGO_IMG,
                }
            });
            this.shops = this.initialShops;
            this.isLoading = false;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    }

    /**
     * Handle the category change - if it does, re-filter the Shop Array to include only 
     * the selected categories.
     */
    handleCategoryChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.clearFilterByName();
        this.isSearchBarVisible = false;
        this.shops = [];
        this.selectedCategoryValues = event.detail;
        this.shops = this.initialShops.filter(shop =>
            this.selectedCategoryValues.includes(shop.category));
    }

    /**
     * handle the seach by name by emptying the shop list and repopulating it
     * with the shops in which their name contains the search term.
     * @param {*} event 
     */
    handleSearchChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.searchTerm = event?.target?.value;
        this.filterShopsByName(event.target.value);
    }

    filterShopsByName(searchTerm) {
        if (!searchTerm || !searchTerm.trim()) {
            this.clearFilterByName();
        } else {
            var eltsToShow = 'div.popInLeft[data-name*="' + searchTerm + '"i]';
            var eltsToHide = 'div.popInLeft:not([data-name*="' + searchTerm + '"i])';
            this.template.querySelectorAll(eltsToHide).forEach(e => e.classList.add('d-none'))
            this.template.querySelectorAll(eltsToShow).forEach(e => e.classList.remove('d-none'))
        }
    }

    /**
     * clears text filter
     */
    clearFilterByName() {
        this.searchTerm = null;
        this.template.querySelectorAll('div.popInLeft').forEach(e => e.classList.remove('d-none'));
    }

    /**
     * toggle search bar visibility
     */
    toggleSearchBar() {
        this.isSearchBarVisible = !this.isSearchBarVisible;
    }

    /**
     * sets page title depending on selected category
     */
    get pageTitle() {
        return this.selectedCategoryValues.length > 1 ? this.labels.TITLE : this.selectedCategoryValues;
    }

    /**
    * Navigate the user to the shop detail page when they select a shop
    */
    handleShopSelection(event) {
        let id = event.currentTarget.dataset.item;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'shop-detail'
            },
            state: {
                recordId: id
            }
        });
    }
}