@isTest
 private class UNITY_SchdlEmailToVendorCOIExpiration_UT {
     public static String CRON_EXP = '0  00 1 3 * ?';
     
     @isTest
     static void testSendCIOExpiredNofitication(){
        Map<String, Object> initData = data_Account();   
        List<Account> vendors = (List<Account>)initData.get('vendors');
       
        Test.startTest();        
        
        Account vendor = [SELECT ID, Name, UNITY_Vendor_Status__c, RecordType.Name FROM Account WHERE ID =: vendors.get(0).id];
        Contact contact = new Contact( FirstName = 'Vendor1', Lastname = 'Vendor',  AccountId = vendor.Id, Email = 'test@test.com' );
        insert contact;
        
        List<String> insuranceTypes = New List<String> {'Automobile Liability','General Liability','Installation Floater Liability',
                                               'Rented Equipment Liability', 'Umbrella Liability','Workers Compensation Liability'};
        List<Integer> numberOfDays = new List<Integer>{-2, 6, 12, 28, 55, 90};
              
        List<UNITY_Insurance__c> insurances = new List<UNITY_Insurance__c>();      
        for (integer i =0; i< numberOfDays.size();i++){
             
            UNITY_Insurance__c insur = new UNITY_Insurance__c();            
             insur.UNITY_Insurance_Type__c = insuranceTypes[i];
             insur.UNITY_Required__c = true;
             insur.UNITY_Account__c = vendor.ID;
             insur.UNITY_Insured_Amount__c = 10000;
             insur.UNITY_Expiration_Date__c = Date.valueOf(Datetime.now().addDays(numberOfDays[i]));
            
            system.debug('>>> insur >>> ' + insur);
            insurances.add(insur);
        }
        
        system.assert(insurances.size() == 6);
        insert insurances;
         
        UNITY_ScheduleEmailToVendorCOIExpiration schdCIOExpirationEmail = new UNITY_ScheduleEmailToVendorCOIExpiration();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, schdCIOExpirationEmail);
        
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                   FROM CronTrigger WHERE id = :jobId];
        
        system.debug('>>>  ct  >>> ' + ct);       
        system.assertEquals(CRON_EXP, ct.CronExpression);
        system.assertEquals(0, ct.TimesTriggered);
         
         Integer beforeInvocations = Limits.getEmailInvocations();
         system.debug('>>> beforeInvocations >> ' + beforeInvocations);
         system.assertEquals(0, beforeInvocations, 'no email sent');

        Test.stopTest();         
     }
   
    static Map<String, Object> data_Account() {
        
        Map<String,Object> toReturn = new Map<String,Object>();
        
        Account customer  = new Account();
        List<Account> vendors = new List<Account>();
        List<Account> accounts = new List<Account>();
        
        Map<String,boolean> serviceRequestType          = new   Map<String,boolean>{'UNITY_Vendor_Type_SR__c'=>true}; 
            
        Map<String,Object> workOrderFields             = UNITY_TestDataFactory.MOCKUP_WORK_ORDER_FIELDS;
        Map<String,Object> vendorPreferenceFields      = UNITY_TestDataFactory.MOCKUP_VENDOR_TRADE_FIELDS;
        Map<String,Object> vendorPreferenceTradeFields = UNITY_TestDataFactory.MOCKUP_VENDOR_PREFERENCE_TRADE_FIELDS;
        Map<String,Object> vendorTradeFields           = UNITY_TestDataFactory.MOCKUP_VENDOR_TRADE_FIELDS;
        Map<String,Object> vendorLocationFields        = UNITY_TestDataFactory.MOCKUP_VENDOR_LOCATION_FIELDS;
        Map<String,Object> accountFields               = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;    
        Map<String,Object> skillFields                 = UNITY_TestDataFactory.MOCKUP_FSO_SKILL_FIELDS;    
        
        Integer dayOfTheWeek = UNITY_Utils.getDayOfTheWeek();
       Map<String,String> todayWorkTime = new Map<String,String>{  UNITY_Constants.ACCOUNT_OPERATION_HOURS.get(dayOfTheWeek)[0]=>'00:00',
                                                                    UNITY_Constants.ACCOUNT_OPERATION_HOURS.get(dayOfTheWeek)[1]=>'23:59'};
                                                                        
                                                                    
        accountFields.put('ShippingPostalCode', UNITY_Utils.generateRandomPin()+'-'+UNITY_Utils.generateRandomPin());      
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE);
        accountFields.put('Name', 'C-'+UNITY_Utils.generateRandomPin());
        accountFields.put('Account_Status__c', 'Active' );
          
        customer = (Account)UNITY_TestDataFactory.createObject(1, Account.getSObjectType(),accountFields ).get(0);
        customer.Type = 'Site/Location';
        toReturn.put('customer', customer);
        
        vendors.addAll(UNITY_TestDataFactory.createAccounts(12, UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE, serviceRequestType, todayWorkTime, true,'SR_'));
        toReturn.put('vendors', vendors);
        
        accounts.addAll(vendors);
        accounts.add(customer);
        
        insert accounts;          
        
        FSO__Skill__c skill = UNITY_TestDataFactory.createSkills(1, false).get(0);
        insert skill;
        
        toReturn.put('skill', skill);
       
        List<UNITY_Vendor_Trade__c>               vendorTrades      = new List<UNITY_Vendor_Trade__c>();
        List<UNITY_Vendor_Covered_Location__c>    locationVendors   = new List<UNITY_Vendor_Covered_Location__c>();
        Map<id,UNITY_Vendor_Preference__c>        vendorPreferences = new Map<id,UNITY_Vendor_Preference__c>();
        List<UNITY_Vendor_Preference_By_Trade__c> vendorPreferenceTrades = new List<UNITY_Vendor_Preference_By_Trade__c>();
        
        for(integer index = 0 ; index < vendors.size(); index++ ){
                
            Account onVendor =  vendors.get(index);
                
            vendorTradeFields.put('Trade__c' , skill.id);
            vendorTradeFields.put('Vendor__c', onVendor.id);
                
            vendorTradeFields.put('Score_SR__c', System.Math.round((System.Math.random()*8)+1));
            vendorTradeFields.put('Price_SR__c', 10);
                
            UNITY_Vendor_Trade__c  vendorTrade  = (UNITY_Vendor_Trade__c)UNITY_TestDataFactory.createObject(1, UNITY_Vendor_Trade__c.getSObjectType(), vendorTradeFields).get(0);
            vendorTrades.add(vendorTrade);
        }
        
        insert vendorTrades;
        toReturn.put('vendorTrades', vendorTrades);
        
        vendorLocationFields.put('Location_Key__c', UNITY_Utils.getLocationKey(customer.ShippingCountryCode, customer.ShippingPostalCode));
        toReturn.put('locationKey',UNITY_Utils.getLocationKey(customer.ShippingCountryCode, customer.ShippingPostalCode));
        
        for(integer index = 0 ; index < vendors.size(); index++ ){
                
            Account onVendor =  vendors.get(index);
            vendorLocationFields.put('Vendor__c', onVendor.id);
                
            UNITY_Vendor_Covered_Location__c locationKey = (UNITY_Vendor_Covered_Location__c)UNITY_TestDataFactory.createObject(1, UNITY_Vendor_Covered_Location__c.getSObjectType(), vendorLocationFields).get(0);
            locationVendors.add(locationKey);
                
        }
        
        insert locationVendors;
        toReturn.put('locationVendors', locationVendors);
        
        return toReturn;
    }
}