import { LightningElement, wire } from 'lwc';
import { handleError } from "c/sharedJSCode";
import getCarouselItemList from "@salesforce/apex/PromoListController.getCarouselItemList";
import { NavigationMixin } from 'lightning/navigation';
import LEARN_MORE from '@salesforce/label/c.LEARN_MORE';

export default class B2cHomePageCarousel extends NavigationMixin(LightningElement) {
    buttonLabel = LEARN_MORE;
    carouselItems;
    @wire(getCarouselItemList)
    wiredPromos({ error, data }) {
        if (data) {
            this.carouselItems = data;
        } else if (error) {
            handleError(error?.body);
        }
    }

    handleRedirect(event) {
        if (event.detail.type === 'Offer') {
            this.redirect('offer-detail',event.detail.id);
        } else {
            this.redirect('event-detail',event.detail.id);
        }
    }

    redirect(commPageName, id) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: commPageName
            },
            state: {
                recordId: id
            }
        });
    }
}