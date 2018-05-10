@isTest
public class UNITY_CustomerInvoice_UT {
    public static Id PRICEBOOKENTRYID_T;
    public static Id PRICEBOOKENTRYID_L;
    public static Id PRICEBOOKENTRYID_P;
    public static Id PRICEBOOKENTRYID_SC;
    public static Id PRODUCTID;
    public static Id SCHARGEPRODUCTID;
    
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
        Map<String,String> prodMapSC = TestDataProvider.getProductAndPriceBookEntry(1,'Customer Service Charge');
        for(String s :prodMapSC.keySet()){
            PRICEBOOKENTRYID_SC = (Id)prodMapT.get(s);
            SCHARGEPRODUCTID = (Id)s;
        }
    }

    
    @testSetup
    public static void init(){
        TestDataProvider.unityTestSetup();
    }
    
    public static TestMethod void testMethod1(){
        
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
        //Get the case
        Case c = [SELECT Id,UNITY_Customer_Service_Contract__c FROM Case LIMIT 1];

        UNITY_Service_Contract__c sc = [SELECT Id,UNITY_Is_Pass_Through__c FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        sc.UNITY_Is_Pass_Through__c = true;

        update sc;

        c.UNITY_Customer_Service_Contract__c = sc.Id;

        update c;

        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = sc.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        wo.Description = 'Test Test Test';
        wo.UNITY_Work_Description__c = 'Test Test Test';
        wo.UNITY_Work_Window_Begin__c = DateTime.now();
        insert wo;

        Test.startTest();

        Test.setMock(WebServiceMock.class, new AvataxCalloutMock());
        UNITY_Invoice__c invoice = new UNITY_Invoice__c(
            UNITY_Customer__c = cust.Id, 
            UNITY_Case__c = c.Id, 
            //UNITY_Service_Charge__c  = 10,
            UNITY_Customer_Service_Contract__c = sc.Id,
            UNITY_Invoice_Status__c = 'Invoice Creation'
        );
        insert invoice;

        UNITY_Invoice_Line_Item__c ili1 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 2, 
            UNITY_Total_Price__c = 10,
            UNITY_Is_Vendor_Supply__c = true,
            UNITY_Type__c = 'Labor - Service',
            UNITY_Activity_Type__c = 'Standard Labor'
        );
        insert ili1;
        UNITY_Invoice_Line_Item__c ili2 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 2, 
            UNITY_Total_Price__c = 10,
            UNITY_Is_Vendor_Supply__c = true
            //UNITY_Type__c = 'Parts',
            //UNITY_Activity_Type__c = 'Parts - Service and Remodel'
        );
        insert ili2;

        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = poRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Vendor PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Final';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        o.UNITY_Invoice__c = invoice.Id;
        o.UNITY_Invoiced__c = true;
        ords.add(o);
        insert ords;
        
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem oItem = new orderItem();
        oItem.OrderId = ords[0].Id;
        oItem.PricebookEntryId = PRICEBOOKENTRYID_L;
        oItem.Quantity = 2;
        oItem.UnitPrice = 10;
        oItem.UNITY_Activity_Type__c = 'Standard Labor';
        oItem.UNITY_Type__c = 'Labor - Service';
        OrderItem oItem2 = new orderItem();
        oItem2.OrderId = ords[0].Id;
        oItem2.PricebookEntryId = PRICEBOOKENTRYID_P;
        oItem2.Quantity = 2;
        oItem2.UnitPrice = 10;
        oItem2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        oItem2.UNITY_Type__c = 'Parts';
        oLines.add(oItem);
        oLines.add(oItem2);
        insert oLines;

        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler_Miner',1);
        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler',1);

        UNITY_MuleHttpCalloutMockImp calloutMock = new UNITY_MuleHttpCalloutMockImp(false);
        calloutMock.supposedEndPoint = UNITY_MuleSiteSettingUtils.getEndPoint(UNITY_MuleSiteSettingUtils.INVOICE);
        Test.setMock(HttpCalloutMock.class, calloutMock);

        invoice.UNITY_Invoice_Status__c = UNITY_Constants.INV_FINALIZED;

        update invoice;
        
        PageReference pr = Page.UNITY_CustomerInvoice;
    	pr.getParameters().put('id',  String.valueOf(invoice.Id));
        Test.setCurrentPage(pr);
         
        ApexPages.StandardController sc1 = new ApexPages.StandardController(invoice);
        UNITY_InvoicePDFController controller = new UNITY_InvoicePDFController(sc1);      
        
        
        
        Test.stopTest();

    }
    
    public static TestMethod void testMethod2(){
        
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
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
        //Get the case
        Case c = [SELECT Id,UNITY_Customer_Service_Contract__c FROM Case LIMIT 1];

        UNITY_Service_Contract__c sc = [SELECT Id,UNITY_Is_Pass_Through__c FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        sc.UNITY_Is_Pass_Through__c = true;

        update sc;

        c.UNITY_Customer_Service_Contract__c = sc.Id;

        update c;

        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = sc.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        wo.Description = 'Test Test Test';
        wo.UNITY_Work_Description__c = 'Test Test Test';
        wo.UNITY_Work_Window_Begin__c = DateTime.now();
        insert wo;

        Test.startTest();

        Test.setMock(WebServiceMock.class, new AvataxCalloutMock());
        UNITY_Invoice__c invoice = new UNITY_Invoice__c(
            UNITY_Customer__c = cust.Id, 
            UNITY_Case__c = c.Id, 
            //UNITY_Service_Charge__c  = 10,
            UNITY_Customer_Service_Contract__c = sc.Id,
            UNITY_Invoice_Status__c = 'Invoice Creation'
        );
        insert invoice;

        UNITY_Invoice_Line_Item__c ili1 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 2, 
            UNITY_Total_Price__c = 10,
            UNITY_Is_Vendor_Supply__c = true,
            UNITY_Type__c = 'Labor - Service',
            UNITY_Activity_Type__c = 'Standard Labor',
            UNITYPM_Is_Preventative_Maintenance__c = true
        );
        insert ili1;
        UNITY_Invoice_Line_Item__c ili2 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 2, 
            UNITY_Total_Price__c = 10,
            UNITY_Is_Vendor_Supply__c = true,
            UNITYPM_Is_Preventative_Maintenance__c = true
            //UNITY_Type__c = 'Parts',
            //UNITY_Activity_Type__c = 'Parts - Service and Remodel'
        );
        insert ili2;
        
          UNITY_Invoice_Line_Item__c ili3 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 5, 
            UNITY_Total_Price__c = 100,
            UNITY_Is_Vendor_Supply__c = true,
            UNITYPM_Is_Preventative_Maintenance__c = true
            //UNITY_Type__c = 'Parts',
            //UNITY_Activity_Type__c = 'Parts - Service and Remodel'
        );
        insert ili3;
        
       UNITY_Invoice_Line_Item__c ili4 = new UNITY_Invoice_Line_Item__c(
            Product__c = PRODUCTID, 
            UNITY_Invoice__c = invoice.Id, 
            UNITY_Quantity__c = 25, 
            UNITY_Total_Price__c = 55,
            UNITY_Is_Vendor_Supply__c = true,
            UNITYPM_Is_Preventative_Maintenance__c = true
            //UNITY_Type__c = 'Parts',
            //UNITY_Activity_Type__c = 'Parts - Service and Remodel'
        );
        insert ili4;

        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = poRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Vendor PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Final';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        o.UNITY_Invoice__c = invoice.Id;
        o.UNITY_Invoiced__c = true;
        ords.add(o);
        insert ords;
        
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem oItem = new orderItem();
        oItem.OrderId = ords[0].Id;
        oItem.PricebookEntryId = PRICEBOOKENTRYID_L;
        oItem.Quantity = 2;
        oItem.UnitPrice = 10;
        oItem.UNITY_Activity_Type__c = 'Standard Labor';
        oItem.UNITY_Type__c = 'Labor - Service';
        OrderItem oItem2 = new orderItem();
        oItem2.OrderId = ords[0].Id;
        oItem2.PricebookEntryId = PRICEBOOKENTRYID_P;
        oItem2.Quantity = 2;
        oItem2.UnitPrice = 10;
        oItem2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        oItem2.UNITY_Type__c = 'Parts';
        oLines.add(oItem);
        oLines.add(oItem2);
        insert oLines;

        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler_Miner',1);
        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler',1);

        UNITY_MuleHttpCalloutMockImp calloutMock = new UNITY_MuleHttpCalloutMockImp(false);
        calloutMock.supposedEndPoint = UNITY_MuleSiteSettingUtils.getEndPoint(UNITY_MuleSiteSettingUtils.INVOICE);
        Test.setMock(HttpCalloutMock.class, calloutMock);

        invoice.UNITY_Invoice_Status__c = UNITY_Constants.INV_FINALIZED;

        update invoice;
        
        PageReference pr = Page.UNITY_CustomerInvoice;
    	pr.getParameters().put('id',  String.valueOf(invoice.Id));
        Test.setCurrentPage(pr);
         
        ApexPages.StandardController sc1 = new ApexPages.StandardController(invoice);
        UNITY_InvoicePDFController controller = new UNITY_InvoicePDFController(sc1);      
        
        
        
        Test.stopTest();

    }

}