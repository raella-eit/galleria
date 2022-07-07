public class FeedItemTriggerHandler extends TriggerHandler implements ITriggerHandler {
    private Map<Id, FeedItem> newMap;
    private Map<Id, FeedItem> oldMap;
    private List<FeedItem> triggerNew;
    private List<FeedItem> triggerOld;

    public FeedItemTriggerHandler() {
        this.newMap = (Map<Id, FeedItem>)Trigger.newMap;
        this.oldMap = (Map<Id, FeedItem>)Trigger.oldMap;
        this.triggerNew = (List<FeedItem>)Trigger.New;
        this.triggerOld = (List<FeedItem>)Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public override void beforeInsert(){}

    public override void afterInsert(){
        FeedItemTriggerHelper.sendFeedItemEmail(triggerNew);
    }

    public override void beforeUpdate(){}

    public override void afterUpdate(){}

    public override void beforeDelete(){}

    public override void afterDelete(){}

    public override void afterUnDelete(){}
}