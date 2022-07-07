public with sharing class ContentDocumentLinkTriggerHandler  extends TriggerHandler implements ITriggerHandler {
	private Map<Id, ContentDocumentLink> newMap;
	private Map<Id, ContentDocumentLink> oldMap;
	private List<ContentDocumentLink> triggerNew;
	private List<ContentDocumentLink> triggerOld;

	public ContentDocumentLinkTriggerHandler(){
		this.newMap = (Map<Id, ContentDocumentLink>)Trigger.newMap;
		this.oldMap = (Map<Id, ContentDocumentLink>)Trigger.oldMap;
		this.triggerNew = (List<ContentDocumentLink>)Trigger.New;
		this.triggerOld = (List<ContentDocumentLink>)Trigger.Old;
	}

	public static Boolean TriggerDisabled = false;
	public Boolean isDisabled(){
		return TriggerDisabled;
	}

	public override void beforeInsert(){
        ContentDocumentLinkTriggerHelper.setVisibility(triggerNew);
	}

	public override void afterInsert(){
		ContentDocumentLinkTriggerHelper.createContentDistribution(triggerNew);
	}

	public override void beforeUpdate(){
	}

	public override void afterUpdate(){
	}

	public override void beforeDelete(){
	}

	public override void afterDelete(){
	}

	public override void afterUnDelete(){
	}
   
}