trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    new ContentDocumentLinkTriggerHandler().run();
}