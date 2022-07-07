import { LightningElement, wire } from 'lwc';
import getUrl from '@salesforce/apex/CommunityUtilities.getUrl';
import B2B_INCIDENT_MGMT_IMG from '@salesforce/resourceUrl/B2B_INCIDENT_MGMT_IMG';
import { handleError } from 'c/sharedJSCode';

const INCIDENT_MGMT_URL = 'INCIDENT_MGMT_URL';
export default class RetailerHandbook extends LightningElement {
    B2B_INCIDENT_MGMT_IMG = B2B_INCIDENT_MGMT_IMG;
    incidentMgmt_pdf_publicLink;

    handleClick() {
        if (this.incidentMgmt_pdf_publicLink) {
            window.open(this.incidentMgmt_pdf_publicLink);
        }
    }

    @wire(getUrl, { urlName: INCIDENT_MGMT_URL })
    getPdfPublicLink({ error, data }) {
        if (data) {
            this.incidentMgmt_pdf_publicLink = data;
        } else if (error) {
            handleError(error?.body);
        }
    }
}