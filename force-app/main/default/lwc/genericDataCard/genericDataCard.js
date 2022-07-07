import { LightningElement, api } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import SHOW_MORE_BTN_LBL from "@salesforce/label/c.SHOW_MORE_BTN_LBL";
import { NavigationMixin } from 'lightning/navigation';

export default class GenericDataCard extends NavigationMixin(LightningElement) {

    labels = {
        SHOW_MORE_BTN_LBL: SHOW_MORE_BTN_LBL
    };
    userLang = LANG;
    _items = [];

    @api redirect = false;

    @api disableLoadMore = false;

    @api parentRedirect = false;

    @api get items() {
        return this._items;
    }

    set items(value) {
        this._items = value;
    }

    handleClick(event) {
        if (this.redirect) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'shop-detail'
                },
                state: {
                    recordId: event.target.dataset.item
                }
            });
        } else {
            const onClickEvent = new CustomEvent("select", {
                detail: {
                    item: event.target.dataset.item
                }
            });

            this.dispatchEvent(onClickEvent);
        }
    }

    handleScroll(event) {
        event.preventDefault();
        const onLoadMoreEvent = new CustomEvent("loadmore", {
            detail: {
                size: this._items.length
            }
        });
        this.dispatchEvent(onLoadMoreEvent);
    }

    get isLoadMoreVisible() {
        return this.items.length && !this.disableLoadMore;
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }
}