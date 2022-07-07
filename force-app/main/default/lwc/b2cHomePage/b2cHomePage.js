import { LightningElement, wire } from 'lwc';
import isguest from "@salesforce/user/isGuest";
import getParkingInfo from '@salesforce/apex/Parking_Manager.getParkingInfo';
export default class B2cHomePage extends LightningElement {
    isGuestUser = isguest;
    @wire(getParkingInfo)
    generalParkingInfo({ error, data }) {
        if (data) {
            sessionStorage.setItem('parkingdata', JSON.stringify(data));
        } else if (error) {
            showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
            handleError(error?.body);
        }
    }


}