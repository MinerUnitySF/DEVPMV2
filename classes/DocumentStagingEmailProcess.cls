global class DocumentStagingEmailProcess implements Messaging.InboundEmailHandler 
{
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
 
      Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            
            UNITY_EmailToDocumentStagingParser.parse(email);


        }catch (Exception ex) {
            result.message = 'Insert problem: ' + ex;
            result.success = false;
            return result;
        }
        result.success = true;
        return result;
    }
}