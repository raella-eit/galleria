import { LightningElement, api, wire } from 'lwc';
import SEARCH_LABEL from "@salesforce/label/c.SELECT_STARTING_POINT_LBL";
import getShopList from "@salesforce/apex/ShopSearchComboController.getShopList";
import getShop from "@salesforce/apex/ShopSearchComboController.getShop";

export default class ShopSearchCombo extends LightningElement {
    @api toId;
    @api url;
    @api fromId;
    labels = {
        SEARCH_LABEL: SEARCH_LABEL
    };
    searchTerm = "";
    shopResults = [];
    selectedRoom;

    @wire(getShop, { roomId: "$fromId" }) originalShop({ error, data }) {
        if (data) {
            this.select(data);
        }
    };

    handleSearchChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.searchTerm = event.currentTarget.value;
        if (this.searchTerm && this.searchTerm.length >= 2 && !this.selectedRoom) {
            getShopList({ name: this.searchTerm }).then(result => {
                this.shopResults = result;
            }).catch(error => {
                console.log(error);
            });
        } else {
            this.selectedRoom = undefined;
            this.shopResults = [];
        }
    }

    select(shop) {
        this.searchTerm = shop.Name;
        this.selectedRoom = shop.RoomID__c;
        this.shopResults = [];
        this.dispatchEvent(new CustomEvent("mapit", {
            detail: {
                start: this.selectedRoom
            }
        }));
        
    }

    onShopSelection(event) {
        event.stopPropagation();
        event.preventDefault();
        let start = this.shopResults.find(shop => shop.Id === event.currentTarget.dataset.id);
        this.select(start);

    }
}