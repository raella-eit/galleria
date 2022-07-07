import { LightningElement, wire, track, api } from 'lwc';
import { showToast, handleError } from 'c/sharedJSCode';
import { refreshApex } from '@salesforce/apex';
import IS_GUEST_USER from '@salesforce/user/isGuest';
import getReservationsList from '@salesforce/apex/UtilityItemReservationController.getReservationsList';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import UIR_MY_BOOKED_ITEMS from '@salesforce/label/c.UIR_MY_BOOKED_ITEMS';
import UIR_WHEELCHAIR_PLACEHOLDER_IMG from '@salesforce/resourceUrl/UIR_WHEELCHAIR_PLACEHOLDER_IMG';
import UIR_STROLLER_PLACEHOLDER_IMG from '@salesforce/resourceUrl/UIR_STROLLER_PLACEHOLDER_IMG';
import UIR_SHOPPER_PLACEHOLDER_IMG from '@salesforce/resourceUrl/UIR_SHOPPER_PLACEHOLDER_IMG';
import UIR_GENERIC_ITEM_PLACEHOLDER_IMG from '@salesforce/resourceUrl/UIR_GENERIC_ITEM_PLACEHOLDER_IMG';
import deleteReservation from '@salesforce/apex/UtilityItemReservationController.deleteReservation';
import DELETE from '@salesforce/label/c.DELETE';
import CANCEL from '@salesforce/label/c.CANCEL';
import UIR_DIALOG_HEADER from '@salesforce/label/c.UIR_DIALOG_HEADER';
import UIR_DIALOG_CONTENT from '@salesforce/label/c.UIR_DIALOG_CONTENT';
import UIR_CONFIRM_DELETE from '@salesforce/label/c.UIR_CONFIRM_DELETE';
import UIR_DELETE_SUCCESS from '@salesforce/label/c.UIR_DELETE_SUCCESS';
import UIR_WHEELCHAIR from '@salesforce/label/c.UIR_WHEELCHAIR';
import UIR_STROLLER from '@salesforce/label/c.UIR_STROLLER';
import UIR_SHOPPER from '@salesforce/label/c.UIR_SHOPPER';

export default class ItemReservationList extends LightningElement {
    @track results = [];
    @track wiredResult = [];
    labels = {
        listTitle: UIR_MY_BOOKED_ITEMS,
        delete: DELETE,
        dialog_headerTitle: UIR_DIALOG_HEADER,
        dialog_content: UIR_DIALOG_CONTENT,
        dialog_cancel: CANCEL,
        dialog_confirm: UIR_CONFIRM_DELETE 
    }
    isGuestUser = IS_GUEST_USER;

    @wire(getReservationsList, { isGuest: '$isGuestUser' })
    retrieveReservations(resp) {
        this.wiredResult = resp;
        if (resp.data) {
            if (resp.data.length > 0) {
                try {
                    this.results = resp.data.map(element => {
                        let url = '';
                        switch (element.type) {
                            case UIR_WHEELCHAIR:
                                url = UIR_WHEELCHAIR_PLACEHOLDER_IMG;
                                break;
                            case UIR_STROLLER:
                                url = UIR_STROLLER_PLACEHOLDER_IMG;
                                break;
                            case UIR_SHOPPER:
                                url = UIR_SHOPPER_PLACEHOLDER_IMG
                                break;
                            default:
                                url = UIR_GENERIC_ITEM_PLACEHOLDER_IMG;
                        }
                        return {
                            reservationId: element.id,
                            reservationCode: element.name,
                            item: element.type,
                            reservationDay: element.day,
                            reservationTime: element.resTime,
                            logo: url
                        }
                    });
                } catch (error) {
                    handleError(error?.body);
                }
            } else {
                this.results = undefined;
            }
        } else if (resp.error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
            handleError(resp.error?.body);
            this.results = undefined;
        }
    }

    @api
    refreshList() {
        refreshApex(this.wiredResult);
    }

    resId;

    openDialog(event) {
        this.resId = event.target.value;
        this.template.querySelector('c-generic-confirmation-dialog').toggleModal();
    }

    deleteReservation(event) {
        deleteReservation({ reservationId: this.resId })
            .then(data => {
                showToast('Success', UIR_DELETE_SUCCESS, 'Success', this);
                this.template.querySelector('c-generic-confirmation-dialog').toggleModal();
                this.refreshList();
            })
            .catch(error => {
                showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
                handleError(error?.body);
            })
    }

}