public class UNITY_AuraPrintCoverPage {
    
    @AuraEnabled
    public static List<String> getDocumentTypes(){
        List<string> result = new List<string>();
        System.debug('@@@getDocumentTypes:'+result);
        /*Schema.DescribeFieldResult F = UNITY_Attachment__c.UNITY_Type__c.getDescribe();
        List<PicklistEntry> entries = F.getPicklistValues();
        for (PicklistEntry ple : entries){
            result.add(ple.getLabel());
        }*/
        
        List<Document_Type_Code_Mapping__mdt> dtcList = [SELECT Type_Code__c, Type__c FROM Document_Type_Code_Mapping__mdt];
        for (Document_Type_Code_Mapping__mdt dtcm: dtcList){
             result.add(dtcm.Type__c);
        }        
        System.debug('@@@getDocumentTypes:'+result);
        return result;   
    }
    
    @AuraEnabled
    public static String getURL(){
        String result;
        
        ConnectApi.CommunityPage comList = ConnectApi.Communities.getCommunities();
        
        for (ConnectApi.Community c: comList.communities){
            if (c.Name == 'Service Provider Community'){
                result =c.siteUrl;
                continue;
            }
        }
        return result;
    }
    
}