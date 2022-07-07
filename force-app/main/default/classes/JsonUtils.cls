/**
 * @company name      : EI Technologies - MENA
 * @author            : elie.nassif@eit-mena.com
 * @created on        : 05-18-2021
 * @description       : 
 * @last modified on  : 11-08-2021
 * @last modified by  : Raella Frem
**/
public class JsonUtils {
    /**
     * @description An overloaded form of `toJsonMap(Object,String)` that defaults the `String` parameter to "jsonValue"
     * @author elie.nassif@eit-mena.com | 05-18-2021
     * @param Object anyObject
     * @return Map<String, Object>
     **/ 
    public static Map<String, Object> toJsonMap(Object anyObject){
        return toJsonMap(anyObject, 'jsonValue');
    }

    /**
     * @description Transforms any `Object` (usually a custom class) to JSON (`Map<String, Object>`) using a custom
     * method that provides keys that are different from the `Object`s' properties.
     * e.g.: An object ABC with a property Name will normally be transformed to {"Name": Name}.
     *       But when using this utils method with the same object ABC, you can choose to use a custom method from ABC
     *       that generates a `new Map<String, Object>{'PersonName' => Name}` which generates {"PersonName" : Name}
     * @author elie.nassif@eit-mena.com | 05-18-2021
     * @param Object anyObject, String toJsonMapMapMethod
     * @return Map<String, Object>
     **/
    public static Map<String, Object> toJsonMap(Object anyObject, String toJsonMapMapMethod){
        toJsonMapMapMethod = String.isNotBlank(toJsonMapMapMethod) ? toJsonMapMapMethod : 'jsonValue';
        String jsonString = JSON.serialize(anyObject, false);
        Map<String, Object> classPropertyMap;
        //transform the json string into a Map to be able to access the values dynamically
        classPropertyMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

        //extract only the jsonValue which contains the mapping from Salesforce -> Advize
        return (Map<String, Object>)classPropertyMap.get(toJsonMapMapMethod);
    }

    /**
     * @description An overloaded form of `toJsonMap(List<Object>,String)` that defaults the `String` parameter to "jsonValue"
     * @author elie.nassif@eit-mena.com | 05-18-2021
     * @param List<Object> objectList
     * @return List<Map<String, Object>>
     **/
    public static List<Map<String, Object>> toJsonMap(List<Object> objectList){
        return toJsonMap(objectList, 'jsonValue');
    }

    /**
     * @description An overloaded form of `toJsonMap(Object,String)` that defaults the `String` parameter to "jsonValue"
     *              And goes over a List of objects.
     * @author elie.nassif@eit-mena.com | 05-18-2021
     * @param List<Object> objectList , String toJsonMapMapMethod
     * @return List<Map<String, Object>>
     **/
    public static List<Map<String, Object>> toJsonMap(List<Object> objectList, String toJsonMapMapMethod){
        List<Map<String, Object>> stringList = new List<Map<String, Object>>();
        if(objectList != null && !objectList.isEmpty()) {
            for(Object objet : objectList) {
                //extract only the result which contains the properties json mapping
                stringList.add(toJsonMap(objet, toJsonMapMapMethod));
            }
        }

        return stringList;
    }

    /**
     * @description Removes null values from a JSON's Map representation
     * @author elie.nassif@eit-mena.com | 05-18-2021
     * @param Map<String, Object> originalMap
     * @return Map<String, Object>
     **/
    public static Map<String, Object> stripNullValues(Map<String, Object> originalMap){
        Map<String, Object> resultMap = new Map<String, Object>();
        for(String key : originalMap.keySet()) {
            Object value = originalMap.get(key);
            if(value != null && String.isNotBlank(String.valueOf(value))) {
                resultMap.put(key, value);
            }
        }

        return resultMap;
    }
}