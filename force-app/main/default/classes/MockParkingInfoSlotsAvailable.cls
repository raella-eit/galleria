@isTest
global class MockParkingInfoSlotsAvailable implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint() == URLs__c.getValues('AmcparkingInfo')?.URL__c){
            String json=		'['+
                '    {'+
                '        "status": "OK",'+
                '        "parkingArea":"L1/P2/C",'+
                '		 "parkingLevel":"B3 (L1,P1,AMC_P2)",'+
                '		 "parkingAreaTag":"Podium 2-C",'+
                ' 		 "totalCapacity":217,'+
                '        "freeLocations":189'+
                '    }'+
                ']';  
            res.setBody(json);
        }
        else{
            res.setBody('<counters><facility-no>1004</facility-no><standard-counter><id>0</id><type>0</type><text>Pre-booked</text><free>0</free><present>0</present><percent>100</percent><max>0</max><status>Occupied</status><status-value>1</status-value></standard-counter><standard-counter><id>1</id><type>0</type><text>Not reserved</text><free>1048</free><present>200</present><percent>16</percent><max>1248</max><status>Free</status><status-value>0</status-value></standard-counter><standard-counter><id>2</id><type>0</type><text>Reserved</text><free>1</free><present>0</present><percent>0</percent><max>1</max><status>Free</status><status-value>0</status-value></standard-counter><standard-counter><id>3</id><type>0</type><text>Total</text><free>1049</free><present>200</present><percent>16</percent><max>1249</max><status>Free</status><status-value>0</status-value></standard-counter></counters>');
        }        
        res.setStatusCode(200);
        return res;
    }
}