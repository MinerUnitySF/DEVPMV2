@isTest
private class UNITYPM_WorkOrderTriggerHandler_Miner_UT {
     @testSetup
    public static void init(){
        TestDataProvider.unityTestSetup();
    }
    

/*
	private static testMethod void test1() {
      TestDataProvider.unityTestSetup();
        
        Account cust;
        Account vend;
        Account bu;
        
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        
        String progCaseId = UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE;
        String pmCaseId = UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
        
        String woPMId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
        
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
        
        createPMuser(admin, c, 'test1@dkfjlf.com.d1', 'test1@dkfjlf.com');
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        
	}
  */
   private static testMethod void test2(){
       List<Account> accts = new List<Account>();
        Account cust = TestDataProvider.getAccounts(1,'Customer', 'Customer')[0];
        cust.Account_Status__c = 'Active';
        cust.UNITY_Customer_Team__c = 'Team 1';
        cust.UNITY_MNS_Customer_Team__c = 'Team 1';
        cust.UNITY_Tier_Level__c = 'Tier 1';
        accts.add(cust);
        
        Account custSite = TestDataProvider.getAccounts(1,'Customer', 'Site/Location')[0];
        custSite.Account_Status__c = 'Active';
        custSite.UNITY_Customer_Team__c = 'Team 1';
        custSite.UNITY_MNS_Customer_Team__c = 'Team 1';
        custSite.UNITY_Tier_Level__c = 'Tier 1';
        accts.add(custSite);
	

       // Account buNSBS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];buNSBS.UNITY_Business_Unit__c = 'NSBS';accts.add(buNSBS);
        Account buMNS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];buMNS.UNITY_Business_Unit__c = 'MNS';accts.add(buMNS);
        insert accts;
        
        //create vendor account 
         String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
         
	    Account vendor;
        Account account = [SELECT Id,RecordTypeId,Account_Email__c,UNITYPM_PIN__c,UNITY_Vendor_Type_PM__c FROM Account where RecordTypeId =:vendRTId];
        vendor = account;
        vendor.UNITY_Vendor_Type_PM__c = true;
        vendor.Account_Email__c = 'vendor@fggt.com';
        vendor.UNITYPM_PIN__c = '123';
	    update vendor;
	    
	      //create vendor 2 account 
	    Account vendor2;
        Account account2 = [SELECT Id,RecordTypeId,Account_Email__c,UNITYPM_PIN__c,UNITY_Vendor_Type_PM__c FROM Account where RecordTypeId =:vendRTId];
        vendor2 = account2;
        vendor2.UNITY_Vendor_Type_PM__c = true;
        vendor2.Account_Email__c = 'vendor2@fggt.com';
        vendor2.UNITYPM_PIN__c = '456';
	    update vendor2;
	    
        
        //create service contracts
        List<UNITY_Service_Contract__c> scList = new List<UNITY_Service_Contract__c>();
        
        UNITY_Service_Contract__c testServiceContract1 = new UNITY_Service_Contract__c( UNITY_Account__c = cust.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract1);
        
        UNITY_Service_Contract__c testServiceContract2 = new UNITY_Service_Contract__c( UNITY_Account__c = custSite.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract2);
       

        UNITY_Service_Contract__c testServiceContract3 = new UNITY_Service_Contract__c( UNITY_Account__c = custSite.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);
        							
         scList.add(testServiceContract3);

         UNITY_Service_Contract__c testVendorServiceContract = new UNITY_Service_Contract__c( UNITY_Account__c = vendor.Id, 
        						   RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 0.00);
     
         scList.add(testVendorServiceContract);
          
         UNITY_Service_Contract__c testVendorServiceContract2 = new UNITY_Service_Contract__c( UNITY_Account__c = vendor2.Id, 
        						   RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 0.00);

         scList.add(testVendorServiceContract2);      

        insert scList;
	    
	   
	    
        Case c = new Case();
        c.AccountId = cust.Id;
        c.UNITY_Customer__c = cust.Id;
        c.RecordTypeId = UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE;
        c.Status = 'New';
        c.UNITY_Business_Unit__c = 'MNS';
        c.UNITY_Business_Unit_Account__c = buMNS.Id;
        c.UNITY_Skill_Broad__c = 'Glass';
        c.UNITY_Customer_IVR_Pin__c ='12345';
        c.UNITY_Miner_IVR_Phone_Number__c = '9497894562';
		insert c;
        
        Case c2 = new Case();
        c2.AccountId = custSite.Id;
        c2.UNITY_Customer__c = custSite.Id;
        c2.UNITY_Business_Unit__c = 'MNS';
        c2.UNITY_Business_Unit_Account__c = buMNS.Id;
        c2.UNITY_Skill_Broad__c = 'Glass';
        c2.RecordTypeId = UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
        c2.ParentId = c.Id;
        c2.Status = 'New';
       
	    insert c2;
	    
	    c2.UNITY_Customer_IVR_Pin__c ='12345';
        c2.UNITY_Miner_IVR_Phone_Number__c = '9497894562';
        
	    update c2;
	    
	     Case c3 = [SELECT id,UNITY_Customer_IVR_Pin__c, UNITY_Miner_IVR_Phone_Number__c
	              from Case where id =:c2.ID] ;
	    
	      //Create an agent
        User agent = TestDataProvider.getUser('Agent', 'One', 'NMS Technician');
        insert agent;
        
	    Test.startTest();
	    
	    UNITY_Constants.executionsPerTrigger.put('UNITYPM_WorkOrderTriggerHandler_Miner_UT',1);
	    
	    system.debug('>>>  neli  case c >>>> ' + c);
	    system.debug('>>>  neli  case c2 >>>> ' + c2);
	     system.debug('>>>  neli  case c3 >>>> ' + c3);
	     
	    WorkOrder wo = [SELECT Id, UNITY_Business_Unit__c, Status,UNITY_Assigned_Vendor__c,
	                                 UNITY_Customer_IVR_Pin__c,UNITY_Miner_IVR_Phone_Number__c,
	                                      UNITY_Accepted_Vendor__c,UNITY_Vendor_Status__c,UNITY_Work_Description__c,
	                                      UNITY_Work_Window_Begin__c,UNITY_Work_Window_End__c,UNITY_Agent__c,RecordTypeId,
	                                      UNITY_Vendor_Contract__c, UNITY_Vendor_Email__c
	                                    FROM WorkOrder 
	                                    WHERE CaseId = :c2.Id LIMIT 1 ]; 
	    
	     system.debug('>>>  neli  work order >>>> ' + wo);
	    
	    WorkOrder wo1 = [SELECT Id, UNITY_Business_Unit__c, Status,UNITY_Assigned_Vendor__c,
	                                 UNITY_Customer_IVR_Pin__c,UNITY_Miner_IVR_Phone_Number__c,
	                                      UNITY_Accepted_Vendor__c,UNITY_Vendor_Status__c,UNITY_Work_Description__c,
	                                      UNITY_Work_Window_Begin__c,UNITY_Work_Window_End__c,UNITY_Agent__c,RecordTypeId,
	                                      UNITY_Vendor_Contract__c, UNITY_Vendor_Email__c
	                                    FROM WorkOrder WHERE ID =:wo.ID];  
	                                    
	                                    
	      system.debug('>>>  neli  work order1 >>>> ' + wo1);
	        system.debug('>>>  neli  work order1  UNITY_Miner_IVR_Phone_Number__c>>>> ' + wo1.UNITY_Miner_IVR_Phone_Number__c);
	          system.debug('>>>  neli  work order1 UNITY_Customer_IVR_Pin__c >>>> ' + wo1.UNITY_Customer_IVR_Pin__c);
	            system.debug('>>>  neli  work order1 >>>> UNITY_Vendor_Email__c ' + wo1.UNITY_Vendor_Email__c);
	      
	    system.assert(c2.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE); 
    	system.assert(wo != null);
	    system.assert(wo.Status == 'New');
	    system.assert(wo.UNITY_Assigned_Vendor__c == null);
        system.assert(wo.RecordTypeId == UNITY_Constants.wo_PREVENTATIVE_MAINTENANCE_RECORDTYPE); 
        
         vendor.UNITY_Service_Contract__c= testVendorServiceContract.ID;
         vendor2.UNITY_Service_Contract__c= testVendorServiceContract2.ID;
         
	     List<WorkOrderLineItem> woliInsertList = [select ID,RecordTypeId,UNITY_PM_WOLI__c from WorkOrderLineItem where WorkOrderId =:wo.ID];
	     system.debug('>>>> neli woliInsertList  >>>>' + woliInsertList);
	     
	     //system.assert(woliInsertList.size()== 3);
	     
	    //assign vendor
	     wo.UNITY_Assigned_Vendor__c = vendor.Id;
         wo.UNITY_Vendor_Status__c = 'Assigned';  
	     wo.UNITY_Work_Description__c = 'Test Test Test';
	     wo.UNITY_Agent__c = agent.Id;
	     wo.UNITY_Vendor_Email__c = vendor.Account_Email__c;
	     wo.UNITY_Vendor_Contract__c = testVendorServiceContract.ID;
	     wo.UNITY_Vendor_PIN__c =vendor.UNITYPM_PIN__c;
	     
	     update wo;
	     
	     system.assert( wo.UNITY_Assigned_Vendor__c == vendor.Id);
	     system.assert( wo.UNITY_Vendor_Status__c == 'Assigned');
	     system.assert( wo.UNITY_Vendor_Contract__c ==testVendorServiceContract.ID);
	     system.assert( wo.UNITY_Vendor_Email__c ==vendor.Account_Email__c);
	     system.assert( wo.UNITY_Vendor_PIN__c == vendor.UNITYPM_PIN__c);
	     
	     //changed vendor:
	     wo.UNITY_Assigned_Vendor__c = vendor2.Id;
         wo.UNITY_Vendor_Status__c = 'Assigned';  
	     wo.UNITY_Work_Description__c = 'Test2 Test2';
	     wo.UNITY_Agent__c = agent.Id;
	     wo.UNITY_Vendor_Email__c = vendor2.Account_Email__c;
	     wo.UNITY_Vendor_Contract__c = testVendorServiceContract2.ID;
	     wo.UNITY_Vendor_PIN__c = vendor2.UNITYPM_PIN__c;
	     
	     update wo;
	    
	      system.assert( wo.UNITY_Assigned_Vendor__c == vendor2.Id);
	      system.assert( wo.UNITY_Vendor_Status__c == 'Assigned');
	      system.assert( wo.UNITY_Vendor_Contract__c == testVendorServiceContract2.ID);
	      system.assert( wo.UNITY_Vendor_PIN__c == vendor2.UNITYPM_PIN__c);
	     
	    
	     wo.UNITY_Accepted_Vendor__c = vendor2.Id;
	     wo.UNITY_Vendor_Status__c = 'Accepted';
	     wo.UNITY_Work_Window_Begin__c = DateTime.now();
         wo.UNITY_Work_Window_End__c = DateTime.now().addMinutes(60);
	     update wo;
	     
	     //wo.FSO__Check_In_Date__c = DateTime.now();
	     // wo.FSO__Completed_Date__c =DateTime.now().addMinutes(60);
	      wo.UNITY_Vendor_Status__c = 'IVR Check Out - Agent Review Needed';
	      wo.UNITY_Override_Attach_Compliance_Reason__c = 'All PM paperwork received and processed';
	      //wo.UNITY_Attachment_Compliant__c = true;
	      update wo;
	     
	      system.assert( wo.UNITY_Override_Attach_Compliance_Reason__c != null);
	      
	     //wo.SFPS_FS_AllTasks_Completed__c = 'Complete';
	    // wo.UNITY_Next_Step__c = 'Completion Confirmed';
	    // wo.UNITY_Attachment_Compliant__c = true;
	     
	       
	     // wo.SFPS_FS_AllTasks_Completed__c = 'Partially Complete';
	      //wo.UNITY_Next_Step__c = 'Requires another trip';
	     // update wo;
	      
	     // system.assert( wo.SFPS_FS_AllTasks_Completed__c != null);
	    //  system.assert( wo.UNITY_Next_Step__c != null);
	      
	     // wo.SFPS_FS_AllTasks_Completed__c = 'PM Complete';
	    // wo.UNITY_Next_Step__c = 'Waiting for checklists';
	     
	    Test.StopTest();
	    
	    
   }

   private static void createPMuser(User runAsUser, Contact c, String username, String email){        
        
        system.runAs(runAsUser){
            Profile p = [select Id,name from Profile where Name = 'UNITY_PM' limit 1];
            
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