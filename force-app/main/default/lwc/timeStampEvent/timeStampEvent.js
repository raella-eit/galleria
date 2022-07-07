import { LightningElement, api, wire, track } from 'lwc';
import getEventTimes from "@salesforce/apex/TimeStampEventController.getEventTimes";
import getContactId from "@salesforce/apex/UserUtils.getContactId";
import SAVE from '@salesforce/label/c.SAVE';
import Agree_BTN_LBL from '@salesforce/label/c.Agree_BTN_LBL';
import LOADING from '@salesforce/label/c.LOADING';
import ALL_EVENTS_BTN_LBL from "@salesforce/label/c.ALL_EVENTS_BTN_LBL";
import EVENTS_TITLE from '@salesforce/label/c.EVENTS_TITLE';
import MY_RESERVATIONS_TITLE from "@salesforce/label/c.MY_RESERVATIONS_TITLE";
import EventReservationSelectionRequired_ERR_MSG from '@salesforce/label/c.EventReservationSelectionRequired_ERR_MSG';
import CANCEL from '@salesforce/label/c.CANCEL';
import Event_Registration_Success_LBL from "@salesforce/label/c.Event_Registration_Success_LBL";
import { NavigationMixin } from 'lightning/navigation';
import createAttendee from '@salesforce/apex/TimeStampEventController.createAttendee';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import UserReservedAllSessions_MSG from "@salesforce/label/c.UserReservedAllSessions_MSG";
import { handleError, showToast } from 'c/sharedJSCode';
import LANG from '@salesforce/i18n/lang';
export default class TimeStampEvent extends NavigationMixin(LightningElement) {

    @api recordId;
    isLoading = true;
    labels = {
        save: SAVE,
        cancel: CANCEL,
        accept: Agree_BTN_LBL,
        noMoreReservationsForYou: UserReservedAllSessions_MSG,
        LOADING: LOADING,
        ALL_EVENTS_BTN_LBL: ALL_EVENTS_BTN_LBL + ' ' + EVENTS_TITLE,
        MY_RESERVATIONS_TITLE: MY_RESERVATIONS_TITLE
    };
    schedule_id = '';
    @track eventDetail = {
        isMultiDate: false
    };
    dayOptions = [];
    error = '';
    _selectedDay;
    set selectedDay(value) {
        this._selectedDay = value;

        if (!this.eventDetail.isMultiDate) {
            this.timeOptions = this.eventDetail.days.find(d => d.day == this.selectedDay)?.times.map(t => {
                return { label: t.display, value: t.id };
            });
            this.selectedTime = this.timeOptions.length > 0 ? this.timeOptions[0].value : undefined;
        }
    }

    get selectedDay() {
        return this._selectedDay;
    }

    @track timeOptions = [];
    @track selectedTime = [];
    @track attendee = {};
    @track showFullBookingMessage = false;

    @wire(getContactId, {}) wiredContactId({ error, data }) {
        if (data) {
            getEventTimes({ recordId: this.recordId, contactId: data }).then(result => {
                this.eventDetail = result;
                if (this.eventDetail.days) {
                    if (LANG === "ar") {
                        this.eventDetail = {
                            ...this.eventDetail,
                            name: this.eventDetail.namear ? this.eventDetail.namear : this.eventDetail.name,
                            description: this.eventDetail.descriptionar ? this.eventDetail.descriptionar : this.eventDetail.description,
                            waiver: this.eventDetail.waiverar ? this.eventDetail.waiverar : this.eventDetail.waiver
                        };
                    }
                    this.schedule_id = this.eventDetail.id;
                    this.dayOptions = this.eventDetail.days.map(day => {
                        return { label: day.day, value: day.day };
                    });
                    if (!this.eventDetail.isMultiDate) {
                        this.selectedDay = this.dayOptions.length > 0 ? this.dayOptions[0].value : undefined;
                    }
                    this.showFullBookingMessage = false;
                } else {
                    this.showFullBookingMessage = true;
                }
                this.isLoading = false;
            }).catch(retrieveError => {
                showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
                handleError(retrieveError.body);
                this.isLoading = false;
            });
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
            handleError(error?.body);
            this.isLoading = false;
        }
    }

    handleDayChange(event) {
        event.stopPropagation();
        event.preventDefault();
        this.selectedDay = event.target.value;
    }

    handleTimeChange(event) {
        event.stopPropagation();
        event.preventDefault();
        this.selectedTime = event.target.value;
    }

    handleTimeSelection(event) {
        event.stopPropagation();
        event.preventDefault();
        if (this.selectedTime.find(t => t == event.target.value)) {
            this.selectedTime = this.selectedTime.filter(t => t != event.target.value);
        } else {
            this.selectedTime.push(event.target.value);
        }
    }


    submitDetails() {
        if (this.selectedTime.length) {
            createAttendee({ scheduleIdList: this.selectedTime })
                .then(() => {
                    showToast('Success', Event_Registration_Success_LBL, 'success', this);
                    this.handleClose();
                })
                .catch(error => {
                    showToast('Error', GENERIC_ERROR_MESSAGE, 'error', this);
                    handleError(error.body);
                });
        } else {
            showToast('Error', EventReservationSelectionRequired_ERR_MSG, 'error', this);
        }

    }


    handleClose() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'event-detail'
            },
            state: {
                recordId: this.recordId,
            }
        });
    }

    handleGoToEvents(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'event-list'
            }
        });
    }

    handleGoToMyReservations(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-reservations'
            }
        });
    }


}