import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { showToast, handleError } from 'c/sharedJSCode';
import { refreshApex } from '@salesforce/apex';
import IS_GUEST_USER from '@salesforce/user/isGuest';
import UIR_OBJECT from '@salesforce/schema/UtilityItemReservation__c';
import getReservationsList from '@salesforce/apex/UtilityItemReservationController.getReservationsList';
import UIR_CARD_TITLE from '@salesforce/label/c.UIR_CARD_TITLE';
import UIR_NO_RESERVATIONS_MSG from '@salesforce/label/c.UIR_NO_RESERVATIONS_MSG';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import GUEST_USER_LOGIN_MESSAGE from '@salesforce/label/c.GUEST_USER_LOGIN_MESSAGE';
import NEW from '@salesforce/label/c.NEW';

export default class ItemsReservationsList extends LightningElement {
    @track results = [];
    @track isModalOpen = false;
    @track wiredResult = [];
    isGuestUser = IS_GUEST_USER;
    loginMessage = GUEST_USER_LOGIN_MESSAGE;

    message = UIR_NO_RESERVATIONS_MSG;
    title = UIR_CARD_TITLE;
    label_new = NEW;

    labels = { reservationCode: '', itemType: '', reservationDay: '', reservationTime: '' };

    @wire(getObjectInfo, { objectApiName: UIR_OBJECT })
    uirInfo({ data, error }) {
        if (data) {
            this.labels.reservationCode = data.fields.Name.label;
            this.labels.itemType = data.fields.Type__c.label;
            this.labels.reservationDay = data.fields.Day__c.label;
            this.labels.reservationTime = data.fields.ReservationTime__c.label;
        } else if (error) {
            console.log('this error here');
            showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
            handleError(error?.body);
        }
    }

    @wire(getReservationsList, { isGuest: '$isGuestUser' })
    retrieveReservations(resp) {
        this.wiredResult = resp;
        if (resp.data) {
            if (resp.data.length > 0) {
                this.results = [];
                resp.data.map(element => {
                    this.results =
                    [...this.results,
                        {
                            reservationId: element.Id,
                            reservationCode: element.Name,
                            item: element.Type__c,
                            reservationDay: element.Day__c,
                            reservationTime: element.ReservationTime__c
                        }
                    ]
                });
            } else {
                this.results = undefined;
            }
        } else if (resp.error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
            handleError(resp.error?.body);
            this.results = undefined;
        }
    }

    refreshData() {
        refreshApex(this.wiredResult);
        this.isModalOpen = false;
        console.log(this.results);
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
}