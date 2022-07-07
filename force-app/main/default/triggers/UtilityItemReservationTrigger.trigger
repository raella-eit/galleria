/**
 * @company name      : EI Technologies - MENA
 * @author            : Raella Frem
 * @created on        : 24-08-2021 
 * @description       : 
 * @last modified on  : 24-08-2021
 * @last modified by  : Raella Frem
**/
trigger UtilityItemReservationTrigger on UtilityItemReservation__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new UtilityItemReservationTriggerHandler().run();
}