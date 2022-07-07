/**
 * @company name      : EI Technologies - MENA
 * @author            : elie.nassif@eit-mena.com
 * @created on        : 10-01-2020 
 * @description       : 
 * @last modified on  : 11-08-2021
 * @last modified by  : Raella Frem
**/
public class ObjectUtils {
    //Function to retrieve a '.class' object (Type) based on a class name
    //Doesn't work if the class is private
    public static Type getClassByClassName(String className){
        return Type.forName(className);
    }

    //Function to retrieve the name of the class based to its instance
    public static String getClassNameByInstance(Object classInstance){
        return String.valueOf(classInstance).split(':')[0];
    }

    //Function to retrieve the variables of a class from a class object
    public static Set<String> getClassAttributeSet(Type myClass){
        Object classInstance = myClass.newInstance();

        String classFieldsSerialize = JSON.serialize(classInstance);
        Map<String, Object> classFieldsDeserialize = (Map<String, Object>) JSON.deserializeUntyped(classFieldsSerialize);

        return classFieldsDeserialize.keyset().clone();
    }

    /**
     * @description : Returns the Record Type Id for a specific Record Type Developer Name
     * @author elie.nassif@eit-mena.com | 10/01/2020
     * @param String objectName AND String recordTypeDevName
     * @return Id
     **/
    @AuraEnabled(cacheable = true)
    public static Id getRecordTypeId(String objectName, String recordTypeDevName) {
        Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();

        return recordTypeId;
    }

    /**
     * @description : Returns all Record Type in a map for a specific Object Name
     * @author elie.nassif@eit-mena.com | 10/01/2020
     * @param String objectName AND String recordTypeDevName
     * @return Id
     **/
    public static Map<String, Schema.RecordTypeInfo> getRecordTypesMap(String objectName) {
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();

        return recordTypesMap;
    }

    /**
     * @description Method to check if the current Org is a Sandbox or Production
     * @author elie.nassif@eit-mena.com | 2020-08-28
     * @return Boolean
     **/
    public static Boolean isSandboxOrg() {
        Boolean isSandbox = true; //For security, we return isSandbox by default
        List<Organization> orgs = [SELECT IsSandbox FROM Organization LIMIT 1];
        if(!orgs.isEmpty()) {
            isSandbox = orgs.get(0).IsSandbox;
        }

        return isSandbox;
    }

    //This method is tested in CaseTriggerClass (Process Migration Net)
    /**
     * @description
     * @author elie.nassif@eit-mena.com | 09-23-2020
     * @param String objectName
     * @return String
     **/
    public static String getAllFieldsObjectsForClone(String objectName) {
        Set<String> fieldsValues = new Set<String>();
        Set<String> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(String field : fieldsMap.keySet()) {
            if(fieldsMap.get(field).getDescribe().isAccessible() && fieldsMap.get(field).getDescribe().isUpdateable()) {
                fieldsValues.add(field);
            }

        }

        return String.join((Iterable<String>)fieldsValues, ', ');
    }

    /**
     * @description Returns any picklist value visible to current User
     * @author elie.nassif@eit-mena.com | 2021-01-05
     * @param String sObjectName
     * @param String picklistFieldName
     * @return List<Schema.PicklistEntry>
     **/
    public static List<Schema.PicklistEntry> getPicklistOptionsBySObjectName(String sObjectName, String picklistFieldName) {
        Schema.SObjectType globalDescription = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult objDescrResult = globalDescription?.getDescribe();
        Map<String, Schema.SObjectField> fields = objDescrResult?.fields?.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(picklistFieldName)?.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult?.getPicklistValues();

        return picklistEntries;
    }

    /**
     * @description : This method return the mime type (extension) of a document using base 64 String
     * https ://stackoverflow.com/questions/57976898/how-to-get-mime-type-from-base-64-string
     * @author elie.nassif@eit-mena.com | 02-08-2021
     * @param String contentDocument
     * @return String
     **/
    static public String getMimeType(string contentDocument){
        String type;
        if(contentDocument.startsWith('JVBERi0')) {
            type = 'pdf';
        } else if(contentDocument.startsWith('iVBORw0KGgo')) {
            type = 'png';
        } else if(contentDocument.startsWith('/9j/4AAQSk')) {
            type = 'jpg';
        } else if(contentDocument.startsWith('SUkqA')) {
            type = 'tif';
        }

        return type;
    }

    /**
     * @description Returns a random entry in a List of Strings
     * @author elie.nassif@eit-mena.com | 03-11-2021
     * @param List<String> listOfElements
     * @return String
     **/
    static public String getRandomElementInListOfString(List<String> listOfElements){
        Integer listRealSize = listOfElements.size() - 1;
        Integer randomIndex = Integer.valueof((Math.random() * listRealSize));

        return listOfElements.get(randomIndex);

    }

    /**
     * @description Returns the `URL__c` value of a `URLs__c` custom setting record
     * @author elie.nassif@eit-mena.com | 07-05-2021
     * @param customSettingName label of the URLs__c custom setting record to query
     * @return String URL value of the retrieved custom setting record
     **/
    /*
    @AuraEnabled(cacheable=true)
    static public String getURLCustomSetting(String customSettingName) {
        List<URLs__c> queriedURLs = [SELECT URL__c
                                     FROM URLs__c
                                     WHERE Name =: customSettingName];

        return !queriedURLs.isEmpty() ? queriedURLs.get(0).URL__c : '';
    }*/

    /**
     * @description Methods and functions in withoutSharing
     */
    public without sharing class ObjectUtilsWoSharing {
        /**
         * @description Removes the sObject list in withoutSharing
         * @param List<SObject> listOfElements
         * @return void
         */
        public void deleteSobjectList(List<SObject> sobjectList){
            delete sobjectList;
        }
    }
}