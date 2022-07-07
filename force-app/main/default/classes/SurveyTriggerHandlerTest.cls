@isTest
Private class SurveyTriggerHandlerTest {
    static testMethod void myUnitTest() {
        
        /*insert Contact,Case*/
        
        Contact con = new Contact(LastName='testcontact', phone='00971722334455');
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
        system.debug('lct' + lct);
        
        LiveChatTranscript lv=[select id,chatkey,CaseId from LiveChatTranscript limit 1 ];
        system.debug('chatkey'+lv.ChatKey);
        /*insert Survey*/
        
        survey__c s = new survey__c();
        s.Chatkey__c='1234567';
        s.phone__c= '00971422334455';
        s.Last_Name__c = 'test';
        s.Email_Address__c = 'test.test@test.com';
        s.How_Satisfied_are_you_with_our_services__c = 'Unsatisfied';
        
        survey__c s2 = new survey__c();
        s2.Chatkey__c='1234567';
        s2.phone__c= '00971422334455';
        s2.Last_Name__c = 'test';
        s2.Email_Address__c = 'test.test@test.com';
        s2.How_Satisfied_are_you_with_our_services__c = 'Unsatisfied';
        s2.Would_you_like_us_to_contact_you_to_disc__c = 'Yes';
        try{
            test.startTest();
            insert s;
            insert s2;
            test.stopTest();
        }
        catch(Exception e){
            System.debug(e);
        }
        // survey__c s1 =[select id,Case__c,Chat_Transcript__c from survey__c limit 1];
        List<Case> casesFromQuestionPro = [SELECT id FROM Case WHERE Origin='QuestionPro'];
        System.assert(casesFromQuestionPro.size() > 0);
    }
}