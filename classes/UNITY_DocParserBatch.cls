/**
 * Created by mbesmonte on 5/7/2018.
 */

global with sharing class UNITY_DocParserBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    String query = 'SELECT Id, DocParser_Id__c, Status__c, Comments__c FROM Document_Staging__c WHERE DocParser_Id__c != null AND Status__c = \'Uploaded\'';

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Document_Staging__c> scope){

        Map<Id, Document_Staging__c> dsSuccessMap = new Map<Id, Document_Staging__c>();

        //Part 1: Create Document Staging Items
        //Create a placeholder for files retrieved from DocParser, as all callouts must be done prior to any DML statements
        List<Document_Staging_Item__c> dsiToInsert = new List<Document_Staging_Item__c>();
        Map<String,Blob> fileFromDocLinkUrlMap = new Map<String,Blob>();

        //Get all document codes/types and put in a map
        Map<String, String> docCodeAndTypeMap = getDocumentTypeReference();

        for(Document_Staging__c ds: scope) {
            List<DocParserBarcodeData> httpresult = UNITY_DocParserUtility.getParsedInfoFromDocParser(ds.DocParser_Id__c);

            //no response from DocParser
            if (httpresult == null) {
                ds.Comments__c += 'Retrieve parsed data: Httpresult is null.  Document not ready.\r\n';
                continue;
            }

            //Set number of child documents; >1 if it's a multi-doc document
            ds.Document_Count__c = httpresult.size();

            //Parse result from DocParser
            Integer counter = 0;
            for (DocParserBarcodeData barcodData : httpresult) {
                counter++;

                Document_Staging_Item__c dsi = new Document_Staging_Item__c();
                dsi.DocPaser_Link__c = barcodData.media_link;
                dsi.Document_Staging__c = ds.Id;
                dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_NEW;
                dsi.Comments__c = '';

                //find the document code and record id
                String documentCode = null;
                Id recordId = null;

                //if there is data from DocParser that has a document type of CCA; get document code and record id
                if (barcodData.ccadata != null) {
                    documentCode = barcodData.ccadata.key_0;
                    recordId = barcodData.ccadata.key_1;
                }
                //if there is data from DocParser that has a document type of WAF; get document code and record id
                if (barcodData.wafdata != null) {
                    documentCode = barcodData.wafdata.key_0;
                    recordId = barcodData.wafdata.key_1;
                }

                //if there's no barcode data, log and continue
                if (documentCode == null || recordId == null) {
                    ds.Comments__c += 'Error obtaining document code for line item: ' + counter;
                    dsi.Comments__c += 'Error obtaining document code(' + documentCode + ') or recordid(' + recordId + ')\r\n';
                    dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                    ds.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                    continue;
                }

                //if there are barcode data, popualte the values to the Document Staging Id
                dsi.Parent_Id__c = recordId;
                dsi.Document_Type_Code__c = documentCode;
                dsi.Comments__c += 'Document code(' + documentCode + ') or recordid(' + recordId + ')\r\n';

                //try to find the document type based on the document code
                String docType = docCodeAndTypeMap.get(documentCode);
                if (docType != null){
                    dsi.Document_Type__c = docType;
                    dsi.Comments__c += 'Document code found.  Type: ' + docType + '\r\n';
                }
                else{
                    ds.Comments__c += 'Document type not found for line item (' + counter + ') using code: ' + documentCode + '\r\n';
                    ds.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                    dsi.Comments__c += 'Document type not found using code: ' + documentCode + '\r\n';
                    dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                }

                //Obtain the split documents from DocParser using the media link they've provided
                Blob b = getAttachmentFromDocParserGivenLink(dsi.DocPaser_Link__c);
                if (b != null){
                    fileFromDocLinkUrlMap.put(dsi.DocPaser_Link__c, b);
                    dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_PARSED;
                }
                else{
                    dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                    dsi.Comments__c += 'Cannot download document from media link\r\n';
                    ds.Comments__c += 'Cannot download document from media link for line item (' + counter + ')\r\n';
                    ds.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                }

                dsiToInsert.add(dsi);

                //add ds to a map, will be referenced later
                if (ds.Status__c != UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED)
                    dsSuccessMap.put(ds.Id, ds);

            }
        }

        //Insert Document Staging Items
        //Log the results and update status up to this point
        insert dsiToInsert;
        update scope;

        //Identify object types of recordIds
        List<Document_Staging_Item__c> workOrderRecords = new List<Document_Staging_Item__c>();
        for (Document_Staging_Item__c dsi: dsiToInsert) {
            if (dsi.Status__c != UNITY_Constants.DOCUMENT_STAGING_STATUS_PARSED)
                continue;

            Id recordID = (Id)dsi.Parent_Id__c;
            String sobjectType = recordID.getSObjectType().getDescribe().getName();

            if (sobjectType == 'WorkOrder') {
                workOrderRecords.add(dsi);
            }
        }

        processWorkOrderRecords(workOrderRecords, fileFromDocLinkUrlMap);


        //Lastly, update status of Document Staging based on the Document Staging items
        List<Document_Staging__c> dsList =[SELECT Status__c, (SELECT Status__c FROM Document_Staging_Items__r)
                                            FROM Document_Staging__c
                                            WHERE Id = :dsSuccessMap.keySet()];

        for(Document_Staging__c ds : dsList) {
            boolean allChildRecordsCompleted = true;
            boolean hasFailure = false;
            for (Document_Staging_Item__c dsi : ds.Document_Staging_Items__r){
                if (dsi.Status__c != UNITY_Constants.DOCUMENT_STAGING_STATUS_ATTACHED){
                    allChildRecordsCompleted = false;
                    break;
                }
                if (dsi.Status__c == UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED){
                    hasFailure = true;
                    break;
                }
            }
            if (!hasFailure && allChildRecordsCompleted && ds.Document_Staging_Items__r != null && ds.Document_Staging_Items__r.size() > 0) {
                ds.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_COMPLETE;
            }
            if (hasFailure)
                ds.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
        }

        update dsList;

    }

    private static Blob getAttachmentFromDocParserGivenLink(String url){
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setTimeout(60000);//sets maximum timeout
        req.setMethod('GET');
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBodyAsBlob(); //6MB limit for sync and 12MB limit for asyc

    }


    private static Map<String, String>  getDocumentTypeReference(){
        List<Document_Type_Code_Mapping__mdt> docReferenceList = [SELECT Type_Code__c, Type__c FROM Document_Type_Code_Mapping__mdt];

        Map<String, String> docCodeAndTypeMap = new Map<String, String>();
        for(Document_Type_Code_Mapping__mdt dtcm : docReferenceList){
            docCodeAndTypeMap.put(dtcm.Type_Code__c, dtcm.Type__c);
        }

        return docCodeAndTypeMap;
    }

    private static void processWorkOrderRecords(List<Document_Staging_Item__c> itemsToProcess, Map<String, Blob> fileFromDocLinkUrlMap){
        //Create unity attachment records
        Map<String, UNITY_Attachment__c> unityToInsert = new Map<String, UNITY_Attachment__c>();
        for (Document_Staging_Item__c dsi: itemsToProcess){
            Id recordID = (Id)dsi.Parent_Id__c;
            String externalId = recordID + dsi.Document_Type_Code__c;

            UNITY_Attachment__c uAtt = new UNITY_Attachment__c();
            uAtt.Work_Order__c = recordID;
            uAtt.UNITY_Type__c = dsi.Document_Type__c;
            unityToInsert.put(externalId, uAtt);
        }

        Database.SaveResult[] unityInsertResults = Database.insert(unityToInsert.values());
        system.debug('@@@DocParseBatch unityInsertResults:'+unityInsertResults);

        //Save records that were successfully inserted
        Set<Id> uAttSuccess = new Set<Id>();
        //Create a map with only successful results
        for (Integer i = 0; i < unityInsertResults.size(); i++) {
            if (unityInsertResults[i].isSuccess()) {
                uAttSuccess.add(unityInsertResults[i].getId());
            }
        }


        //Create the actual attachment for the Unity Att record
        List<Attachment> attToInsert = new List<Attachment>();
        Map<Id, Document_Staging_Item__c> unityAndStagingItemMap = new Map<Id, Document_Staging_Item__c>();

        for (Document_Staging_Item__c dsi: itemsToProcess) {
            if (dsi.Status__c != 'Parsed')
                continue;

            String externalId = (Id)dsi.Parent_Id__c + dsi.Document_Type_Code__c;

            //Check if unity insertion was successful, if so, create attachment
            if (!uAttSuccess.contains(unityToInsert.get(externalId).Id))
                continue;

            attToInsert.add(new Attachment(Name = 'docparser', ParentId = unityToInsert.get(externalId).Id, Body = fileFromDocLinkUrlMap.get(dsi.DocPaser_Link__c)));

            unityAndStagingItemMap.put(unityToInsert.get(externalId).Id, dsi);
        }

        Database.SaveResult[] attchmentInsertResults = Database.insert(attToInsert);
        system.debug('@@@DocParseBatch attchmentInsertResults: '+ attchmentInsertResults);

        //Create an att and ParentId map
        Map<Id, Id> attAndUnityMap = new Map<Id, Id>();
        for (Attachment att: attToInsert){
            attAndUnityMap.put(att.Id, att.ParentId);
        }
        system.debug('@@@DocParseBatch attAndUnityMap: '+ attAndUnityMap);

        //Update Doc Staging Item status
        List<Document_Staging_Item__c> dsiToUpdate = new List<Document_Staging_Item__c>();
        for (Integer i = 0; i < attchmentInsertResults.size(); i++) {
            Id unityId = attAndUnityMap.get(attchmentInsertResults[i].getId());
            if (unityId != null){
                Document_Staging_Item__c dsi = unityAndStagingItemMap.get(unityId);
                if (dsi != null) {
                    if (attchmentInsertResults[i].isSuccess())
                        dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_ATTACHED;
                    else
                        dsi.Status__c = UNITY_Constants.DOCUMENT_STAGING_STATUS_FAILED;
                    dsiToUpdate.add(dsi);
                }
            }
        }
        update dsiToUpdate;

    }


    //This method is called after all batches are processed
    global void finish(Database.BatchableContext bc){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {'mbesmonte@minercorp.com'});
        mail.setReplyTo('mbesmonte@minercorp.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}