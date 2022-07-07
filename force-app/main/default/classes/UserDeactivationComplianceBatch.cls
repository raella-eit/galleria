public without sharing class UserDeactivationComplianceBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static Id CUSTOMER_PROFILE_ID = ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER);
    private static final String CASE_QUERY = 'SELECT Id FROM Case WHERE AccountId IN :accountIdSet OR ContactPhone = :phoneSet OR SuppliedPhone = :phoneSet OR ContactEmail = :emailSet OR SuppliedEmail = :emailSet';
    private static final String RESERVATION_QUERY = 'SELECT Id FROM UtilityItemReservation__c WHERE Contact__c IN :contactIdSet OR Customer_Type_Account__c IN :accountIdSet';
    //private static final String Contact_QUERY = 'SELECT Id FROM Contact WHERE Id IN :contactIdSet';
    private static final String LOCATION_QUERY = 'SELECT Id FROM DeviceLocation__c WHERE Email__c IN :emailSet OR PersonId__c IN :contactIdSet';
    private static final String ENTITLEMENT_QUERY = 'SELECT Id FROM Entitlement WHERE AccountId IN :accountIdSet';
    private static final String ACCOUNT_QUERY = 'SELECT Id FROM Account WHERE ToDelete__c = True';
    private static final String USER_QUERY = 'SELECT Id,CommunityNickname FROM User WHERE Deactivation_Requested__c = TRUE AND ProfileId = : CUSTOMER_PROFILE_ID AND IsPortalEnabled = TRUE';
    Map<Id, User> userMap = new Map<Id, User>();
    public Set<Id> accountIdSet = new Set<Id>();
    public Set<Id> accIdSet = new Set<Id>(); // used to get corresponding users
    public Set<Id> contactIdSet = new Set<Id>();
    public Set<String> phoneSet = new Set<String>();
    public Set<String> emailSet = new Set<String>();
    public String objectToDelete = 'Case';
    private String nextObject = 'UtilityItemReservation__c'; 
    public UserDeactivationComplianceBatch(){
        this.init();
    }
    
    
    @TestVisible
    private UserDeactivationComplianceBatch(String objectName){
        this.init();
        this.objectToDelete = String.isNotBlank(objectName) ? objectName : 'Case';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('>>> ' + UserDeactivationComplianceBatch.class.getName() + ' Started <<<');
        String query = '';
        
        switch on this.objectToDelete {
            when 'UtilityItemReservation__c' {
                query = RESERVATION_QUERY;
                nextObject = 'DeviceLocation__c';
            }
            when 'DeviceLocation__c' {
                query = LOCATION_QUERY;
                nextObject = 'Entitlement';
            }
            when 'Entitlement' {
                query = ENTITLEMENT_QUERY;
                nextObject = 'User';
            }
            when 'User' {
                query = USER_QUERY;
                nextObject = 'Account';
            }when 'Account' {
                query = ACCOUNT_QUERY;
                nextObject = 'NoObject';
            } 
            when else {
                query = CASE_QUERY;
                nextObject = 'UtilityItemReservation__c';
            }
        }
        System.debug('>>> ' + query + ' query <<<');
        
        
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if(String.isNotBlank(nextObject) && !nextObject.equalsIgnoreCase('Account') )  { 
            System.debug('delete'+scope);
            delete scope;
        } else if(nextObject.equalsIgnoreCase('Account')) {
            for(sObject user : scope) {
                System.UserManagement.obfuscateUser(String.valueOf(user.get('Id')));
                user.put('isActive', false);
                user.put('IsPortalEnabled', false);
                user.put('MobilePhone', '');
                user.put('Phone', '');
            }
            update scope;            
        }
        SYSTEM.DEBUG('@@@@@@@ ' + nextObject);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('>>> ' + UserDeactivationComplianceBatch.class.getName() + ' finish <<<');
        
        System.debug(' finish nextObject '+nextObject);
        if(String.isNotBlank(nextObject)  && nextObject != 'NoObject') {
            UserDeactivationComplianceBatch nextBatch = new UserDeactivationComplianceBatch(this.nextObject);
            Database.executeBatch(nextBatch);
        }
    }
    
    private void init(){
        this.userMap = new Map<Id, User>([SELECT Id, AccountId, ContactId, Account.PersonMobilePhone, Username, Email, Account.PersonEmail, isActive, Phone, MobilePhone
                                          FROM User
                                          WHERE Deactivation_Requested__c = TRUE
                                          AND ProfileId = : CUSTOMER_PROFILE_ID
                                          AND isActive = TRUE]);
        fillData();
        
    }
    Private void fillData(){
        for(User user : this.userMap.values()) {
            this.contactIdSet.add(User.ContactId);
            this.accountIdSet.add(user.AccountId);
            this.phoneSet.add(user.Phone);
            this.phoneSet.add(user.MobilePhone);
            this.phoneSet.add(user.Account.PersonMobilePhone);
            this.emailSet.add(user.Email);
            this.emailSet.add(user.Username);
            this.emailSet.add(user.Account.PersonEmail);
        }
    }
}