global class UNITY_VendorExpirationCOINotification implements Database.Batchable<sObject>, Database.Stateful{
      global integer CountContactEmails;
      global integer CountAccountEmails;

    global UNITY_VendorExpirationCOINotification(){
        CountContactEmails = 0;
        CountAccountEmails = 0;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
         Date dateForData = System.today().addDays(61);
         String accID = '0013100001juEEH';
         
       String query = 'SELECT Id, UNITY_Account__c, UNITY_Account__r.ID, ';
          query+=' UNITY_Account__r.Account_Email__c, UNITY_Expiration_Date__c,'; 
          query+=' UNITY_Insurance_Type__c'; 
          query+=' FROM UNITY_Insurance__c';         
          query+=' WHERE UNITY_Account__c IN (SELECT ID FROM Account WHERE UNITY_Vendor_Status__c = ' + '\'Active\'' + ' AND RecordType.Name = ' + '\'Vendor\'' + ')'; 
          query+=' AND UNITY_Account__r.Account_Email__c != NULL';
          query+=' ORDER BY UNITY_Account__c, UNITY_Expiration_Date__c DESC limit 100' ;
          
         return Database.getQueryLocator(query);
    }
     
    global void execute (Database.BatchableContext BC, List<UNITY_Insurance__c> insurances)
    { 
         Set <ID> accID = new Set<ID>();
         for( UNITY_Insurance__c ins : insurances )
          {
             accID.add(ins.UNITY_Account__r.ID);
          }
        
        Map<ID, List<Contact>> accContactMap = new Map <ID, List<Contact>>(); 
       
         for (Contact  c : [SELECT ID, AccountID FROM contact WHERE AccountID IN :accID  ] ){
            if(!accContactMap.containsKey(c.accountID))
                accContactMap.put(c.accountID,new List<Contact>());
                
            accContactMap.get(c.accountID).add(c);
        }
          
         system.debug('>>>> accContactMap >>>>>' + accContactMap.size());
          
        List<String> tempNames = new List<String>{'UNITY_COI_Due_to_Expired', 'UNITY_COI_Due_to_Expire_7_days','UNITY_COI_Due_to_Expire_15_days',
                                                        'UNITY_COI_Due_to_Expire_30_days', 'UNITY_COI_Due_to_Expire_60_days'};
       
        String expiredtemp , expire7temp, expire15temp, expire30temp, expire60temp;
            
                for (EmailTemplate emailTemplates : [SELECT Id,  DeveloperName FROM EmailTemplate WHERE DeveloperName IN : + tempNames])
                {
                    if (emailTemplates.DeveloperName == 'UNITY_COI_Due_to_Expired'){
                        expiredtemp = emailTemplates.ID;
                    }
                    else if (emailTemplates.DeveloperName == 'UNITY_COI_Due_to_Expire_7_days'){
                        expire7temp = emailTemplates.ID;
                    }
                    else if (emailTemplates.DeveloperName == 'UNITY_COI_Due_to_Expire_15_days'){
                         expire15temp = emailTemplates.ID;
                    }
                    else if (emailTemplates.DeveloperName == 'UNITY_COI_Due_to_Expire_30_days'){
                        expire30temp = emailTemplates.ID;
                    }
                    else if (emailTemplates.DeveloperName == 'UNITY_COI_Due_to_Expire_60_days'){
                        expire60temp = emailTemplates.ID;
                    }
                }
                
                //remove duplicates
                 insurances = removeDuplicateCIO (insurances);           
                   
                 for( UNITY_Insurance__c insurance : insurances )
                  {
                        Date expirationDate = insurance.UNITY_Expiration_Date__c;
                        String insuranceType = insurance.UNITY_Insurance_Type__c;
                        Date todayDate = System.today(); 
                       
                        Integer daysBetween = todayDate.daysBetween(expirationDate);  
                        
                        Boolean expired60day =  (daysBetween <= 60 && daysBetween > 30 ? true: false);
                        Boolean expired30day =  (daysBetween <= 30 && daysBetween > 15 ? true: false);
                        Boolean expired15day =  (daysBetween <= 15 && daysBetween > 7 ? true: false);
                        Boolean expired7day =  (daysBetween <= 7 ? true: false);
                        Boolean expired =  (daysBetween < 0 ? true: false);
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                            if (expired){
                                  email.setTemplateId(expiredtemp);
                            }
                            else if (expired7day){
                                 email.setTemplateId(expire7temp);
                            }
                            else if (expired15day){
                                 email.setTemplateId(expire15temp);
                            }
                            else if (expired30day){
                                email.setTemplateId(expire30temp); 
                                
                            }
                            else if(expired60day){
                                 email.setTemplateId(expire60temp);
                            }                            
                          
                             email.setWhatId(insurance.ID);
                             email.setSaveAsActivity(false);
                             
                             if ( accContactMap.size()> 0){
                                 system.debug('>>>> from map >>>>' + accContactMap.get(insurance.UNITY_Account__r.ID));
                                 List<string> cntIDs = new List<String>(); 
                                 for(Contact cnt: accContactMap.get(insurance.UNITY_Account__r.ID)){
                                    cntIDs.add(cnt.ID);
                                    CountContactEmails++;
                                 }
                               
                                 system.debug('>>>> neli Contact List >>>>>' + cntIDs);
                                 //email.setToAddresses(cntIDs) ;  
                                 if (cntIDs.size() > 0) {
                                    email.setTargetObjectId(cntIDs[0]);
                                   
                                     if(!Test.isRunningTest())  
                                         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                                      
                                 }
                             }
                     }  
         }
    
    
    global void finish(Database.BatchableContext info){     
     system.debug('#######  CountContactEmails #####' + CountContactEmails);
     system.debug('#######  CountAccountEmails #####' + CountAccountEmails);
    } 
    
    private static List<UNITY_Insurance__c> removeDuplicateCIO (List<UNITY_Insurance__c> duplicateInsurance ){
        
        List<UNITY_Insurance__c> distinctInsurance= new List<UNITY_Insurance__c>();
        
        for (UNITY_Insurance__c cio: duplicateInsurance){
            Boolean found = false;   
            for(Integer i=0; i< distinctInsurance.size(); i++){
                if (cio.UNITY_Insurance_Type__c.equalsIgnoreCase(distinctInsurance[i].UNITY_Insurance_Type__c)
                            && cio.UNITY_Account__c.equals(distinctInsurance[i].UNITY_Account__c)){
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
}