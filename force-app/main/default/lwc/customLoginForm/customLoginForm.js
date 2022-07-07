import { LightningElement, track } from 'lwc';
import { handleError } from 'c/sharedJSCode';
import { NavigationMixin } from 'lightning/navigation';
import doLogin from '@salesforce/apex/CommunityUtilities.doLogin';
import LOGIN_FORGOT_PASSWORD from '@salesforce/label/c.LOGIN_FORGOT_PASSWORD';
import LOGIN_REGISTER from '@salesforce/label/c.LOGIN_REGISTER';
import LOGIN from '@salesforce/label/c.LOGIN';

export default class CustomLoginForm extends NavigationMixin(LightningElement) {
    username;
    password;
    @track errorCheck;
    @track errorMessage;

    labels = {
        forgotPassword: LOGIN_FORGOT_PASSWORD,
        register: LOGIN_REGISTER,
        login: LOGIN
    }

    handleUserNameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin(event) {
        if (this.username && this.password) {
            event.preventDefault();
            event.stopPropagation();
            doLogin({
                username: this.username,
                password: this.password
            })
                .then((result) => {
                    window.location.href = result;
                })
                .catch((error) => {
                    this.errorCheck = true;
                    this.errorMessage = error.body.message;
                    handleError(error?.body);
                });
        }
    }

    get baseUrl() {
        return 'https://' + location.host + '/b2c/';
    }

    handleForgotPassword(event) {
        event.preventDefault();
        event.stopPropagation();
        window.open(this.baseUrl + 's/login/ForgotPassword', '_self');
    }

    handleRegister(event) {
        event.preventDefault();
        event.stopPropagation();
        window.open(this.baseUrl + 'secur/CommunitiesSelfRegUi', '_self');
    }
}