import { LightningElement, api } from 'lwc';

import IS_GUEST_USER from '@salesforce/user/isGuest';

export default class ItemsReservations extends LightningElement {
    @api hideImage;
    isGuestUser = IS_GUEST_USER;

    openModal() {
        this.template.querySelector('c-new-utility-item-reservation').openModal();
    }

    closeModal() {
        this.template.querySelector('c-new-utility-item-reservation').closeModal();
    }

    refreshData() {
        this.closeModal();
        this.template.querySelector('c-item-reservation-list').refreshList();
    }

}