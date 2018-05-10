@isTest
public class UNITYPM_OrderLineItemsController_UT {
    //Setup Product and Pricebook Info
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
    public static testMethod void test(){
        
        Id standardPriceBookId = Test.getStandardPricebookId();

        UNITY_Constants.MAX_TRIGGER_EXECUTION = 6;

        List<OrderItem> orderItems = new List<OrderItem>();

        Map<String,UNITY_General_Settings__c> generalSettings = UNITY_General_Settings__c.getAll();
        
        List<UNITY_General_Settings__c> gSettings =  new List<UNITY_General_Settings__c>();

        if(!generalSettings.KeySet().contains(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY))
            gSettings.add(new UNITY_General_Settings__c(Name = UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY, UNITY_Value__c = 'Vendor Service Fee', UNITY_Description__c='Vendor Service Fee'));
        

        if(!generalSettings.KeySet().contains(UNITY_Constants.PO_INVOICEABLE_STATUSES))
            gSettings.add(new UNITY_General_Settings__c(Name = UNITY_Constants.PO_INVOICEABLE_STATUSES, UNITY_Value__c = 'Final', UNITY_Description__c='PO INVOICEABLE STATUS'));
        
        
        if(!gSettings.isEmpty()) insert gSettings ;

        Test.startTest();
        //system.runAs(createUser()){

            Product2 product = new Product2(Name = 'Test', Unity_Is_Stockable__c = true);
            product.UNITY_Status__c = 'Inactive';
            insert product;

            //Get the accounts
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String usageRecRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        String purchaseOrdRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
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
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];

        Asset a = new Asset(
            Name = 'TestAsset#1',
            AccountId = cust.Id,
            Product2Id = PRODUCTID,
            SerialNumber = '1234567',
            UNITY_Asset_Location_On_Site__c = 'At a place in the place'
        );
        insert a;
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
            
        FSO__Location__c location = new FSO__Location__c(FSO__Geolocation__Latitude__s = 10, FSO__Geolocation__Longitude__s = 10);
        insert location; 
        
        FSO__LocationStock__c ls = new FSO__LocationStock__c(UNITY_MAC__c = 2, FSO__Location__c = location.Id, FSO__Quantity__c  = 10, FSO__Product__c = product.Id);
        insert ls;
        
        RecordType woRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'WorkOrder' AND DeveloperName = 'Service_Request'];
        WorkOrder wo = new WorkOrder(UNITY_Work_Window_Begin__c  = datetime.now(), UNITY_Agent__c = UserInfo.getUserId() ,RecordTypeId = woRecordType.Id, UNITY_Customer__c = cust.Id, UNITY_Assigned_Vendor__c = vend.Id, AccountId = cust.Id, CaseId = c.Id, Subject='Test', Status = 'New');
        
        wo.UNITY_Customer_Service_Contract__c = sc.Id;
        wo.UNITY_Work_Window_Begin__c = Date.today();
        wo.UNITY_Work_Window_End__c = Date.today().addDays(6);
        wo.UNITY_Truck_On_Site__c = location.Id;
        
        insert wo;
        
        List<WorkOrderLineItem> wolis = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
        wolis.add(woli);
        WorkOrderLineItem woli2 = new WorkOrderLineItem(AssetId = a.Id, WorkOrderId = wo.Id);
        wolis.add(woli2);
        insert wolis;
        
        RecordType poRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Order' AND DeveloperName = 'UNITY_Purchase_Order'];
        RecordType spoRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Order' AND DeveloperName = 'UNITY_Stocking_Purchase_Order'];
        Order order = new Order(FSO__WorkOrder__c = wo.Id,Type = 'Vendor PO', RecordTypeId = poRecordType.Id, AccountId = cust.Id, EffectiveDate = Date.Today(), Status = 'Draft');
        insert order;
        
        PricebookEntry pbe1 = new PricebookEntry();
        
        pbe1.Pricebook2Id = standardPriceBookId;
        pbe1.Product2Id = product.Id;
        pbe1.UnitPrice = 80;
        
        insert pbe1;
        
        OrderItem oi = new OrderItem(UNITY_Type__c = 'Non Billable',PricebookEntryId = pbe1.Id, OrderId = order.Id, Quantity = 5, UnitPrice = 10, UNITY_Part_Delivered__c = true);
        oi.UNITY_Shipment_Received__c  = true;
        oi.UNITY_Actual_Quantity__c    = 100;
        oi.UNITY_Asset__c = a.Id;
        oi.UNITY_Type__c = 'Parts';
        oi.UNITYPM_Is_Preventative_Maintenance__c = true;
        orderItems.add(oi);
        insert oi;
 
        UNITYPM_OrderLineItemsController controller = new UNITYPM_OrderLineItemsController();
        controller.orderId = order.Id;
            
        Test.stopTest();
        
    }
}