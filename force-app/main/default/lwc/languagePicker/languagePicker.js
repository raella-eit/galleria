import { LightningElement } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import GENERIC_ERROR_MESSAGE from "@salesforce/label/c.GENERIC_ERROR_MESSAGE";
import { handleError, showToast } from 'c/sharedJSCode';
import GRAssets from "@salesforce/resourceUrl/GRSiteAssets";
import isguest from "@salesforce/user/isGuest";
import changeUserLanguage from "@salesforce/apex/CommunityUtilities.changeUserLanguage";

export default class LanguagePicker extends LightningElement {
    userLanguage = LANG;
    FLAGS = GRAssets + "/GRSiteAssets/images/flags";
    optionList = [{
        label: "English", value: "en_US", i18n: "en-US", icon: `${this.FLAGS + "/us.svg"}#flag-icon-css-us`, languageRedirect: "en_US", menuLabel: 'EN'
    }, {
        label: "العربية", value: "ar", i18n: "ar", icon: `${this.FLAGS + "/ae.svg"}#flag-icon-css-ae`, languageRedirect: "ar", menuLabel: 'AR'
    }];

    selectedOption = this.optionList.find(option => option.i18n == this.userLanguage);

    changeLanguage(event) {
        let languageCode = event.detail;
        let hasLanguageChanged = !this.selectedOption || (this.selectedOption && this.selectedOption.value != languageCode);
        if (hasLanguageChanged) {
            this.selectedOption = this.optionList.find(option => option.value == languageCode);
            if (this.selectedOption) {
                if (!isguest) {
                    changeUserLanguage({ lang: this.selectedOption.value }).then(() => {
                        location.reload();
                    }).catch(error => {
                        console.log(error);
                        showToast("Error", GENERIC_ERROR_MESSAGE, "error");
                        handleError(error);
                    });
                } else {
                    location.search = location.search.replace(/language=[^&$]*/i, 'language=' + this.selectedOption.languageRedirect);
                }
            }
        }
    }
}