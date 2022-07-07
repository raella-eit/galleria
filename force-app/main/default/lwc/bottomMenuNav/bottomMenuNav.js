import { LightningElement, track, wire } from 'lwc';
import IconAssets from '@salesforce/resourceUrl/Bottom_Nav_Icons';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import getNavigationItems from '@salesforce/apex/NavigationItemsController.getLocalizedNavigationItems';
import isGuestUser from '@salesforce/user/isGuest';

export default class BottomMenuNav extends NavigationMixin(LightningElement) {

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
        // this.urlLanguage = this.urlStateParameters.language;
    }

    menuName = 'Bottom Navigation Menu';
    @track menuItems = [];
    @track isLoaded = false;
    @track error = false;
    pageReference;
    publishStatus = ['--preview.', '--live.'].includes(window.Location.href) ? 'Draft' : 'Live';
    isOpen = false;
    @wire(getNavigationItems, {
        menuName: '$menuName',
        publishStatus: '$publishStatus',
        isGuestUser: '$guest',
        language: '$urlLanguage'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            this.menuItems = data.map((item, index) => {
                return {
                    target: item.target,
                    id: index.toString(),
                    label: item.labelEN,
                    defaultListViewId: item.defaultListViewId,
                    type: item.type,
                    accessRestriction: item.accessRestriction,
                    icon: IconAssets + "/" + item.labelEN.replace(/\s+/g, '') + ".png"
                };
            }).filter(item => {
                // Only show "Public" items if guest user
                return item.accessRestriction === "None"
                    || (item.accessRestriction === "LoginRequired" && !isGuestUser);
            });
            this.error = false;
            this.isLoaded = true;
        } else if (error) {
            this.error = true;
            this.menuItems = [];
            this.isLoaded = true;
        }
    }
    handleMenuSelection(event) {
        // console.log(event.currentTarget.dataset.name);
        event.stopPropagation();
        event.preventDefault();
        let target = event.currentTarget.dataset.target;

        this.pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: basePath + target
            }
        };

        if (this.pageReference) {
            this[NavigationMixin.GenerateUrl](this.pageReference)
                .then(url => {
                    this.href = url;
                });
            this[NavigationMixin.Navigate](this.pageReference);
        }
    }

    toggleMenu() {
        this.isOpen = !this.isOpen;
    }

}