import { LightningElement, wire, track } from 'lwc';
import { showToast, handleError } from 'c/sharedJSCode';
import lang from '@salesforce/i18n/lang';

import PARKING_TITLE from '@salesforce/label/c.PARKING_TITLE';
import PARKING_AVAILABLE from '@salesforce/label/c.PARKING_AVAILABLE';
import PARKING_PAGE_DESCRIPTION from '@salesforce/label/c.PARKING_PAGE_DESCRIPTION';
import PARKING_EAST from '@salesforce/label/c.PARKING_EAST';
import PARKING_WEST from '@salesforce/label/c.PARKING_WEST';
import PARKING_SUBTITE_DETAILS from '@salesforce/label/c.PARKING_SUBTITE_DETAILS';
import PARKING_LEVEL from '@salesforce/label/c.PARKING_LEVEL';
import PARKING_ZONE from '@salesforce/label/c.PARKING_ZONE';
import GENERIC_ERROR_MESSAGE from '@salesforce/label/c.GENERIC_ERROR_MESSAGE';
import PARKING_SHOWMORE from '@salesforce/label/c.PARKING_SHOWMORE';
import DETAILS from '@salesforce/label/c.DETAIL_LABEL';
import FIRST_PARKING_LBL from "@salesforce/label/c.FIRST_PARKING_LBL";
import SECOND_PARKING_LBL from "@salesforce/label/c.SECOND_PARKING_LBL";
import THIRD_PARKING_LBL from "@salesforce/label/c.THIRD_PARKING_LBL";
import FOURTH_PARKING_LBL from "@salesforce/label/c.FOURTH_PARKING_LBL";

import PARKING_WEST_IMG from '@salesforce/resourceUrl/PARKING_WEST_IMG';
import PARKING_EAST_IMG from '@salesforce/resourceUrl/PARKING_EAST_IMG';

import getParkingInfo from '@salesforce/apex/Parking_Manager.getParkingInfo';

export default class AvailableParkingSlots extends LightningElement {

    labels = {
        pageTitle: PARKING_TITLE,
        pageDescription: PARKING_PAGE_DESCRIPTION,
        eastParkingName: PARKING_EAST,
        westParkingName: PARKING_WEST,
        available: PARKING_AVAILABLE,
        subtitle: PARKING_SUBTITE_DETAILS,
        level: PARKING_LEVEL,
        zone: PARKING_ZONE,
        showMore: PARKING_SHOWMORE
    };

    PARKING_WEST_IMG = PARKING_WEST_IMG;
    PARKING_EAST_IMG = PARKING_EAST_IMG;


    westParkingItems = [];
    eastParkingItems = [];

    parkingDetailItems = [];

    @track showDetails = false;

    appLang = lang;

    eastSelected = false;

    get alignClass() {
        if (this.appLang == 'ar') {
            return 'col-auto ms-auto';
        }
        else {
            return 'col-auto me-auto';
        }
    }

    parkingdata;
    loaded = false;
    allParkingItems = [];

    connectedCallback() {
        //check if any values were passed in
        if (sessionStorage.getItem('parkingdata')) {
            //An Id key is in the session Storage
            this.parkingdata = sessionStorage.getItem('parkingdata');

            //Clear session storage after getting the Id
            sessionStorage.clear();
        }
        if (!this.parkingdata) {
            getParkingInfo().then(result => {
                sessionStorage.setItem('parkingdata', JSON.stringify(result));
                this.parkingdata = result;
                this.constructData();
            }).catch(error => {
                showToast('Error', GENERIC_ERROR_MESSAGE, 'Error', this);
                handleError(error?.body);
            });
        } else {
            this.parkingdata = JSON.parse(this.parkingdata);
            this.constructData();
        }
    }

    constructData() {
        this.allParkingItems = this.parkingdata.map(elt => {
            return {
                ...elt,
                cardImg: elt.label === PARKING_WEST ? PARKING_WEST_IMG : PARKING_EAST_IMG,
                percentageStyle: 'width: ' + (parseInt(elt.percent) <= 22 ? '22%' : elt.percent + '%')
            };
        });
    }

    showImage(event) {
        event.target.classList.remove('d-none');
        event.target.classList.add('fadeIn');
    }

    toggleParkingDetails(event) {
        this.showDetails = true;
        let selected = this.allParkingItems.find(elt => elt.id == event.target.dataset.item);
        this.parkingDetailItems = selected.details.map(elt => {
            return {
                ...elt,
                percentageStyle: 'width: ' + (parseInt(elt.percent) <= 22 ? '22%' : elt.percent + '%')
            };
        });
        this.eastSelected = selected.label !== PARKING_WEST;
        this.labels.subtitle = selected.label;
        this.labels.subtitle += ' ' + DETAILS;
    }

    get detailsByLevel() {
        let floors = [];
        this.parkingDetailItems.forEach(elt => {
            let fl = floors.find(floor => floor.name === elt.floor);
            if (!fl) {
                fl = {
                    name: elt.floor,
                    details: []
                };
                floors.push(fl);
            }
            fl.details.push(elt);
        });
        floors.sort(GetSortOrder("name", this.eastSelected));
        floors.forEach(fl => {
            fl.details.sort(GetSortOrder("id", false));
            let name = this.labels.level + " " + fl.name;
            if (this.eastSelected) {
                switch (fl.name) {
                    case "P4":
                        name = fl.name + " (" + FIRST_PARKING_LBL + " " + this.labels.level + ")";
                        break;
                    case "P3":
                        name = fl.name + " (" + SECOND_PARKING_LBL + " " + this.labels.level + ")";
                        break;
                    case "P2":
                        name = fl.name + " (" + THIRD_PARKING_LBL + " " + this.labels.level + ")";
                        break;
                    case "P1":
                        name = fl.name + " (" + FOURTH_PARKING_LBL + " " + this.labels.level + ")";
                        break;
                }
            }
            fl["displayLabel"] = name;
        });
        return floors;
    }

}

function GetSortOrder(prop, inverse) {
    return function (a, b) {
        if ((a[prop] > b[prop] && !inverse) || (inverse && a[prop] <= b[prop])) {
            return 1;
        } else if ((a[prop] < b[prop] && !inverse) || (inverse && a[prop] >= b[prop])) {
            return -1;
        }
        return 0;
    };
}