import { LightningElement } from 'lwc';
import CLIENT_INVITATION_SECTION_TITLE from "@salesforce/label/c.CLIENT_INVITATION_SECTION_TITLE";
import CLIENT_INVITATION_SECTION_DESCRIPTION from "@salesforce/label/c.CLIENT_INVITATION_SECTION_DESCRIPTION";
import CLIENT_INVITATION_SECTION_BTN_LBL from "@salesforce/label/c.CLIENT_INVITATION_SECTION_BTN_LBL";
import CLIENT_INVITATION_SECTION_BACKGROUND from "@salesforce/resourceUrl/CLIENT_INVITATION_SECTION_BACKGROUND";
import { NavigationMixin } from 'lightning/navigation';

export default class ClientInvitationSection extends NavigationMixin(LightningElement) {
    labels = {
        CLIENT_INVITATION_SECTION_TITLE: CLIENT_INVITATION_SECTION_TITLE,
        CLIENT_INVITATION_SECTION_DESCRIPTION: CLIENT_INVITATION_SECTION_DESCRIPTION,
        CLIENT_INVITATION_SECTION_BTN_LBL: CLIENT_INVITATION_SECTION_BTN_LBL
    };

    background = CLIENT_INVITATION_SECTION_BACKGROUND;

    renderedCallback() {
        document.body.style.setProperty("--custom-bg-url", 'url("' + window.location.origin + this.background + '")');
    }
    onClickLogin(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            },
        });
    }
}