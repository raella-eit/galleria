public class UserTriggerHandler extends TriggerHandler implements ITriggerHandler {
    private Map<Id, User> newMap;
    private Map<Id, User> oldMap;
    private List<User> triggerNew;
    private List<User> triggerOld;

    public UserTriggerHandler() {
        this.newMap = (Map<Id, User>)Trigger.newMap;
        this.oldMap = (Map<Id, User>)Trigger.oldMap;
        this.triggerNew = (List<User>)Trigger.New;
        this.triggerOld = (List<User>)Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public override void beforeInsert(){
        UserTriggerHelper.addUserNickName(triggerNew);
    }

    public override void afterInsert(){
        UserTriggerHelper.addUserToGroup(triggerNew);
    }

    public override void beforeUpdate(){}

    public override void afterUpdate(){}

    public override void beforeDelete(){}

    public override void afterDelete(){}

    public override void afterUnDelete(){}
}