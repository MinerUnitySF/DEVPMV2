@isTest
private class UNITYPM_AssetsWorkPlanPDFCntrlExt_UT{


    private static String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
    private static String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
	private static String woRTId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
    private static Account cust;
    private static Account vend;
	private static WorkOrder wo;
    

    //Setup test data
    @testSetup
    public static void init(){
        TestDataProvider.unityTestSetup();
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
    private static testMethod void test(){
        setupAcctAndWorkOrder();
        
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
        
        Test.startTest();  
	    //create assets
	    List<Asset> assets = new List <Asset>();
	    
	    Asset asset1 = new Asset(Name = 'Test1', Description ='Test1', AccountId = cust.Id, UNITY_Asset_Type__c= 'Dock');
        assets.add(asset1);
        Asset asset2 = new Asset(Name = 'Test2',  Description ='Test2',  AccountId = cust.Id, UNITY_Asset_Type__c ='Dock');
        assets.add(asset2);
        Asset asset3 = new Asset(Name = 'Test3',  Description ='Test3',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Dock');
        assets.add(asset3);
        Asset asset11 = new Asset(Name = 'Test11', Description ='Test11', AccountId = cust.Id, UNITY_Asset_Type__c= 'Dock');
        assets.add(asset11);
        Asset asset21 = new Asset(Name = 'Test21',  Description ='Test21',  AccountId = cust.Id, UNITY_Asset_Type__c ='Dock Equipment');
        assets.add(asset21);
        Asset asset31 = new Asset(Name = 'Test31',  Description ='Test31',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Walkie Stacker');
        assets.add(asset31);
        Asset asset41 = new Asset(Name = 'Test41', Description ='Test41', AccountId = cust.Id, UNITY_Asset_Type__c= 'Walkie Stacker');
        assets.add(asset41);
        Asset asset52 = new Asset(Name = 'Test52',  Description ='Test52',  AccountId = cust.Id, UNITY_Asset_Type__c ='Walkie Stacker');
        assets.add(asset52);
        Asset asset63 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Dock');
        assets.add(asset63);
        Asset asset4 = new Asset(Name = 'Test4',  Description ='Test4',  AccountId = cust.Id, UNITY_Asset_Type__c ='Dockleveler');
        assets.add(asset4);
        Asset asset5 = new Asset(Name = 'Test5',  Description ='Test5',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Dockleveler');
        assets.add(asset5);
        
        Asset asset67 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Carpet Extractor');
        assets.add(asset67);
        
        Asset asset68 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Carpet Extractor');
        assets.add(asset68);
        
        Asset asset69 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Carpet Extractor');
        assets.add(asset69);
        
         Asset asset70 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Carpet Extractor');
        assets.add(asset70);
        
        Asset asset71 = new Asset(Name = 'Test63',  Description ='Test63',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Forklift');
        assets.add(asset71);
        
        insert assets;
	    
	    assets = [select id, name , Description, AccountId, UNITY_Asset_Type__c from asset];
	    
	   
	     system.assert(assets.size() == 16);
	    
	    //create work plan and work plan items
	    List<FSO__WorkPlan__c> workPlanList = new List<FSO__WorkPlan__c>();
	    
	    FSO__WorkPlan__c wp1 = new FSO__WorkPlan__c(Name ='wp1', UNITY_Asset_Type__c ='Dock', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp1);
	    
	    FSO__WorkPlan__c wp2 = new FSO__WorkPlan__c(Name ='wp2', UNITY_Asset_Type__c ='Forklift', UNITY_Group_Assets__c = false);
	    workPlanList.add(wp2);  
	    
	    FSO__WorkPlan__c wp11 = new FSO__WorkPlan__c(Name ='wp11', UNITY_Asset_Type__c ='Dock Equipment', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp11);
	    
	    FSO__WorkPlan__c wp12 = new FSO__WorkPlan__c(Name ='wp12', UNITY_Asset_Type__c ='Dockleveler', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp12);
	    
	    FSO__WorkPlan__c wp13 = new FSO__WorkPlan__c(Name ='wp13', UNITY_Asset_Type__c ='EOD', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp13);
	    
	    FSO__WorkPlan__c wp14 = new FSO__WorkPlan__c(Name ='wp14', UNITY_Asset_Type__c ='Walkie Stacker', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp14);
	    
	    FSO__WorkPlan__c wp15 = new FSO__WorkPlan__c(Name ='wp15', UNITY_Asset_Type__c ='Carpet Extractor', UNITY_Group_Assets__c = true);
	    workPlanList.add(wp15);   	    
	    
	    insert workPlanList;
	    
	    wp1 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp1.ID];
	     wp2 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp2.ID];
	    wp11 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp11.ID];
	    wp12 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp12.ID];
	    wp13 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp13.ID];
	    wp14 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp14.ID];
	    wp15 = [select id, Name, UNITY_Asset_Type__c, UNITY_Group_Assets__c from FSO__WorkPlan__c  where id =: wp15.ID];
	   
	    
	    system.assert(workPlanList.size() == 7);
	    
	    
	    List <FSO__WorkPlanItem__c> wpil = new List<FSO__WorkPlanItem__c>();
	    FSO__WorkPlanItem__c  wpi1 = new FSO__WorkPlanItem__c (Name = 'wpi1', FSO__Description__c ='wpi1', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp1.ID);
	    wpil.add(wpi1);
	    
	    FSO__WorkPlanItem__c  wpi11 = new FSO__WorkPlanItem__c (Name = 'wp11', FSO__Description__c ='wp11', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp11.ID);
	    wpil.add(wpi11);
	    
	    FSO__WorkPlanItem__c  wpi12 = new FSO__WorkPlanItem__c (Name = 'wp12', FSO__Description__c ='wp12', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp12.ID);
	    wpil.add(wpi12);
	    
	    FSO__WorkPlanItem__c  wpi13 = new FSO__WorkPlanItem__c (Name = 'wp13', FSO__Description__c ='wp13', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp13.ID);
	    wpil.add(wpi13);
	    
	    FSO__WorkPlanItem__c  wpi14 = new FSO__WorkPlanItem__c (Name = 'wp14', FSO__Description__c ='wp14', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp14.ID);
	    wpil.add(wpi14);
	    
	    FSO__WorkPlanItem__c  wpi15 = new FSO__WorkPlanItem__c (Name = 'wp15', FSO__Description__c ='wp15', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp15.ID);
	    wpil.add(wpi15);
	    
	    FSO__WorkPlanItem__c  wpi2 = new FSO__WorkPlanItem__c (Name = 'wpi2', FSO__Description__c ='wpi2', UNITY_Render_Type__c='Pass/Fail', FSO__WorkPlan__c = wp2.ID );
	    wpil.add(wpi2);
	    
	    insert wpil;
	    
	    //connect assets and work plan 
	    workPlanList = [select id,Name, UNITY_Asset_Type__c from FSO__WorkPlan__c ];
	    
	    
	    //create WOLI's
        List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>();
        
        system.assert(wo != null);
        
        system.debug('@@@@  wo  @@@@ ' + wo) ;
         
        for (Asset a :assets){
           WorkOrderLineItem woli = new WorkOrderLineItem ();
	       if (a.UNITY_Asset_Type__c == 'Dock' ){
	            woli.WorkOrderId = wo.ID;
	            woli.AssetId = a.ID;
	            woli.UNITY_Work_Plan__c = wp1.ID;
	            woli.UNITY_Render_Type__c=  wpi1.UNITY_Render_Type__c;
	            woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	         }
	       else  if (a.UNITY_Asset_Type__c == 'Dock Equipment' ){
	            woli.WorkOrderId = wo.ID;
	            woli.AssetId = a.ID;
	            woli.UNITY_Work_Plan__c = wp11.ID;
	            woli.UNITY_Render_Type__c=  wpi1.UNITY_Render_Type__c;
	            woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	         }
	        else  if (a.UNITY_Asset_Type__c == 'Walkie Stacker' ){
	            woli.WorkOrderId = wo.ID;
	            woli.AssetId = a.ID;
	            woli.UNITY_Work_Plan__c = wp14.ID;
	            woli.UNITY_Render_Type__c=  wpi1.UNITY_Render_Type__c;
	            woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	         }
	         else  if (a.UNITY_Asset_Type__c == 'Dockleveler' ){
	            woli.WorkOrderId = wo.ID;
	            woli.AssetId = a.ID;
	            woli.UNITY_Work_Plan__c = wp12.ID;
	            woli.UNITY_Render_Type__c=  wpi1.UNITY_Render_Type__c;
	            woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	         }
	         else  if (a.UNITY_Asset_Type__c == 'Carpet Extractor' ){
	            woli.WorkOrderId = wo.ID;
	            woli.AssetId = a.ID;
	            woli.UNITY_Work_Plan__c = wp15.ID;
	            woli.UNITY_Render_Type__c=  wpi1.UNITY_Render_Type__c;
	            woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	         }
	       else if (a.UNITY_Asset_Type__c == 'Forklift' ){
	           woli.WorkOrderId = wo.ID;
	           woli.AssetId = a.ID;
	           woli.UNITY_Work_Plan__c = wp2.ID;
	           //woli.UNITY_Work_Plan__r.Name = wp2.Name;
	           woli.UNITY_Render_Type__c=   wpi2.UNITY_Render_Type__c;
	           woli.UNITY_PM_WOLI__c = true;
	            woli.FSO__IsRequired__c = true;
	            woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
	       }
	    
	       system.debug('@@@@ neli add woli  @@@@ ' + woli) ;
	       wolis.add(woli);
	    }
	     
	    system.assert(wolis.size() == 16);
	    
	    insert wolis;
        
        
	    PageReference pr = Page.UNITYPM_AssetsWorkPlanPDF;
    	pr.getParameters().put('id',  String.valueOf(wo.Id));
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        UNITYPM_AssetsWorkPlanPDFCntrlExtension controller = new UNITYPM_AssetsWorkPlanPDFCntrlExtension(sc);
        
        List<UNITYPM_AssetsWorkPlanPDFCntrlExtension.assetsRowsWPLIsWrapper> pageWrapper= controller.pageWrapper;
        
         system.assert(pageWrapper.size() > 0);
        
        system.debug('>>> neli pageWrapper.size() >>>> ' + pageWrapper.size());
        
        system.assert(pageWrapper.size() == 6);
        
         Test.stopTest();
		
    }

}