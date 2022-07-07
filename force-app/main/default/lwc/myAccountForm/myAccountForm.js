import { LightningElement, api, track, wire } from 'lwc';
import { showToast } from 'c/sharedJSCode';
import STORE_IMG_UPLOAD_LBL from '@salesforce/label/c.STORE_IMG_UPLOAD_LBL';
import STORE_LOGO_UPLOAD_LBL from '@salesforce/label/c.STORE_LOGO_UPLOAD_LBL';
import NO_FILES_SELECTED_ERR_MSG from '@salesforce/label/c.NO_FILES_SELECTED_ERR_MSG';
import LOADING_TXT from '@salesforce/label/c.LOADING_UPLOAD';

import saveFiles from '@salesforce/apex/FilesManagerController.saveFiles';
import canManageFiles from '@salesforce/apex/FilesManagerController.canManageFiles';

export default class MyAccountForm extends LightningElement {
    @api recordId;

    @track showFileUpload;
    @track canDeleteFiles;

    STORE_IMG_LABEL = STORE_IMG_UPLOAD_LBL;
    LOGO_IMG_LABEL = STORE_LOGO_UPLOAD_LBL;
    acceptedFormats = ['image/png', 'image/jpg', 'image/jpeg'];
    isSpinnerVisible;
    message;
    altText = LOADING_TXT;

    files = [];

    @wire(canManageFiles, { recordId: '$recordId' })
    managePermissions({ error, data }) {
        if (data) {
            if (data == 'false') {
                this.showFileUpload = false;
                this.canDeleteFiles = false;
            } else {
                this.showFileUpload = true;
                this.canDeleteFiles = true;
            }
        } else if (error) {
            handleError(error?.body);
        }
    }

    handleChooseImages(event) {
        let file = {
            name: event.detail.name,
            filesByType: event.detail.filesToUpload
        };
        let index = this.files.findIndex((object => object.name == file.name));
        index == -1 ? this.files.push(file) : this.files[index] = file;
    }

    handleUpload(event) {
        this.isSpinnerVisible = true;
        if (this.files != null || this.file != []) {
            this.message = null;
            saveFiles({ idParent: this.recordId, filesList: this.files })
                .then(data => {
                    this.isSpinnerVisible = false;
                    showToast('Success', data, 'Success', this);
                    this.files = [];
                    this.refresh();
                })
                .catch(error => {
                    this.isSpinnerVisible = false;
                    showToast('Error', JSON.stringify(error), 'Error', this);
                });
        } else {
            this.isSpinnerVisible = true;
            this.message = NO_FILES_SELECTED_ERR_MSG;
        }
    }

    handleDelete(event) {
        this.refresh();
    }

    refresh() {
        let childrenArray = this.template.querySelectorAll('c-attachments-display');
        childrenArray[0].refreshList();
        childrenArray[1].refreshList();
    }
}