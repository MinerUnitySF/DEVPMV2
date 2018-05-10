@isTest
public class UNITY_WorkOrderLineItemTriggerHandler_UT {
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
        cust.UNITY_TimeZoneSidKey__c = 'America/Chicago';
        update cust;
        
        test.startTest();        
      
         Asset a = new Asset(
            Name = 'TestAsset#1',
            AccountId = cust.Id,
            Product2Id = PRODUCTID,
            SerialNumber = '1234567',
            UNITY_Asset_Location_On_Site__c = 'At a place in the place'
        );
        insert a;
        
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        UNITY_Service_Contract__c sc = new UNITY_Service_Contract__c();
        sc.UNITY_Account__c = cust.Id;
        sc.UNITY_Trip_Charge__c = 10;
        sc.UNITY_IS_Active__c   = true;
        sc.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
        sc.UNITY_Default_Labor_Rate__c = System.Math.round((System.Math.random()*99)+1);
        sc.UNITY_Invoicing_Increments__c = 'Next ¼ hr';
        sc.UNITY_ServiceReport_Template__c = 'MY TEMPLATE';
        
        insert sc;
        
        c.AssetId = a.Id;
        c.UNITY_Customer_Service_Contract__c = sc.Id;
        update c;
        
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
        
        
           wolis = new List<WorkOrderLineItem>();
            WorkOrderLineItem woli = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli);
            WorkOrderLineItem woli2 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli2);
           WorkOrderLineItem woli3 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli3);
           WorkOrderLineItem woli4 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli4);
           WorkOrderLineItem woli5 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli5);
           WorkOrderLineItem woli6 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli6);
           WorkOrderLineItem woli7 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
            wolis.add(woli7);
               insert wolis;
        
        wolis = [select id, AssetId, WorkOrderId, Status,Description from WorkOrderLineItem where workorderID =:wo.ID];
        system.debug('>>>> neli wolis >>>' + wolis);
        
        List<WorkOrderLineItem> wolisUpdate = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> wolisDelete = new List<WorkOrderLineItem>();
        Integer count = 0;
        
        for (WorkOrderLineItem w:wolis){
            if ( w.AssetId != null){
                w.Description = 'update asset';
                w.status ='Completed';
                
                wolisUpdate.add(w);
            }
        }
        update wolisUpdate;
       
         wolis = [select id, AssetId, WorkOrderId, Status,Description from WorkOrderLineItem where workorderID =:wo.ID];
        
         for (WorkOrderLineItem w:wolis){
            if ( w.AssetId != null && count <=2){
                wolisDelete.add(w);
                count++;
            }
         }
        delete wolisDelete;
        
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterUpdate = true;        
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterUpdate();
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterUpdate = false;        
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterUpdate();
        
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterInsert = true;
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterInsert();
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterInsert = false;
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterInsert();
        
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterDelete = true;
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterDelete();
        UNITY_WorkOrderLineItemTriggerHandler.isFirstTriggerRun_AfterDelete = false;
        UNITY_WorkOrderLineItemTriggerHandler.runTriggerOnce_AfterDelete();
       
        
        test.stoptest();
    } 
}