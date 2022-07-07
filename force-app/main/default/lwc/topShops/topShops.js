import { LightningElement, wire } from 'lwc';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import TOP_SHOPS_SECTION_TITLE from "@salesforce/label/c.TOP_SHOPS_SECTION_TITLE";
import ALL_SHOPS_BTN_LBL from "@salesforce/label/c.ALL_SHOPS_BTN_LBL";
import { handleError, showToast } from "c/sharedJSCode";
import { NavigationMixin } from 'lightning/navigation';
import getAccountList from "@salesforce/apex/ShopListController.getAccountList";
import LOGO_IMG from '@salesforce/resourceUrl/ACT_LogoPlaceholder';

const step = 6;
export default class TopShops extends NavigationMixin(LightningElement) {
    labels = {
        TOP_SHOPS_SECTION_TITLE: TOP_SHOPS_SECTION_TITLE,
        ALL_SHOPS_BTN_LBL: ALL_SHOPS_BTN_LBL
    };
    rowLimit = step;
    rowOffSet = 0;
    accountItems = [];

    @wire(getAccountList, {
        limitSize: "$rowLimit",
        offset: "$rowOffSet",
        isFeaturedFirst: true
    }) shopList({ error, data }) {
        if (data) {
            this.accountItems = [];
            data.map(element => {
                this.accountItems =
                    [...this.accountItems,
                    {
                        id: element.id,
                        title: element.title,
                        imgSrc: element.imgSrc ? element.imgSrc : LOGO_IMG,
                    }
                    ];
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }

    handleClick(event) {
        let id = event.target.dataset.item;
        event.preventDefault();
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

    handleLoadMore(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'shop-list'
            }
        });
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }
}