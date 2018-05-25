public class UNITY_EmailToDocumentStagingParser {
    
    public static void parse(Messaging.inboundEmail email){

        String subject     = email.subject.trim();
        String fromAddress = email.fromAddress;
        String fromDomain  = fromAddress.split('@')[1];
        String toDomain    = email.toAddresses[0].split('@')[1];
       
         List<ContentVersion> conVerList = new List<ContentVersion>();
        
           if (email.binaryAttachments != null) {
              
                for(Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                   ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; 
                    conVer.PathOnClient = bAttachment.fileName;
                    conVer.Title =  bAttachment.fileName;
                    conVer.VersionData = bAttachment.body; 
                    conVerList.add(conVer);
                }
                
                if ( conVerList.size() > 0)
                     insert conVerList;
           }
    
            List<Document_Staging__c> docStagingList = new List<Document_Staging__c>();
             
            for (Integer i=0; i< conVerList.size(); i++){
               Document_Staging__c  newDocStaging = new Document_Staging__c( Incoming_Email_Address__c = email.fromAddress,Email_Subject__c =subject,  Status__c ='New', Document_Source__c = 'email' );
                system.debug('>>>  newDocStaging  >>> ' + newDocStaging);
               docStagingList.add(newDocStaging);
            }
             
            insert docStagingList;
           
             system.debug('>>>  docStagingList.sieze()  >>> ' + docStagingList.size());
             
            List<ContentDocumentLink> clList = new List<ContentDocumentLink>();
            
            for(ContentVersion cv :[SELECT ContentDocumentId  FROM ContentVersion WHERE ID IN :conVerList]){  
                  system.debug('>>>  ContentDocument id  >>> ' + cv.ContentDocumentId);
                   ID linkedEntityId;
                    for (Integer i = (docStagingList.size()-1) ; i>= 0 ; i--){
                          linkedEntityId = docStagingList[i].ID;
                          docStagingList.remove(i);
                          break;
                     }
                  system.debug('>>>  linkedEntityId  >>> ' + linkedEntityId);
                 ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId =linkedEntityId, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I', Visibility = 'InternalUsers');   
                 
                  system.debug('>>>  ContentDocumentLink >>> ' + cl);
                 clList.add(cl);
            }
           
           if ( clList.size()> 0)
                insert clList;
    }
}