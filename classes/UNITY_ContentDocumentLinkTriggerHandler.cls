public class UNITY_ContentDocumentLinkTriggerHandler {

    //prevent multiple attachments in the Document Staging table
    public static void organizeAttachments(List<ContentDocumentLink > contentList){

        //get linkedentityid and check if it's related to Document Staging
        Map<ContentDocumentLink, Id> cdlAndParentId = new Map<ContentDocumentLink, Id>();
        Set<Id> parentSet = new Set<Id>();
        for (ContentDocumentLink  cd: contentList){
            system.debug('@@@organizeAttachments cd.LinkedEntityId :'+cd.LinkedEntityId );
            String sobjectType =cd.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (sobjectType == 'Document_Staging__c'){
                cdlAndParentId.put(cd, cd.LinkedEntityId);
                parentSet.add(cd.LinkedEntityId);
            }
        }
        system.debug('@@@organizeAttachments cdlAndParentId:' + cdlAndParentId);
        system.debug('@@@organizeAttachments parentSet:' + parentSet);
                
        //get records to be reParented
        List<ContentDocumentLink> reparentRecords = new List<ContentDocumentLink>();
        
        if (cdlAndParentId.size() > 0){

            //Is there content with the same parent?                                                                    
            List<ContentDocumentLink> cdlMap = [SELECT ID, LinkedEntityId
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId in :parentSet];

            Set<Id> parentWithAssocDocStagingRecord = new Set<Id>();
            
            for(ContentDocumentLink cdl: cdlMap){
                parentWithAssocDocStagingRecord.add(cdl.LinkedEntityId);
            }

            parentSet = new Set<Id>(); //repopulate parentset with just those that exists in multiple cds
            //find content where linkedentityid already exists
            for (ContentDocumentLink cd: cdlAndParentId.keySet()){
                if (parentWithAssocDocStagingRecord.contains(cd.LinkedEntityId)){
                    parentSet.add(cd.LinkedEntityId);
                    reparentRecords.add(cd);
                }
            }
            
        }
        
        system.debug('@@@organizeAttachments reparentRecords:' + reparentRecords);
        system.debug('@@@organizeAttachments parentSet:' + parentSet);

        //Get parent records
        Map<ID, Document_Staging__c> parentMap = new  Map<ID, Document_Staging__c>([SELECT ID, Document_Source__c, Status__c
                                                                                        FROM Document_Staging__c 
                                                                                        WHERE ID IN :parentSet]);

        //reparent the CDLs
        List<Document_Staging__c> newDocStagingList = new List<Document_Staging__c>();
        for (ContentDocumentLink cdl : reparentRecords){
            Document_Staging__c origParent = parentMap.get(cdl.LinkedEntityId);
            
            Document_Staging__c newDocStaging = new Document_Staging__c(Document_Source__c = origParent.Document_Source__c, Status__c =origParent.Status__c );
            newDocStagingList.add(newDocStaging);  
        }

        system.debug('@@@organizeAttachments newDocStagingList:' + newDocStagingList);
        
        if (newDocStagingList.size() > 0)
            insert newDocStagingList;
        
        Integer counter = 0;
        for (ContentDocumentLink cdl : reparentRecords){
            cdl.LinkedEntityId = newDocStagingList[counter].Id;
            counter ++;
        }
        
        system.debug('@@@organizeAttachments reparentRecords:'+reparentRecords);

    }

    /** upload attachments to DocParser */
    public static void prepareFileUploadToDocParser(List<ContentDocumentLink> contentDocLinkList){ 

        //Check if File is related to Document Staging
        Map<Id, ContentDocumentLink> filesForDocStagingMap = new Map<Id, ContentDocumentLink>();
        Set<Id> docStagingIds = new Set<Id>();
        Set<Id> contentDocIds = new Set<Id>();

        system.debug('@@@prepareFileUploadToDocParser contentDocLinkList:'+contentDocLinkList);

        for (ContentDocumentLink cd: contentDocLinkList){
            String sobjectType = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (sobjectType == 'Document_Staging__c'){
                filesForDocStagingMap.put(cd.Id, cd);
                docStagingIds.add(cd.LinkedEntityId);
                contentDocIds.add(cd.ContentDocumentId);
            }
        }

        //if there are no files related to Document Staging, return
        if (docStagingIds.size() <= 0)
            return;

        system.debug('@@@prepareFileUploadToDocParser contentDocIds'+contentDocIds);

        //Get content document
        Map<Id, ContentDocument> cdMap = new Map<Id, ContentDocument>([SELECT Id, LatestPublishedVersionId,Title FROM ContentDocument
                                                                        WHERE Id in :contentDocIds]);

        system.debug('@@@prepareFileUploadToDocParser contend document map cdMap:'+cdMap);

        //Create a content distribution for each file, so it can be externally accessed
        List<ContentDistribution> contentDistributionToInsert = new List<ContentDistribution>();
        for (ContentDocumentLink cdl : filesForDocStagingMap.values()){
            ContentDocument cd = cdMap.get(cdl.ContentDocumentId);
            if (cd == null)
                continue;
            ContentDistribution cdist = new ContentDistribution();
            cdist.Name = cd.Title;
            cdist.ContentVersionId = cd.LatestPublishedVersionId;
            cdist.PreferencesAllowOriginalDownload = true;
            cdist.PreferencesAllowPDFDownload = true;
            cdist.PreferencesAllowViewInBrowser = true;
            cdist.PreferencesExpires = false;
            cdist.PreferencesPasswordRequired = false;
            contentDistributionToInsert.add(cdist);
        }

        Database.SaveResult[] result = Database.Insert(contentDistributionToInsert, false);

        system.debug('@@@prepareFileUploadToDocParser Content Distribution save result:'+result);

        //Get Ids of successful insert
        Set<Id> cdistLinkIds = new Set<Id>();
        for (Database.SaveResult r : result){
            if (r.isSuccess())
                cdistLinkIds.add(r.getId());
        }

        Map<Id, ContentDistribution> contentDistMap = new Map<Id, ContentDistribution>([SELECT Id, PdfDownloadUrl, ContentDownloadUrl, ContentDocumentId
                                                    FROM ContentDistribution WHERE Id in :cdistLinkIds]);

        system.debug('@@@prepareFileUploadToDocParser Content Distribution map: '+contentDistMap);
        Map<Id, Id> contentDocAndcontentDistMap = new Map<Id,Id>();
        for (ContentDistribution cdist: contentDistMap.values()){
            contentDocAndcontentDistMap.put(cdist.ContentDocumentId, cdist.Id);
        }
        system.debug('@@@prepareFileUploadToDocParser Content Doc & Content Dist Map: '+contentDocAndcontentDistMap);

        //Fetch document staging records
        Map<Id, Document_Staging__c> docStagingMap = new Map<Id, Document_Staging__c>([SELECT Id, Status__c
                                                                                        FROM Document_Staging__c
                                                                                        WHERE Status__c = 'New'
                                                                                        AND DocParser_Id__c = null
                                                                                        AND Id = :docStagingIds]);


        for (ContentDocumentLink a: filesForDocStagingMap.values()){
            Document_Staging__c ds = docStagingMap.get(a.LinkedEntityId);
            Id cdistId = contentDocAndcontentDistMap.get(a.ContentDocumentId);
            ContentDistribution cdist = contentDistMap.get(cdistId);
            ds.Content_Download_URL__c = cdist.ContentDownloadUrl;
            ds.Pdf_Download_Url__c = cdist.PdfDownloadUrl;
            ContentDocument cd = cdMap.get(a.ContentDocumentId);
            ds.File_Name__c = cd.Title;
        }
        update docStagingMap.values();

        system.debug('@@@prepareFileUploadToDocParser updated docStagingMap: '+docStagingMap);

        for (ContentDocumentLink a: filesForDocStagingMap.values()){
            Document_Staging__c ds = docStagingMap.get(a.LinkedEntityId);
            if (ds != null)
                UNITY_DocParserUtility.UploadDocumentToDocParserViaLinkF(ds.Id);
        }


    }

}