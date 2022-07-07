@isTest private class pagedirectionsTest {
    @isTest static void testfinishLocation(){
        Contact con = new Contact(LastName='testcontact');
        try{
            insert con;
        }
        catch(Exception e){}
        List<Case> listC = new list<Case>();
        List<Id> newCaseIds = new List<Id>();
        for(Integer i=0;i<1;i++){
            Case c = new Case(Contactid=con.id, Subject='Test Subject'+i, Origin='Phone',Level_1__c='Price',Level_2__c='Clarity',Level_3__c='Parking',priority='Medium');
            listC.add(c);
        }
        insert listC;
        case c1 =[select id from case limit 1];
        /*insert Live Chat Visitor*/
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
        /*insert Live Chat Transcript*/
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChatKey='1234567';
        lct.CaseId=c1.id;
        try{
            insert lct;
        }catch(Exception e){}
        Test.setCurrentPage(Page.Questionpro_Page_redirect);
        ApexPages.currentPage().getParameters().put('chatKey', '1234567');
        //Test.setCurrentPage(testPage);
        Test.StartTest();
        pagedirections controller = new pagedirections();
        // call the urlRedirect and check the results of the pageReference.
        pageReference p = controller.urlRedirection();
        Test.StopTest();
    }
}