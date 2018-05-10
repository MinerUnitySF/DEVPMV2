trigger UNITY_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after update, after insert) {

    if (Trigger.isBefore && Trigger.isInsert){
        system.debug('@@@ContentDeliveryLinkTrigger - organizeAttachments');
        UNITY_ContentDocumentLinkTriggerHandler.organizeAttachments(Trigger.new);
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        system.debug('@@@ContentDeliveryLinkTrigger - prepareFileUploadToDocParser');
        UNITY_ContentDocumentLinkTriggerHandler.prepareFileUploadToDocParser(Trigger.new);
    }
}