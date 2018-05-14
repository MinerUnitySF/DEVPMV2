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
        List<Attachment> a = [SELECT ID,Name,Body, ContentType, BodyLength FROM Attachment WHERE ParentId = :documentStagingId];
        system.debug('@@@UploadDocumentToDocParser attachment a: '+a);
        //4826251

        //look for file if attachment is null
        ContentVersion cv = null;
        if (a.size() == 0){
            List<ContentDocumentLink> cdl = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:documentStagingId];
            if (cdl != null && cdl.size() > 0) {
                cv = [SELECT Id, title, ContentDocumentId, VersionData, FileType, ContentSize, ContentUrl, ExternalDocumentInfo1 FROM ContentVersion WHERE ContentDocumentId = :cdl[0].ContentDocumentId];
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

        system.debug('@@@heap size remaining:'+Limits.getLimitHeapSize() );
        // assemble the body payload
        String contentDisposition  = '\nContent-Disposition: form-data; name="file"; filename="' + filename;
        String strHeader = '--' + strSeparationKey + contentDisposition + '"\nContent-Type: application/octet-stream\n\n';
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

        return'';
/*
        if(blobBody.size()>8000000) {
            // throw new CustomException('File size limit is 3 MBytes');
            system.debug('File size limit is 8 MBytes');
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
        if (docParserId != null && !String.isEmpty(docParserId)) {
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
*/
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

        List<DocParserBarcodeData> result = new List<DocParserBarcodeData>();
        if (res.getStatusCode() == 200){
            String responseBody = res.getBody();
            system.debug('@@@getParseInfo responseBody:'+responseBody);

            List<Object> untypedResults = (List<Object>)JSON.deserializeUntyped(responseBody);
            system.debug('@@@getParseInfo untypedResults :' + untypedResults );

            for(Object rootObj: untypedResults){
                Map<String, Object> rootMap = (Map<String, Object>)rootObj;
                system.debug('@@@getParseInfo rootObj:' + rootObj );

                DocParserBarcodeData dp = new DocParserBarcodeData();

                for(String attrLabel: rootMap.keySet()){
                    Object obj = rootMap.get(attrLabel);
                    if (attrLabel == 'id'){
                        dp.id = (String)obj;
                    } else if (attrLabel == 'document_id'){
                        dp.document_id = (String)obj;
                    }else if (attrLabel == 'remote_id'){
                        dp.remote_id = (String)obj;
                    }else if (attrLabel == 'file_name'){
                        dp.file_name = (String)obj;
                    }else if (attrLabel == 'media_link'){
                        dp.media_link = (String)obj;
                    }else if (attrLabel == 'media_link_original'){
                        dp.media_link_original = (String)obj;
                    }else if (attrLabel == 'media_link_data'){
                        dp.media_link_data = (String)obj;
                    }else if (attrLabel == 'page_count'){
                        dp.page_count = (Integer)obj;
                    }else if (attrLabel == 'uploaded_at'){
                        dp.uploaded_at = (String)obj;
                    }else if (attrLabel == 'processed_at'){
                        dp.processed_at = (String)obj;
                    }else if (attrLabel == 'barcodedata'){
                        dp.barcodedata = parsetBarcodeDetailsList(obj);
                    }else if (attrLabel == 'wafdetails'){
                        dp.wafdetails = parsetBarcodeDetailsList(obj);
                    }else if (attrLabel == 'ccadetails'){
                        dp.ccadetails = parsetBarcodeDetailsList(obj);
                    }else if (attrLabel == 'ccadata'){
                        dp.ccadata = parseBarcodeDetails(obj);
                    }else if (attrLabel == 'wafdata'){
                        dp.wafdata = parseBarcodeDetails(obj);
                    }

                }
                result.add(dp);
            }


        }
        system.debug('@@@result:'+result);
        return result;
    }

    public  static BarcodeDetails parseBarcodeDetails(Object o){

        BarcodeDetails bd = null;

        if (o == null)
            return bd;

        bd = new BarcodeDetails();
        Map<String, Object> mapObj = (Map<String, Object>)o;
        for(String key: mapObj.keySet()){
            if (key == 'key_0')
                bd.key_0 = (String)mapObj.get(key);
            if (key == 'key_1')
                bd.key_1 = (String)mapObj.get(key);
            if (key == 'key_2')
                bd.key_2 = (String)mapObj.get(key);
        }
        return bd;
    }

    public static List<BarcodeDetails> parsetBarcodeDetailsList(Object obj){
        List<BarcodeDetails> result = null;

        if (obj == null)
            return result;

        //result has to be null if there is no data
        result = new List<BarcodeDetails>();

        if (obj instanceof List<Object>) {
            List<Object> lObj = (List<Object>)obj;
            for (Object o : lObj)
                result.add(parseBarcodeDetails(o));
        } else if (obj != null) {
            result.add(parseBarcodeDetails(obj));
        }

        return result;
    }

}