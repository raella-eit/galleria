import { LightningElement, api, wire, track } from 'lwc';
import getShop from "@salesforce/apex/ShopDetailController.getShop";
import findStore from "@salesforce/apex/wayFinding.findStore";
import getUrl from '@salesforce/apex/CommunityUtilities.getUrl';
import LANG from '@salesforce/i18n/lang';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import DETAIL_LABEL from "@salesforce/label/c.DETAIL_LABEL";
import ABOUT_LABEL from "@salesforce/label/c.ABOUT_LABEL";
import DIRECTION_LABEL from "@salesforce/label/c.Direction_label";
import CONTACT from '@salesforce/label/c.CONTACT';
import LOCATION from '@salesforce/label/c.LOCATION';
import PARK_NEAR from '@salesforce/label/c.PARK_NEAR';
import HOURS from '@salesforce/label/c.HOURS';
import LOGO_IMG from '@salesforce/resourceUrl/ACT_LogoPlaceholder';
import STORE_IMG from '@salesforce/resourceUrl/ACT_StoreImgPlaceholder';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, showToast } from 'c/sharedJSCode';
import IS_GUEST from '@salesforce/user/isGuest';
import existsLocationInfo from '@salesforce/apex/ShopDetailController.existsLocationIfo';
import CLOSE_BTN_LBL from "@salesforce/label/c.CLOSE_BTN_LBL";
import START_BTN_LBL from "@salesforce/label/c.START_BTN_LBL";
import WF_CONFIRM_DIALOG_LBL from "@salesforce/label/c.WF_CONFIRM_DIALOG_LBL";
import Id from '@salesforce/user/Id';
const wayFindingApi = 'Wayfinding_URL';

export default class ShopDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    showModal = false;
    fromId;
    toId;
    url;
    label = {
        DETAIL_LABEL,
        ABOUT_LABEL,
        DIRECTION_LABEL,
        CONTACT,
        LOCATION,
        PARK_NEAR,
        HOURS,
        CLOSE_BTN_LBL,
        WF_CONFIRM_DIALOG_LBL,
        START_BTN_LBL
    };
    isGuest = IS_GUEST;
    showDirection = false;

    @track shop = {};
    @track showDetails = true;
    @track showAbout = false;

    iframeCls = "iframe-dimensions";

    handleDetailBtnClick(event) {
        this.showDetails = true;
        this.showAbout = false;
    }

    handleAboutBtnClick(event) {
        this.showDetails = false;
        this.showAbout = true;
    }

    @wire(existsLocationInfo, { shopId: '$recordId' })
    hasLocationInfo({ error, data }) {
        console.log('elie has location');
        if (data) {
            this.locate(true);
        }
    }

    locate(updateUrl) {
        console.log('elie locate', updateUrl);
        findStore({ storeId: this.recordId, isGuest: this.isGuest })
            .then(data => {
                console.log('ada', data);
                this.showDirection = true;
                if (updateUrl) {
                    getUrl({ urlName: wayFindingApi })
                        .then(result => {
                            this.url = result;
                            this.toId = data.toId;
                            this.fromId = data.fromId;
                        })
                        .catch(error => {
                            handleError(error?.body);
                        });
                } else {
                    console.log(data);
                    this.toId = data.toId;
                    this.fromId = data.fromId;
                }
            })
            .catch(error => {
                console.log(error);
                handleError(error?.body);
            });
    }

    @wire(getShop, { shopId: "$recordId" }) wiredShop({ error, data }) {
        if (data) {
            if (this.isArabic) {
                this.shop = {
                    title: data.titleAr ? data.titleAr : data.title,
                    description: data.descriptionAr ? data.descriptionAr : data.description,
                    imgSrc: data.imgSrc ? data.imgSrc : LOGO_IMG,
                    storeImgSrc: data.storeImgSrc ? data.storeImgSrc : STORE_IMG,
                    dates: data.dates,
                    parkingDescription: data.parkingDescription,
                    phone: data.phone
                };
            } else {
                this.shop = {
                    title: data.title,
                    description: data.description,
                    imgSrc: data.imgSrc ? data.imgSrc : LOGO_IMG,
                    storeImgSrc: data.storeImgSrc ? data.storeImgSrc : STORE_IMG,
                    subDescription: data.subDescription,
                    parkingDescription: data.parkingDescription,
                    phone: data.phone,
                    dates: data.dates
                };
            }

        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }


    handleClick(event) {
        event.preventDefault();
        this.locate(false);
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    onSelection(event) {
        this.fromId = event.detail.start;
        // console.log(JSON.stringify(event.detail.messageObj));
        // console.log(this.template.querySelector(".iframe-dimensions").contentWindow.postMessage(event.detail.messageObj.data,"*"))
        // this.template.querySelector(".iframe-dimensions").contentWindow.postMessage(event.detail.messageObj,"*");
    }

    redirectToWayfinding() {

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: this.finalUrl
        //     },
        // });
        // this.iframeCls = "iframe-dimensions";
        // this.showModal = false;
        var messageObj = {};
        messageObj.data = {};
        messageObj.action = 'mapit';
        messageObj.data.from = this.fromId;
        messageObj.data.to = this.toId;
        messageObj.data.step = null;
        messageObj.data.hideYouAreHere = 'yes';
        const evt = new CustomEvent("mapit", {
            detail: { messageObj },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(evt);
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }

    get finalUrl() {
        return this.url + '?from=' + this.fromId + '&to=' + this.toId + '&hideYouAreHere=yes';
    }

    get imgCls() {
        return "img-div-sizing flex-shrink-0 " + (this.isArabic ? "ms-3" : "me-3");
    }

    get isArabic() {
        return LANG === "ar";
    }
    get testUser() {
        return Id === "0053W000002fpGpQAI";
    }
}