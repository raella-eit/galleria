import { LightningElement, wire } from 'lwc';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import { handleError, showToast } from 'c/sharedJSCode';
import { NavigationMixin } from 'lightning/navigation';
import LANG from '@salesforce/i18n/lang';
import LOADING from '@salesforce/label/c.LOADING';
import NO_RESULT_FOUND_MSG from "@salesforce/label/c.NO_RESULT_FOUND_MSG";
import SHOW_MORE_BTN_LBL from "@salesforce/label/c.SHOW_MORE_BTN_LBL";
import MY_RESERVATIONS_TITLE from "@salesforce/label/c.MY_RESERVATIONS_TITLE";
import ALL_EVENTS_BTN_LBL from "@salesforce/label/c.ALL_EVENTS_BTN_LBL";
import EVENTS_TITLE from '@salesforce/label/c.EVENTS_TITLE';
import RegistrationCancelationSuccess_LBL from "@salesforce/label/c.RegistrationCancelationSuccess_LBL";
import getContactId from "@salesforce/apex/UserUtils.getContactId";
import getAttendeeList from "@salesforce/apex/MyReservationListController.getAttendeeList";
import deleteAttendee from "@salesforce/apex/MyReservationListController.deleteAttendee";
const p2_bdhighlight = 'p-2 bd-highlight';
const p2_flex_bdhighlight = 'p-2 flex-grow-1 bd-highlight';
export default class MyReservationList extends NavigationMixin(LightningElement) {
    isLoading = true;
    appLang = LANG;
    labels = {
        SHOW_MORE_BTN_LBL: SHOW_MORE_BTN_LBL,
        TITLE: MY_RESERVATIONS_TITLE,
        LOADING: LOADING,
        NO_RESULT_FOUND_MSG: NO_RESULT_FOUND_MSG,
        ALL_EVENTS_BTN_LBL: ALL_EVENTS_BTN_LBL + ' ' + EVENTS_TITLE
    };

    reservations = [];

    handleGoToEvents(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'event-list'
            }
        });
    }

    handleEventSelection(event) {
        let id = event.currentTarget.dataset.item;
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

    @wire(getContactId, {}) wiredContactId({ error, data }) {
        if (data) {
            getAttendeeList({ contactId: data }).then(result => {
                this.reservations = result;
                if (this.reservations && this.reservations.length > 0) {
                    console.log(this.reservations);
                    if (LANG === "ar") {
                        this.reservations = this.reservations.map(r => {
                            return {
                                ...r,
                                name: r.B2C_Promo_Schedule__r.Content_Management__r.B2C_Promo_Name_Ar__c ? r.B2C_Promo_Schedule__r.Content_Management__r.B2C_Promo_Name_Ar__c : r.B2C_Promo_Schedule__r.Content_Management__r.Name

                            };
                        });
                    } else {
                        this.reservations = this.reservations.map(r => {
                            return {
                                ...r,
                                name: r.B2C_Promo_Schedule__r.Content_Management__r.Name

                            };
                        });
                    }
                }
                this.isLoading = false;
            }).catch(reservationError => {
                showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
                handleError(reservationError);
                this.isLoading = false;
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    }

    handleReservationDelete(event) {
        event.preventDefault();
        event.stopPropagation();
        let id = event.currentTarget.dataset.item;
        deleteAttendee({ attendeeId: id }).then(() => {
            this.reservations = this.reservations.filter(att => att.Id != id);
            showToast('Success', RegistrationCancelationSuccess_LBL, 'success', this);
        }).catch(error => {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error.body);
        });
    }
}