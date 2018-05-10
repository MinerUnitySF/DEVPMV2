public class UNITY_AuraCOIExpiredNotifyController {
    private static final String noticeMessage1 = 'Notice of Insurance Expiration ';
    private static final String noticeMessage1a =' Please be advised that your certificate of ';
    private static final String noticeMessage1b =' insurance is due to expire in ';
    private static final String noticeMessage1c = ' Days.'; 
    private static final String noticeMessage1d =' Please send an updated copy of your insurance to: ';
        
    private static final String email =' E-Mail: ServiceProviderUpdate@minercorp.com';
    private static final String fax =' Fax: 210 – 678 – 4125';  
    private static final String expiredCOINotice1 = 'NOTICE OF EXPIRED INSURANCE  ';
    private static final String expiredCOINotice1a = ' Please be advised that we do not have a current certificate of '; 
    private static final String expiredCOINotice1b = ' insurance on file for your company. ';
    private static final String expiredCOINotice1c = ' Please note that if we do not receive an updated certificate of insurance it will affect your ability to receive work orders and can affect issuance of payment. ';
    private static final String expiredCOINotice1d = ' Please send an updated copy of your insurance with Miner named as additional insured to: ';
       
    @AuraEnabled
    public static List<InsuranceExpiredMessages> getExpiredInsurances (){        
        List<InsuranceExpiredMessages> insuranceMessages = new List<InsuranceExpiredMessages>();
        ID userid = userinfo.getUserId();
             
          Contact c = [SELECT AccountID FROM Contact WHERE ID IN (SELECT ContactId
                      FROM User 
                    WHERE Id =: userId)]; 
         insuranceMessages = vendorExpiredInsurances(c.AccountID);
          
         return insuranceMessages;       
    } 
    
    public static List<InsuranceExpiredMessages> vendorExpiredInsurances(String accountID){
          List<InsuranceExpiredMessages> insuranceMessages = new List<InsuranceExpiredMessages>();
          
          if (accountID != NULL){  
                 List <UNITY_Insurance__c> vendorCIOList = [SELECT Id, UNITY_Account__c, UNITY_Expiration_Date__c, UNITY_Insurance_Type__c 
                                                FROM UNITY_Insurance__c
                                                     WHERE UNITY_Account__c =:accountID
                                                     ORDER BY UNITY_Expiration_Date__c DESC];
                  //remove duplicates                                   
                  vendorCIOList =  removeDuplicateCIO (vendorCIOList);
                  
                  for ( UNITY_Insurance__c insurance :vendorCIOList){   
                                                         
                     Date expirationDate = insurance.UNITY_Expiration_Date__c;
                     String insuranceType = insurance.UNITY_Insurance_Type__c;
                     Date todayDate = System.today();                   
                   
                      Integer daysBetween = todayDate.daysBetween(expirationDate);  
                      Boolean compareDays =  (daysBetween <= 60 ? true: false);
                                           
                      InsuranceExpiredMessages message = new InsuranceExpiredMessages();                                           
                       
                        if (daysBetween < 0){ 
                             message.noticeExpiration = expiredCOINotice1;
                             message.noticeTypeCertificateExpired = expiredCOINotice1a;
                             message.noticeCertificateExpired = expiredCOINotice1b;
                             message.noticeCertificateExpiredBold = expiredCOINotice1c;
                             message.noticeCertificateExpiredMsg = expiredCOINotice1d;
                             message.noticeEmail =email;
                             message.noticeFax  = fax;   
                             message.expiredInsurance = true;
                             message.expiredInsuranceInDays = false;
							 message.insuranceType =insuranceType;
                            
                            insuranceMessages.add(message);
                         } 
                         else{                                                    
                                 message.noticeExpiration = noticeMessage1;
                                 message.expiredTypeInsurance = noticeMessage1a;
                                 message.noticeCertificateExpireInDays = noticeMessage1b;
                                 message.noticeDays = daysBetween;
                                 message.noticeInDays = noticeMessage1c;
                                 message.noticeUpdateCopy =noticeMessage1d;
                                 message.noticeEmail = email;
                                 message.noticeFax  = fax;
                                 message.expiredInsuranceInDays = true;
                                 message.expiredInsurance = false; 
                                 message.insuranceType =insuranceType;  
                                  if (compareDays)
                                         insuranceMessages.add(message);
                           }
                       }
           }    
          return insuranceMessages;
    }
    
     private static List<UNITY_Insurance__c> removeDuplicateCIO (List<UNITY_Insurance__c> duplicateInsurance ){
        List<UNITY_Insurance__c> distinctInsurance= new List<UNITY_Insurance__c>();
        
        for (UNITY_Insurance__c cio: duplicateInsurance){
            Boolean found = false;   
            for(Integer i=0; i< distinctInsurance.size(); i++){
                if (cio.UNITY_Insurance_Type__c.equalsIgnoreCase(distinctInsurance[i].UNITY_Insurance_Type__c)){
                    found=true;
                    break;
                }
             }
         if(!found)
               distinctInsurance.add(cio);
        }
         
         
         Date dateForData = System.today().addDays(61);
         List <UNITY_Insurance__c>  insuratceToExpired  = new List<UNITY_Insurance__c>();
         
         for (UNITY_Insurance__c cio: distinctInsurance){
           if (cio.UNITY_Expiration_Date__c <= dateForData) {
               insuratceToExpired.add(cio);
           } 
         }
          
        return insuratceToExpired;
    }
    
    public class InsuranceExpiredMessages{
        @AuraEnabled
        public Boolean expiredInsurance {get;set;}
        @AuraEnabled
        public Boolean expiredInsuranceInDays {get;set;}
        @AuraEnabled
        public String expiredTypeInsurance {get;set;}
        @AuraEnabled
        public String noticeUpdateCopy {get;set;}
        @AuraEnabled
        public String noticeExpiration {get;set;} 
        @AuraEnabled
        public String noticeCertificateExpireInDays {get;set;}
        @AuraEnabled
        public String insuranceType {get;set;}
        @AuraEnabled
        public String noticeFinalExpiration {get;set;}
        @AuraEnabled
        public String noticeCertificateExpired {get;set;}
        @AuraEnabled
        public String noticeCertificateExpiredBold {get;set;}  
        @AuraEnabled
        public String noticeCertificateExpiredMsg {get;set;}  
        @AuraEnabled
        public String noticeTypeCertificateExpired {get;set;}
        @AuraEnabled
        public Integer noticeDays {get;set;}
         @AuraEnabled
        public String noticeInDays {get;set;}
        @AuraEnabled
        public String noticeFax {get;set;}
        @AuraEnabled
        public String noticeEmail {get;set;}
    }
}