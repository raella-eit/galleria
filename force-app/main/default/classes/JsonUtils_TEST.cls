/**
 * @company name      : EI Technologies - MENA
 * @author            : 
 * @created on        : 11-08-2021
 * @description       : 
 * @last modified on  : 11-08-2021
 * @last modified by  : Raella Frem
**/
@isTest
public with sharing class JsonUtils_TEST {
    private static CustomObjectType obj = new CustomObjectType('Test');

    @isTest
    private static void toJsonTest(){
        List<CustomObjectType> objList = new List<CustomObjectType>();
        objList.add(obj);
        Test.startTest();
        Map<String, Object> result1 = JsonUtils.toJsonMap(obj);
        Map<String, Object> result2 = JsonUtils.toJsonMap(obj, 'jsonValue');
        System.assertNotEquals(null, result1, 'The JSON transformation of the Object is NULL.');
        System.assertNotEquals(null, result2, 'The JSON transformation of the Object is NULL.');
        System.assertEquals(result1, result2, 'The JSON transformation of the same Object is not the same.');
        List<Map<String, Object>> result3 = JsonUtils.toJsonMap(objList);
        List<Map<String, Object>> result4 = JsonUtils.toJsonMap(objList, 'jsonValue');
        System.assertNotEquals(null, result3, 'The JSON transformation of the List of Objects is NULL.');
        System.assertNotEquals(null, result4, 'The JSON transformation of the List of Objects is NULL.');
        System.assert(!result3.isEmpty(), 'The JSON transformation of the List of Objects is empty.');
        System.assert(!result4.isEmpty(), 'The JSON transformation of the List of Objects is empty.');
        System.assertEquals(result3, result4, 'The JSON tranformation of the same List of Objects is not the same.');
        Test.stopTest();
    }

    @isTest
    private static void stripNullValuesTest(){
        Test.startTest();
        Map<String, Object> jsonValue = JsonUtils.stripNullValues(obj.jsonValue);
        System.assert(!jsonValue.isEmpty(), 'Non-NULL values ​​were removed from the result.');
        obj = new CustomObjectType(null);
        Map<String, Object> jsonValueWithoutNulls = JsonUtils.stripNullValues(obj.jsonValue);
        System.assert(jsonValueWithoutNulls.isEmpty(), 'There are NULL values ​​in the Map.');
        Test.stopTest();
    }

    public class CustomObjectType {
        private String name {
            get; set;
        }
        public Map<String, Object> jsonValue {
            get {
                //INDENT-OFF
                return new Map<String, Object> {'PersonName' => this.name};
                //INDENT-ON
            }
        }

        public CustomObjectType(String name){
            this.name = name;
        }
    }
}