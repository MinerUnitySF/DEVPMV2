@isTest
public class UNITY_WorkOrderTriggerHandler_Miner_UT { 
    
    public static TestMethod void test1(){
        
        //Create a test user
        User u = TestDataProvider.getUsers(1)[0];
        u.Ignore_Validations__c = true;
        insert u;
        //create a queue
        Group q = new Group(Name = 'NSBS Tier 1 Team 1',Type = 'Queue',DeveloperName='UNITY_Tier_1_Team_1');
        insert q;
        //Create a queue object
        QueueSObject qso = new QueueSObject(QueueID = q.id, SobjectType = 'Case');
        insert qso;
        //create a regular group
        Group g = new Group(
            Name = 'NSBS Team 1',
            Type = 'Regular'
        );
        insert g;
        //Add the curremt user to the regular group
        GroupMember gm = new GroupMember(
            GroupId = g.Id,
            UserOrGroupId = u.Id
        );
        insert gm;
        //Add the regular group to the queue
        GroupMember qm = new GroupMember(
            GroupId = q.Id,
            UserOrGroupId = g.Id
        );
        insert qm;
        
        System.runAs(u){
            //Create BU SPecific Team field Map
            UNITY_BU_Team_Field_Map__c nsbsTeamMap = new UNITY_BU_Team_Field_Map__c(
                Name = 'NSBS',
                UNITY_Field_API_Name__c = 'UNITY_Customer_Team__c'
            );
            insert nsbsTeamMap;
            List<Account> accts = new List<Account>();
            Account cust = TestDataProvider.getAccounts(1,'Customer', 'Customer')[0];
            cust.Account_Status__c = 'Active';
            cust.UNITY_Customer_Team__c = 'Team 1';
            cust.UNITY_MNS_Customer_Team__c = 'Team 1';
            cust.UNITY_Tier_Level__c = 'Tier 1';
            accts.add(cust);
            Account vend = TestDataProvider.getAccounts(1,'Vendor', 'Vendor')[0];
            accts.add(vend);
            Account buNSBS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];
            buNSBS.UNITY_Business_Unit__c = 'NSBS';
            accts.add(buNSBS);
            insert accts;
            Account loc = TestDataProvider.getAccounts(1,'Customer', 'Site/Location')[0];
            loc.Account_Status__c = 'Active';
            loc.UNITY_Customer_Team__c = 'Team 1';
            loc.UNITY_MNS_Customer_Team__c = 'Team 1';
            loc.UNITY_Tier_Level__c = 'Tier 1';
            loc.UNITY_Bill_To_Account__c = cust.Id;
            loc.ParentId = cust.Id;
            insert loc;
            
            Case c = UNITY_TestDataFactory.createCases(1,loc.Id,loc.Id)[0];
            c.UNITY_Customer__c = loc.Id;
            c.UNITY_Business_Unit__c = 'NSBS';
            c.UNITY_Business_Unit_Account__c = buNSBS.Id;
            c.UNITY_Skill_Broad__c = 'Glass';
            
            update c;
            
            String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
            
            Test.startTest();
            WorkOrder wo = new WorkOrder();
            wo.AccountId = loc.Id;
            wo.UNITY_Assigned_Vendor__c = vend.Id;
            wo.UNITY_Business_Unit_Account__c = buNSBS.Id;
            wo.UNITY_Business_Unit__c = 'NSBS';
            wo.UNITY_Customer__c = loc.Id;
            wo.UNITY_Skill_Broad__c = 'Glass';
            wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
            wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
            wo.Priority = '24 Hour Response';
            wo.Status = 'New';
            wo.RecordTypeId = woRTId;
            wo.CaseId = c.Id;
            insert wo;
            
            wo.UNITY_Accepted_Vendor__c = vend.Id;
            wo.UNITY_Vendor_Status__c = 'Accepted';
            update wo;
            
            Set<Id> cids = new Set<Id>();
            cids.add(c.Id);
            UNITY_WorkOrderTriggerHandler_Miner.reassignCaseToCustTeam(cids);
            UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_After();
            UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_After();
            UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_Before();
            UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_Before();
            
            Test.stopTest();
        }
    }
    
    
    
     public static TestMethod void test2(){
        
        //Create a test user
        User u = TestDataProvider.getUsers(1)[0];
        u.Ignore_Validations__c = true;
        insert u;
        //create a queue
        Group q = new Group(Name = 'NSBS Tier 1 Team 1',Type = 'Queue',DeveloperName='UNITY_Tier_1_Team_1');
        insert q;
        //Create a queue object
        QueueSObject qso = new QueueSObject(QueueID = q.id, SobjectType = 'Case');
        insert qso;
        //create a regular group
        Group g = new Group(
            Name = 'NSBS Team 1',
            Type = 'Regular'
        );
        insert g;
        //Add the curremt user to the regular group
        GroupMember gm = new GroupMember(
            GroupId = g.Id,
            UserOrGroupId = u.Id
        );
        insert gm;
        //Add the regular group to the queue
        GroupMember qm = new GroupMember(
            GroupId = q.Id,
            UserOrGroupId = g.Id
        );
        insert qm;
        
        System.runAs(u){
            
             UNITY_Constants.executionsPerTrigger.put('UNITY_WorkOrderTriggerHandler_Miner_UT',1);
             
            //Create BU SPecific Team field Map
            UNITY_BU_Team_Field_Map__c nsbsTeamMap = new UNITY_BU_Team_Field_Map__c(
                Name = 'NSBS',
                UNITY_Field_API_Name__c = 'UNITY_Customer_Team__c'
            );
            insert nsbsTeamMap;
            List<Account> accts = new List<Account>();
            Account cust = TestDataProvider.getAccounts(1,'Customer', 'Customer')[0];
            cust.Account_Status__c = 'Active';
            cust.UNITY_Customer_Team__c = 'Team 1';
            cust.UNITY_MNS_Customer_Team__c = 'Team 1';
            cust.UNITY_Tier_Level__c = 'Tier 1';
            accts.add(cust);
            Account vend = TestDataProvider.getAccounts(1,'Vendor', 'Vendor')[0];
            accts.add(vend);
            Account buNSBS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];
            buNSBS.UNITY_Business_Unit__c = 'NSBS';
            accts.add(buNSBS);
            insert accts;
            Account loc = TestDataProvider.getAccounts(1,'Customer', 'Site/Location')[0];
            loc.Account_Status__c = 'Active';
            loc.UNITY_Customer_Team__c = 'Team 1';
            loc.UNITY_MNS_Customer_Team__c = 'Team 1';
            loc.UNITY_Tier_Level__c = 'Tier 1';
            loc.UNITY_Bill_To_Account__c = cust.Id;
            loc.ParentId = cust.Id;
            insert loc;
            
            Case c = UNITY_TestDataFactory.createCases(1,loc.Id,loc.Id)[0];
            c.UNITY_Customer__c = loc.Id;
            c.UNITY_Business_Unit__c = 'NSBS';
            c.UNITY_Business_Unit_Account__c = buNSBS.Id;
            c.UNITY_Skill_Broad__c = 'Glass';
            
            update c;
            
            String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
            
            Test.startTest();
            
              UNITY_Constants.executionsPerTrigger.put('UNITY_WorkOrderTriggerHandler_Miner_UT',1);
            
                WorkOrder wo = new WorkOrder();
                wo.AccountId = loc.Id;
                wo.UNITY_Assigned_Vendor__c = vend.Id;
                wo.UNITY_Business_Unit_Account__c = buNSBS.Id;
                wo.UNITY_Business_Unit__c = 'NSBS';
                wo.UNITY_Customer__c = loc.Id;
                wo.UNITY_Skill_Broad__c = 'Glass';
                wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
                wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
                wo.Priority = '24 Hour Response';
                wo.Status = 'New';
                wo.RecordTypeId = woRTId;
                wo.CaseId = c.Id;
                insert wo;
                
                wo.UNITY_Accepted_Vendor__c = vend.Id;
                wo.UNITY_Vendor_Status__c = 'Accepted';
                update wo;
                
                 system.debug('>>>>>  neli work order wo 1>>>>' + wo);
                   
                wo.UNITY_Work_Window_Begin__c = DateTime.now();
                wo.UNITY_Work_Window_End__c = DateTime.now().addMinutes(60);
                wo.Status = 'IVR Check Out - Agent Review Needed';
                wo.SFPS_FS_LastCheckOut__c = DateTime.now().addMinutes(60);
    	        update wo;
                
                system.debug('>>>>>  neli work order wo >>>> 2' + wo);
                
                c.UNITY_Attachment_Compliant__c = true;
                update c;
                
                wo.UNITY_Attachment_Compliant__c=true;
                 update wo;
                
                wo.Status ='IVR Check Out - Agent Review Needed'; 
                wo.SFPS_FS_AllTasks_Completed__c ='All Tasks Completed/Verified';
                wo.UNITY_Next_Step__c = 'Completion Confirmed';
                update wo;
                
                system.debug('>>>>>  neli work order wo >>>> 3' + wo);
                
                UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_After();
                UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_After();
                UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_Before();
                UNITY_WorkOrderTriggerHandler_Miner.runTriggerOnce_Before();
                
            
            
            Test.stopTest();
        }
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

    public static testMethod void testWOShareVendor(){
        TestDataProvider.unityTestSetup();
        
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

        Test.stopTest();

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
    }
}