import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { showToast } from 'c/sharedJSCode';

import getContentDetails from '@salesforce/apex/FilesManagerController.getContentDetails';
import deleteContentDocument from '@salesforce/apex/FilesManagerController.deleteContentDocument';
import getLoginURL from '@salesforce/apex/FilesManagerController.getLoginURL';
import canManageFiles from '@salesforce/apex/FilesManagerController.canManageFiles';

import NO_FILES_SELECTED_ERR_MSG from '@salesforce/label/c.NO_FILES_SELECTED_ERR_MSG';
import DEL_FILE_LIMIT from '@salesforce/label/c.DEL_FILE_LIMIT';
import DEL_FILE_APPROVAL_ERROR from '@salesforce/label/c.DEL_FILE_APPROVAL_ERROR';
import FILE_UPLOAD_LABEL from '@salesforce/label/c.FILE_UPLOAD_LABEL';
import LOADING from '@salesforce/label/c.LOADING';
import saveFiles from '@salesforce/apex/FilesManagerController.saveFiles';

const actions = [
    {label: 'Preview', name:'Preview'},
    {label: 'Download', name: 'Download'},
    {label: 'Delete', name: 'Delete'}
];

const columns = [
    {
        label: 'Title', fieldName: 'Title', wrapText: true, //initialWidth: 650,
        cellAttributes: {
            iconName: { fieldName: 'icon' }, iconPosition: 'left'
        }
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }
];

export default class RelatedFilesDisplay extends NavigationMixin(LightningElement) {
    @api title;
    @api showDetails;
    @api showFileUpload;
    @api showsync;
    @api recordId;
    @api usedInCommunity;
    @api showFilters;
    @api accept;
    @api canDeleteAll;
    @api objectApiName;
    acceptedFormats = ['image/png', 'image/jpg', 'image/jpeg'];

    @track dataList;
    @track isPermit = false;
    @track canDeleteFiles;
    @track columnsList = columns;
    isSpinnerVisible = false;
    label = FILE_UPLOAD_LABEL;
    loadingText = LOADING;

    wiredFilesResult;
    files = [];

    connectedCallback() {
        if(this.objectApiName == 'Permit__c'){
            this.isPermit = true;
        }
        this.handleSync();
    }

    getBaseUrl() {
        let baseUrl = 'https://' + location.host + '/';
        getLoginURL()
            .then(result => {
                baseUrl = result;
            })
            .catch(error => {
                console.error('Error: \n ', error);
            });
        return baseUrl;
    }

    @wire(canManageFiles, { recordId: '$recordId'})
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
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Download':
                this.downloadFile(row);
                break;
            case 'Delete':
                if (this.canDeleteFiles) {
                    this.handleDeleteFiles(row);
                } else {
                    showToast('Error', DEL_FILE_APPROVAL_ERROR, 'Error', this);
                }
                break;
            default:
        }
    }

    previewFile(file) {
        if (!this.usedInCommunity) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: file.ContentDocumentId
                }
            });
        } else if (this.usedInCommunity) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.fileUrl
                }
            }, false);
        }
    }

    downloadFile(file) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: file.downloadUrl
            }
        }, false
        );
    }

    handleDeleteFiles(row) {
        if (this.dataList.length == 1 && !this.canDeleteAll) {
            showToast('Error', DEL_FILE_LIMIT, 'Error', this);
            return;
        }
        this.isSpinnerVisible = true;
        deleteContentDocument({
            parentObjectRecordId: this.recordId,
            contentDocumentRecordId: row.ContentDocumentId
        })
            .then(result => {
                this.dataList = this.dataList.filter(item => {
                    return item.ContentDocumentId !== row.ContentDocumentId;
                });
            })
            .catch(error => {
                showToast('Error', DEL_FILE_APPROVAL_ERROR, 'Error', this);
                // console.error('**** error **** \n ', error)
            })
            .finally(() => {
                this.isSpinnerVisible = false;
            });
    }

    handleSync() {
        let imageExtensions = ['png', 'jpg', 'gif'];
        let supportedIconExtensions = ['ai', 'attachment', 'audio', 'box_notes', 'csv', 'eps', 'excel', 'exe',
            'flash', 'folder', 'gdoc', 'gdocs', 'gform', 'gpres', 'gsheet', 'html', 'image', 'keynote', 'library_folder',
            'link', 'mp4', 'overlay', 'pack', 'pages', 'pdf', 'ppt', 'psd', 'quip_doc', 'quip_sheet', 'quip_slide',
            'rtf', 'slide', 'stypi', 'txt', 'unknown', 'video', 'visio', 'webex', 'word', 'xml', 'zip'];

        this.isSpinnerVisible = true;
        getContentDetails({
            recordId: this.recordId
        })
            .then(result => {
                let parsedData = JSON.parse(result);
                let stringifiedData = JSON.stringify(parsedData);
                let finalData = JSON.parse(stringifiedData);
                let baseUrl = this.getBaseUrl();
                finalData.forEach(file => {
                    file.downloadUrl = baseUrl + 'sfc/servlet.shepherd/document/download/' + file.ContentDocumentId;
                    file.fileUrl = baseUrl + 'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + file.Id; 
                    file.CREATED_BY = file.ContentDocument.CreatedBy.Name;
                    file.Size = this.formatBytes(file.ContentDocument.ContentSize, 2);

                    let fileType = file.ContentDocument.FileType.toLowerCase();
                    if (imageExtensions.includes(fileType)) {
                        file.icon = 'doctype:image';
                    } else {
                        if (supportedIconExtensions.includes(fileType)) {
                            file.icon = 'doctype:' + fileType;
                        }
                    }
                });
                this.dataList = finalData;
            })
            .catch(error => {
                console.error('**** error **** \n ', error)
            })
            .finally(() => {
                this.isSpinnerVisible = false;
            });
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
                    this.handleSync();
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

    handleUploadFinished() {
        this.handleSync();
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleSearch(event) {
        let value = event.target.value;
        let name = event.target.name;
        if (name === 'Title') {
            this.dataList = this.dataList.filter(file => {
                return file.Title.toLowerCase().includes(value.toLowerCase());
            });
        } else if (name === 'Created By') {
            this.dataList = this.dataList.filter(file => {
                return file.CREATED_BY.toLowerCase().includes(value.toLowerCase());
            });
        }
    }
}