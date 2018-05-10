@isTest
public class UNITY_ServiceContractHandlerTest {
    
    /*    
     *   Data inserted :   Customer Account 
     *                     Vendors Accounts ( each vendors has all request type [SR,Project,PM,SS] )
     *                     Skills 
     *                     Vendor Trades ( Each vendor cover all skills )
     *                     Vendor Covered location ( Each vendors cover the customer location )
     *                    
     */
    @testSetup 
    static void init() {
        
        Account customer              = new Account();
        List<Account> accounts        = new List<Account>();
        List<Account> accountsVendors = new List<Account>();
        List<FSO__Skill__c> skills = new List<FSO__Skill__c>();
        
        
        Map<String,boolean> allRequestType = new   Map<String,boolean>{ 'UNITY_Vendor_Type_SR__c'      => true,
                                                                        'UNITY_Vendor_Type_Project__c' => true,
                                                                        'UNITY_Vendor_Type_PM__c'      => true,
                                                                        'UNITY_Vendor_Type_SS__c'      => true}; 
            
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
        customer = (Account)UNITY_TestDataFactory.createObject(1, Account.getSObjectType(),accountFields ).get(0); 
        
        accountsVendors.addAll(UNITY_TestDataFactory.createAccounts(12, UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE, allRequestType, todayWorkTime, true,'ALL_'));
        
        accounts.addAll(accountsVendors);
        accounts.add(customer);
        
        insert accounts;
        
        skills = UNITY_TestDataFactory.createSkills(3, false);
        insert skills;
       
        List<UNITY_Vendor_Trade__c>               vendorTrades      = new List<UNITY_Vendor_Trade__c>();
        List<UNITY_Vendor_Covered_Location__c>    locationVendors   = new List<UNITY_Vendor_Covered_Location__c>();
        Map<id,UNITY_Vendor_Preference__c>        vendorPreferences = new Map<id,UNITY_Vendor_Preference__c>();
        List<UNITY_Vendor_Preference_By_Trade__c> vendorPreferenceTrades = new List<UNITY_Vendor_Preference_By_Trade__c>();
        
        // create dynamic vendors trade records per trade 
        for(FSO__Skill__c onSkill :skills){

            for(integer index = 0 ; index < accountsVendors.size(); index++ ){
                
                Account onVendor =  accountsVendors.get(index);
                
                vendorTradeFields.put('Trade__c' , onSkill.id);
                vendorTradeFields.put('Vendor__c', onVendor.id);
                
                vendorTradeFields.put('Price_SS__c', null);
                vendorTradeFields.put('Price_PM__c', null);
                vendorTradeFields.put('Price_Project__c', null);
                vendorTradeFields.put('Price_SR__c', null);
                
                if(onVendor.UNITY_Vendor_Type_SS__c){
                    vendorTradeFields.put('Score_SS__c', System.Math.round((System.Math.random()*8)+1));
                }
                if(onVendor.UNITY_Vendor_Type_PM__c){
                     vendorTradeFields.put('Score_PM__c', System.Math.round((System.Math.random()*8)+1));
                }
                if(onVendor.UNITY_Vendor_Type_Project__c){
                     vendorTradeFields.put('Score_Project__c', System.Math.round((System.Math.random()*8)+1));
                }
                if(onVendor.UNITY_Vendor_Type_SR__c){
                     vendorTradeFields.put('Score_SR__c', System.Math.round((System.Math.random()*8)+1));
                }           
                UNITY_Vendor_Trade__c  vendorTrade  = (UNITY_Vendor_Trade__c)UNITY_TestDataFactory.createObject(1, UNITY_Vendor_Trade__c.getSObjectType(), vendorTradeFields).get(0);
                vendorTrades.add(vendorTrade);
            }
        }
        
        
        insert vendorTrades;
        
        vendorLocationFields.put('Location_Key__c', UNITY_Utils.getLocationKey(customer.ShippingCountryCode, customer.ShippingPostalCode));
            
        for(integer index = 0 ; index < accountsVendors.size(); index++ ){
                
            Account onVendor =  accountsVendors.get(index);
            vendorLocationFields.put('Vendor__c', onVendor.id);
                
            UNITY_Vendor_Covered_Location__c locationKey = (UNITY_Vendor_Covered_Location__c)UNITY_TestDataFactory.createObject(1, UNITY_Vendor_Covered_Location__c.getSObjectType(), vendorLocationFields).get(0);
            locationVendors.add(locationKey);
                
        }
        
        insert locationVendors;
        
    }
    
    /*   
     * Create Active SC without SCLI, that way use the Default Labor Rate on SC
     * 
     */
    static testMethod void createActiveSCTest(){
        
        // get all vendors account 
        list<Account>  vendors  = [SELECT id FROM Account WHERE RecordTypeId = :UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE]; 
        
        // get all the skills 
        list<FSO__Skill__c> skills= [SELECT id, name  FROM FSO__Skill__c ];
        
        // store all request types for vendor
        list<id> recordTypeIds = new list<id>{  UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE,
                                                UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE,
                                                UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE};
        
                                                    
        // list of SC                                            
        list<UNITY_Service_Contract__c> serviceContracts = new list<UNITY_Service_Contract__c>();
        
        // create SC per Request type per Vendor, each SC will be inactive
        for(Account vendor :vendors){
            serviceContracts.addAll(getServiceContractPerRT(recordTypeIds,true,vendor));
        }
        
        insert serviceContracts; 
        
        // key : request type Id + account id
        // value : SC.UNITY_Default_Labor_Rate__c
        Map<String,double> rt_defaultPrice = new Map<String,double>();
        
        // Now create SCLI per SC, each one Houly rate Record type 
        for(UNITY_Service_Contract__c sc :serviceContracts ){
            rt_defaultPrice.put(sc.RecordTypeId+'-'+sc.UNITY_Account__c, sc.UNITY_Default_Labor_Rate__c);
        }
        
        
        // get all vendors trade 
        list<UNITY_Vendor_Trade__c>  vendorTrades  = [SELECT id, Vendor__c, Price_SS__c, Price_PM__c , Price_SR__c, Price_Project__c FROM UNITY_Vendor_Trade__c ]; 
        
        // go for each vendor trade and try to check the price per request type
        for(UNITY_Vendor_Trade__c  vt :vendorTrades ){
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_SR__c, 'Service Request price should be '+rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_PM__c, 'Preventive Maintence price should be '+rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_Project__c, 'Project Management price should be '+rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_SS__c, 'Site Survey price should be '+rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c));
        }
        
    }
    
    /*   
     * Create Inactve SC and related SCLI, after that Update the SC status to active 
     * set SCLI.UNITY_Labor_Cost__c = null that way use the Default Labor Rate on parent SC
     */
    static testMethod void createInactiveSCTest(){
        
        // get all vendors account 
        list<Account>  vendors  = [SELECT id FROM Account WHERE RecordTypeId = :UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE]; 
        
        // get all the skills 
        list<FSO__Skill__c> skills= [SELECT id, name  FROM FSO__Skill__c ];
        
        // store all request types for vendor
        list<id> recordTypeIds = new list<id>{  UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE,
                                                UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE,
                                                UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE};
        
        // list of SC                                            
        list<UNITY_Service_Contract__c> serviceContracts = new list<UNITY_Service_Contract__c>();
        
        // create SC per Request type per Vendor, Each SC will be inactive
        for(Account vendor :vendors){
            serviceContracts.addAll(getServiceContractPerRT(recordTypeIds,false,vendor));
        }
        
        insert serviceContracts; 
        
        // key : request type Id + account id
        // value : SC.UNITY_Default_Labor_Rate__c
        Map<String,double> rt_defaultPrice = new Map<String,double>();
        
        // list of SCLI 
        list<UNITY_Service_Contract_Line_Item__c> sclis = new list<UNITY_Service_Contract_Line_Item__c>();
        
        // Now create SCLI per SC, Eeach one Houly rate Record type 
        for(UNITY_Service_Contract__c sc :serviceContracts ){
            sclis.addAll(getSCLI(skills, UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,sc,null));
            rt_defaultPrice.put(sc.RecordTypeId+'-'+sc.UNITY_Account__c, sc.UNITY_Default_Labor_Rate__c);
        }
        
        insert sclis;
        
        // after insert, Update each SC to active 
        for(UNITY_Service_Contract__c sc :serviceContracts ){
            sc.UNITY_IS_Active__c = true;
        }
        
        update serviceContracts;
        
        // get all vendors trade 
        list<UNITY_Vendor_Trade__c>  vendorTrades  = [SELECT id, Vendor__c, Price_SS__c, Price_PM__c , Price_SR__c, Price_Project__c FROM UNITY_Vendor_Trade__c ]; 
        
        // go for each vendor trade and try to check the price per request type
        for(UNITY_Vendor_Trade__c  vt :vendorTrades ){
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_SR__c, 'Service Request price should be '+rt_defaultPrice.get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_PM__c, 'Preventive Maintence price should be '+rt_defaultPrice.get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_Project__c, 'Project Management price should be '+rt_defaultPrice.get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE+'-'+vt.Vendor__c));
            
            if(rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c) != null) 
                System.assertEquals(rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c), vt.Price_SS__c, 'Site Survey price should be '+rt_defaultPrice.get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE+'-'+vt.Vendor__c));
        }
        
    }
    
    /*   
     * Create Inactve SC and related SCLI, after that Update the SC status to active 
     * set SCLI.UNITY_Labor_Cost__c = null that way use the Default Labor Rate on parent SC
     */
    static testMethod void updatePriceFromSCLI(){
        
        // get all vendors account 
        list<Account>  vendors  = [SELECT id FROM Account WHERE RecordTypeId = :UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE]; 
        
        // get all the skills 
        list<FSO__Skill__c> skills= [SELECT id, name  FROM FSO__Skill__c ];
        
        // store all request types for vendor
        list<id> recordTypeIds = new list<id>{  UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE,
                                                UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
                                                UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE,
                                                UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE};
        Test.startTest();
                                                        
            // list of SC                                            
            list<UNITY_Service_Contract__c> serviceContracts = new list<UNITY_Service_Contract__c>();
            
            // create SC per Request type per Vendor, Each SC will be inactive
            for(Account vendor :vendors){
                serviceContracts.addAll(getServiceContractPerRT(recordTypeIds,true,vendor));
            }
            
            insert serviceContracts; 
            
            // key   : account id + trade Id
            // value : Map<String,double> key   : record type id SC
            //                            value : price
            Map<String,Map<String,double>> vendorTrade_requestTypePrice = new Map<String,Map<String,double>>();
            
            // list of SCLI 
            list<UNITY_Service_Contract_Line_Item__c> sclis = new list<UNITY_Service_Contract_Line_Item__c>();
            Map<String,list<UNITY_Service_Contract_Line_Item__c>> sc_scli = new Map<String,list<UNITY_Service_Contract_Line_Item__c>>();
            
            // Now create SCLI per SC, each one Houly rate Record type 
            for(UNITY_Service_Contract__c sc :serviceContracts ){
                if(sc_scli.get(sc.id)==null)sc_scli.put(sc.id, new list<UNITY_Service_Contract_Line_Item__c>());
                sc_scli.get(sc.id).addAll(getSCLI(skills, UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,sc, System.Math.round((System.Math.random()*99)+1)));
                sclis.addAll(sc_scli.get(sc.id));
            }
            
            insert sclis;
            
            // go per SC and create a key = account id + trade id 
            // to new map ( key : sc record type , labor hour price (double)  )
            for(UNITY_Service_Contract__c sc :serviceContracts){
                for(UNITY_Service_Contract_Line_Item__c scli :sc_scli.get(sc.Id)){
                    String key = sc.UNITY_Account__c+'-'+scli.UNITY_Trade__c;
                    if(vendorTrade_requestTypePrice.get(key) == null )vendorTrade_requestTypePrice.put(key ,new Map<String,double>());
                    vendorTrade_requestTypePrice.get(key).put( sc.RecordTypeId, scli.UNITY_Labor_Hours__c);
                }
            }
            
            // get all vendors trade 
            list<UNITY_Vendor_Trade__c>  vendorTrades  = [SELECT id,Trade__c , Vendor__c, Price_SS__c, Price_PM__c , Price_SR__c, Price_Project__c FROM UNITY_Vendor_Trade__c ]; 
            
            // go for each vendor trade and try to check the price per request type
            for(UNITY_Vendor_Trade__c  vt :vendorTrades ){
                
                String key = vt.Vendor__c+'-'+vt.Trade__c;
                
                if(vendorTrade_requestTypePrice.get(key) != null){
                    
                    if(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE) != null) 
                        System.assertEquals(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE), vt.Price_SR__c, 'Service Request price should be '+vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE));
                
                    if(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE) != null) 
                        System.assertEquals(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE), vt.Price_PM__c, 'Preventive Maintence price should be '+vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE));
                    
                    if(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE) != null) 
                        System.assertEquals(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE), vt.Price_Project__c, 'Project Management price should be '+vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE));
                    
                    if(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE) != null) 
                        System.assertEquals(vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE), vt.Price_SS__c, 'Site Survey price should be '+vendorTrade_requestTypePrice.get(key).get(UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE));
                }
           }  
        
           delete serviceContracts;
       Test.stopTest();
        
    }
    
    /*
     *  Create SC per Record Type related to one Account
     */
    private static list<UNITY_Service_Contract__c> getServiceContractPerRT(List<id> recordTypes , boolean status ,Account acc){
        
        list<UNITY_Service_Contract__c> toReturn  = new list<UNITY_Service_Contract__c>();
        
        if((recordTypes != null) && (recordTypes.size()>0) && (status !=null) && (acc!=null)){
            
            for(id rt :recordTypes ){
                UNITY_Service_Contract__c sc = new UNITY_Service_Contract__c();
                sc.RecordTypeId  = rt;
                sc.UNITY_Account__c = acc.Id;
                sc.UNITY_Trip_Charge__c = 10;
                sc.UNITY_IS_Active__c   = status;
                sc.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
                sc.UNITY_Default_Labor_Rate__c = System.Math.round((System.Math.random()*99)+1);
                sc.UNITY_Invoicing_Increments__c = 'Next ¼ hr';
                toReturn.add(sc);
            }
        }
        
        return toReturn;
    }
    
    /*
     *  Create scli per skill for one sc
     * 
     */
    private static list<UNITY_Service_Contract_Line_Item__c> getSCLI(List<FSO__Skill__c> skills,id rtId,  UNITY_Service_Contract__c sc, Double laborCost){
        
        list<UNITY_Service_Contract_Line_Item__c> toReturn = new list<UNITY_Service_Contract_Line_Item__c>();
        for(FSO__Skill__c skill :skills){
            UNITY_Service_Contract_Line_Item__c scli = new UNITY_Service_Contract_Line_Item__c();
            scli.RecordTypeId = rtId;
            scli.UNITY_Trade__c = skill.Id;
            scli.UNITY_Labor_Cost__c = laborCost;
            scli.UNITY_Service_Contract__c = sc.Id;
            toReturn.add(scli);
        }
        return toReturn;
    }
    
}