import { LightningElement, wire } from 'lwc';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import TOP_EVENTS_SECTION_TITLE from "@salesforce/label/c.TOP_EVENTS_SECTION_TITLE";
import ALL_EVENTS_BTN_LBL from "@salesforce/label/c.ALL_EVENTS_BTN_LBL";
import { handleError, showToast } from "c/sharedJSCode";
import { NavigationMixin } from 'lightning/navigation';
import getEventsList from "@salesforce/apex/EventListController.getFutureEventList";
const step = 4;
export default class TopShops extends NavigationMixin(LightningElement) {
    labels = {
        TOP_EVENTS_SECTION_TITLE: TOP_EVENTS_SECTION_TITLE,
        ALL_EVENTS_BTN_LBL: ALL_EVENTS_BTN_LBL
    };
    rowLimit = step;
    rowOffSet = 0;
    eventItems = [];

    @wire(getEventsList, {
        limitSize: "$rowLimit",
        offset: "$rowOffSet",
    }) futureEventsList({ error, data }) {
        if (data) {
            this.eventItems = data;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }

    handleEventSelection(event) {
        let id = event.detail.item;
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'event-detail'
            },
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
                pageName: 'event-list'
            }
        });
    }
}