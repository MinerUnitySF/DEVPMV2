@isTest
public class UNITYPM_AddRemoveAssetsCntrlExt_UT {
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
    
    public static TestMethod void test1(){
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
        
        wo= [SELECT ID,Account.ID, WorkOrderNumber, UNITY_Vendor_Status__c, UNITY_Assigned_Vendor__c
                               FROM WorkOrder
                                    WHERE id =: wo.ID];
        
        List<Asset> assets = new List <Asset>();
	    
	    Asset asset1 = new Asset(Name = 'Test1', Description ='Test1 asset1', AccountId = cust.Id, UNITY_Asset_Type__c= 'Dock');
        assets.add(asset1);
        Asset asset2 = new Asset(Name = 'Test2',  Description ='Test2 asset2',  AccountId = cust.Id, UNITY_Asset_Type__c ='Dock');
        assets.add(asset2);
        Asset asset3 = new Asset(Name = 'Test3',  Description ='Test3 asset3',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Scrubber');
        assets.add(asset3);        
        Asset asset4 = new Asset(Name = 'Test asset4',  Description ='Test asset4',  AccountId = cust.Id, UNITY_Asset_Type__c = 'Scrubber');
        assets.add(asset4);
        
         insert assets;
         assets = [select id, name , Description, AccountId, UNITY_Asset_Type__c from asset];      
       
        
         List<FSO__WorkPlan__c> workPlanList = new List<FSO__WorkPlan__c>();
         FSO__WorkPlan__c wp1 = new FSO__WorkPlan__c(Name ='wp1', UNITY_Asset_Type__c ='Dock', UNITY_Group_Assets__c = true);
	     workPlanList.add(wp1);
	    
	     FSO__WorkPlan__c wp2 = new FSO__WorkPlan__c(Name ='wp2', UNITY_Asset_Type__c ='Forklift', UNITY_Group_Assets__c = false);
	     workPlanList.add(wp2);  
          insert workPlanList;
        
         List <FSO__WorkPlanItem__c> wpil = new List<FSO__WorkPlanItem__c>();
	    FSO__WorkPlanItem__c  wpi1 = new FSO__WorkPlanItem__c (Name = 'wpi1', FSO__Description__c ='wpi1', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp1.ID);
	    wpil.add(wpi1);
	     
	    FSO__WorkPlanItem__c  wpi2 = new FSO__WorkPlanItem__c (Name = 'wp2', FSO__Description__c ='wp2', UNITY_Render_Type__c='Yes/No', FSO__WorkPlan__c = wp2.ID);
	    wpil.add(wpi2);
	      insert wpil;
        
        List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>();
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
                wolis.add(woli);
	         }              
         }
        insert wolis;
        
                
        PageReference pr = Page.UNITYPM_AddRemoveAssetsPage;
    	pr.getParameters().put('id',  String.valueOf(wo.Id));
        Test.setCurrentPage(pr);
         
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        UNITYPM_AddRemoveAssetsCntrlExt controller = new UNITYPM_AddRemoveAssetsCntrlExt(sc);
        
        List<UNITYPM_WorkPlanAssetsWrapper> wrpList = controller.getExistingwOLIs();
        system.debug('>>> nelie wrpList >>>>' + wrpList.size());
        
        List<UNITYPM_WorkPlanAssetsWrapper> wrpDisplayList = controller.getRecordsToDisplay();
        system.assert( wrpDisplayList.size() > 0);
        
        List<SelectOption> numList = controller.getNumbersList();
        system.assert( numList.size() > 0);
        
        List<SelectOption> assetsList = controller.getDefaultAssetsList();       
        system.assert( assetsList.size() > 0);
        
        controller.accountID = cust.Id;
        controller.workOrderNumber = wo.WorkOrderNumber;
        controller.selectedAssetVal = 'Dock';
        controller.selectedNumVal = '5';
        
        controller.addDefaultAssets();
        
        asset asl = [select id, name , Description, AccountId, UNITY_Asset_Type__c from asset where UNITY_Asset_Type__c ='Dock' limit 1];
        FSO__WorkPlan__c wp = [select id, UNITY_Asset_Type__c from FSO__WorkPlan__c where UNITY_Asset_Type__c ='Dock'];
        
        List<String> selectedAssets = new List<String> ();
        String s = '{aId =' + asl.ID + ',wpId =' + wp.ID + '}';
        UNITYPM_AddRemoveAssetsCntrlExt.handleAssetsSubmit(selectedAssets, wo.ID);
        
        
        test.stoptest();
    } 
    
}