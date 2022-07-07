public without sharing class ProfileUtils {

    public static final String GR_PARTNER_USER = 'GR B2B Partner Community User';

    public static final String GR_CUSTOMER_USER = 'GR B2C Customer Community Login User';

    public static final String GR_SYSTEM_ADMIN = 'System Administrator';
    
    public static final String GR_MARKETING_USER = 'GR Marketing';
    
    public static final String GR_MARKETING_TEAM_USER = 'Marketing Team';
    
    public static final String SF_STANDARD_USER = 'Standard User';

    public static Id getProfileIdByName(String profileName) {
        return [SELECT Id
                FROM Profile
                WHERE Name = : profileName]?.get(0).Id;
    }
}