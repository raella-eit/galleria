import { LightningElement, api, track, wire } from 'lwc';
import { showToast, format } from 'c/sharedJSCode';
 
import retrieveFiles from '@salesforce/apex/FilesManagerController.retrieveFiles';

import FILE_LIMIT_REACHED from '@salesforce/label/c.FILE_LIMIT_REACHED';
import FILE_TYPE_UNSUPPORTED from '@salesforce/label/c.FILE_TYPE_UNSUPPORTED';
import FILE_SIZE_ERROR from '@salesforce/label/c.FILE_SIZE_ERROR';
import MAX_FILE_SIZE_INFO_MSG from '@salesforce/label/c.MAX_FILE_SIZE_INFO_MSG';
export default class FileUpload extends LightningElement {
    @api recordId;
    @api inputLabel;
    @api name;
    @api acceptedFormats;
    @api acceptsMultiple;
    @api maxFiles;
    @api minFiles;
    @api maxSize = 1048576;

    @track fileNames = '';
    @track filesToUpload = [];
    fileContents;
    currentNumberOfFiles;

    @track hasMultiple = false;
    disable = false;
    require = false;
    get infoMaxSize() {
        return format(MAX_FILE_SIZE_INFO_MSG, this.formatBytes(this.maxSize, 2));
    }

    get isDisabled() {
        return this.disable ? true : false;
    }

    get isRequired() {
        return this.require || this.minFiles == 1 ? true : false;
    }

    connectedCallback() {
        this.hasMultiple = (this.acceptsMultiple == "true" ? true : false);
    }

    @wire(retrieveFiles, { recordId: '$recordId', name: '$name' })
    logoLimit({ error, data }) {
        if (data) {
            if (this.maxFiles == 100 || data.length == 0) { /* no limit on number of files to upload */
                this.disable = false;
            } else if (data.length >= this.maxFiles) { /* limit already reached */
                this.disable = true;
            } else if (data.length < this.minFiles) { /* minimum number of files not yet met */
                this.require = true;
            } else if (!data.length) { /* no files related to the record */
                this.require = true;
            }
            this.currentNumberOfFiles = data.length ? data.length : 0;
        } else if (error) {
            // TODO   
        }
    }

    // on file choose change, send chosen files to parent component -> handle save in parent
    handleFileChange(event) {
        let files = event.target.files;
        let allowedRemaining = this.maxFiles - this.currentNumberOfFiles;
        let filesTotalSize = 0;
        if (files.length > 0) {
            if (files.length > this.maxFiles || files.length > allowedRemaining) {
                showToast('Error', format(FILE_LIMIT_REACHED, isNaN(allowedRemaining) ? this.maxFiles : allowedRemaining), 'Error', this);
                return;
            }

            let filesName = '';
            this.filesToUpload = [];
            for (let i = 0; i < files.length; i++) {
                let file = files[i];
                filesTotalSize += files[i].size;
                if (!this.acceptedFormats.includes(file.type) && !this.acceptedFormats.includes('All')) {
                    showToast('Error', FILE_TYPE_UNSUPPORTED, 'Error', this);
                    return;
                }
                filesName = filesName + file.name + ', ';

                let reader = new FileReader();
                reader.onload = f => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesToUpload.push({
                        title: file.name,
                        versionData: fileContents,
                        contentType: file.type
                    });
                };
                reader.readAsDataURL(file);
            }
            this.fileNames = filesName.slice(0, filesName.length - 2);

            if (filesTotalSize > this.maxSize*1.37) {
                showToast('Error', FILE_SIZE_ERROR, 'Error', this);
                this.filesToUpload = [];
                this.fileNames = '';
                return;
            }
        }

        var params = { name: this.name, filesToUpload: this.filesToUpload };
        this.dispatchEvent(new CustomEvent('choose', {
            detail: params
        }));
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }
}