import { LightningElement, api, wire, track } from 'lwc';
import getLostAndFoundCase from '@salesforce/apex/lostAndFoundCasesController.getLostAndFoundCase';
import LOST_FOUND_TITLE from '@salesforce/label/c.LOST_FOUND_TITLE';
import B2C_CONTACT_US from '@salesforce/label/c.B2C_CONTACT_US';

export default class LostAndFoundRecordForm extends LightningElement {
    
    @api recordId;
    @track error = false;
    @track caseRecord ;
    @track Home_Address__c;
    @track Subject;
    @track Where_Lost__c;
    @track When_Lost__c;
    @track Item_Full_Description__c;
    labels = {
        title: LOST_FOUND_TITLE,
        help: B2C_CONTACT_US
   };
    connectedCallback(){
        console.log('recordId',this.recordId);
    }

    @wire(getLostAndFoundCase, {
        caseId: '$recordId'
    })
    getLostAndFoundCase({ error, data }) {
        
        if (data) {
            console.log('case -> ',data);
            this.caseRecord = data;
            this.Home_Address__c =data.Home_Address__c;
            this.Subject =data.Subject;
            this.Where_Lost__c =data.Where_Lost__c;
            this.When_Lost__c =data.When_Lost__c;
            this.Item_Full_Description__c =data.Item_Full_Description__c;
            this.error = false;
        } else if (error) {
            console.log('error',error);
        }

    }
}