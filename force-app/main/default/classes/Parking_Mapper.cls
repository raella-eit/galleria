public class Parking_Mapper {
    // public final ParkingWrapper.GRParking ALL_PARKING_INFO = getGeneralParkingInfoNew();

    // not deployed - to be adjusted
    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper> getGeneralParkingInfo() {
        List<ParkingWrapper> generalParkingInfoList = new List<ParkingWrapper>();
        ParkingWrapper westParkingInfo = Parking_Manager.getParkingSlotsAvailable('1010');
        // ParkingWrapper westParkingInfo = Parking_Manager.getParkingSlotsAvailable('1001');
        // ParkingWrapper westParkingInfo = Parking_Manager.getParkingSlotsAvailable('1004');
        ParkingWrapper eastParkingInfo = new ParkingWrapper();
        Integer availableSpotsSum = 0;
        Integer totalSpotsSum = 0;
        for(ParkingWrapper eastParkingDetail : Parking_Manager.getAmcParkingInfoSlotsAvailable()) {
            availableSpotsSum += eastParkingDetail.availableSpots;
            totalSpotsSum += eastParkingDetail.totalSpots;
        }
        eastParkingInfo.id = '1';
        eastParkingInfo.name = System.Label.PARKING_EAST;
        eastParkingInfo.availableSpots = availableSpotsSum;
        eastParkingInfo.totalSpots = totalSpotsSum;
        eastParkingInfo.percentage = String.valueOf(((eastParkingInfo.availableSpots * 100) / eastParkingInfo.totalSpots));
        generalParkingInfoList.add(westParkingInfo);
        generalParkingInfoList.add(eastParkingInfo);

        return generalParkingInfoList;
    }

    @AuraEnabled(cacheable = true)
    public static ParkingWrapper.GRParking getGeneralParkingInfoNew() {
        ParkingWrapper.GRParking generalParkingInfoList = new ParkingWrapper.GRParking();
        ParkingWrapper.Parkingstructure amcParking = new ParkingWrapper.Parkingstructure();
        amcParking.P1Level = new list<ParkingWrapper>();
        amcParking.P2Level = new list<ParkingWrapper>();
        amcParking.P3Level = new list<ParkingWrapper>();
        amcParking.P4Level = new list<ParkingWrapper>();
        amcParking.totalLevel = new ParkingWrapper();

        ParkingWrapper.Parkingstructure southParking = new ParkingWrapper.Parkingstructure();
        southParking.P1Level = new list<ParkingWrapper>();
        southParking.P2Level = new list<ParkingWrapper>();
        southParking.totalLevel = new ParkingWrapper();

        Integer availableSpotsSum = 0;
        Integer totalSpotsSum = 0;

        ParkingWrapper parkingInfo1001 = Parking_Manager.getParkingSlotsAvailable('1001');
        southParking.P1Level.add(parkingInfo1001);
        availableSpotsSum += parkingInfo1001.availableSpots;
        totalSpotsSum += parkingInfo1001.totalSpots;

        ParkingWrapper parkingInfo1004 = Parking_Manager.getParkingSlotsAvailable('1004');
        southParking.P2Level.add(parkingInfo1004);
        availableSpotsSum += parkingInfo1004.availableSpots;
        totalSpotsSum += parkingInfo1004.totalSpots;

        ParkingWrapper southParkingInfo = new ParkingWrapper();
        southParkingInfo = fillGeneralParkingInfo('1', 'West', availableSpotsSum,  totalSpotsSum);
        southParking.totalLevel = southParkingInfo;

        ParkingWrapper eastParkingInfo = new ParkingWrapper();
        availableSpotsSum = 0;
        totalSpotsSum = 0;

        for(ParkingWrapper eastParkingDetail : Parking_Manager.getAmcParkingInfoSlotsAvailable()) {
            availableSpotsSum += eastParkingDetail.availableSpots;
            totalSpotsSum += eastParkingDetail.totalSpots;
            if(eastParkingDetail.level.contains('P1')) {
                amcParking.P1Level.add(eastParkingDetail);
            } else if(eastParkingDetail.level.contains('P2')) {
                amcParking.P2Level.add(eastParkingDetail);
            } else if(eastParkingDetail.level.contains('P3')) {
                amcParking.P3Level.add(eastParkingDetail);
            } else if(eastParkingDetail.level.contains('P4')) {
                amcParking.P4Level.add(eastParkingDetail);
            }
        }
        eastParkingInfo = fillGeneralParkingInfo('1', System.Label.PARKING_EAST, availableSpotsSum,  totalSpotsSum);
        amcParking.totalLevel = eastParkingInfo;

        generalParkingInfoList.AmcParking = amcParking;
        generalParkingInfoList.SouthParking = southParking;

        return generalParkingInfoList;
    }

    private static ParkingWrapper fillGeneralParkingInfo(string Id, string parkingName, integer availableSpotsSum, integer totalSpotsSum){
        ParkingWrapper retVal = new ParkingWrapper();
        retVal.id = Id;
        retVal.name = parkingName;
        retVal.availableSpots = availableSpotsSum;
        retVal.totalSpots = totalSpotsSum;
        retVal.percentage = String.valueOf(((retVal.availableSpots * 100) / retVal.totalSpots));

        return retVal;
    }

    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper> getEastParkingDetails() {
        return Parking_Manager.getAmcParkingInfoSlotsAvailable();
    }

    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper> getParkingInfo () {
        List<ParkingWrapper> generalParkingInfoList = new List<ParkingWrapper>();
        ParkingWrapper.GRParking allResults = getGeneralParkingInfoNew();
        ParkingWrapper amcParking = new ParkingWrapper();
        amcParking.id = System.Label.PARKING_EAST;
        amcParking.name = allResults.AmcParking.totalLevel.name;
        amcParking.level = allResults.AmcParking.totalLevel.level;
        amcParking.zone = allResults.AmcParking.totalLevel.zone;
        amcParking.availableSpots = allResults.AmcParking.totalLevel.availableSpots;
        amcParking.totalSpots = allResults.AmcParking.totalLevel.totalSpots;
        amcParking.percentage = allResults.AmcParking.totalLevel.percentage;
        generalParkingInfoList.add(amcParking);

        ParkingWrapper westParking = new ParkingWrapper();
        westParking.id = System.Label.PARKING_WEST;
        westParking.name = allResults.SouthParking.totalLevel.name;
        westParking.level = allResults.SouthParking.totalLevel.level;
        westParking.zone = allResults.SouthParking.totalLevel.zone;
        westParking.availableSpots = allResults.SouthParking.totalLevel.availableSpots;
        westParking.totalSpots = allResults.SouthParking.totalLevel.totalSpots;
        westParking.percentage = allResults.SouthParking.totalLevel.percentage;
        generalParkingInfoList.add(westParking);

        return generalParkingInfoList;
    }

    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper.ParkingDetail> getEastDetails() {
        ParkingWrapper.GRParking allResults = getGeneralParkingInfoNew();
        List<ParkingWrapper.ParkingDetail> parkingDetailList = new List<ParkingWrapper.ParkingDetail>();
        ParkingWrapper.ParkingDetail p1Detail = new ParkingWrapper.ParkingDetail();
        p1Detail.id = 'P1';
        p1Detail.parkingDetails = allResults.AmcParking.P1Level;
        ParkingWrapper.ParkingDetail p2Detail = new ParkingWrapper.ParkingDetail();
        p2Detail.id = 'P2';
        p2Detail.parkingDetails = allResults.AmcParking.P2Level;
        ParkingWrapper.ParkingDetail p3Detail = new ParkingWrapper.ParkingDetail();
        p3Detail.id = 'P3';
        p3Detail.parkingDetails = allResults.AmcParking.P3Level;
        ParkingWrapper.ParkingDetail p4Detail = new ParkingWrapper.ParkingDetail();
        p4Detail.id = 'P4';
        p4Detail.parkingDetails = allResults.AmcParking.P4Level;

        // p1Details.add(allResults.AmcParking.P1Level)
        // List<List<ParkingWrapper>> eastDetailsList = new List<List<ParkingWrapper>> {p1Details, p2Details, p3Details, p4Details};

        return new List<ParkingWrapper.ParkingDetail> {p1Detail, p2Detail, p3Detail, p4Detail};

    }

    @AuraEnabled(cacheable = true)
    public static List<ParkingWrapper.ParkingDetail> getWestDetails() {
        ParkingWrapper.GRParking allResults = getGeneralParkingInfoNew();
        List<ParkingWrapper.ParkingDetail> parkingDetailList = new List<ParkingWrapper.ParkingDetail>();
        ParkingWrapper.ParkingDetail p1Detail = new ParkingWrapper.ParkingDetail();
        p1Detail.id = 'P1';
        p1Detail.parkingDetails = allResults.SouthParking.P1Level;
        ParkingWrapper.ParkingDetail p2Detail = new ParkingWrapper.ParkingDetail();
        p2Detail.id = 'P2';
        p2Detail.parkingDetails = allResults.SouthParking.P2Level;

        return new List<ParkingWrapper.ParkingDetail> {p1Detail, p2Detail};
    }

}