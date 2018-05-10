@isTest
public class UNITY_FixWorkOrderManualSharing_UT {
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
    
    static  testmethod void test1(){
        Account cust;
        Account vend;
        Account bu;
        
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String usageRecRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        String purchaseOrdRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;

        Test.startTest();
		User admin = TestDataProvider.getUser('Tim', 'System_Admin', 'System Administrator');
        
        //Get the accounts
        List<Account> accounts = [SELECT Id,RecordTypeId,Account_Email__c FROM Account];
        
        for(Account a :accounts){
            if(a.RecordTypeId == custRTId)
                cust = a;
            if(a.RecordTypeId == vendRTId)
                vend = a;
            if(a.RecordTypeId == buRTId)
                bu = a;
        }

		Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.Email='test@test.com';
        c.AccountId = vend.Id;
        insert c;
        
        createuser(admin, c, 'test1@dkfjlf.com.d1', 'test1@dkfjlf.com');
       
        Contact c1 = new Contact();
        c1.FirstName = 'Test';
        c1.LastName = 'Test';
        c1.Email='test@test.com';
        c1.AccountId = vend.Id;
        insert c1;
        
        createuser(admin, c1, 'test1@dkfjlf.com.d1111', 'test1@dkfjlf1111.com');
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        //Create an agent
        User agent = TestDataProvider.getUser('Agent', 'One', 'NMS Technician');
        insert agent;
        
        //Create a Work Order
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = testCase.Id;
        wo.Description = 'Test Test Test';
        wo.UNITY_Work_Description__c = 'Test Test Test';
        wo.UNITY_Work_Window_Begin__c = DateTime.now();
        wo.UNITY_Work_Window_End__c = DateTime.now().addMinutes(60);
        wo.MSPFS_Intercompany_Transfer__c = true;
        wo.UNITY_Agent__c = agent.Id;
        wo.UNITY_Assigned_Vendor__c = vend.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Vendor_Status__c = 'Accepted';
        wo.Subject = 'Test';
        insert wo;    

      

        //Determine the group id
        List<UserRole> ur = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId = :vend.Id];
        Map<Id,Group> groupMap = new Map<Id, Group>([SELECT Id, RelatedID FROM Group WHERE RelatedID = :ur[0].Id]);
        List<WorkOrderShare> shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        System.Assert(shareList.size() > 0);
         
        UNITY_Constants.executionsPerTrigger.put('UNITY_WorkOrderTriggerHandler_Miner',1); 
        
        wo.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
		wo.UNITY_Assigned_Vendor__c = null;
		update wo;
       
        shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        system.debug('@@@testWOShareVendor unshare:'+shareList);
        System.Assert(shareList.size() <= 0);
       
         
        Account vend2 = new Account();
        vend2.RecordTypeId  = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        vend2.Name = 'Test Vendor Account';
        vend2.Type = 'Site/Location';
        vend2.BillingCity = 'Brooklyn';
        vend2.BillingStateCode = 'NY';
        vend2.BillingStreet = '123 Fake St.';
        vend2.BillingPostalCode = '123456';
        vend2.Account_Status__c = 'Active';
        insert vend2;

        system.debug('@@@testWOShareVendor vend2:'+vend2);
        
        Contact c2 = new Contact();
        c2.FirstName = 'Test';
        c2.LastName = 'Test';
        c2.Email='test@test.com';
        c2.AccountId = vend2.Id;
        insert c2;
        
        createuser(admin, c2, 'test2@test.com.d1', 'test2@test.com');
        
        wo.UNITY_Assigned_Vendor__c = vend2.Id;
        update wo;

        wo = [SELECT UNITY_Assigned_Vendor__c From WorkOrder where Id = :wo.Id];
        system.debug('@@@testWOShareVendor wo1:'+wo.UNITY_Assigned_Vendor__c);
        
        ur = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId = :vend2.Id];
        groupMap = new Map<Id, Group>([SELECT Id, RelatedID FROM Group WHERE RelatedID = :ur[0].Id]);
        
        shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        system.debug('@@@testWOShareVendor share to vend2:'+shareList);
        System.Assert(shareList.size() > 0);       
        
        
        UNITY_FixWorkOrderManualSharing obj = new UNITY_FixWorkOrderManualSharing();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
    }
    
    
     static  testmethod void test2(){
        Account cust;
        Account vend;
        Account bu;
        
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String usageRecRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        String purchaseOrdRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;

        Test.startTest();
		User admin = TestDataProvider.getUser('Tim', 'System_Admin', 'System Administrator');
        
        //Get the accounts
        List<Account> accounts = [SELECT Id,RecordTypeId,Account_Email__c FROM Account];
        
        for(Account a :accounts){
            if(a.RecordTypeId == custRTId)
                cust = a;
            if(a.RecordTypeId == vendRTId)
                vend = a;
            if(a.RecordTypeId == buRTId)
                bu = a;
        }

		Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.Email='test@test.com';
        c.AccountId = vend.Id;
        insert c;
        
        createuser(admin, c, 'test1@dkfjlf.com.d1', 'test1@dkfjlf.com');
       
        Contact c1 = new Contact();
        c1.FirstName = 'Test';
        c1.LastName = 'Test';
        c1.Email='test@test.com';
        c1.AccountId = vend.Id;
        insert c1;
        
        createuser(admin, c1, 'test1@dkfjlf.com.d1111', 'test1@dkfjlf1111.com');
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        //Create an agent
        User agent = TestDataProvider.getUser('Agent', 'One', 'NMS Technician');
        insert agent;
         
         User agent1 = TestDataProvider.getUser('Agent1', 'Two', 'NMS Technician');
        insert agent1;
        
        //Create a Work Order
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = testCase.Id;
        wo.Description = 'Test Test Test';
        wo.UNITY_Work_Description__c = 'Test Test Test';
        wo.UNITY_Work_Window_Begin__c = DateTime.now();
        wo.UNITY_Work_Window_End__c = DateTime.now().addMinutes(60);
        wo.MSPFS_Intercompany_Transfer__c = true;
        wo.UNITY_Agent__c = agent.Id;
        wo.UNITY_Assigned_Vendor__c = vend.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Vendor_Status__c = 'Accepted';
        wo.Subject = 'Test';
        insert wo;          

        //Determine the group id
        List<UserRole> ur = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId = :vend.Id];
        Map<Id,Group> groupMap = new Map<Id, Group>([SELECT Id, RelatedID FROM Group WHERE RelatedID = :ur[0].Id]);
        List<WorkOrderShare> shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        System.Assert(shareList.size() > 0);
         
        UNITY_Constants.executionsPerTrigger.put('UNITY_WorkOrderTriggerHandler_Miner',1); 
        
        wo.UNITY_Vendor_Status__c = UNITY_Constants.WO_VENDOR_STATUS_REJECTED; 
		wo.UNITY_Assigned_Vendor__c = null;
		update wo;
       
        shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        system.debug('@@@testWOShareVendor unshare:'+shareList);
        System.Assert(shareList.size() <= 0);
       
         
        Account vend2 = new Account();
        vend2.RecordTypeId  = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        vend2.Name = 'Test Vendor Account';
        vend2.Type = 'Site/Location';
        vend2.BillingCity = 'Brooklyn';
        vend2.BillingStateCode = 'NY';
        vend2.BillingStreet = '123 Fake St.';
        vend2.BillingPostalCode = '123456';
        vend2.Account_Status__c = 'Active';
        insert vend2;

        system.debug('@@@testWOShareVendor vend2:'+vend2);
        
        Contact c2 = new Contact();
        c2.FirstName = 'Test';
        c2.LastName = 'Test';
        c2.Email='test@test.com';
        c2.AccountId = vend2.Id;
        insert c2;
        
        createuser(admin, c2, 'test2@test.com.d1', 'test2@test.com');
        
        wo.UNITY_Assigned_Vendor__c = vend2.Id;
        update wo;

        wo = [SELECT UNITY_Assigned_Vendor__c From WorkOrder where Id = :wo.Id];
        system.debug('@@@testWOShareVendor wo1:'+wo.UNITY_Assigned_Vendor__c);
        
        ur = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId = :vend2.Id];
        groupMap = new Map<Id, Group>([SELECT Id, RelatedID FROM Group WHERE RelatedID = :ur[0].Id]);
        
        shareList = [SELECT Id, UserOrGroupId FROM WorkOrderShare WHERE UserOrGroupId = :groupMap.keySet()];
        system.debug('@@@testWOShareVendor share to vend2:'+shareList);
        System.Assert(shareList.size() > 0);       
        
        wo.UNITY_Agent__c = agent1.Id;
        update wo;
         
        List<WorkOrderShare> woShare = new List<WorkOrderShare>();
        
         for (WorkOrderShare ws : [SELECT UserOrGroupId, Id, AccessLevel, ParentId, RowCause FROM WorkOrderShare where UserOrGroupId =:groupMap.keySet()]){
             woShare.add(ws);
         }
         
         delete woShare;
         
        UNITY_FixWorkOrderManualSharing obj = new UNITY_FixWorkOrderManualSharing();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
    }
    
    private static void createuser(User runAsUser, Contact c, String username, String email){        
        
        system.runAs(runAsUser){
            Profile p = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
            
            User user = new User();
            user.ProfileID = p.id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = username;   
            user.Alias = 't1';
            user.Email = email;
            user.IsActive = true;
            user.ContactId = c.Id;
            insert user;
        }
    }
}