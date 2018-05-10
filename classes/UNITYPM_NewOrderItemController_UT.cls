@isTest
public class UNITYPM_NewOrderItemController_UT {

  	//Setup Product and Pricebook Info
    public static Id PRICEBOOKENTRYID_T;
    public static Id PRICEBOOKENTRYID_L;
    public static Id PRICEBOOKENTRYID_P;
    public static Id PRICEBOOKENTRYID_F;
    public static Id PRODUCTID_T;
    public static Id PRODUCTID_L;
    public static Id PRODUCTID_P;
    public static Id PRODUCTID_F;
    private static String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
    private static String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
    private static String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
	private static String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
    private static String usageRecRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
	private static String purchaseOrdRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
    private static Account cust;
    private static Account vend;
    private static Account bu;
	private static WorkOrder wo;
    
    static{
        //Create Product & pricebook
        Map<String,String> prodMapP = TestDataProvider.getProductAndPriceBookEntry(1,'Part');
        for(String s :prodMapP.keySet()){
            PRICEBOOKENTRYID_P = (Id)prodMapP.get(s);
            PRODUCTID_P = (Id)s;
        }
        Map<String,String> prodMapL = TestDataProvider.getProductAndPriceBookEntry(1,'Labor');
        for(String s :prodMapL.keySet()){
            PRICEBOOKENTRYID_L = (Id)prodMapL.get(s);
            PRODUCTID_L = (Id)s;
        }
        Map<String,String> prodMapT = TestDataProvider.getProductAndPriceBookEntry(1,'Travel');
        for(String s :prodMapT.keySet()){
            PRICEBOOKENTRYID_T = (Id)prodMapT.get(s);
            PRODUCTID_T = (Id)s;
        }
         Map<String,String> prodMapF = TestDataProvider.getProductAndPriceBookEntry(1,'Freight');
        for(String s :prodMapF.keySet()){
            PRICEBOOKENTRYID_F = (Id)prodMapF.get(s);
            PRODUCTID_F = (Id)s;
        }
    }
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
            if(a.RecordTypeId == buRTId)
                bu = a;
        }
        cust.Type = 'Site/Location';
        update cust;

        //Get the case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        //Create a Work Order
        wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
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
        wo.UNITY_Primary_Technician__c = TestDataProvider.getUser('Tech', 'One', 'NMS Technician').Id; 
        wo.UNITY_Secondary_Technician__c = TestDataProvider.getUser('Tech', 'Two', 'NMS Technician').Id;
        insert wo;        
    }
    
    //Test attach Quote
    public static TestMethod void test1(){
		setupAcctAndWorkOrder();        
        //Start test execution
        Test.startTest();
        //Create a PO
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = usageRecRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Purchase Order';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        ords.add(o);
        insert ords;
		//Set the vfPage as current page
		PageReference pr = Page.UNITYPM_NewOrderItem;
        pr.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pr);
        //Create a standard Controller for the order object
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        UNITYPM_NewOrderItemController controller = new UNITYPM_NewOrderItemController(sc);
        //Get Asset types
        List<SelectOption> options = controller.getAssetTypes();
        System.assert(options.size() > 0);
        //Add a line Labor
        controller.addItem();
        //Assert that the line was created
        System.assert(controller.oLines.size() == 1);
        //Set the line as Labor
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        //Call the onproduct change method of the line
        controller.oLines[0].onProductChange();
        //Check that the line was set as is vendor supply
        System.assert(controller.oLines[0].item.UNITY_Is_Vendor_Supply__c);
        //Call onVendorSupplyChange on the line
        controller.oLines[0].onVendorSupplyChange();
        //Set the Qty to 1
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();
        //Add a line Travel
        controller.addItem();
        //Assert that the line was created
        System.assert(controller.oLines.size() == 2);
        //Set the line as Travel
        controller.oLines[1].pbe.Product2Id = PRODUCTID_T;
        //Call the onproduct change method of the line
        controller.oLines[1].onProductChange();
        //Check that the line was set as is vendor supply
        System.assert(controller.oLines[1].item.UNITY_Is_Vendor_Supply__c);
        //Call onVendorSupplyChange on the line
        controller.oLines[1].onVendorSupplyChange();
        //Set the Qty to 1
        controller.oLines[1].item.Quantity = 1;
        controller.oLines[1].onCostQtyChange();
        //Add a line Part
        controller.addItem();
        //Assert that the line was created
        System.assert(controller.oLines.size() == 3);
        //Set the line as Part by...
        //Calling the onproduct change method of controller passing the line index and product id as a param
        pr.getParameters().put('index', '2');
        pr.getParameters().put('myValue', PRODUCTID_P);
        controller.onProductChange();
        System.assert(controller.oLines[2].pbe.Product2Id == PRODUCTID_P);
        //Check that the line activity type is set to Parts - Service and Remodel
        System.assert(controller.oLines[2].item.UNITY_Activity_Type__c == 'Field Supplies');
        //Set the Qty to 2 and Cost to 100
        controller.oLines[2].item.Quantity = 1;
        controller.oLines[2].item.UNITY_Cost__c = 100;
        controller.oLines[2].onCostQtyChange();
        //Check that the total cost is set to Quantiry * Cost
        System.assert(controller.oLines[2].item.UNITY_Total_Cost__c == (1 * 100));
        //Set Part line as Is Vendor Supply
        controller.oLines[2].item.UNITY_Is_Vendor_Supply__c = true;
        //Call onVendorSupplyChange on the line
        controller.oLines[2].onVendorSupplyChange();
        //Check theat the Line Type changed to Vendor Services
        System.assert(controller.oLines[2].item.UNITY_Type__c == 'Vendor Services');
        //Set Part line as Is Vendor Supply
        controller.oLines[2].item.UNITY_Is_Vendor_Supply__c = false;
        //Call onVendorSupplyChange on the line
        controller.oLines[2].onVendorSupplyChange();
        //Check theat the Line Type changed to Parts
        System.assert(controller.oLines[2].item.UNITY_Type__c == 'Vendor Services');
        //Check pbe is created
        controller.doQuickSave();
        controller.doSave();
        Test.stopTest();
    }

    public static TestMethod void testOnVendorSupplyChange(){
        setupAcctAndWorkOrder();    
        //Start test execution
        Test.startTest();
        //Create a PO
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = usageRecRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Purchase Order';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        ords.add(o);
        insert ords;
		//Set the vfPage as current page
		PageReference pr = Page.UNITYPM_NewOrderItem;
        pr.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pr);
        //Create a standard Controller for the order object
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        UNITYPM_NewOrderItemController controller = new UNITYPM_NewOrderItemController(sc);
        
        //Test scenario: Labor line, isMSPBU = false, Vendor supplied
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        System.assert(controller.oLines[0].item.UNITY_Is_Vendor_Supply__c);
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();
        System.assert(controller.oLines[0].item.UNITY_Type__c == 'Vendor Services');

        //Test scenario: Labor line, isMSPBU = true, Vendor supplied
        o.UNITY_Business_Unit__c = 'MSP Nashville';
        update o;
        controller = new UNITYPM_NewOrderItemController(sc);
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();
        System.assert(controller.oLines[0].item.UNITY_Type__c == 'Vendor Services');
        
        //Test scenario: Travel line, isMSPBU = true, Vendor supplied
        controller.addItem();
        System.assert(controller.oLines.size() == 2);
        controller.oLines[1].pbe.Product2Id = PRODUCTID_T;
        controller.oLines[1].onProductChange();
        controller.oLines[1].onVendorSupplyChange();
        controller.oLines[1].item.Quantity = 1;
        controller.oLines[1].onCostQtyChange();
        System.assert(controller.oLines[1].item.UNITY_Type__c == 'Vendor Services');
        
        //Test scenario: Travel line, isMSPBU = true, Vendor supplied
        controller.addItem();
        System.assert(controller.oLines.size() == 3);
        controller.oLines[2].pbe.Product2Id = PRODUCTID_P;
        controller.oLines[2].onProductChange();
        controller.oLines[2].onVendorSupplyChange();
        controller.oLines[2].item.Quantity = 1;
        controller.oLines[2].onCostQtyChange();
        System.assert(controller.oLines[2].item.UNITY_Type__c == 'Vendor Services');
        
        
        controller.doQuickSave();
        controller.doSave();
        Test.stopTest();
    }
    
    public static TestMethod void testDeleteSel(){
		setupAcctAndWorkOrder();        
        //Start test execution
        Test.startTest();
        //Create a PO
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = usageRecRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Purchase Order';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        ords.add(o);
        insert ords;
		//Set the vfPage as current page
		PageReference pr = Page.UNITYPM_NewOrderItem;
        pr.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pr);
        //Create a standard Controller for the order object
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        UNITYPM_NewOrderItemController controller = new UNITYPM_NewOrderItemController(sc);
        //Add a new order line item
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();        
        controller.doQuickSave();
        controller.doSave();

        //Test delete
		controller.oLines[0].sel = true;      
        controller.deleteSel();
		System.assert(controller.oLines.size() == 0);
        
        //Add a new order line item
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();        
        controller.doQuickSave();
        controller.doSave();
        
		//Test new line
		controller.oLines[0].sel = false;
        controller.deleteSel();
		System.assert(controller.oLines[0].index == 0);
                        
        Test.stopTest();
    }
    
    public static TestMethod void testOnPartSourceChange(){
		setupAcctAndWorkOrder();        
        //Start test execution
        Test.startTest();
        //Create a PO
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = usageRecRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Purchase Order';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        ords.add(o);
        insert ords;
		//Set the vfPage as current page
		PageReference pr = Page.UNITYPM_NewOrderItem;
        pr.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pr);
        //Create a standard Controller for the order object
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        UNITYPM_NewOrderItemController controller = new UNITYPM_NewOrderItemController(sc);
        
        //Add a new order line item
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();

        //Assign Part Source
        controller.oLines[0].item.UNITY_Part_Source__c  = bu.Id;

      
        //Test technician and burden rate 
        controller.addItem();
        System.assert(controller.oLines.size() == 2);
        controller.oLines[1].pbe.Product2Id = PRODUCTID_L;
        
        CKSW_BASE__Location__c baseLoc = new CKSW_BASE__Location__c();
        baseLoc.Name = 'Nashville';
        baseLoc.MSPFS_Business_Unit_Account__c = bu.Id;
        insert baseLoc;
            
        CKSW_BASE__Resource__c resource1 = new CKSW_BASE__Resource__c();
        resource1.Name = 'Technician One';
        resource1.MSPFS_Burden_Rate__c = 40.00;
        resource1.CKSW_BASE__Location__c = baseLoc.Id;
        insert resource1;
        
        CKSW_BASE__Resource__c resource2 = new CKSW_BASE__Resource__c();
        resource2.Name = 'Technician Two';
        resource2.MSPFS_Burden_Rate__c = 50.00;
        resource2.CKSW_BASE__Location__c = baseLoc.Id;
        insert resource2;
                
     	controller.oLines[1].item.MSPFS_Technician__c = resource1.Id;
     	controller.oLines[1].item.MSPFS_Technician2__c = resource2.Id;
		controller.doQuickSave();
        controller.oLines[1].onProductChange();
		
		controller.doQuickSave();        
                
        Test.stopTest();
    }
    
    public static TestMethod void testGetStockInfo(){
		FSO__Location__c loc = new FSO__Location__c();
    	loc.Name = 'Miner Nashville Warehouse';
        loc.FSO__Geolocation__Latitude__s = 1.0;
        loc.FSO__Geolocation__Longitude__s = 1.0;
    	insert(loc);
                  
        FSO__LocationStock__c locStock = new  FSO__LocationStock__c();
        locStock.FSO__Location__c = loc.Id;
        locStock.FSO__Product__c = PRODUCTID_L;
        locStock.UNITY_Min__c = 5.0;
		insert(locStock);        
        
        String[] arg = new String[]{loc.Id,PRODUCTID_L};
        Map<String,String> valsMap = UNITYPM_NewOrderItemController.getStockInfo(arg);
        
        //Test part in stock
        System.assert(valsMap.size() > 1);
        
        //Test part not in stock
        String[] arg1 = new String[]{'',PRODUCTID_L};
        Map<String,String> valsMap1 = UNITYPM_NewOrderItemController.getStockInfo(arg1);
        System.assert(valsMap1.size() == 1);
        
    }
    
    
    public static TestMethod void test(){
		setupAcctAndWorkOrder();        
        //Start test execution
        Test.startTest();
        //Create a PO
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = usageRecRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Purchase Order';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Final';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        ords.add(o);
        insert ords;
		//Set the vfPage as current page
		PageReference pr = Page.UNITYPM_NewOrderItem;
        pr.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pr);
        //Create a standard Controller for the order object
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        UNITYPM_NewOrderItemController controller = new UNITYPM_NewOrderItemController(sc);
        controller.setAssetType('');
        controller.getAssetType();
		
        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].item.UNITYPM_Is_Preventative_Maintenance__c = true;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();        
        controller.doQuickSave();
        controller.doSave();

        //Test delete
		controller.oLines[0].sel = true;      
        controller.deleteSel();        

        controller.addItem();
        System.assert(controller.oLines.size() == 1);
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 1;
        controller.oLines[0].onCostQtyChange();        
        controller.doQuickSave();
        controller.doSave();

        //Test delete
		controller.oLines[0].sel = true;      
        controller.deleteSel(); 
                
        controller.addItem();
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].onVendorSupplyChange();
        controller.oLines[0].item.Quantity = 0;
        controller.oLines[0].onCostQtyChange();        
        controller.doSave();

        controller.oLines[0].sel = true;      
        controller.deleteSel(); 
        
        controller.addItem();
        controller.oLines[0].pbe.Product2Id = PRODUCTID_L;
        controller.oLines[0].onProductChange();
        controller.oLines[0].item.UNITY_Is_Vendor_Supply__c=true;
        controller.oLines[0].item.UNITY_Activity_Type__c = 'L';
        controller.oLines[0].item.Quantity = 0;
        controller.oLines[0].item.UNITY_Cost__c = null;
        controller.oLines[0].onCostQtyChange();        
        controller.validateLines();
        
        pr.getParameters().put('index', '0');
        pr.getParameters().put('myValue', '');                
        pr.getParameters().put('strIndexes', '{"strIndexes":"0"}');                
        Test.setCurrentPage(pr);
        
        controller.onAssetChange();
        
        controller.addItem();
        controller.oLines[1].onProductChange();
        controller.oLines[1].item.UNITY_Is_Vendor_Supply__c=true;
        controller.oLines[1].item.UNITY_Activity_Type__c = 'L';
        controller.oLines[1].item.Quantity = 0;
        controller.oLines[1].item.UNITY_Cost__c = null;
        controller.oLines[1].onQtyChange();   
        
        Test.stopTest();
    }
    
}