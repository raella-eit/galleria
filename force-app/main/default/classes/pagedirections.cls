public Without Sharing class pagedirections {
    public String liveAgentChatKey  {get;set;}
    list<LiveChatTranscript> transcript = new list<LiveChatTranscript>();
    String url;
    public PageReference urlRedirection() {
    PageReference page = null;
        liveAgentChatKey = ApexPages.currentPage().getParameters().get('chatKey');
        transcript = [SELECT Id, CaseID,ChatKey FROM LiveChatTranscript WHERE ChatKey =: liveAgentChatKey LIMIT 1];
        try{
        IF(transcript.SIZE()>0){
        url = 'https://gulfrelated.questionpro.com/t/m3YZ3Y?custom1=Survey__c&custom3=0123W000000L2qzQAC&custom4='+liveAgentChatKey+'&custom5='+transcript[0].Id+'&custom6='+transcript[0].CaseID;
        }
        page = new PageReference(url);
        page.setRedirect(true);
        }
        catch(Exception e){

}
        return page;
    }
}