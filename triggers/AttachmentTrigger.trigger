/**This the trigger for attachments
** @programer: Izay Ramos-Irizarry
** @version: 2.0
** @date: 6/17/2015
*/
trigger AttachmentTrigger on Attachment (before insert, after insert, after update) {
    //Call the emailServiceWorkOrder from AttachmentHelper class
    
    if (Trigger.isInsert && Trigger.isAfter){
      AttachmentHelper.manageServiceReport(Trigger.New);      
    }
  
    if (Trigger.isUpdate && Trigger.isAfter){
     AttachmentHelper.manageServiceReport(Trigger.New);
    }  
  
    if (Trigger.isInsert && Trigger.isBefore){
      AttachmentHelper.uploadDocumentstaingAttachments(Trigger.New);
    }
    
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        AttachmentHelper.prepareFileUploadToDocParser(Trigger.New);
    }
}