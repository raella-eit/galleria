public without sharing class FilesManagerController {

    public class FilesByTypeWrapper {
        public String name;
        public List<FileInfo> filesByType;
    }

    public class FileInfo {
        public String title;
        public Blob versionData;
        public String contentType;
    }

    /**
     * @description returns files related to a specific object given recordId
     *  -- Used in My Account page
     *  -- Display -> thumbnails
     * @author Raella Frem | 22-09-2021
     * @param String recordId
     * @param String name
     * @return List<ContentVersion>
     **/
    @AuraEnabled (cacheable = true)
    public static List<ContentVersion> retrieveFiles(String recordId, String name){

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId
                                             FROM ContentDocumentLink
                                             WHERE LinkedEntityId =: recordId];

        List<Id> cdIds = new List<Id>();
        for(ContentDocumentLink obj : cdlList) {
            cdIds.add(obj.ContentDocumentId);
        }
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, ContentUrl,
                                       VersionNumber, Title, PathOnClient,
                                       FileType, FileExtension, ContentSize,
                                       CreatedDate
                                       FROM ContentVersion
                                       WHERE ContentDocumentId IN:cdIds
                                       AND Type__c = :name];

        return cvList;
    }

    /**
     * @description adds files to Files Related List of sObject with Id = idParent
     * @author Raella Frem | 31-08-2021
     * @param Id idParent
     * @param list<Object> filesToInsert
     **/
    @AuraEnabled
    public static String saveFiles(Id idParent, List<Object> filesList){
        Boolean isPartner = UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER) ? true : false;
        List<ContentVersion> documentsList = new List<ContentVersion>();
        for(Object filesByName : filesList) {
            FilesByTypeWrapper fileWrapper = (FilesByTypeWrapper)JSON.deserialize(JSON.serialize(filesByName), FilesByTypeWrapper.class);
            for(FileInfo file : fileWrapper.filesByType) {
                FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                ContentVersion document = new ContentVersion();
                document.PathOnClient = fileData.title;
                document.Title = fileData.title;
                document.VersionData = fileData.versionData;
                document.FirstPublishLocationId = idParent;
                document.isMajorVersion = true;
                document.Type__c = fileWrapper.name;
                document.IsVerified__c = isPartner ? false : true;
                documentsList.add(document);
            }
        }
        try {
            if(ContentVersion.SObjectType.getDescribe().isCreateable()) {
                insert documentsList;
                
                if(idParent.getSobjectType().getDescribe().getName() == 'Account') {
                    Account account = [SELECT Id, PublicationStatus__c
                                       FROM Account
                                       WHERE Id = :idParent]?.get(0);
                    account.PublicationStatus__c = 'Draft';
                    update account;
                }
                return System.Label.FILE_UPLOAD_SUCCESS;
            }

            return System.Label.INSUFFICIENT_ACCESS_MSG;
        } catch(DmlException ex) {
            throw new AuraHandledException(System.Label.FILE_UPLOAD_ERROR);
        }
    }

    /**
     * @description returns files related to a specific object given recordId
     *  -- Used in Permit and Offer record page
     *  -- Display -> datatable
     * @author Raella Frem | 20-09-2021
     * @param String recordId
     * @return String
     **/
    @AuraEnabled
    public static String getContentDetails(String recordId) {
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();

        for(ContentDocumentLink cdl : contentDocumentList) {
            contentDocumentId.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> contentVersionList = [SELECT Id, FileType, Title, FileExtension,
                                                   ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                   CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                   FROM ContentVersion
                                                   WHERE ContentDocumentId IN : contentDocumentId];

        return JSON.serialize(contentVersionList);
    }

    /**
     * @description deletes file
     * @author Raella Frem | 20-09-2021
     * @param String recordId
     **/
    @AuraEnabled
    public static void deleteContentDocument(Id parentObjectRecordId, Id contentDocumentRecordId) {
        String canDeleteFiles = canManageFiles(parentObjectRecordId);
        if(canDeleteFiles == 'true') {
            try {
                Database.delete(ContentDocumentRecordId);
            } catch(DmlException ex) {
                throw new AuraHandledException(System.Label.GENERIC_ERROR_MESSAGE);
            }
        } else {
            throw new AuraHandledException(System.Label.DEL_FILE_APPROVAL_ERROR);
        }
    }

    /**
     * @description returns file ContentType given file extension
     * @author Raella Frem | 20-09-2021
     * @param String fileType
     * @return string
     **/
    public static string ContentType(String fileType) {

        switch on fileType.toLowerCase(){
            when 'doc', 'dot' {
                return 'application/msword';
            }
            when 'docx', 'dotx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'xlsx' {
                return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            }
            when 'csv', 'xls', 'xlt', 'xla' {
                return 'application/vnd.ms-excel';
            }
            when 'ppt', 'pot', 'pps', 'ppa' {
                return 'application/vnd.ms-powerpoint';
            }
            when 'pptx' {
                return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'wmv' {
                return 'video/x-ms-wmv';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'png' {
                return 'image/png';
            }
            when 'pdf' {
                return 'application/pdf';
            }
            when else {
                return 'image/jpeg';
            }
        }
    }

    /**
     * @description returns login URL
     * @author Raella Frem | 20-09-2021
     * @return String
     **/
    @AuraEnabled(cacheable = true)
    public static String getLoginURL(){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        User userRecord = [Select Id, AccountId, ContactId FROM User Where Id = :UserInfo.getUserId()];
        if(userRecord.ContactId != null) {
            baseUrl = getExperienceURL();
        }

        return baseUrl;
    }

    /**
     * @description returns experience URL
     * @author Raella Frem | 20-09-2021
     * @return String
     **/
    public static String getExperienceURL(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        baseURL =  baseURL.replace('/s/login', '');
        baseURL =  baseURL.replace('/s/Login', '');
        baseURL =  baseURL.replace('/login', '');
        baseURL =  baseURL.replace('/Login', '');

        return baseURL;
    }

    /**
     * @description returns true only if record is Rejected OR logged in user is admin. Otherwise, partner user shouldn't be able to manage files.
     * @author Raella Frem | 19-09-2021
     * @param String recordId
     * @return Boolean
     **/
    @AuraEnabled(cacheable = true)
    public static String canManageFiles(Id recordId){
        if(UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_PARTNER_USER)) {
            String sObjectType = recordId.getSobjectType().getDescribe().getName();
            String approvalStatus;
            if(sObjectType == 'Permit__c') {
                approvalStatus = [SELECT ApprovalStatus__c FROM Permit__c WHERE Id = :recordId]?.get(0).ApprovalStatus__c;
            } else if(sObjectType == 'Offer__c') {
                approvalStatus = [SELECT Approval_Status__c FROM Offer__c WHERE Id = :recordId]?.get(0).Approval_Status__c;
            } else if(sObjectType == 'Account') {
                approvalStatus = [SELECT ApprovalStatus__c FROM Account WHERE Id = :recordId]?.get(0).ApprovalStatus__c;
                if (approvalStatus == 'Pending') {
                    return 'false';
                } else {
                    return 'true';
                }
            }
            if(approvalStatus == 'Approved' || approvalStatus == 'Pending') {
                return 'false';
            }
        }

        return 'true';
    }

}