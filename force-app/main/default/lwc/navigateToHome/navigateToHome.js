import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import IconAssets from '@salesforce/resourceUrl/Bottom_Nav_Icons';
import NAVIGATE_TO_HOME_LBL from "@salesforce/label/c.NAVIGATE_TO_HOME_LBL";
export default class NavigateToHome extends NavigationMixin(LightningElement) {
    homeIcon = IconAssets + '/Home_Bot.png';
    label = NAVIGATE_TO_HOME_LBL;
    navigateHome() {
        window.location.href = "/b2c";
    }

}