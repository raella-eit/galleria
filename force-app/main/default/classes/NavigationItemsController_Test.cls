@isTest
public class NavigationItemsController_Test {
     
    @isTEST
    public static void getLocalizedNavigationItemsTest (){ 
        List<NavigationItemsController.NavItemWrapper> englishItemsList = NavigationItemsController.getLocalizedNavigationItems('Shops','Live',true,'en_US');
        List<NavigationItemsController.NavItemWrapper> arabicItemsList = NavigationItemsController.getLocalizedNavigationItems('Shops','Live',false,'ar');
    }
}