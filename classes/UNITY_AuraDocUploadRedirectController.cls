public class UNITY_AuraDocUploadRedirectController {
	@auraEnabled
    public static Id generateNewDocumentStaging(){
        Document_Staging__c	ds = new Document_Staging__c();
        ds.Document_Source__c = 'Community';
        insert ds;
        return ds.id;
    }
    
    @AuraEnabled
    public static List<Document_Staging__c> getDocumentStagingList(){
        return [SELECT Id, File_Name__c, Status__c, CreatedDate, DocParser_Page_Count__c, Document_Source__c, Comments__c, Name FROM Document_Staging__c WHERE OwnerID =: UserInfo.getUserId() ORDER BY CreatedDate];
    }
}