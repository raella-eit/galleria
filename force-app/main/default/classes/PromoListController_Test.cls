@isTest
public class PromoListController_Test {
    @testSetup 
    static void setup(){
        //User
        User testUser = TestDataFactoryGR.createTestUser();
        insert testUser;
    } 
    
    
    @isTest
    public static void shopDetailTest(){
        User testUser = [Select id from User limit 1];
        System.runAs(testUser){ 
            List<GenericDataCardItem> lst = PromoListController.getCarouselItemList();
        }
    }
}