import { LightningElement, api, wire, track } from 'lwc';
import getNavigationItems from '@salesforce/apex/NavigationItemsController.getLocalizedNavigationItems';

import isGuestUser from '@salesforce/user/isGuest';
import IconAssets from '@salesforce/resourceUrl/Bottom_Nav_Icons';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';


/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationItemsController apex class.
 */
export default class NavigationMenu extends NavigationMixin(LightningElement) {

    /**
     * the menuName (NavigationMenuLinkSet.MasterLabel) exposed by the .js-meta.xml
     */
    @api menuName = 'Default Navigation';

    /**
     * the menu items when fetched by the NavigationItemsController
     */
    @track menuItems = [];

    /**
     * if the items have been loaded
     */
    @track isLoaded = false;

    /**
     * the error if it occurs
     */
    @track error;

    /**
     * the publish status of the communitiy, needed in order to determine from which schema to 
     * fetch the NavigationMenuItems from
     */
    publishStatus = ['--preview.', '--live.'].includes(window.Location.href) ? 'Draft' : 'Live';

    /**
     * to determine if the toggle is active or not
     */
    isToggled = false;

    /**
     * to identify properties of the current page
     */
    pageReference;
    href = '';

    guest = isGuestUser;
    currentPageReference = null; 
    urlStateParameters = null;
 
    /* Params from Url */
    urlLanguage = null;
 
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
 
    setParametersBasedOnUrl() {
       this.urlLanguage = this.urlStateParameters.language ? this.urlStateParameters.language : 'en_US' ;
    }

    /**
     * We use wire and pass it the controller and the arguments that the controller needs. 
     */
    
    @wire(getNavigationItems, {
        menuName: '$menuName',
        publishStatus: '$publishStatus',
        isGuestUser: '$guest',
        language: '$urlLanguage'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            this.menuItems = data.map((item, index) => {
                let imgUrl = IconAssets + "/"+item.labelEN.replace(/\s+/g, '')+".png";
                return {
                    target: item.target,
                    id: index.toString(),
                    label: item.label,
                    defaultListViewId: item.defaultListViewId,
                    type: item.type,
                    accessRestriction: item.accessRestriction,
                    imgUrl: imgUrl
                };
            }).filter(item => {
                // Only show "Public" items if guest user
                return item.accessRestriction === "None"
                    || (item.accessRestriction === "LoginRequired" && !isGuestUser);
            });
            // console.log(JSON.stringify(this.menuItems));
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    toggleNavigation() {
        this.isToggled = !this.isToggled;
    }

    handleNaviation(event) {
        event.stopPropagation();
        event.preventDefault();
        // console.log(this.menuItems.find(item => item.id == id));
        const { type, target, defaultListViewId } = this.menuItems.find(item => item.id == event.detail);

        // get the correct PageReference object for the nav menu item type
        if (type === 'SalesforceObject') {
            // aka "Salesforce Object" menu item type
            this.pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: target
                },
                state: {
                    filterName: defaultListViewId
                }
            };
        } else if (type === 'InternalLink') {
            // aka "Community Page" menu item type

            // WARNING: Normally you shouldn't use 'standard__webPage' for internal relative targets, but
            // we don't have a way of identifying the PageReference type of an InternalLink URL
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: basePath + target
                }
            };
        } else if (type === 'ExternalLink') {
            // aka "External URL" menu item type
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: target
                }
            };
        }

        // use the NavigationMixin from lightning/navigation to generate the URL for navigation. 
        if (this.pageReference) {
            this[NavigationMixin.GenerateUrl](this.pageReference)
                .then(url => {
                    this.href = url;
                });
            this[NavigationMixin.Navigate](this.pageReference);
        }
    }

    get navigationClass() {
        return this.isToggled ? "navigation active" : "navigation";
    }

    get toggleClass() {
        return this.isToggled ? "toggle active" : "toggle";
    }

    get optionList() {
        return this.menuItems.map(item => {
            return {
                value: item.id,
                label: item.label,
                isChecked: false,
                showImage: item.isImgValid,
                imgUrl: item.imgUrl

            };
        });
    }

}