import { LightningElement, api } from 'lwc';

export default class LoadingSpinner extends LightningElement {
    @api isSpinnerVisible;
    @api size;
    @api altText;
}