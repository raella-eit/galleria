@isTest
public class ContentVersionTrigger_TEST {
    @TestSetup
    static void makeData(){
        List<Account> accountList = TestDataFactoryGR.createAccountsList(1, 'GR Test Account', true);
        FilesManagerController.FilesByTypeWrapper wrapper = new FilesManagerController.FilesByTypeWrapper();
        FilesManagerController.FileInfo fileInfo = new FilesManagerController.FileInfo();
        fileInfo.title = 'test';
        fileInfo.versionData = Blob.valueOf('4AAQSkZJRgABAQAAAQABAA');
        fileInfo.contentType = 'image/jpeg';
        List<FilesManagerController.FileInfo> fileList = new List<FilesManagerController.FileInfo>();
        fileList.add(fileInfo);
        wrapper.name = 'Logo';
        wrapper.filesByType = fileList;

        List<Object> filesList = new List<Object>();
        filesList.add(wrapper);

        FilesManagerController.saveFiles(accountList?.get(0).Id, filesList);
    }

    @isTest
    public static void updateShopLogoTest() {
        List<Account> accountList = [SELECT Id, ApprovalStatus__c, PublicationStatus__c
                                     FROM Account];

        for(Account account : accountList) {
            account.ApprovalStatus__c = 'Approved';
            account.PublicationStatus__c = 'Published';
        }

        update accountList;

        List<B2CShop__c> b2cShopList = [SELECT Id, LogoDownloadUrl__c
                                        FROM B2CShop__c];

        System.assert(!b2cShopList.isEmpty(),
                      'logo download url should be duplicated on B2C Shop record');
    }
}