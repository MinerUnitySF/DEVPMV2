trigger ContentDocumentTriggerHandler on ContentDocument (before insert, after update) {
    system.debug('@@@ FIle Upload');
    if (Trigger.isBefore && Trigger.isInsert)
        ContentDeliveryTriggerHandler.organizeAttachments(Trigger.new);
}