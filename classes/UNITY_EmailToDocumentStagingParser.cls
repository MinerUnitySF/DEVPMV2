public class UNITY_EmailToDocumentStagingParser {
    
    public static void parse(Messaging.inboundEmail email){

        Document_Staging__c newDocStaging;

        String subject     = email.subject.trim();
        String fromAddress = email.fromAddress;
        String fromDomain  = fromAddress.split('@')[1];
        String toDomain    = email.toAddresses[0].split('@')[1];
        
         List<Attachment> attachments = new List<Attachment>();
        if (email.textAttachments != null) {
            for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment txtAttachment = new Attachment();
                txtAttachment.Name = tAttachment.fileName;
                txtAttachment.Body = Blob.valueOf(tAttachment.body);
                attachments.add(txtAttachment);
            }
        }
    
        if (email.binaryAttachments != null) {
            for(Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment binAttachment = new Attachment();
                binAttachment.Name = bAttachment.fileName;
                binAttachment.Body = bAttachment.body;
                attachments.add(binAttachment);
            }
        }
        
       
        newDocStaging = new Document_Staging__c( Incoming_Email_Address__c = email.fromAddress,Email_Subject__c =subject,  Status__c ='New', Document_Source__c = 'email' );
         
        insert newDocStaging;
       
         if(! attachments.isEmpty()) {
            for(Attachment att : attachments) {
                att.ParentId = newDocStaging.Id;
            }
            insert attachments;
        }
    }
}