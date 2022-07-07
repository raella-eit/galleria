import { LightningElement, track, wire } from 'lwc';
import getUrl from '@salesforce/apex/CommunityUtilities.getUrl';
import B2B_ARTICLES_IMG from '@salesforce/resourceUrl/B2B_ARTICLES_IMG';
import { handleError } from 'c/sharedJSCode';

const FAQ_PDF_URL = 'FAQ_PDF_URL';
export default class RetailerHandbook extends LightningElement {
    B2B_ARTICLES_IMG = B2B_ARTICLES_IMG;
    faq_pdf_publicLink;

    handleClick() {
        if (this.faq_pdf_publicLink) {
            window.open(this.faq_pdf_publicLink);
        }
    }

    @wire(getUrl, { urlName: FAQ_PDF_URL })
    getPdfPublicLink({ error, data }) {
        if (data) {
            this.faq_pdf_publicLink = data;
        } else if (error) {
            handleError(error?.body);
        }
    }
}