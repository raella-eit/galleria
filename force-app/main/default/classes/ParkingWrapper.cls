public class ParkingWrapper {
    @AuraEnabled
    public String id {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public Integer available {get; set;}
    @AuraEnabled
    public Integer percent {get; set;}
    @AuraEnabled
    public String floor {get; set;}
    @AuraEnabled
    public List<ParkingWrapper> details {get; set;}
}