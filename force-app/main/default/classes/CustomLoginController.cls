global with sharing class CustomLoginController {
    global String username {get; set;}
    global String password {get; set;}
    public String orgId {get; set;}
    public String siteURL  {get; set;}
    public String startURL {get; set;}
    public List<AuthProvider> authProviders {get; set;}

    global CustomLoginController () {
        orgId = UserInfo.getOrganizationId();
        siteURL  = Site.getBaseUrl();
        startURL = System.currentPageReference().getParameters().get('startURL');
        if(startURL == null) startURL = '/';
        authProviders = [SELECT Id, DeveloperName, FriendlyName, IconUrl, SsoKickoffUrl FROM AuthProvider];
    }

    global PageReference login() {
        PageReference currentPage = ApexPages.currentPage();
        String urlSuffix = '';
        if(currentPage.getParameters().containsKey('callback')) {
            urlSuffix += 's/' + currentPage.getParameters().get('callback');
            if(currentPage.getParameters().containsKey('id')) {
                urlSuffix += '?recordId=' + currentPage.getParameters().get('id');
            }
        }

        return Site.login(username, password, startUrl + urlSuffix);
    }

    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }

    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }

}