public without sharing class CommunityUtilities {

    @AuraEnabled(cacheable = true)
    public static String getUrl(String urlName){

        return URLs__c.getValues(urlName)?.URL__c;
    }

    @AuraEnabled
    public static void changeUserLanguage(String lang){
        User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
        currentUserInfo.LanguageLocaleKey = lang;
        update currentUserInfo;
    }

    @AuraEnabled(cacheable = false)
    public static Boolean isAgentLive(){
        return ![SELECT Id FROM UserServicePresence WHERE IsCurrentState = true LIMIT 1]?.isEmpty();
    }
}