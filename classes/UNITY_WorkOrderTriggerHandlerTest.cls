@isTest
public class UNITY_WorkOrderTriggerHandlerTest {
     public static Id PRICEBOOKENTRYID_T;
    public static Id PRICEBOOKENTRYID_L;
    public static Id PRICEBOOKENTRYID_P;
    public static Id PRODUCTID;
    static{
        //Create Product & pricebook
        Map<String,String> prodMapP = TestDataProvider.getProductAndPriceBookEntry(1,'Part');
        for(String s :prodMapP.keySet()){
            PRICEBOOKENTRYID_P = (Id)prodMapP.get(s);
            PRODUCTID = (Id)s;
        }
        Map<String,String> prodMapL = TestDataProvider.getProductAndPriceBookEntry(1,'Labor');
        for(String s :prodMapL.keySet()){
            PRICEBOOKENTRYID_L = (Id)prodMapL.get(s);
        }
        Map<String,String> prodMapT = TestDataProvider.getProductAndPriceBookEntry(1,'Travel');
        for(String s :prodMapT.keySet()){
            PRICEBOOKENTRYID_T = (Id)prodMapT.get(s);
        }
    }
    //Setup test data
    @testSetup
    public static void init(){
        TestDataProvider.unityTestSetup();
    }
    
    static testMethod void testMethod1 (){
          //Get the accounts
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String urRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
        List<Account> accounts = [SELECT Id,RecordTypeId,Account_Email__c FROM Account];
        Account cust;
        Account vend;
        Account bu;
        for(Account a :accounts){
            if(a.RecordTypeId == custRTId)
                cust = a;
            if(a.RecordTypeId == vendRTId)
                vend = a;
            if(a.RecordTypeId == buRTId)
                bu = a;
        }
         
        test.startTest();        
      
         
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;
        
        wo.UNITY_Assigned_Vendor__c = vend.Id;      
        wo.Subject='Test';
        wo.UNITY_Work_Window_Begin__c = Datetime.now();  
        wo.UNITY_Vendor_Status__c = 'Accepted';         
         update wo;
        
         //add wolis
          List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>();
           WorkOrderLineItem wolich = new WorkOrderLineItem ();
                wolich.WorkOrderId = wo.ID;
                wolich.UNITY_PM_WOLI__c = false;
                wolich.FSO__IsRequired__c = true;
                wolich.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                wolich.Description =Datetime.now().format() + ' : Tech Check-In'; 
                wolich.FSO__IsCompleted__c = true;
                 wolich.Status = 'In Progress';
                wolich.SFPS_FS_Task_Type__c = 'Check-In';
                wolis.add(wolich);
         
              wolich = new WorkOrderLineItem ();         
	            wolich.WorkOrderId = wo.ID;
                wolich.UNITY_PM_WOLI__c = false;
                wolich.FSO__IsRequired__c = true;
                wolich.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                wolich.Description =Datetime.now().format() + ' : Tech Check-Out';
                wolich.FSO__IsCompleted__c = true;
                wolich.Status = 'In Progress';
                wolich.SFPS_FS_Task_Type__c = 'Check-Out';
                wolis.add(wolich);
         
         insert wolis;     
       
          wolis = new List<WorkOrderLineItem>();
              wolich = new WorkOrderLineItem ();
                wolich.WorkOrderId = wo.ID;
                wolich.UNITY_PM_WOLI__c = false;
                wolich.FSO__IsRequired__c = true;
                wolich.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                DateTime dt1 = DateTime.now() + Double.valueOf(10) / 1440;
                wolich.Description =dt1.format() + ' : Tech Check-In'; 
                wolich.FSO__IsCompleted__c = true;
                wolich.Status = 'Completed';
                wolich.SFPS_FS_Task_Type__c = 'Check-In';
                wolis.add(wolich);
            wolich = new WorkOrderLineItem ();         
	            wolich.WorkOrderId = wo.ID;
                wolich.UNITY_PM_WOLI__c = false;
                wolich.FSO__IsRequired__c = true;
                wolich.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                
                DateTime dt2 = DateTime.now() + Double.valueOf(20) / 1440;
                wolich.Description =dt2.format() + ' : Tech Check-Out';
                wolich.FSO__IsCompleted__c = true;
                wolich.Status = 'Completed';
                wolich.SFPS_FS_Task_Type__c = 'Check-Out';
                wolis.add(wolich);
           insert wolis;       
        
        test.stoptest();
    }
    static testMethod void test_populateParentObjectFieldsOnAsset(){

        Map<String,Object> accountFields = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;  
        accountFields.put('Type','Site/Location' );
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE );
        accountFields.put('Account_Status__c', 'Active' );

        List<Account> accounts = new List<Account>();

        //Account acc = new Account(Name = 'Test', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
        Account acc = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accounts.add(acc);
        //Account acc2 = new Account(Name = 'Test2', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
        Account acc2 = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accounts.add(acc2);
        insert accounts;
        
        List<Asset> assets = new List<Asset>();
        Asset asset = new Asset(Name = 'Test', AccountId = acc.Id);
        assets.add(asset);
        Asset asset2 = new Asset(Name = 'Test2', AccountId = acc.Id);
        assets.add(asset2);
        insert assets;
        
        RecordType customerRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Customer' AND SObjectType = 'Account'];
        RecordType srRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Service_Request' AND SObjectType = 'Case'];
        //Account customer = new Account(Account_Status__c = 'Active', RecordTypeId = customerRt.Id, Name='Test2', BillingCity='City', BillingStateCode='CA', BillingStreet='Test Street', BillingPostalCode='12345', Account_Email__c = 'test2@test.com');
        accountFields.put('RecordTypeId', customerRt.Id );
        Account customer = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        insert customer;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', Email='test@test.com');
        insert con;
        
        Case c = new Case(Status = 'Verified', RecordTypeId = srRT.Id, UNITY_Customer__c = customer.Id, ContactId = con.Id);
        insert c;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c(Name = 'Avatax URL', Value__c = 'www.someTestURL.com');
        insert kvs;
        
        List<WorkOrder> workOrders = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset.Id, AccountId = acc.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo);
        
        WorkOrder wo2 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset.Id, AccountId = acc.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo2);
        
        WorkOrder wo3 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', AssetId = asset.Id, AccountId = acc2.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo3);
        
        WorkOrder wo4 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', AssetId = asset.Id, AccountId = acc2.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo4);
        
        WorkOrder wo5 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset2.Id, AccountId = acc2.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo5);
        
        WorkOrder wo6 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset2.Id, AccountId = acc.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo6);
        
        WorkOrder wo7 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', AssetId = asset2.Id, AccountId = acc.Id, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo7);
        
        insert workOrders;
    
        List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(AssetId = asset.Id, WorkOrderId = wo.Id);
        wolis.add(woli);
        WorkOrderLineItem woli2 = new WorkOrderLineItem(AssetId = asset2.Id, WorkOrderId = wo.Id);
        wolis.add(woli2);
        WorkOrderLineItem woli3 = new WorkOrderLineItem(AssetId = asset.Id, WorkOrderId = wo2.Id);
        wolis.add(woli3);
        WorkOrderLineItem woli4 = new WorkOrderLineItem(AssetId = asset.Id, WorkOrderId = wo3.Id);
        wolis.add(woli4);
        WorkOrderLineItem woli5 = new WorkOrderLineItem(AssetId = asset.Id, WorkOrderId = wo4.Id);
        wolis.add(woli5);
        WorkOrderLineItem woli6 = new WorkOrderLineItem(AssetId = asset2.Id, WorkOrderId = wo5.Id);
        wolis.add(woli6);
        WorkOrderLineItem woli7 = new WorkOrderLineItem(AssetId = asset2.Id, WorkOrderId = wo6.Id);
        wolis.add(woli7);
        WorkOrderLineItem woli8 = new WorkOrderLineItem(AssetId = asset2.Id, WorkOrderId = wo7.Id);
        wolis.add(woli8);
        insert wolis;
    Test.startTest();
        asset = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset.Id];
        //system.assertEquals(2, asset.SSVY_Open_Work_Orders__c);
        //system.assertEquals(4, asset.SSVY_Total_of_Work_Orders__c);
        
        asset2 = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset2.Id];
        //system.assertEquals(3, asset.SSVY_Open_Work_Orders__c);
        //system.assertEquals(4, asset.SSVY_Total_of_Work_Orders__c);
    
        workOrders = new List<WorkOrder>();
        wo.AssetId = asset2.Id;
        workOrders.add(wo);
        
        wo3.Status = 'New';
        workOrders.add(wo3);
        
        wo4.AssetId = asset2.Id;
        workOrders.add(wo4);
        
        wo5.Status = 'Closed';
        workOrders.add(wo5);
        
        wo6.Status = 'Closed';
        wo6.AssetId = asset.Id;
        workOrders.add(wo6);
        
        update workOrders;
        
        asset = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset.Id];
        //system.assertEquals(2, asset.SSVY_Open_Work_Orders__c); 
        //system.assertEquals(3, asset.SSVY_Total_of_Work_Orders__c);
        
        asset2 = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset2.Id];
        //system.assertEquals(1, asset2.SSVY_Open_Work_Orders__c); 
        //system.assertEquals(4, asset2.SSVY_Total_of_Work_Orders__c);

        workOrders = new List<WorkOrder>();
        workOrders.add(wo2);
        workOrders.add(wo3);
        workOrders.add(wo4);
        workOrders.add(wo5);
        workOrders.add(wo6);
        workOrders.add(wo7);
        delete workOrders;
        
        //asset = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset.Id];
        //system.assertEquals(0, asset.SSVY_Open_Work_Orders__c); 
        //system.assertEquals(0, asset.SSVY_Total_of_Work_Orders__c);
        
        //asset2 = [SELECT Name, SSVY_Open_Work_Orders__c, SSVY_Total_of_Work_Orders__c FROM Asset WHERE Id =: asset2.Id];
        //system.assertEquals(1, asset2.SSVY_Open_Work_Orders__c); 
        //system.assertEquals(1, asset2.SSVY_Total_of_Work_Orders__c);

        Test.stopTest();
    }
    
    static testMethod void test_populateParentObjectFieldsOnAccount(){

        Map<String,Object> accountFields = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;  
        accountFields.put('Type','Site/Location' );
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE );
        accountFields.put('Account_Status__c', 'Active' );


        List<Account> accounts = new List<Account>();
        //Account acc = new Account(Name = 'Test', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
        Account acc = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        Account acc2 = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accounts.add(acc);
        accounts.add(acc2);
        //Account acc2 = new Account(Name = 'Test2', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
     
        insert accounts;
        
        List<Asset> assets = new List<Asset>();
        Asset asset = new Asset(Name = 'Test', AccountId = acc.Id);
        assets.add(asset);
        Asset asset2 = new Asset(Name = 'Test2', AccountId = acc.Id);
        assets.add(asset2);
        insert assets;
        
        RecordType customerRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Customer' AND SObjectType = 'Account'];
        RecordType srRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Service_Request' AND SObjectType = 'Case'];
        //Account customer = new Account(Account_Status__c = 'Active', RecordTypeId = customerRt.Id, Name='Test2', BillingCity='City', BillingStateCode='CA', BillingStreet='Test Street', BillingPostalCode='12345', Account_Email__c = 'test2@test.com');
        accountFields.put('RecordTypeId', customerRt.Id);
        Account customer = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        insert customer;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', Email='test@test.com');
        insert con;
        
        Case c = new Case(Status = 'Verified', RecordTypeId = srRT.Id, UNITY_Customer__c = customer.Id, ContactId = con.Id);
        insert c;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c(Name = 'Avatax URL', Value__c = 'www.someTestURL.com');
        insert kvs;
        
        Date date1 = Date.today();
        
        RecordType siteSurveyRT = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'Site_Survey'];
        
        List<WorkOrder> workOrders = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', RecordTypeId = siteSurveyRT.Id, AssetId = asset.Id, AccountId = acc.Id, FSO__Completed_Date__c = date1, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo);
        
        WorkOrder wo2 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset.Id, AccountId = acc.Id, FSO__Completed_Date__c = date1, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo2);
        
        WorkOrder wo3 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', AssetId = asset.Id, AccountId = acc2.Id, FSO__Completed_Date__c = date1.addDays(7), UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo3);
        
        WorkOrder wo4 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', RecordTypeId = siteSurveyRT.Id, AssetId = asset.Id, AccountId = acc2.Id, FSO__Completed_Date__c = date1.addDays(10), UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo4);
        
        WorkOrder wo5 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', RecordTypeId = siteSurveyRT.Id, AssetId = asset2.Id, AccountId = acc2.Id, FSO__Completed_Date__c = date1.addDays(-5), UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo5);
        
        WorkOrder wo6 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'New', AssetId = asset2.Id, AccountId = acc.Id, FSO__Completed_Date__c = null, UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo6);
        
        WorkOrder wo7 = new WorkOrder(UNITY_Customer__c = customer.Id, Status = 'Closed', RecordTypeId = siteSurveyRT.Id, AssetId = asset2.Id, AccountId = acc.Id, FSO__Completed_Date__c = date1.addDays(5), UNITY_Assigned_Vendor__c = acc.Id, CaseId = c.Id, Subject='Test');
        workOrders.add(wo7);
        
        insert workOrders;

        Test.startTest();
        
        acc = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc.Id];
        //system.assertEquals(2, acc.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(date1.addDays(5), acc.SSVY_Last_Visited_Date__c);
        
        acc2 = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc2.Id];
        //system.assertEquals(2, acc2.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(date1.addDays(10), acc2.SSVY_Last_Visited_Date__c);
        
        workOrders = new List<WorkOrder>();
        wo.AssetId = asset2.Id;
        wo.AccountId = acc2.Id;
        workOrders.add(wo);
        
        wo2.RecordTypeId = siteSurveyRT.Id;
        wo2.AccountId = acc2.Id;
        workOrders.add(wo2);
        
        wo3.RecordTypeId = siteSurveyRT.Id;
        wo3.Status = 'New';
        workOrders.add(wo3);
        
        wo4.FSO__Completed_Date__c = null;
        wo4.AssetId = asset2.Id;
        workOrders.add(wo4);
        
        wo5.Status = 'Closed';
        workOrders.add(wo5);
        
        wo6.Status = 'Closed';
        wo6.AssetId = asset.Id;
        wo6.FSO__Completed_Date__c = date1.addDays(11);
        workOrders.add(wo6);
        
        update workOrders;
        
        acc = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc.Id];
        //system.assertEquals(1, acc.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(date1.addDays(11), acc.SSVY_Last_Visited_Date__c);
        
        acc2 = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc2.Id];
        //system.assertEquals(5, acc2.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(date1.addDays(7), acc2.SSVY_Last_Visited_Date__c);
        
        workOrders = new List<WorkOrder>();
        workOrders.add(wo2);
        workOrders.add(wo3);
        workOrders.add(wo4);
        workOrders.add(wo5);
        workOrders.add(wo6);
        workOrders.add(wo7);
        delete workOrders;
        
        acc = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc.Id];
        //system.assertEquals(0, acc.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(null, acc.SSVY_Last_Visited_Date__c);
        
        acc2 = [SELECT Name, SSVY_Last_Visited_Date__c, SSVY_Total_Site_Surveys_Completed__c FROM Account WHERE Id =: acc2.Id];
        //system.assertEquals(1, acc2.SSVY_Total_Site_Surveys_Completed__c);
        //system.assertEquals(date1, acc2.SSVY_Last_Visited_Date__c);
        
        Test.stopTest();
    }
    
    static testMethod void test_copyFieldsAccounts(){
        
        integer MAX_ACCOUNTS = 10;
        integer MAX_CASES    = 10;
        integer MAX_WO_PER_CASE = 10;
        
        list<Account> accounts = new list<Account>();
        list<Case>    cases    = new list<Case>();
        list<WorkOrder> workOrders  = new list<WorkOrder>();
        
        
        Map< id, list<Case> >  accountsId_cases       = new Map< id, list<Case> >();
        Map< id, list<WorkOrder> > caseId_WOs = new Map< id, list<WorkOrder> >();
        
        // create accounts 
        Account aliAccount = new Account();
        aliAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        aliAccount.Name = 'Ali Customer Account'; 
        aliAccount.type = 'Site/Location'; 
        aliAccount.BillingPostalCode         = '123';
        aliAccount.BillingCountryCode        = 'US';
        aliAccount.BillingCity               = 'billingCity';
        aliAccount.BillingStateCode          = 'NY';
        aliAccount.BillingStreet             = '123 Fake St.';
        
        accounts.add(aliAccount);
        
        // create accounts 
        Account endUserAccount = new Account();
        endUserAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        endUserAccount.Name = 'End User Account';
        endUserAccount.BillingCountryCode        = 'US';
        endUserAccount.BillingCity               = 'billingCity';
        endUserAccount.BillingStateCode          = 'NY';
        endUserAccount.BillingStreet             = '123 Fake St.';
        endUserAccount.BillingPostalCode         = '123';
        endUserAccount.Account_Status__c         = 'Active';
        endUserAccount.Type = 'Customer';
        accounts.add(endUserAccount);
        
        Account customerAccount = new Account();
        customerAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        customerAccount.Name = 'Customer Account';
        customerAccount.BillingCountryCode        = 'US';
        customerAccount.BillingCity               = 'billingCity';
        customerAccount.BillingStateCode          = 'NY';
        customerAccount.BillingStreet             = '123 Fake St.';
        customerAccount.BillingPostalCode         = '123';
        customerAccount.Account_Status__c         = 'Active';
        accounts.add(customerAccount);
        
        insert accounts;
        
        Case onCase = new Case();   
        onCase.AccountId = aliAccount.id;
        onCase.UNITY_Customer__c = customerAccount.id;
        onCase.Status = 'Verified';
        onCase.Origin = 'Web';
        onCase.UNITY_Portal_Source__c = 'SMS';
        
        insert onCase;
        
        
        Test.startTest();
            
            for(integer i = 0 ; i < MAX_CASES ; i++){

                WorkOrder  wo = new WorkOrder();
                wo.RecordTypeId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
                wo.CaseId = onCase.id;
                wo.AccountId = customerAccount.id;
                wo.UNITY_Customer__c = customerAccount.id;
                wo.Subject = 'WO-'+i;
                workOrders.add(wo);
                
            }
            
            insert workOrders;
            
            workOrders = [SELECT id, UNITY_Customer__c,UNITY_Customer_PIN__c, Case.UNITY_Customer__c FROM WorkOrder ];            
            /*
            for(WorkOrder onWO :workOrders){
                System.assertEquals(onWO.Case.UNITY_Customer__c, onWO.UNITY_Customer__c, 'Should be the same.');
                System.assert(onWO.UNITY_Customer_PIN__c!= NULL && 
                              onWO.UNITY_Customer_PIN__c.length() == 4,'The UNITY_Customer_PIN__ field value should be a four digit string,'+onWO.UNITY_Customer_PIN__c);
            }
            */
            
        Test.stopTest();    
    
    }

    private static String  VENDOR_ID      = 'vendorId';
    private static String  VENDOR_PIN     = 'vendorPin';
    private static String  VENDOR_EMAIL   = 'vendorEmail';
    private static String  IS_OON         = 'isOON';
    private static String  VENDOR_WARNING = 'vendorWarning';
    private static String  AUTO_DISPATCH  = 'autoDispatch';
    
    static testMethod void manualVendorAssignment(){
        
        Map<String,Object> data = data_A();
        
        Account customer      = (Account)data.get('customer');
        FSO__Skill__c skill   = (FSO__Skill__c)data.get('skill');
        String locationKey    = (String)data.get('locationKey');
        List<Account> vendors = (List<Account>)data.get('vendors');
        List<UNITY_Vendor_Trade__c>               vendorTrades      = (List<UNITY_Vendor_Trade__c>)data.get('vendorTrades');
        List<UNITY_Vendor_Covered_Location__c>    locationVendors   = (List<UNITY_Vendor_Covered_Location__c>)data.get('locationVendors');
        Map<id,UNITY_Vendor_Preference__c>        vendorPreferences = null;
        List<UNITY_Vendor_Preference_By_Trade__c> vendorPreferenceTrades = null;
        
        Map<String,Object> workOrderFields         = UNITY_TestDataFactory.MOCKUP_WORK_ORDER_FIELDS;
        Map<String,Object> caseFields              = UNITY_TestDataFactory.MOCKUP_WORK_ORDER_FIELDS;
        Map<String,Object> vendorPreferenceFields  = UNITY_TestDataFactory.MOCKUP_VENDOR_ASSIGNMENT_FIELDS;
        
        Map<String, Object> dataFields = new  Map<String, Object>();
        dataFields.put(VENDOR_ID        , vendors.get(0).id);
        dataFields.put(VENDOR_PIN       , null);
        dataFields.put(VENDOR_EMAIL     , vendors.get(0).Account_Email__c);
        dataFields.put(IS_OON           , false);
        dataFields.put(VENDOR_WARNING   , null);
            
        Test.startTest();
        
            caseFields.put('RecordTypeId'     , UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE);
            caseFields.put('Status'           , 'Verified');
            caseFields.put('AccountId'        , customer.id);
            caseFields.put('Customer__c'      , customer.id);
            caseFields.put('UNITY_Trade__c'   , skill.id);
            
            Case onCase = (Case) UNITY_TestDataFactory.createObject(1, Case.getSObjectType(), caseFields).get(0);
            insert onCase; 
            
            workOrderFields.put('RecordTypeId'      , UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE);
            workOrderFields.put('CaseId'      , onCase.id);
            workOrderFields.put('AccountId'   , customer.id);
            workOrderFields.put('Subject'   , 'WO-Test');
            workOrderFields.put('UNITY_Trade__c'    , skill.id);
            workOrderFields.put('UNITY_Customer__c' , customer.id);
            
            WorkOrder workOrder  = UNITY_TestDataFactory.createWorkOrders(1,workOrderFields).get(0) ;
            insert workOrder;
        
            vendorPreferenceFields.put('Customer__c', customer.id);
            vendorPreferenceFields.put('Trade__c'   , skill.id);
            vendorPreferenceFields.put('Vendor__c'  , vendors.get(0).id);
            vendorPreferenceFields.put('Status__c'  , UNITY_Constants.VENDOR_ASSIGNMENT_STATUS_CANDIDATE);
            vendorPreferenceFields.put('Work_Order__c' , workOrder.id);
            UNITY_Vendor_Assignment__c vendorAssignment = (UNITY_Vendor_Assignment__c)UNITY_TestDataFactory.createObject(1, UNITY_Vendor_Assignment__c.getSObjectType(), vendorPreferenceFields).get(0);
            insert vendorAssignment;
            
            vendorAssignment = [SELECT id, Customer__c, Trade__c, Vendor__c, Status__c, PIN__c, Work_Order__c,UNITY_Vendor_Email__c FROM UNITY_Vendor_Assignment__c WHERE id = :vendorAssignment.id ];
            //system.assert(vendorAssignment.PIN__c != null);
            //system.assert(vendorAssignment.UNITY_Vendor_Email__c != null);
            
            dataFields.put(VENDOR_PIN       , vendorAssignment.PIN__c);
        
            workOrder = getWO(workOrder.id);
/*
            system.assertEquals(null ,workOrder.UNITY_Vendor_Email__c );
            system.assertEquals(null ,workOrder.UNITY_Assigned_Vendor__c );
            system.assertEquals(null ,workOrder.UNITY_Accepted_Vendor__c );
            system.assertEquals(null ,workOrder.UNITY_Vendor_PIN__c);
            system.assertEquals(false,workOrder.UNITY_OON_Vendor_Assigned__c);
            system.assertEquals(null ,workOrder.UNITY_Vendor_Assignment_Warning__c);
            
        */
            // Assign vendor
            workOrder.UNITY_Assigned_Vendor__c = vendors.get(0).id; 
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_ASSIGNED;
        
            update workOrder;
        
            workOrder = getWO(workOrder.id);
            
            checkAssignmentFields(true, false, false, workOrder, dataFields,false);
            
            // Reject vendor
            dataFields.put(VENDOR_ID        , null);
            dataFields.put(VENDOR_PIN       , null);
            dataFields.put(VENDOR_EMAIL     , null);
            dataFields.put(IS_OON           , false);
            dataFields.put(VENDOR_WARNING   , null);
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
        
            update workOrder;
            
            workOrder = getWO(workOrder.id);
            
            checkAssignmentFields(false, false, true, workOrder, dataFields,false);
        
            // Reassign vendor
            dataFields.put(VENDOR_ID        , vendors.get(0).id);
            dataFields.put(VENDOR_PIN       , vendorAssignment.PIN__c);
            dataFields.put(VENDOR_EMAIL     , vendors.get(0).Account_Email__c);
            dataFields.put(IS_OON           , false);
            dataFields.put(VENDOR_WARNING   , null);
            workOrder.UNITY_Assigned_Vendor__c = vendors.get(0).id; 
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_ASSIGNED;
        
            update workOrder;
        
            workOrder = getWO(workOrder.id);
            
            checkAssignmentFields(true, false, false, workOrder, dataFields,false);
        
            // Accept venor
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_ACCEPTED; 
        
            update workOrder;
            
            workOrder = getWO(workOrder.id);
            
            checkAssignmentFields(false, true, false, workOrder, dataFields,false);
        
            
        
        Test.stopTest();
        
    }
    
  
    static testMethod void autoDispatchAssignment(){
        
        Map<String,Object> data = data_A();
        
        Account customer      = (Account)data.get('customer');
        FSO__Skill__c skill   = (FSO__Skill__c)data.get('skill');
        String locationKey    = (String)data.get('locationKey');
        List<Account> vendors = (List<Account>)data.get('vendors');
        List<UNITY_Vendor_Trade__c>               vendorTrades      = (List<UNITY_Vendor_Trade__c>)data.get('vendorTrades');
        List<UNITY_Vendor_Covered_Location__c>    locationVendors   = (List<UNITY_Vendor_Covered_Location__c>)data.get('locationVendors');
        Map<id,UNITY_Vendor_Preference__c>        vendorPreferences = null;
        List<UNITY_Vendor_Preference_By_Trade__c> vendorPreferenceTrades = null;
        
        Map<String,Object> workOrderFields         = UNITY_TestDataFactory.MOCKUP_WORK_ORDER_FIELDS;
        Map<String,Object> caseFields              = UNITY_TestDataFactory.MOCKUP_WORK_ORDER_FIELDS;
        Map<String,Object> vendorPreferenceFields  = UNITY_TestDataFactory.MOCKUP_VENDOR_ASSIGNMENT_FIELDS;
        
        Map<String, Object> dataFields = new  Map<String, Object>();
        dataFields.put(VENDOR_ID        , null);
        dataFields.put(VENDOR_PIN       , null);
        dataFields.put(VENDOR_EMAIL     , null);
        dataFields.put(IS_OON           , false);
        dataFields.put(VENDOR_WARNING   , null);
        dataFields.put(AUTO_DISPATCH    , null);
         
        Map<id,Account> vendorsMap  = new Map<id,Account>();
        for(Account vendor :vendors){
            vendorsMap.put(vendor.id, vendor);
        }
            
        Test.startTest();
        
            caseFields.put('RecordTypeId'     , UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE);
            caseFields.put('AccountId'        , customer.id);
            caseFields.put('Customer__c'      , customer.id);
            caseFields.put('UNITY_Trade__c'   , skill.id);
            
            Case onCase = (Case) UNITY_TestDataFactory.createObject(1, Case.getSObjectType(), caseFields).get(0);
            insert onCase; 
            
            onCase.Status = 'Verified ';
            onCase.Description = 'test case';
            update onCase;
        
            workOrderFields.put('RecordTypeId'      , UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE);
            workOrderFields.put('CaseId'      , onCase.id);
            workOrderFields.put('AccountId'   , customer.id);
            workOrderFields.put('Subject'   , 'WO-Test');
            workOrderFields.put('UNITY_Trade__c'    , skill.id);
            workOrderFields.put('UNITY_Customer__c' , customer.id);
            workOrderFields.put('UNITY_Customer_Service_Contract_Price__c' , 100);
            workOrderFields.put('UNITY_Customer_Margin__c' , 70);
            WorkOrder workOrder  = UNITY_TestDataFactory.createWorkOrders(1,workOrderFields).get(0) ;
            insert workOrder;
            
           // list<UNITY_wrapperVendorByTrade> vendorsW = UNITY_Vendor_Utils.getVendorsSpecific(new list<id>{workOrder.id}, false).get(workOrder.id);
                
            workOrder = getWO(workOrder.id);
            workOrder.UNITY_Auto_Dispatch__c = true ;
            update workOrder;
        
            list<UNITY_Vendor_Assignment__c> vendorAssignments = [SELECT id, Customer__c, Trade__c, Vendor__c, Status__c, PIN__c, Work_Order__c,UNITY_Vendor_Email__c FROM UNITY_Vendor_Assignment__c WHERE Work_Order__c = :workOrder.id ];
            //system.assert(vendorAssignments.size()== 3);
            system.debug('>>> neli vendorAssignments.size() >>>>' + vendorAssignments.size());
        
            Map<id,UNITY_Vendor_Assignment__c> assignmentMap = new Map<id,UNITY_Vendor_Assignment__c>();
            for(UNITY_Vendor_Assignment__c va :vendorAssignments){
                assignmentMap.put(va.Vendor__c, va);
            }

            workOrder = getWO(workOrder.id);
           /*
            dataFields.put(VENDOR_ID        , vendorsW.get(0).id);
            dataFields.put(VENDOR_PIN       , assignmentMap.get(vendorsW.get(0).id).PIN__c);
            dataFields.put(VENDOR_EMAIL     , vendorsW.get(0).email);
            dataFields.put(IS_OON           , false);
            dataFields.put(VENDOR_WARNING   , null);
            dataFields.put(AUTO_DISPATCH    , 1);
            
            checkAssignmentFields(true, false, false, workOrder, dataFields,false);
        
            
            // Reject vendor
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
            update workOrder;
            
        
            workOrder = getWO(workOrder.id);

            dataFields.put(VENDOR_ID        , vendorsMap.get(vendorsW.get(1).id).id);
            dataFields.put(VENDOR_PIN       , assignmentMap.get(vendorsW.get(1).id).PIN__c);
            dataFields.put(VENDOR_EMAIL     , vendorsMap.get(vendorsW.get(1).id).Account_Email__c);
            dataFields.put(IS_OON           , false);
            dataFields.put(VENDOR_WARNING   , null);
            dataFields.put(AUTO_DISPATCH    , 2);
        
            checkAssignmentFields(true, false, false, workOrder, dataFields,false);
            
            // Reject vendor
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
            update workOrder;
            
            workOrder = getWO(workOrder.id);

            dataFields.put(VENDOR_ID        , vendorsMap.get(vendorsW.get(2).id).id);
            dataFields.put(VENDOR_PIN       , assignmentMap.get(vendorsW.get(2).id).PIN__c);
            dataFields.put(VENDOR_EMAIL     , vendorsMap.get(vendorsW.get(2).id).Account_Email__c);
            dataFields.put(IS_OON           , false);
            dataFields.put(VENDOR_WARNING   , null);
            dataFields.put(AUTO_DISPATCH    , 3);
        
            checkAssignmentFields(true, false, false, workOrder, dataFields,false);
             */
             
            // Reject vendor
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
            update workOrder;
            
            workOrder = getWO(workOrder.id);
        
            //system.assertEquals(UNITY_Constants.WO_VENDOR_STATUS_NO_CANDIDATE ,workOrder.UNITY_Vendor_Status__c);
            system.debug('>>>>   neli workOrder.UNITY_Vendor_Status__c) >>>>' + workOrder.UNITY_Vendor_Status__c);
        
            vendorAssignments = [SELECT id, Customer__c, Trade__c, Vendor__c, Status__c, PIN__c, Work_Order__c,UNITY_Vendor_Email__c FROM UNITY_Vendor_Assignment__c WHERE Work_Order__c = :workOrder.id ];
            
            for(UNITY_Vendor_Assignment__c va :vendorAssignments){
               // system.assertEquals(UNITY_Constants.WO_VENDOR_STATUS_REJECTED ,va.Status__c);
                system.debug('>>>>  neli va.Status__c >>>> ' + va.Status__c);
            }
        
        Test.stopTest();
        
    }

    
    static void checkAssignmentFields(Boolean isAssigned, Boolean isAccepted, Boolean isRejected, WorkOrder workOrder, Map<String, Object> data, boolean isOON) {
        
        if(isRejected){
           /* system.assertEquals(null ,workOrder.UNITY_Vendor_Email__c,'Vendor Email');
            system.assertEquals(null ,workOrder.UNITY_Assigned_Vendor__c,'Vendor Assigned');
            system.assertEquals(null ,workOrder.UNITY_Accepted_Vendor__c,'Vendor Accepted');
            system.assertEquals(null ,workOrder.UNITY_Vendor_PIN__c,'Vendor PIN');
            system.assertEquals(false,workOrder.UNITY_OON_Vendor_Assigned__c,'OON Assigned');
            system.assertEquals(null ,workOrder.UNITY_Vendor_Assignment_Warning__c,'');*/
        }else{
            if(isAssigned){
                //system.assertEquals(data.get(VENDOR_ID)      ,workOrder.UNITY_Assigned_Vendor__c,'Vendor Assigned');
                //system.assertEquals(data.get(VENDOR_EMAIL)   ,workOrder.UNITY_Vendor_Email__c,'Vendor Email');
               // system.assertEquals(data.get(VENDOR_PIN)     ,workOrder.UNITY_Vendor_PIN__c,'Vendor PIN');
                //system.assertEquals(data.get(IS_OON)         ,workOrder.UNITY_OON_Vendor_Assigned__c,'OON Assigned'); 
                //system.assertEquals(data.get(VENDOR_WARNING) ,workOrder.UNITY_Vendor_Assignment_Warning__c,'Wanrning');
                if(data.get(AUTO_DISPATCH)!=null) system.assertEquals(data.get(AUTO_DISPATCH) ,workOrder.UNITY_Dispatch_Attempts__c,'Dispatch_Attempts');
            }else if(isAccepted){
                //system.assertEquals(data.get(VENDOR_ID),workOrder.UNITY_Accepted_Vendor__c,'Vendor Assigned');
            }
        }
        
        
    }    
    
    static WorkOrder getWO(id woId) {
         return [SELECT id, UNITY_Vendor_Email__c, UNITY_Action__c, ownerId,
                                 UNITY_Assigned_Vendor__c, UNITY_Agent__c ,
                                 UNITY_Accepted_Vendor__c, 
                                 UNITY_Vendor_PIN__c,UNITY_Dispatch_Attempts__c,
                                 UNITY_OON_Vendor_Assigned__c, UNITY_Vendor_Status__c,
                                 UNITY_Vendor_Assignment_Warning__c 
                         FROM  WorkOrder 
                         WHERE id = :woId ];
    }   
    
    
    static Map<String,Object> data_A() {
        
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