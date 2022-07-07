import { LightningElement, wire } from 'lwc';
import { handleError, showToast } from "c/sharedJSCode";
import { NavigationMixin } from 'lightning/navigation';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import LOADING from '@salesforce/label/c.LOADING';
import getFutureEventList from "@salesforce/apex/EventListController.getFutureEventList";
import EVENTS_TITLE from '@salesforce/label/c.EVENTS_TITLE';
import NO_RESULT_FOUND_MSG from "@salesforce/label/c.NO_RESULT_FOUND_MSG";
import lang from '@salesforce/i18n/lang';
const step = 10;
export default class EventList extends NavigationMixin(LightningElement) {
    labels = {
        EVENTS_TITLE: EVENTS_TITLE,
        NO_RESULT_FOUND_MSG: NO_RESULT_FOUND_MSG,
        LOADING: LOADING
    };

    eventItems = [];
    initialEvents = [];
    rowLimit = step;
    rowOffSet = 0;

    isLoading = true;

    appLang = lang;
    
    get alignClass () {
        if(this.appLang == 'ar'){
            return 'col-auto ms-auto mt-2';
        }
        else{
           return 'col-auto me-auto mt-2';
        }
    }

    /**
     * Retrieve the list of events to be displayed 
     */
    @wire(getFutureEventList, {
        limitSize: "$rowLimit",
        offset: "$rowOffSet"
    }) upcommingEventList({ error, data }) {
        if (data) {
            var loadMore = data.length <= this.rowLimit && data.length != 0;
            data.map(element => {
                let titleAR = element.titleAr ? element.titleAr : element.title;
                let descriptionAR = element.descriptionAr ? element.descriptionAr : element.description; 
                this.initialEvents =
                    [...this.initialEvents,
                    {
                        id: element.id,
                        imgSrc: element.imgSrc,
                        title: this.appLang == 'ar' ? titleAR : element.title,
                        subDescription: element.subDescription,
                        parentName: element.parentName,
                        dates: element.dates,
                        description: this.appLang == 'ar' ?  descriptionAR : element.description,
                        parentId: element.parentId,
                        parentName: element.parentName,
                        objectType: element.objectType 
                    }
                    ]
            });
            this.eventItems = this.initialEvents;
            if (loadMore) {
                this.rowOffSet += step;
            }
            this.isLoading = false;
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
        }
    }
    /**
     * Navigate the user to the event detail page when they select and offer
     */
    handleEventSelection(event) {
        let itemId = event.detail.item;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'event-detail'
            },
            //Set URL parameters
            state: {
                recordId: itemId
            }
        });
    }

}