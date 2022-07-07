import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { format, showToast, handleError } from 'c/sharedJSCode';
import { refreshApex } from '@salesforce/apex';

import retrieveFiles from '@salesforce/apex/FilesManagerController.retrieveFiles';
import deleteFile from '@salesforce/apex/FilesManagerController.deleteContentDocument';
import getLoginURL from '@salesforce/apex/FilesManagerController.getLoginURL';

import ACT_LogoPlaceholder from '@salesforce/resourceUrl/ACT_LogoPlaceholder';
import ACT_StoreImgPlaceholder from '@salesforce/resourceUrl/ACT_StoreImgPlaceholder';

import RELATED_FILES_LIST_TITLE from '@salesforce/label/c.RELATED_FILES_LIST_TITLE';

export default class AttachmentRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api name;
    @api allowDeleteAll;
    @api canDeleteFiles;
    @track results = [];
    @track placeholderResults = [];
    @track isPlaceholder = false;
    relatedListTitle = 'Images';
    placeholderRelatedListTitle = 'Images';
    canDeleteAll;

    logoPlaceholder = ACT_LogoPlaceholder;
    storePlaceholder = ACT_StoreImgPlaceholder;

    @api refreshList() {
        refreshApex(this.wiredImagesList);
    }

    connectedCallback() {
        this.canDeleteAll = (this.allowDeleteAll == "true" ? true : false);
    }

    @wire(retrieveFiles, { recordId: '$recordId', name: '$name' })
    fetchFileData(result) {
        this.wiredImagesList = result;
        if (result.data) {
            this.prepareFileRows(result.data);
        }
    }

    prepareFileRows(data) {
        if (data) {
            this.relatedListTitle = format(RELATED_FILES_LIST_TITLE, this.name, data.length);
            if (data.length > 0) {
                this.isPlaceholder = false;
                this.results = [];
                let baseUrl = this.getBaseUrl();
                data.map(element => {
                    let fSize = this.formatFileSize(element.ContentSize);
                    let fDate = this.formatDateString((element.CreatedDate).slice(0, 10));
                    this.results =
                        [...this.results,
                        {
                            fileId: element.Id,
                            fileName: element.Title,
                            filePath: element.PathOnClient,
                            fileType: element.FileType,
                            fileExtn: element.FileExtension,
                            fileSize: fSize,
                            fileDate: fDate,
                            thumbnailPath: baseUrl + 'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + element.Id,
                            downloadUrl: baseUrl + '/sfc/servlet.shepherd/document/download/' + element.ContentDocumentId,
                            viewUrl: baseUrl + 'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + element.Id,
                            documentId: element.ContentDocumentId
                        }
                        ]
                });
            } else {
                this.isPlaceholder = true;
                this.displayPlaceholderResults(this.name);
            }
        }
    }

    displayPlaceholderResults(name) {
        this.placeholderRelatedListTitle = format(RELATED_FILES_LIST_TITLE, this.name, 0);
        if (name == 'Logo') {
            this.placeholderResults = [{
                fileId: '1',
                filename: this.logoPlaceholder,
                thumbnailPath: this.logoPlaceholder
            }]
        } else if (name == 'Store') {
            this.placeholderResults = [{
                fileId: '1',
                filename: this.storePlaceholder,
                thumbnailPath: this.storePlaceholder
            }]
        }
    }

    formatDateString(dateStr) {
        const dt = new Date(dateStr);
        const year = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(dt);
        const month = new Intl.DateTimeFormat('en', { month: 'short' }).format(dt);
        const day = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(dt);
        return month + ' ' + day + ', ' + year;
    }

    formatFileSize(fileSize) {
        let f = Math.abs(fileSize / 1024);
        return (f > 1024 ? Math.abs(fileSize / (1024 * 1024)).toFixed(2) + ' MB'
            : Math.round(f) + ' KB');
    }

    deleteImage(event) {
        if (this.results.length == 1 && !this.canDeleteAll) {
            showToast('Error', DEL_IMG_LIMIT_MSG, 'Error', this);
            return;
        } else {
            deleteFile({ parentObjectRecordId: this.recordId, contentDocumentRecordId: event.target.value })
                .then(data => {
                    showToast('Success', data, 'Success', this);
                    refreshApex(this.wiredImagesList);
                    this.dispatchEvent(new CustomEvent('delete', {
                        detail: this.name
                    }));
                })
                .catch(error => {
                    showToast('Error', error, 'Error', this);
                    handleError(error?.body);
                })
        }
    }

    getBaseUrl() {
        let baseUrl = 'https://' + location.host + '/';
        getLoginURL()
            .then(result => {
                baseUrl = result;
            })
            .catch(error => {
                handleError(error?.body);
            });
        return baseUrl;
    }
}