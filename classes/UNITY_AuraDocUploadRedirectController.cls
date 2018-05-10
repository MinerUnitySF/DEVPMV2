public class UNITY_AuraDocUploadRedirectController {
	@auraEnabled
    public static Id generateNewDocumentStaging(){
        Document_Staging__c	ds = new Document_Staging__c();
        ds.Document_Source__c = 'Community';
        insert ds;
        return ds.id;
    }
    
}