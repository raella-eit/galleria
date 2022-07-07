import { LightningElement, api, wire } from 'lwc';
import findStore from '@salesforce/apex/wayFinding.findStore';
import { NavigationMixin } from 'lightning/navigation';
import device from '@salesforce/client/formFactor'
import getUrl from '@salesforce/apex/CommunityUtilities.getUrl';
import wayFindingConfirmation from '@salesforce/label/c.wayFindingConfirmation';
import wayFindingConfirmationButton from '@salesforce/label/c.wayFindingConfirmationButton';
import labelError from "@salesforce/label/c.WayFinding_missing_URL";
import { showToast, handleError } from 'c/sharedJSCode';

const wayFindingApi='Wayfinding_URL';
export default class WayFindingDialog extends NavigationMixin(LightningElement) {

    
    htmlLabel = {
        wayFindingConfirmation,
        wayFindingConfirmationButton
    }
    
    @api recordId;
    @api deviceId;
    fromId;
    toId;
    url;



    //Wire service to call find store method in wayFinding apex class passing Account Id as param and returning source & destination ID for Wayfinding URL
    @wire(findStore, { storeId: '$recordId' })
    wiredEvent({ error, data }) {
        if (data) {
            getUrl({ urlName: wayFindingApi})
            .then(result =>{
                this.url=result
                console.log('URL1',this.url);   
            this.toId = data.toId;
            this.fromId=data.fromId;
            this.url  += '?from=' + this.fromId + '&to=' + this.toId;
            })
            .catch(error =>{
                handleError(error?.body)
            })

            
        } else if (error) {
            console.log('error'+JSON.stringify(error));
            handleError(error?.body);
            
        } 
    }

    handleClick() {
        if (this.url) {
            if (device !== 'Large') {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.url
                    }
                });
            } else {
                window.open(this.url);
            }
        } else {
            showToast('Erreur', labelError, 'error', this);
        }
    }
}