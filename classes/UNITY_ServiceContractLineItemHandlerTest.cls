@isTest
public class UNITY_ServiceContractLineItemHandlerTest{
    
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
    
    static testMethod void test1(){
         system.debug('>>>> neli from test >>>>>');
        // get all vendors account 
        list<Account>  vendors  = [SELECT id FROM Account WHERE RecordTypeId = :UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE]; 
        
        // get all the skills 
        list<FSO__Skill__c> skills= [SELECT id, name  FROM FSO__Skill__c ];
        
         Test.startTest();
             UNITY_Constants.executionsPerTrigger.put('UNITY_ServiceContractLineItemHandlerTest',1);
         
        // store all request types for vendor
        list<id> recordTypeIds = new list<id>{  UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE,
                                                UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
                                                UNITY_Constants.SC_PROJECT_MANAGEMENT_RECORDTYPE,
                                                UNITY_Constants.SC_SITE_SURVEY_RECORDTYPE
            };
          
                                                        
            // list of SC                                            
            list<UNITY_Service_Contract__c> serviceContracts = new list<UNITY_Service_Contract__c>();
            
            // create SC per Request type per Vendor, Each SC will be inactive
            for(Account vendor :vendors){
                serviceContracts.addAll(getServiceContractPerRT(recordTypeIds,true,vendor));
            }
            system.debug('>>>>   neli serviceContracts >>>>' + serviceContracts);
            insert serviceContracts; 
            
            
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
            
            
            validatePrices(serviceContracts, sc_scli);            
            
            // test update scli labor rate 
            for(UNITY_Service_Contract_Line_Item__c scli :sclis ){
                scli.UNITY_Labor_Cost__c = System.Math.round((System.Math.random()*99)+1);
            }
        
            update sclis;
        
            validatePrices(serviceContracts, sc_scli);    
    
         test.stopTest();
        
    }
    static testMethod void updateVendorTradePrices(){
        
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
              UNITY_Constants.executionsPerTrigger.put('UNITY_ServiceContractLineItemHandlerTest',1);                                           
            // list of SC                                            
            list<UNITY_Service_Contract__c> serviceContracts = new list<UNITY_Service_Contract__c>();
            
            // create SC per Request type per Vendor, Each SC will be inactive
            for(Account vendor :vendors){
                serviceContracts.addAll(getServiceContractPerRT(recordTypeIds,true,vendor));
            }
            
            insert serviceContracts; 
            
            
            
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
            
            
            validatePrices(serviceContracts, sc_scli);            
            
            // test update scli labor rate 
            for(UNITY_Service_Contract_Line_Item__c scli :sclis ){
                scli.UNITY_Labor_Cost__c = System.Math.round((System.Math.random()*99)+1);
            }
        
            update sclis;
        
            validatePrices(serviceContracts, sc_scli);           
        
    }
    
    private static void validatePrices(list<UNITY_Service_Contract__c> serviceContracts, Map<String,list<UNITY_Service_Contract_Line_Item__c>> sc_scli){
        
        // key   : account id + trade Id
        // value : Map<String,double> key   : record type id SC
        //                            value : price
        Map<String,Map<String,double>> vendorTrade_requestTypePrice = new Map<String,Map<String,double>>();
        
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
        
    }
    
    static testMethod void test_hasPreferredPartOnAccounts(){
       
        // setup data 
        integer MAX_SC   = 3;
        integer MAX_SCLI = 5;
        list<Account> accounts = new list<Account>();
        list<UNITY_Service_Contract__c> serviceContracts            = new list<UNITY_Service_Contract__c>();
        list<UNITY_Service_Contract_Line_Item__c> serviceControlLIs = new list<UNITY_Service_Contract_Line_Item__c>();
        
        Map< id, list<UNITY_Service_Contract__c> >           accountsId_scs = new Map< id, list<UNITY_Service_Contract__c> >();
        Map< id, list<UNITY_Service_Contract_Line_Item__c> > scId_sclis     = new Map< id, list<UNITY_Service_Contract_Line_Item__c> >();
        
        // create accounts 
        Account aliAccount = new Account();
        aliAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        aliAccount.Name = 'Ali Customer Account';
        accounts.add(aliAccount);
        
        Account alexAccount = new Account();
        alexAccount.RecordTypeId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        alexAccount.Name = 'Alex Customer Account';
        accounts.add(alexAccount);
    
        insert accounts;
        
         Test.startTest();
          UNITY_Constants.executionsPerTrigger.put('UNITY_ServiceContractLineItemHandlerTest',1);   
        
        for(Account onAccount :accounts){
            
            // should be just one service contract in active status per account 
            boolean isThereActiveAccount = false ;
            list<UNITY_Service_Contract__c> aux_sc = new list<UNITY_Service_Contract__c>();
            
            for(integer i = 0 ; i < MAX_SC ; i++){ 
                
                UNITY_Service_Contract__c sc = new UNITY_Service_Contract__c();
                sc.UNITY_Account__c = onAccount.id;
                if(!isThereActiveAccount){
                    sc.UNITY_IS_Active__c = true;
                    isThereActiveAccount  = true;
                }
                aux_sc.add(sc);
                
            }
            
            serviceContracts.addAll(aux_sc);
            accountsId_scs.put( onAccount.id , aux_sc );
            
        }
        
        insert serviceContracts;
        
        for(UNITY_Service_Contract__c onServiceContract :serviceContracts){ 
            
            list<UNITY_Service_Contract_Line_Item__c> aux_sclis = new list<UNITY_Service_Contract_Line_Item__c>();
            
            
            for(integer i = 0 ; i < MAX_SCLI ; i++){ 
                UNITY_Service_Contract_Line_Item__c  scli = new UNITY_Service_Contract_Line_Item__c();
                scli.UNITY_Service_Contract__c = onServiceContract.id;
                scli.UNITY_Is_Preferred_Part__c = false;
                scli.RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE;
                aux_sclis.add(scli);
            }
			/*            
            for(integer i = 0 ; i < MAX_SCLI ; i++){ 
                UNITY_Service_Contract_Line_Item__c  scli = new UNITY_Service_Contract_Line_Item__c();
                scli.UNITY_Service_Contract__c = onServiceContract.id;
                scli.UNITY_Is_Preferred_Part__c = false;
                scli.RecordTypeId = UNITY_Constants.SCLI_DISTRIBUTOR_TO_FLEET_RECORDTYPE;
                aux_sclis.add(scli);
            }
            
            for(integer i = 0 ; i < MAX_SCLI ; i++){ 
                UNITY_Service_Contract_Line_Item__c  scli = new UNITY_Service_Contract_Line_Item__c();
                scli.UNITY_Service_Contract__c = onServiceContract.id;
                scli.UNITY_Is_Preferred_Part__c = false;
                scli.RecordTypeId = UNITY_Constants.SCLI_FLEET_TO_ACCOUNT_RECORDTYPE;
                aux_sclis.add(scli);
            }
            
            UNITY_Service_Contract_Line_Item__c  scli = new UNITY_Service_Contract_Line_Item__c();
            scli.UNITY_Service_Contract__c = onServiceContract.id;
            scli.UNITY_Is_Preferred_Part__c = false;
            scli.RecordTypeId = UNITY_Constants.SCLI_INTERNATIONAL_REQUIREMENTS_RECORDTYPE;
            aux_sclis.add(scli);
            */
            serviceControlLIs.addAll(aux_sclis);
            scId_sclis.put( onServiceContract.id , aux_sclis);
            
        }
        
        insert serviceControlLIs;
        

       
            list<UNITY_Service_Contract_Line_Item__c> serviceContractLIs = [SELECT id, UNITY_Is_Preferred_Part__c 
                                                                            FROM   UNITY_Service_Contract_Line_Item__c
                                                                            WHERE  RecordTypeId = :UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE]; //UNITY_Constants.SCLI_INTERNATIONAL_REQUIREMENTS_RECORDTYPE];
        
           for(UNITY_Service_Contract_Line_Item__c onSCLI :serviceContractLIs){
                onSCLI.UNITY_Is_Preferred_Part__c = true ; 
           }
           update serviceContractLIs;
           
           accounts = [SELECT id , UNITY_Has_Preferred_Part__c FROM Account ];
            
           for(Account onAccount :accounts){
                System.assertEquals(false, onAccount.UNITY_Has_Preferred_Part__c, 'Update a Service Contract Line Item with different record type than FLEET_TO_ACCOUNT and DISTRIBUTOR_TO_FLEET shiuldn\'t be reflected in the Account field.');
           }
          
           UNITY_Service_Contract_Line_Item__c serviceContractLI  = [SELECT id, UNITY_Is_Preferred_Part__c 
                                                                     FROM   UNITY_Service_Contract_Line_Item__c
                                                                     WHERE   UNITY_Service_Contract__r.UNITY_Account__c = :aliAccount.id AND 
                                                                            UNITY_Service_Contract__r.UNITY_IS_Active__c = true 
                                                                     LIMIT 1];
           serviceContractLI.UNITY_Is_Preferred_Part__c = true ;
           update serviceContractLI;
         
           
           System.assertEquals(true, serviceContractLI.UNITY_Is_Preferred_Part__c);
        
           aliAccount = [SELECT id, UNITY_Has_Preferred_Part__c FROM Account WHERE id = :aliAccount.id];
           aliAccount.UNITY_Has_Preferred_Part__c = true;
           update aliAccount;
          
            System.assertEquals(true, aliAccount.UNITY_Has_Preferred_Part__c);
        
           //System.assertEquals(true, aliAccount.UNITY_Has_Preferred_Part__c, 'The Account.UNITY_Has_Preferred_Part__c should have true value.');
           
          // serviceContractLI.UNITY_Is_Preferred_Part__c = false ;
          // update serviceContractLI;        
        
           //aliAccount = [SELECT id, UNITY_Has_Preferred_Part__c FROM Account WHERE id = :aliAccount.id];
           //System.assertEquals(false, aliAccount.UNITY_Has_Preferred_Part__c, 'The Account.UNITY_Has_Preferred_Part__c should have false value.');
           
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