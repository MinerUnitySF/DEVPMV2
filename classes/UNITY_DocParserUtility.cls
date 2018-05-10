global class UNITY_DocParserUtility{


    webservice static String UploadDocumentToDocParserWS(Id documentStagingId){
        return UNITY_DocParserUtility.UploadDocumentToDocParser(documentStagingId);
    }

    @future (callout=true)
    public static void UploadDocumentToDocParserF(Id documentStagingId) {
        UNITY_DocParserUtility.UploadDocumentToDocParser(documentStagingId);
    }

    //This method takes in a document staging id, looks for the File or Attachment, and uploads the file to DocParser
    public static String UploadDocumentToDocParser(Id documentStagingId){

        Document_Staging__c docStaging = [SELECT Id, Status__c, DocParser_Id__c FROM Document_Staging__c WHERE Id = :documentStagingId];

        //Check if the document staging record has a File or an Attachment
        List<Attachment> a = [SELECT ID,Name,Body FROM Attachment WHERE ParentId = :documentStagingId];
        system.debug('@@@UploadDocumentToDocParser attachment a: '+a);

        //look for file if attachment is null
        ContentVersion cv = null;
        if (a.size() == 0){
            List<ContentDocumentLink> cdl = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:documentStagingId];
            if (cdl != null && cdl.size() > 0) {
                cv = [SELECT Id, title, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl[0].ContentDocumentId];
                system.debug('@@@UploadDocumentToDocParser content version cv: '+cv);
            }
        }
        system.debug('@@@UploadDocumentToDocParser -a:'+a);
        system.debug('@@@UploadDocumentToDocParser -cv:'+cv);


        if ((a == null || a.size() ==0) && cv == null){
            system.debug('@@@UploadDocumentToDocParser - no attachment or content version found for documentStagingId:' + documentStagingId);
            return 'No attachment found.';
        }

        Id docId = a.size() != 0 ? a[0].Id : cv.Id;
        system.debug('@@@UploadDocumentToDocParser - file/attachment id - docId:'+docId);
        String filename = a.size() != 0 ? a[0].Name : cv.Title;
        system.debug('@@@UploadDocumentToDocParser - file/attachment filename:'+filename);

        UNITY_DocParser_Settings__c docParserSettings = UNITY_DocParser_Settings__c.getValues('DocParserSetting');

        if (docParserSettings == null){
            system.debug('@@@UploadDocumentToDocParser - UNITY_DocParser_Settings__c is empty!');
            return 'DocParser Setting not found.';
        }

        system.debug('@@@UploadDocumentToDocParser - UNITY_DocParser_Settings__c API_Key__c:'+docParserSettings.API_Key__c);
        system.debug('@@@UploadDocumentToDocParser - UNITY_DocParser_Settings__c Parser_ID__c:'+docParserSettings.Parser_ID__c);
        system.debug('@@@UploadDocumentToDocParser - UNITY_DocParser_Settings__c URL__c:'+docParserSettings.Upload_URL__c);

        // change the following variables according to your use-case
        String strApiKey = docParserSettings.API_Key__c;
        String strParserId = docParserSettings.Parser_ID__c;
        String strTargetURL = docParserSettings.Upload_URL__c;
        strTargetURL = strTargetURL.replace('{0}', strParserId);
        strTargetURL = strTargetURL.replace('{1}', docId);
        String strSeparationKey = '';

        system.debug('@@@UploadDocumentToDocParser - strTargetURL:'+strTargetURL);
        
        // assemble the body payload
        String strHeader = '--' + strSeparationKey + '\nContent-Disposition: form-data; name="file"; filename="' + filename + '"\nContent-Type: application/octet-stream\n\n';
        String strBody = EncodingUtil.base64Encode(a.size() != 0 ? a[0].Body : cv.VersionData);
        String strFooter = '\n--' + strSeparationKey + '--';

        String strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n'));
        while(strHeaderEncoded.endsWith('=')) {
            strHeader+=' ';
            strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n'));
        }
        String strBodyEncoded = strBody;
        String strFooterEncoded = EncodingUtil.base64Encode(Blob.valueOf(strFooter));

        Blob blobBody = null;
        String last4Bytes = strBodyEncoded.substring(strBodyEncoded.length()-4,strBodyEncoded.length());

        if(last4Bytes.endsWith('=')) {
            Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
            HttpRequest objHttpRequest = New HttpRequest();
            objHttpRequest.setBodyAsBlob(decoded4Bytes);
            String last4BytesFooter = objHttpRequest.getBody()+strFooter;
            blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded.substring(0,strBodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
        } else {
            blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded+strFooterEncoded);
        }
        
        if(blobBody.size()>3000000) {
            // throw new CustomException('File size limit is 3 MBytes');
            system.debug('File size limit is 3 MBytes');
        }else{
            system.debug('blobBody.size()'+blobBody.size());
        }
        
        // send out the request
        HttpRequest req = New HttpRequest();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + strSeparationKey);
        req.setHeader('Authorization', 'Basic ' + strApiKey);
        req.setMethod('POST');
        req.setEndpoint(strTargetURL);
        req.setBodyAsBlob(blobBody);
        req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));
        Http http = New Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res.getBody());
        
        JSONParser parser = JSON.createParser(res.getBody());
        string docParserId = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'id')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                docParserId += parser.getText();
            }
        }

        system.debug('@@@UploadDocumentToDocParser - docParserId:' + docParserId);
        if (docParserId != null) {
            docStaging.DocParser_Id__c = docParserId;
            docStaging.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_UPLOADED;
            docStaging.Comments__c = 'Document Upload Successful. DocParserID: '+ docParserId + ' \r\n';
            update docStaging;
            return 'Success';
        }
        else{
            docStaging.Comments__c = 'Document Upload Failed.' + '\r\n';
            docStaging.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
            update docStaging;
            return 'Failed';
        }

    }
    
    public static List<DocParserBarcodeData> getParsedInfoFromDocParser(String docparserId){

        UNITY_DocParser_Settings__c docParserSettings = UNITY_DocParser_Settings__c.getValues('DocParserSetting');

        if (docParserSettings == null){
            system.debug('@@@getParseInfo - UNITY_DocParser_Settings__c is empty!');
        }

        system.debug('@@@getParseInfo - UNITY_DocParser_Settings__c API_Key__c:'+docParserSettings.API_Key__c);
        system.debug('@@@getParseInfo - UNITY_DocParser_Settings__c Parser_ID__c:'+docParserSettings.Parser_ID__c);
        system.debug('@@@getParseInfo - UNITY_DocParser_Settings__c URL__c:'+docParserSettings.Parse_URL__c);

        String strApiKey = docParserSettings.API_Key__c;
        String strParserId = docParserSettings.Parser_ID__c;
        String strTargetURL = docParserSettings.Parse_URL__c;
        strTargetURL = strTargetURL.replace('{0}', strParserId);
        strTargetURL = strTargetURL.replace('{1}', docparserId);

        system.debug('@@@getParseInfo - UNITY_DocParser_Settings__c strTargetURL:'+strTargetURL);

        // send out the request
        HttpRequest req = New HttpRequest();
        req.setHeader('Authorization', 'Basic ' + strApiKey);
        req.setMethod('GET');
        req.setEndpoint(strTargetURL);
        Http http = New Http();
        HTTPResponse res = http.send(req);

        List<DocParserBarcodeData> result = null;
        if (res.getStatusCode() == 200){
            String responseBody = res.getBody();
            system.debug('@@@getParseInfo responseBody:'+responseBody);

            result = DocParserBarcodeData.parse(responseBody);
            system.debug('@@@getParseInfo result :' + result );
        }
        return result;
    }

}