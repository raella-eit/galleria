public class Parking_Manager {

    public class AmcParkingInfo {
        public String status;
        public String parkingArea;
        public String parkingLevel;
        public String parkingAreaTag;
        public Integer totalCapacity;
        public Integer freeLocations;
    }

    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper> getParkingInfo(){
        List<ParkingWrapper> parkingList = new List<ParkingWrapper>();
        parkingList.add(getAmcParkingInfo());
        parkingList.add(getAmiParkingInfo());

        return parkingList;
    }

    public static ParkingWrapper getAmiParkingInfo(){
        String url = URLs__c.getValues('ParkingService_URL')?.URL__c;
        Set<String> facilityIdSet = new Set<String> {'1001', '1004'};

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'text/xml');
        request.setMethod('GET');
        request.setTimeout(120000);

        ParkingWrapper amiParking = new ParkingWrapper();
        amiParking.id = '2';
        amiParking.label = System.Label.PARKING_WEST;
        amiParking.details = new List<ParkingWrapper>();
        amiParking.available = 0;
        Integer total = 0;

        for(String facilityId : facilityIdSet) {
            request.setEndpoint('Callout:sc01parking' + url.replace('facilityIdValue', facilityId));
            HttpResponse response = http.send(request);
            DOM.Document doc = new DOM.Document();
            doc.load(response.getBody());
            DOM.XmlNode counterXml = getStandardCounter(doc);
            if(counterXml != null) {
                ParkingWrapper amclvl = new ParkingWrapper();
                amclvl.floor = facilityId == '1001' ? 'P1' : 'P2';
                amclvl.label = 'ALL';
                amclvl.available = Integer.valueOf(counterXml.getChildElement('free', null)?.getText());
                amclvl.percent = Math.round(100 - Integer.valueOf(counterXml.getChildElement('percent', null)?.getText()));
                amclvl.id = '2' + '-' + amclvl.floor + '-' + amclvl.label;

                total += Integer.valueOf(counterXml.getChildElement('max', null)?.getText());
                amiParking.available += amclvl.available;

                amiParking.details.add(amclvl);
            }
        }

        amiParking.percent = Math.round((amiParking.available * 100) / total);

        return amiParking;
    }

    private static DOM.XmlNode getStandardCounter(DOM.Document doc){
        for(DOM.XmlNode child : doc.getRootElement().getChildElements()) {
            if(child.getName() == 'standard-counter' && child.getChildElement('id', null)?.getText() == '1') {

                return child;
            }
        }

        return null;
    }

    public static ParkingWrapper getAmcParkingInfo (){
        String url = URLs__c.getValues('AmcparkingInfo')?.URL__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        string bodyObj = response.getBody();
        List<AmcParkingInfo> amcParkingInfoList = (List<AmcParkingInfo>) System.JSON.deserialize(bodyObj, List<AmcParkingInfo> .class);

        ParkingWrapper amcParking = new ParkingWrapper();
        amcParking.id = '1';
        amcParking.label = System.Label.PARKING_EAST;
        amcParking.details = new List<ParkingWrapper>();
        amcParking.available = 0;
        Integer total = 0;
        for(AmcParkingInfo lvl : amcParkingInfoList) {
            ParkingWrapper amclvl = new ParkingWrapper();
            amclvl.floor = lvl.parkingLevel.substringBetween('AMC_', ')');
            amclvl.label = lvl.parkingAreaTag.substringAfterLast('-');
            amclvl.available = lvl.freeLocations;
            amclvl.percent = Math.round((amclvl.available * 100) / lvl.totalCapacity);
            amclvl.id = '1' + '-' + amclvl.floor + '-' + amclvl.label;

            total += lvl.totalCapacity;
            amcParking.available += amclvl.available;

            amcParking.details.add(amclvl);
        }
        amcParking.percent = Math.round((amcParking.available * 100) / total);

        return amcParking;
    }

}