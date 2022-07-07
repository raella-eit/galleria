public class Questionprojsongenerator {
    
    public  void jsonGeneratorSample(List<account> accList) {
       //List<account> accList1=[select id,personEmail from account where personEmail='jennifer.victor@weare4c.com'];
        Id surveyrecordTypeId = Schema.SObjectType.survey__c.getRecordTypeInfosByName().get('Account Survey').getRecordTypeId();//'0123O000000E4P2QAK';
        system.debug('recordtypeid'+surveyrecordTypeId);
        String surveyid='7736294';
        String strJson = '';
        if(!accList.isEmpty()){
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject(); 
    gen.writeStringField('surveyID',surveyid);
    gen.writeStringField('sendEmail','True');    
    gen.writeFieldName('contacts');
    gen.writeStartArray();
            system.debug('acclist'+accList);
    for(account acc :accList){
        gen.writeStartObject();
        gen.writeStringField('field1','account');
        gen.writeStringField('field3', acc.Id);
        gen.writeStringField('field4',surveyrecordTypeId);
        gen.writeStringField('email', acc.personemail);
        gen.writeStringField('segmentCode','S1');
        gen.writeEndObject();
    }
    gen.writeEndArray();
    gen.writeStringField('invitationTemplateID','-1');
    gen.writeEndObject();
    String jsonData = gen.getAsString();
    System.debug('jsonData-' + jsonData);
		try{
        String endpoint = 'https://api.questionpro.com/a/api/questionpro.cx.importTransaction?apiKey=28a41175-c2c2-4370-93ae-9079054ff7ce';
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');
		req.setbody(jsonData);
		Http http = new Http();
		HTTPResponse response = http.send(req); 
            if (response.getStatusCode() == 200) {
                 String jsonResponse = response.getBody();
                 System.debug('Response-' + jsonResponse);
                    }
        }
            catch(Exception e){
                    System.debug('Error-' + e.getMessage());   
                }
        }
        
        }
}