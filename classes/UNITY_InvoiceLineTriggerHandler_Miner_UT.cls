@isTest
public class UNITY_InvoiceLineTriggerHandler_Miner_UT {
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
    @testSetup
    public static void testSetup(){
        UNITY_MuleSiteSettingUtilsTest.setUp();
        UNITY_Mule2Salesforce_MappingUtilsTest.setUp();
        UNITY_Mulesoft_Credentials__c mCreds = new UNITY_Mulesoft_Credentials__c(
            Name = 'Test-Basic Authorization-162468',
            Authorization_Header__c = 'Basic dXNlcjE6cGFzc3dvcmQx'
        );
        //Create BU Specific Team field Map
        UNITY_BU_Team_Field_Map__c nsbsTeamMap = new UNITY_BU_Team_Field_Map__c(
            Name = 'NSBS',
            UNITY_Field_API_Name__c = 'UNITY_Customer_Team__c'
        );
        insert nsbsTeamMap;
        List<Account> accts = new List<Account>();
        Account cust = TestDataProvider.getAccounts(1,'Customer', 'Customer')[0];cust.Account_Status__c = 'Active';
        cust.Account_Status__c = 'Active';
        cust.UNITY_Customer_Team__c = 'Team 1';
        cust.UNITY_MNS_Customer_Team__c = 'Team 1';
        cust.UNITY_Tier_Level__c = 'Tier 1';
        Account vend = TestDataProvider.getAccounts(1,'Vendor','Vendor')[0];vend.UNITY_Vendor_Status__c = 'Active';
        Account bu = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];bu.UNITY_Business_Unit__c = 'NSBS';bu.UNITY_Company_Code__c = 'NSBS';bu.UNITY_Vendor_Status__c = 'Active';
        accts.add(cust);accts.add(vend);accts.add(bu);insert accts;
        UNITY_Service_Contract__c vendorContract = new UNITY_Service_Contract__c();
        vendorContract.UNITY_Account__c = vend.Id;
        vendorContract.UNITY_Trip_Charge__c = 10;
        vendorContract.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
        vendorContract.UNITY_Default_Labor_Rate__c = 75;
        vendorContract.UNITY_Invoicing_Increments__c = 'Next ¼ hr';
        vendorContract.UNITY_Business_Unit__c = 'MNS';
        vendorContract.UNITY_IS_Active__c = true;
        vendorContract.RecordTypeId = UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE;
        insert vendorContract;
        TestDataProvider.setKeyValueStore();
        TestDataProvider.setGLMatrix();
        User u = TestDataProvider.getUsers(1)[0];
        //Create Contact
        List<Contact> contacts = UNITY_TestDataFactory.createContacts(1,cust.Id);
        List<Case> cases = UNITY_TestDataFactory.createCases(1,cust.Id,cust.Id,contacts.get(0).Id,UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE);
        cases[0].UNITY_Business_Unit_Account__c = bu.Id;
        cases[0].UNITY_Business_Unit__c = 'NSBS';
        update cases;
        Product2 prod = new Product2(
            Name = 'TestProduct',
            ProductCode = 'Test-123456',
            Make1__c = 'TestMake',
            Model__c = 'TestModel',
            Broad__c = 'Door',
            Group__c = 'High Speed',
            Type__c = 'Electrical',
            Family = 'Equipment',
            SVMXC__Product_Line__c = 'Equipment',
            IsActive = true,
            Description = 'Installed Product Test Product',
            SVMXC__Product_Cost__c = 0.00,
            SVMXC__Inherit_Parent_Warranty__c = true,
            UNITY_Status__c = 'Active',
            UNITY_Product_Cost__c = 0,
            UNITY_Unit_Of_Measure__c = 'Each',
            UNITY_Product_Type__c ='Customer Service Charge'
        );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 100, 
            IsActive = true
        );
        insert standardPrice;
    }
    
    
    static testmethod void test1(){
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String oRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        
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
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
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
        wo.CaseId = testCase.Id;
        wo.Description = 'Test Test Test';
        wo.UNITY_Work_Description__c = 'Test Test Test';
        wo.UNITY_Work_Window_Begin__c = DateTime.now();
        insert wo;
        Test.startTest();

        UNITY_Invoice__c invoice = new UNITY_Invoice__c();
        invoice.UNITY_Case__c = testCase.Id;
        invoice.UNITY_Customer__c = cust.Id;
        invoice.UNITY_Customer_Email__c = cust.Account_Email__c;
        invoice.UNITY_Status__c = 'Invoice Creation';
        invoice.UNITY_Invoice_Status__c = 'Invoice Creation';        
        
        //invoice.UNITY_Customer_Service_Contract__c = testCase.UNITY_Customer_Service_Contract__c;
        insert invoice;
        
        List<Order> ords = new List<Order>();
        Order o = new Order();
        o.RecordTypeId = oRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.Type = 'Usage Request PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();
        o.UNITY_NTE__c = 200;
        o.UNITY_Invoice__c = invoice.Id;
        ords.add(o);
        insert ords;
        
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem oItem = new orderItem();
        oItem.OrderId = ords[0].Id;
        oItem.PricebookEntryId = PRICEBOOKENTRYID_T;
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
      
        List<UNITY_Invoice_Line_Item__c> invoiceLineItems = new List<UNITY_Invoice_Line_Item__c>();
        
        for(OrderItem oi :oLines){
            UNITY_Invoice_Line_Item__c ili = new UNITY_Invoice_Line_Item__c();
            ili.UNITY_Invoice__c = invoice.Id;
            ili.UNITY_Total_Price__c = 100;
            ili.UNITY_Cost__c = 50;
            ili.UNITY_Sales_Tax__c = null;
            ili.UNITY_PO_Price__c = 100; 
            ili.UNITY_Quantity__c = oi.Quantity;
            ili.UNITY_Adjusted_Quantity__c = oi.Quantity;
            ili.Product__c = PRODUCTID;
            ili.UNITY_Tax_Code__c = null;
            ili.UNITY_Is_Vendor_Supply__c = false;
            ili.UNITY_Activity_Type__c = oi.UNITY_Activity_Type__c;
            ili.UNITY_Type__c = oi.UNITY_Type__c;
            invoiceLineItems.add(ili);
        }
        insert invoiceLineItems;
        
        invoiceLineItems[0].UNITY_Quantity__c = 2;
            
        update invoiceLineItems[0];
        
        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler_Miner',1);
        UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceTriggerHandler',1);
         UNITY_Constants.executionsPerTrigger.put('UNITY_InvoiceLineTriggerHandler_Miner',1);
        
        Test.setMock(WebServiceMock.class, new AvataxCalloutMock());
        System.debug('##### Before changing status');
        UNITY_Invoice__c inv = [SELECT Id,Name,UNITY_Invoice_Status__c,UNITY_Service_Charge__c FROM UNITY_Invoice__c WHERE Id = :invoice.Id LIMIT 1];
        inv.UNITY_Invoice_Status__c = 'Disputed';
        update inv;
        Test.stopTest();  
    }
}