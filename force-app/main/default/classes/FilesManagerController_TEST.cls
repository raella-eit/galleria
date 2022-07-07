@isTest
public class FilesManagerController_TEST {

    @isTest
    public static void saveFilesTest() {
        User systemAdministrator;
        User partnerUser;

        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('admin')) {
                systemAdministrator = userRec;
            } else if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            }
        }

        List<Offer__c> offersList = new List<Offer__c>();
        System.runAs(partnerUser) {
            offersList = TestDataFactoryGR.createOffersList(1, 'Offer', true);
        }

        FilesManagerController.FilesByTypeWrapper wrapper = new FilesManagerController.FilesByTypeWrapper();
        FilesManagerController.FileInfo fileInfo = new FilesManagerController.FileInfo();
        fileInfo.title = 'test';
        fileInfo.versionData = Blob.valueOf('4AAQSkZJRgABAQAAAQABAA');
        fileInfo.contentType = 'image/jpeg';
        List<FilesManagerController.FileInfo> fileList = new List<FilesManagerController.FileInfo>();
        fileList.add(fileInfo);
        wrapper.name = 'Offer';
        wrapper.filesByType = fileList;

        List<Object> filesList = new List<Object>();
        filesList.add(wrapper);

        String result = FilesManagerController.saveFiles(offersList?.get(0).Id, filesList);
        System.assertEquals('File(s) successfully uploaded.', result, 'files should be saved');
    }

    @isTest
    public static void getContentDetails_deleteContentDocument_Test() {
        User partnerUser;

        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
                break;
            }
        }

        List<Offer__c> offersList = new List<Offer__c>();
        System.runAs(partnerUser) {
            offersList = TestDataFactoryGR.createOffersList(1, 'Offer', true);
        }

        Id parentOfferId = offersList?.get(0).Id;

        List<ContentVersion> contentVersionsList = TestDataFactoryGR.createRelatedContentVersionsList(2, parentOfferId, 'Offer');

        String serializedContentVersionsList = FilesManagerController.getContentDetails(offersList?.get(0).Id);

        System.assert(serializedContentVersionsList.length() > 0, 'Files should be added and linked to the created offer');

        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId
                                             FROM ContentDocumentLink
                                             WHERE LinkedEntityId = : parentOfferId];

        for(ContentDocumentLink cdl : cdlList) {
            FilesManagerController.deleteContentDocument(parentOfferId, cdl.Id);
        }

        List<ContentVersion> remainingContentVersionsList = [SELECT Id
                                                             FROM ContentVersion
                                                             WHERE FirstPublishLocationId = :parentOfferId];

        System.assert(remainingContentVersionsList.isEmpty(), 'All files should be deleted');
    }

    @isTest
    public static void retrieveFilesTest() {
        User partnerUser;

        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
                break;
            }
        }

        List<Offer__c> offersList = new List<Offer__c>();
        System.runAs(partnerUser) {
            offersList = TestDataFactoryGR.createOffersList(1, 'Offer', true);
        }

        Id parentOfferId = offersList?.get(0).Id;

        List<ContentVersion> contentVersionsList = TestDataFactoryGR.createRelatedContentVersionsList(2, parentOfferId, 'Offer');

        List<ContentVersion> retrievedFilesList = FilesManagerController.retrieveFiles(parentOfferId, 'Offer');
        System.assertEquals(2, retrievedFilesList.size(), '2 files should be retrieved');
    }

    @isTest
    public static void contentTypeTest() {
        String fileType = 'doc';
        System.assertEquals('application/msword', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'docx';
        System.assertEquals('application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                            FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'xlsx';
        System.assertEquals('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                            FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'csv';
        System.assertEquals('application/vnd.ms-excel', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'ppt';
        System.assertEquals('application/vnd.ms-powerpoint', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'pptx';
        System.assertEquals('application/vnd.openxmlformats-officedocument.presentationml.presentation',
                            FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'wav';
        System.assertEquals('audio/wav', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'wmv';
        System.assertEquals('video/x-ms-wmv', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'mp3';
        System.assertEquals('audio/mpeg', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'mp4';
        System.assertEquals('video/mp4', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'png';
        System.assertEquals('image/png', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'pdf';
        System.assertEquals('application/pdf', FilesManagerController.ContentType(fileType), 'Incorrect file type');
        fileType = 'jpg';
        System.assertEquals('image/jpeg', FilesManagerController.ContentType(fileType), 'Incorrect file type');
    }

    @isTest
    public static void canManageFilesTest() {
        User partnerUser;
        User systemAdmin;

        for(User userRec : TestDataFactoryGR.createCommunityUsersList()) {
            if(userRec.Email.contains('partner')) {
                partnerUser = userRec;
            } else if(userRec.Email.contains('admin')) {
                systemAdmin = userRec;
            }
        }

        List<Offer__c> offersList = TestDataFactoryGR.createOffersList(1, 'Offer', false);
        List<Permit__c> permitsList = TestDataFactoryGR.createPermitsList(1, 'Permit', 'PRMT_EventAndInStoreActivation', false);

        Offer__c offer = new Offer__c();
        Permit__c permit = new Permit__c();

        if(!offersList.isEmpty() && !permitsList.isEmpty()) {
            offer = offersList.get(0);
            permit = permitsList.get(0);
        }

        String canManageFilesRetVal_OFFER;
        String canManageFilesRetVal_PERMIT;

        offer.Approval_Status__C = 'Approved';
        permit.ApprovalStatus__c = 'Approved';

        System.runAs(partnerUser) {
            insert offer;
            insert permit;
            canManageFilesRetVal_OFFER = FilesManagerController.canManageFiles(offer.Id);
            canManageFilesRetVal_PERMIT = FilesManagerController.canManageFiles(permit.Id);
        }

        System.assertEquals('false', canManageFilesRetVal_OFFER, 'Partner user shouldn\'t be able to manage files if Offer is Approved');
        System.assertEquals('false', canManageFilesRetVal_PERMIT, 'Partner user shouldn\'t be able to manage files if Permit is Approved');

        offer.Approval_Status__c = 'Rejected';
        permit.ApprovalStatus__c = 'Rejected';

        System.runAs(systemAdmin) {
            update offer;
            update permit;
        }

        System.runAs(partnerUser) {
            canManageFilesRetVal_OFFER = FilesManagerController.canManageFiles(offer.Id);
            canManageFilesRetVal_PERMIT = FilesManagerController.canManageFiles(permit.Id);
        }

        System.assertEquals('true', canManageFilesRetVal_OFFER, 'Partner user should be able to manage files if Offer is Approved');
        System.assertEquals('true', canManageFilesRetVal_PERMIT, 'Partner user should be able to manage files if Permit is Approved');
    }

}