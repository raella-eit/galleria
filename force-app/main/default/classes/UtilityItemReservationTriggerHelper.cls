public with sharing class UtilityItemReservationTriggerHelper {
    
    public static final Integer MAX_ITEMS_PER_DAY = 0;
    
    /**
* @description - retrieves available utility items filtered by chosen type (from reservation) and reserves one item for customer
*              - retrieves current user's contact id and links the UtilityItemReservation record to the customer's Contact record
* @author Raella Frem | 24-08-2021
* @param List<UtilityItemReservation__c> triggerNew
**/
    public static void reserveAvailableUtilityItem (List<UtilityItemReservation__c> triggerNew) {
        
        /*
* Get Current User's Contact Id
*/
        List<User> currentUser = [SELECT Id, ContactId,AccountId, Profile.Id, Total_Reservations__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        for(User user : currentUser) {
            decimal total = 0;
            
            if(user.Total_Reservations__c !=null )
            {
                total = user.Total_Reservations__c;
            }
            system.debug('user' +user);
            user.Total_Reservations__c = triggerNew.isEmpty()? total : total + triggerNew.size();
            
        }
        
        Id currentUserContactId = currentUser?.get(0).ContactId;
        //
        Id currentUserAccountId = currentUser?.get(0).AccountId;
        //
        /*
* Retrieve new Reservations Item Types and Reservation Dates
*/
        String requestedReservationType;
        Date requestedReservationDate;
        Time requestedReservationStartTime;
        Time requestedReservationEndTime;
        
        if(!triggerNew.isEmpty()) {
            requestedReservationType = triggerNew.get(0).Type__c;
            requestedReservationDate = triggerNew.get(0).Day__c;
            requestedReservationStartTime = triggerNew.get(0).FromTime__c;
            requestedReservationEndTime = triggerNew.get(0).ToTime__c;
        }
        
        /*
* Retrieve all Utility Items with (or without) Reservations of same Type and Day as New Reservation
*/
        UtilityItemReservationTriggerHelperWO utilityItemReservationTriggerHelperWO = new UtilityItemReservationTriggerHelperWO();
        List<UtilityItem__c> conflictingUtilityItemList =
            utilityItemReservationTriggerHelperWO.getExistingItemsList(requestedReservationType,
                                                                       requestedReservationDate,
                                                                       requestedReservationStartTime,
                                                                       requestedReservationEndTime);
        
        Map<String, List<UtilityItem__c>> itemsByTypeMap = new Map<String, List<UtilityItem__c>>();
        List<UtilityItem__c> utilityItemList = null;
        
        /*
* Check if Utility Item has Children (-> has reservations)
*/
        for(UtilityItem__c item : conflictingUtilityItemList) {
            if(item.Utility_Item_Reservations__r.isEmpty()) {
                utilityItemList = itemsByTypeMap.containsKey(item.Type__c) ? itemsByTypeMap.get(item.Type__c) : new List<UtilityItem__c>();
                utilityItemList.add(item);
                itemsByTypeMap.put(item.Type__c, utilityItemList);
            }
        }
        
        for(UtilityItemReservation__c newItemReservationRec : triggerNew) {
            /*
* If Add from Community -> Contact field not visible ->
*      Add current user's contact Id to Utility Item Reservation record
* If Add by System Administrator ->
*      Contact field shall be added manually by sys admin
*/
           /* if(newItemReservationRec.Contact__c == null && UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER)) {
                newItemReservationRec.Contact__c = currentUserContactId;
            }
            if(newItemReservationRec.Contact__c == null && UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER)) {
                newItemReservationRec.Contact__c = currentUserContactId;
            }*/
            //
            if(newItemReservationRec.Customer_Type_Account__c == null && UserInfo.getProfileId() == ProfileUtils.getProfileIdByName(ProfileUtils.GR_CUSTOMER_USER)) {
                newItemReservationRec.Customer_Type_Account__c = currentUserAccountId;
            }
            
            //
            	
            /*
* If found available in Map<"Type","Available Utility Items">
*      Add Item to Reservation
* Else
*      Add Error
*/
            if(itemsByTypeMap.containsKey(newItemReservationRec.Type__c)) {
                utilityItemList = itemsByTypeMap.get(newItemReservationRec.Type__c);
                if(!utilityItemList.isEmpty()) {
                    newItemReservationRec.UtilityItem__c = utilityItemList.remove(0).Id;
                } else {
                    newItemReservationRec.addError(String.format(System.Label.NoItemsAvailable, new String[] {newItemReservationRec.Type__c}));
                }
            } else {
                newItemReservationRec.addError(String.format(System.Label.NoItemsAvailable, new String[] {newItemReservationRec.Type__c}));
            }
        }
        
        update currentUser;
    }
    
    /**
* @description restricts the number of items that a user can book per day depending on MAX_ITEMS_PER_DAY variable
* @author Raella Frem | 28-09-2021
* @param List<UtilityItemReservation__c> triggerNew
**/
    public static void restrictNbOfReservations (List<UtilityItemReservation__c> triggerNew) {
       
        //Id contactId;
        Id accountId;
        Date requestedReservationDate = null;
        if(!triggerNew.isEmpty()) {
           	accountId = triggerNew.get(0).Customer_Type_Account__c;
           //  contactId = triggerNew.get(0).Contact__c;
            requestedReservationDate = triggerNew.get(0).Day__c;
        }
        
        /*if(MAX_ITEMS_PER_DAY != 0 && getNumberOfExistingReservations(contactId, requestedReservationDate) == MAX_ITEMS_PER_DAY + 1) {
            triggerNew.get(0).Day__c.addError(System.Label.MAX_RESERVATIONS_REACHED);
        }*/
        if(MAX_ITEMS_PER_DAY != 0 && getNumberOfExistingReservations(accountId, requestedReservationDate) == MAX_ITEMS_PER_DAY + 1) {
            triggerNew.get(0).Day__c.addError(System.Label.MAX_RESERVATIONS_REACHED);
        }
    }
    
   // public static Integer getNumberOfExistingReservations(Id contactId, Date requestedReservationDate) {
   public static Integer getNumberOfExistingReservations(Id accountId, Date requestedReservationDate) {
        return [SELECT COUNT()
                FROM UtilityItemReservation__c
               // WHERE Contact__c = : contactId
                WHERE Customer_Type_Account__c = : accountId
                AND Day__c = : requestedReservationDate];
    }
    
    public without sharing class UtilityItemReservationTriggerHelperWO {
        
        public List<UtilityItem__c> getExistingItemsList(String requestedReservationType,
                                                         Date requestedReservationDate,
                                                         Time requestedReservationStartTime,
                                                         Time requestedReservationEndTime) {
                                                             return [SELECT Name, Id, Type__c,
                                                                     (SELECT Name, Day__c, FromTime__c, ToTime__c, Id
                                                                      FROM Utility_Item_Reservations__r
                                                                      WHERE Day__c = : requestedReservationDate
                                                                      AND FromTime__c <= : requestedReservationEndTime
                                                                      AND ToTime__c >= : requestedReservationStartTime
                                                                     )
                                                                     FROM UtilityItem__c
                                                                     WHERE Type__c = : requestedReservationType
                                                                     AND isActive__c = TRUE];
                                                         }
    }
}