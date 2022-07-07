@isTest
public class CustomLoginController_TEST {
    
    @isTest 
    public static void customLoginTest() {
        CustomLoginController loginCtrl = new CustomLoginController();
        loginCtrl.login();
        loginCtrl.getEncodedSiteUrl();
        loginCtrl.getEncodedStartUrl();
    }
}