@isTest
private class UNITYPM_AddRemoveWOLIs_UT {
    
    private static String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
    private static String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
	private static String woRTId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
    private static Account cust;
    private static Account vend;
	private static WorkOrder wo;
	
	
    @testSetup
    public static void init(){
        TestDataProvider.unityTestSetup();
    }
    
	private static testMethod void test() {
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
	    
	    //UNITY_Constants.executionsPerTrigger.put('UNITYPM_AddWorkPlansControllerExtension_UT',1);
	    
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
	  
	    system.assert(c2.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE); 
    	system.assert(wo != null);
	    system.assert(wo.Status == 'New');
	    system.assert(wo.UNITY_Assigned_Vendor__c == null);
        system.assert(wo.RecordTypeId == UNITY_Constants.wo_PREVENTATIVE_MAINTENANCE_RECORDTYPE); 
        
        vendor.UNITY_Service_Contract__c= testVendorServiceContract.ID;
	     
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
	     
	    
	    //create assets
	    List<Asset> assets = new List <Asset>();
	    
	    Asset asset1 = new Asset(Name = 'Test1', Description ='Test1', AccountId = custSite.Id, UNITY_Asset_Type__c= 'Dock');
        assets.add(asset1);
        
         Asset asset2 = new Asset(Name = 'Test2',  Description ='Test2',  AccountId = custSite.Id, UNITY_Asset_Type__c ='Dock');
        assets.add(asset2);
        
         Asset asset3 = new Asset(Name = 'Test3',  Description ='Test3',  AccountId = custSite.Id, UNITY_Asset_Type__c = 'Dock');
         assets.add(asset3);
          
        Asset asset4 = new Asset(Name = 'Test4',  Description ='Test4',  AccountId = custSite.Id, UNITY_Asset_Type__c ='Forklift');
        assets.add(asset4);
        
        Asset asset5 = new Asset(Name = 'Test5',  Description ='Test5',  AccountId = custSite.Id, UNITY_Asset_Type__c = 'Forklift');
        assets.add(asset5);
        
        insert assets;
	    
	    assets = [select id, name , Description, AccountId, UNITY_Asset_Type__c from asset];
	    
	      system.assert(assets.size() == 5);
	    
	    //create work plan and work plan items
	    List<FSO__WorkPlan__c> workPlanList = new List<FSO__WorkPlan__c>();
	    FSO__WorkPlan__c wp1 = new FSO__WorkPlan__c(Name ='wp1', UNITY_Asset_Type__c ='Dock');
	    workPlanList.add(wp1);
	    
	    FSO__WorkPlan__c wp2 = new FSO__WorkPlan__c(Name ='wp2', UNITY_Asset_Type__c ='Forklift');
	    workPlanList.add(wp2);  
	    
	    insert workPlanList;
	    
	    workPlanList = [select id from FSO__WorkPlan__c ];
	    
	    system.assert(workPlanList.size() == 2);
	    
	    
	    List <FSO__WorkPlanItem__c> wpil = new List<FSO__WorkPlanItem__c>();
	    FSO__WorkPlanItem__c  wpi1 = new FSO__WorkPlanItem__c (Name = 'wpi1', FSO__Description__c ='wpi1', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp1.ID);
	    wpil.add(wpi1);
	    
	    FSO__WorkPlanItem__c  wpi2 = new FSO__WorkPlanItem__c (Name = 'wpi2', FSO__Description__c ='wpi2', UNITY_Render_Type__c='Pass/Fail', FSO__WorkPlan__c = wp2.ID );
	    wpil.add(wpi2);
	    
	    insert wpil;
	    
	    //connect assets and work plan 
	    workPlanList = [select id, UNITY_Asset_Type__c from FSO__WorkPlan__c ];
	    
	    
	    //===============================================================
	    //work order  --> wo.id
	     List<String> assetnameWPid = new List<String>();
	     Set<ID> wpIDs = new Set<ID>();
	     Set<ID> aIDs = new Set<ID>();
	    
	    for (Asset a :assets){
	       aIDs.add(a.ID) ;
	       if (a.UNITY_Asset_Type__c == 'Dock' ){
	          wpIDs.add(wp1.ID); 
	           assetnameWPid.add(a.ID + ',' + wp1.ID);
	       }
	       if (a.UNITY_Asset_Type__c == 'Forklift' ){
	           wpIDs.add(wp2.ID) ;
	            assetnameWPid.add(a.ID + ',' + wp2.ID);
	       }
	    }
	    
	    system.assert(assetnameWPid.size() == 5);
	    system.assert(aIDs.size() == 5);
	    system.assert(wpIDs.size() == 2);
	    
	     UNITYPM_AddRemoveWOLIsOnWrokOrder.createWorkOrderLineItems(wo.ID, assetnameWPid, wpIDs, aIDs);
         
         List<WorkOrderLineItem> wolis = [select ID from WorkOrderLineItem where WorkOrderId =:wo.ID];
         
          system.assert(wolis.size() > 0);
	      
	      UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets( cust.Id, wo.id, 'Dock', 4);
	      
	      UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets( cust.Id, wo.id, 'Forklift', 5);
	      
	    Test.StopTest();
	    
	    
	}

     public static void setupAcctAndWorkOrder(){
        //Get the accounts
        List<Account> accounts = [SELECT Id,RecordTypeId,Account_Email__c FROM Account];
        
        for(Account a :accounts){
            if(a.RecordTypeId == custRTId)
                cust = a;
            if(a.RecordTypeId == vendRTId)
                vend = a;
        }
        cust.Type = 'Site/Location';
        update cust;

        vend.UNITY_Vendor_Status__c = 'Active';
        update vend;
               
    }
    private static testMethod void test2(){
         setupAcctAndWorkOrder();
       
       Test.StartTest();
       
        //Get the case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        //Create a Work Order
        wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Business_Unit__c = 'MNS';
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
        insert wo; 
        
	   // PageReference pr = Page.chk4;
    //	pr.getParameters().put('id',  String.valueOf(wo.Id));
        //Test.setCurrentPage(pr);
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(wo);
       // UNITYPM_AddWorkPlansControllerExtension controller = new UNITYPM_AddWorkPlansControllerExtension(sc);
        // controller.addPlan();
         
         //create assets
	    List<Asset> assets = new List <Asset>();
	    
	    Asset asset1 = new Asset(Name = 'Test1', Description ='Test1', AccountId = cust.Id, UNITY_Asset_Type__c= 'Dock');
        assets.add(asset1);
        
         Asset asset2 = new Asset(Name = 'Test2',  Description ='Test2',  AccountId = cust.Id, UNITY_Asset_Type__c ='Dock');
        assets.add(asset2);
        
         Asset asset3 = new Asset(Name = 'Test3',  Description ='Test3',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Dock');
         assets.add(asset3);
          
        Asset asset4 = new Asset(Name = 'Test4',  Description ='Test4',  AccountId = cust.Id, UNITY_Asset_Type__c ='Forklift');
        assets.add(asset4);
        
        Asset asset5 = new Asset(Name = 'Test5',  Description ='Test5',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Forklift');
        assets.add(asset5);
        
        insert assets;
	    
	    assets = [select id, name , Description, AccountId, UNITY_Asset_Type__c from asset];
	    
	      system.assert(assets.size() == 5);
	    
	    //create work plan and work plan items
	    List<FSO__WorkPlan__c> workPlanList = new List<FSO__WorkPlan__c>();
	    FSO__WorkPlan__c wp1 = new FSO__WorkPlan__c(Name ='wp1', UNITY_Asset_Type__c ='Dock');
	    workPlanList.add(wp1);
	    
	    FSO__WorkPlan__c wp2 = new FSO__WorkPlan__c(Name ='wp2', UNITY_Asset_Type__c ='Forklift');
	    workPlanList.add(wp2);  
	    
	    insert workPlanList;
	    
	    workPlanList = [select id from FSO__WorkPlan__c ];
	    
	    system.assert(workPlanList.size() == 2);
	    
	    
	    List <FSO__WorkPlanItem__c> wpil = new List<FSO__WorkPlanItem__c>();
	    FSO__WorkPlanItem__c  wpi1 = new FSO__WorkPlanItem__c (Name = 'wpi1', FSO__Description__c ='wpi1', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp1.ID);
	    wpil.add(wpi1);
	    
	    FSO__WorkPlanItem__c  wpi2 = new FSO__WorkPlanItem__c (Name = 'wpi2', FSO__Description__c ='wpi2', UNITY_Render_Type__c='Pass/Fail', FSO__WorkPlan__c = wp2.ID );
	    wpil.add(wpi2);
	    
	    insert wpil;
	    
	    //connect assets and work plan 
	    workPlanList = [select id, UNITY_Asset_Type__c from FSO__WorkPlan__c ];
	    
	    
	    //===============================================================
	    //work order  --> wo.id
	     List<String> assetnameWPid = new List<String>();
	     Set<ID> wpIDs = new Set<ID>();
	     Set<ID> aIDs = new Set<ID>();
	    
    	    for (Asset a :assets){
    	       aIDs.add(a.ID) ;
    	       if (a.UNITY_Asset_Type__c == 'Dock' ){
    	          wpIDs.add(wp1.ID); 
    	           assetnameWPid.add(a.ID + ',' + wp1.ID);
    	       }
    	       if (a.UNITY_Asset_Type__c == 'Forklift' ){
    	            wpIDs.add(wp2.ID) ;
    	            assetnameWPid.add(a.ID + ',' + wp2.ID);
    	       }
    	    }
    	    
    	    system.assert(assetnameWPid.size() == 5);
    	    system.assert(aIDs.size() == 5);
    	    system.assert(wpIDs.size() == 2);
	    
	    
	    
	     
	      UNITYPM_AddRemoveWOLIsOnWrokOrder.createWorkOrderLineItems(wo.ID, assetnameWPid, wpIDs, aIDs);
	      
	      List<WorkOrderLineItem> wolis = [select ID from WorkOrderLineItem where WorkOrderId =:wo.ID];
	      
	      system.assert(wolis.size() > 0);
	      
	      UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets( cust.Id, wo.id, 'Dock', 4);
	      
	      UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets( cust.Id, wo.id, 'Forklift', 5);
	      
	      Test.StopTest();
    }
}