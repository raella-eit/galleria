/**
 * @company name      : EI Technologies - MENA
 * @author            : Raella Frem
 * @created on        : 11-08-2021
 * @description       : 
 * @last modified on  : 24-08-2021
 * @last modified by  : Raella Frem
**/
public interface ITriggerHandler {
     void beforeInsert();
     void afterInsert();
     void beforeUpdate();
     void afterUpdate();
     void beforeDelete();
     void afterDelete();
     void afterUnDelete();
     Boolean isDisabled();
}