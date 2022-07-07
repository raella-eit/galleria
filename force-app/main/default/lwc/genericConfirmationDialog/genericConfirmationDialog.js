import { LightningElement, api } from 'lwc';
import CLOSE from '@salesforce/label/c.CLOSE';

export default class GenericConfirmationDialog extends LightningElement {
    isModalOpen = false;
    @api headerTitle;
    @api content;
    @api cancelButtonLabel;
    @api confirmButtonLabel;

    label_close = CLOSE;

    handleConfirm () {
        this.dispatchEvent(new CustomEvent('confirm'));
    }

    @api toggleModal() {
        this.isModalOpen = !this.isModalOpen;
    }
}