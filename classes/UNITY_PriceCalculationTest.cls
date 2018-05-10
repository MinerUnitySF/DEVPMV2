@isTest
public with sharing class UNITY_PriceCalculationTest {
    //Setup Product and Pricebook Info
    public static Id PRICEBOOKENTRYID_T;
    public static Id PRICEBOOKENTRYID_L;
    public static Id PRICEBOOKENTRYID_P;
    public static Id PRODUCTID;
    public static Id PRODUCTID_L;
    public static Id PRODUCTID_T;
    static{
        //Create Product & pricebook
        Map<String,Map<Id,Id>> prodMapP = TestDataProvider.getProductAndPriceBookEntry(1,new List<String>{'Part','Labor','Travel','Freight'});
        for(String s :prodMapP.keySet()){
            Map<Id,Id> temp = prodMapP.get(s);
            if(s == 'Part'){
                for(Id key :temp.keySet()){
                    PRODUCTID = key;
                    PRICEBOOKENTRYID_P = temp.get(key);
                }
                    
            }else if (s == 'Labor'){
                for(Id key :temp.keySet()){
                    PRODUCTID_L = key;
                    PRICEBOOKENTRYID_L = temp.get(key);
                }
            }else if (s == 'Travel'){
                for(Id key :temp.keySet()){
                    PRODUCTID_T = key;
                    PRICEBOOKENTRYID_T = temp.get(key);
                }
            }
        }
    }
    @testSetup 
    static void init() {
        TestDataProvider.unityTestSetup();
    }

    //Test 1 - POLI pricing test (labor, travel, part) standard service contract Asset Light
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
        String tradeId = [SELECT Id FROM FSO__Skill__c WHERE Name = 'Glass, Board up, Mirrors & Displays' LIMIT 1].Id;
        //Get the service contracts and create lines of each record type
        UNITY_Service_Contract__c custSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        UNITY_Service_Contract__c vendSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :vend.Id LIMIT 1];
        List<UNITY_Service_Contract_Line_Item__c> sclis = new List<UNITY_Service_Contract_Line_Item__c>();
        UNITY_Service_Contract_Line_Item__c custLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 75,
            UNITY_Trip_Charge__c = 50,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(custLine1);
        UNITY_Service_Contract_Line_Item__c custLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 50,
            UNITY_Cost_Plus__c = 10
        ); sclis.add(custLine2);
        UNITY_Service_Contract_Line_Item__c custLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_NTE_RECORDTYPE,
            UNITY_Trade__c =  tradeId,
            Unity_NTE__c = 500
        ); sclis.add(custLine3);
        UNITY_Service_Contract_Line_Item__c custLine4 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine4);
        UNITY_Service_Contract_Line_Item__c vendLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 50,
            UNITY_Trip_Charge__c = 35,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(vendLine1);
        UNITY_Service_Contract_Line_Item__c vendLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine2);
        insert sclis;
        //Insert the Account Pricing Matrix
        UNITY_Account_Pricing_Matrix__c apm = new UNITY_Account_Pricing_Matrix__c();
        apm.UNITY_Broad__c = 'Glass';
        apm.UNITY_Business_Unit_Account__c = bu.Id;
        apm.UNITY_Customer_Size__c = 'Huge';
        apm.UNITY_Cost_Plus__c = 20;
        insert apm;
        UNITY_BU_Markup_Junction__c bum = new UNITY_BU_Markup_Junction__c();
        bum.UNITY_BU_Account__c = bu.Id;
        bum.UNITY_Product__c = PRODUCTID;
        bum.UNITY_Markup__c = 15;
        insert bum;
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        //Create a WO
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = custSC.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.UNITY_Trade__c = tradeId;
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;

        wo.OwnerId = UserInfo.getUserId();
        update wo;

        //Create an Order
        Order o = new Order();
        o.RecordTypeId = urRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.UNITY_Vendor_Contract__c = vendSC.Id;
        o.Type = 'Usage Request PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();

        //Start the test
        test.startTest();

        insert o;//insert the order

        //create order lines
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem line1 = new orderItem();
        line1.OrderId = o.Id;
        line1.PricebookEntryId = PRICEBOOKENTRYID_L;
        line1.Quantity = 2;
        line1.UnitPrice = 10;
        line1.UNITY_Activity_Type__c = 'Vendor Services';
        line1.UNITY_Type__c = 'Vendor Standard Labor';
        line1.UNITY_Vendor_OT_Multiplier__c = true;
        OrderItem line2 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_P;
        line2.Quantity = 2;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line2.UNITY_Type__c = 'Vendor Services';
        OrderItem line3 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_T;
        line2.Quantity = 1;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Vendor Services';
        line2.UNITY_Type__c = 'Vendor Standard Travel';
        OrderItem line4 = new orderItem();
        line4.OrderId = o.Id;
        line4.PricebookEntryId = PRICEBOOKENTRYID_L;
        line4.Quantity = 2;
        line4.UnitPrice = 10;
        line4.UNITY_Activity_Type__c = 'Vendor Services';
        line4.UNITY_Type__c = 'Vendor Standard Labor';
        line4.UNITY_Number_of_Techs__c = '2 Technicians';
        line4.UNITY_Customer_OT_Multiplier__c = true;
        OrderItem line5 = new orderItem();
        line5.OrderId = o.Id;
        line5.PricebookEntryId = PRICEBOOKENTRYID_L;
        line5.Quantity = 2;
        line5.UnitPrice = 10;
        line5.UNITY_Activity_Type__c = 'Vendor Services';
        line5.UNITY_Type__c = 'Vendor Standard Labor';
        line5.UNITY_Number_of_Techs__c = 'Multi-Tech';
        line5.UNITY_Vendor_Holiday_Multiplier__c = true;
        OrderItem line6 = new orderItem();
        line6.OrderId = o.Id;
        line6.PricebookEntryId = PRICEBOOKENTRYID_L;
        line6.Quantity = 2;
        line6.UnitPrice = 10;
        line6.UNITY_Activity_Type__c = 'Vendor Services';
        line6.UNITY_Type__c = 'Vendor Standard Labor';
        line6.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line6.UNITY_Customer_Holiday_Multiplier__c = true;
        
        oLines.add(line1);oLines.add(line2);
        //oLines.add(line3);
        oLines.add(line4);oLines.add(line5);oLines.add(line6);

        insert oLines;
        update oLines;

        //Stop the test
        test.stopTest();

    }

    //Test 2 - QLI pricing test (labor, travel, part) standard service contract Asset Light
    public static TestMethod void test2(){
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
        String tradeId = [SELECT Id FROM FSO__Skill__c WHERE Name = 'Glass, Board up, Mirrors & Displays' LIMIT 1].Id;
        //Get the service contracts and create lines of each record type
        UNITY_Service_Contract__c custSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        UNITY_Service_Contract__c vendSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :vend.Id LIMIT 1];
        List<UNITY_Service_Contract_Line_Item__c> sclis = new List<UNITY_Service_Contract_Line_Item__c>();
        UNITY_Service_Contract_Line_Item__c custLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 75,
            UNITY_Trip_Charge__c = 50,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(custLine1);
        UNITY_Service_Contract_Line_Item__c custLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 50,
            UNITY_Cost_Plus__c = 10
        ); sclis.add(custLine2);
        UNITY_Service_Contract_Line_Item__c custLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_NTE_RECORDTYPE,
            UNITY_Trade__c =  tradeId,
            Unity_NTE__c = 500
        ); sclis.add(custLine3);
        UNITY_Service_Contract_Line_Item__c custLine4 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine4);
        UNITY_Service_Contract_Line_Item__c vendLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 50,
            UNITY_Trip_Charge__c = 35,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(vendLine1);
        UNITY_Service_Contract_Line_Item__c vendLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine2);
        UNITY_Service_Contract_Line_Item__c vendLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine3);
        insert sclis;
        //Insert the Account Pricing Matrix
        UNITY_Account_Pricing_Matrix__c apm = new UNITY_Account_Pricing_Matrix__c();
        apm.UNITY_Broad__c = 'Glass';
        apm.UNITY_Business_Unit_Account__c = bu.Id;
        apm.UNITY_Customer_Size__c = 'Huge';
        apm.UNITY_Cost_Plus__c = 20;
        insert apm;
        UNITY_BU_Markup_Junction__c bum = new UNITY_BU_Markup_Junction__c();
        bum.UNITY_BU_Account__c = bu.Id;
        bum.UNITY_Product__c = PRODUCTID;
        bum.UNITY_Markup__c = 15;
        insert bum;
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        //Create a WO
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Vendor_Contract__c = vendSC.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = custSC.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.UNITY_Trade__c = tradeId;
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;

        wo.OwnerId = UserInfo.getUserId();
        update wo;

        FSO__Location__c loc = new FSO__Location__c();
        loc.Name = 'Miner Nashville Warehouse';
        loc.FSO__Geolocation__Latitude__s = 1.0;
        loc.FSO__Geolocation__Longitude__s = 1.0;
        insert(loc);

        FSO__LocationStock__c locStock = new  FSO__LocationStock__c();
        locStock.FSO__Location__c = loc.Id;
        locStock.FSO__Product__c = PRODUCTID;
        locStock.UNITY_Min__c = 500.0;
        locStock.FSO__Quantity__c = 500;
        insert(locStock); 

        FSO__LocationStock__c locStock2 = new  FSO__LocationStock__c();
        locStock2.FSO__Location__c = loc.Id;
        locStock2.FSO__Product__c = PRODUCTID_L;
        locStock2.UNITY_Min__c = 500.0;
        locStock2.FSO__Quantity__c = 500;
        insert(locStock2); 

        FSO__LocationStock__c locStock3 = new  FSO__LocationStock__c();
        locStock3.FSO__Location__c = loc.Id;
        locStock3.FSO__Product__c = PRODUCTID_T;
        locStock3.UNITY_Min__c = 500.0;
        locStock3.FSO__Quantity__c = 500;
        insert(locStock3); 
        //Start the test
        test.startTest();
        //Create an Order
        UNITY_Proposal__c p = UNITY_TestDataFactory.createQuote(1,c.Id,wo.Id,cust.Id,UserInfo.getUserId())[0];

        //create order lines
        List<UNITY_Proposal_Line_Item__c> pLines = new List<UNITY_Proposal_Line_Item__c>();
        UNITY_Proposal_Line_Item__c line1 = new UNITY_Proposal_Line_Item__c();
        line1.UNITY_Proposal__c = p.Id;
        line1.UNITY_Product__c = PRODUCTID_L;
        line1.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line1.UNITY_Activity_Type__c = 'Vendor Services';
        line1.UNITY_Type__c = 'Vendor Standard Labor';
        line1.UNITY_Vendor_OT_Multiplier__c = true;
        UNITY_Proposal_Line_Item__c line2 = new UNITY_Proposal_Line_Item__c();
        line2.UNITY_Proposal__c = p.Id;
        line2.UNITY_Product__c = PRODUCTID;
        line2.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line2.UNITY_Type__c = 'Vendor Services';
        UNITY_Proposal_Line_Item__c line3 = new UNITY_Proposal_Line_Item__c();
        line2.UNITY_Proposal__c = p.Id;
        line2.UNITY_Product__c = PRODUCTID_T;
        line2.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Vendor Services';
        line2.UNITY_Type__c = 'Vendor Standard Travel';
        UNITY_Proposal_Line_Item__c line4 = new UNITY_Proposal_Line_Item__c();
        line4.UNITY_Proposal__c = p.Id;
        line4.UNITY_Product__c = PRODUCTID_L;
        line4.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line4.UNITY_Activity_Type__c = 'Vendor Services';
        line4.UNITY_Type__c = 'Vendor Standard Labor';
        line4.UNITY_Number_of_Techs__c = '2 Technicians';
        line4.UNITY_Customer_OT_Multiplier__c = true;
        UNITY_Proposal_Line_Item__c line5 = new UNITY_Proposal_Line_Item__c();
        line5.UNITY_Proposal__c = p.Id;
        line5.UNITY_Product__c = PRODUCTID_L;
        line5.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line5.UNITY_Activity_Type__c = 'Vendor Services';
        line5.UNITY_Type__c = 'Vendor Standard Labor';
        line5.UNITY_Number_of_Techs__c = 'Multi-Tech';
        line5.UNITY_Vendor_Holiday_Multiplier__c = true;
        UNITY_Proposal_Line_Item__c line6 = new UNITY_Proposal_Line_Item__c();
        line6.UNITY_Proposal__c = p.Id;
        line6.UNITY_Product__c = PRODUCTID_L;
        line6.UNITY_Quantity__c = 2;
        //line1.UnitPrice = 10;
        line6.UNITY_Activity_Type__c = 'Vendor Services';
        line6.UNITY_Type__c = 'Vendor Standard Labor';
        line6.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line6.UNITY_Customer_Holiday_Multiplier__c = true;
        UNITY_Proposal_Line_Item__c line7 = new UNITY_Proposal_Line_Item__c();
        line7.UNITY_Proposal__c = p.Id;
        line7.UNITY_Product__c = PRODUCTID;
        line7.UNITY_Quantity__c = 2;
        line7.UNITY_Activity_Type__c = 'Vendor Services';
        line7.UNITY_Type__c = 'Part';
        line7.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line7.UNITY_Customer_Holiday_Multiplier__c = true;
        UNITY_Proposal_Line_Item__c line8 = new UNITY_Proposal_Line_Item__c();
        line8.UNITY_Proposal__c = p.Id;
        line8.UNITY_Product__c = PRODUCTID;
        line8.UNITY_Quantity__c = 2;
        line8.UNITY_Activity_Type__c = 'Vendor Services';
        line8.UNITY_Type__c = 'Non Billable';
        line8.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line8.UNITY_Customer_Holiday_Multiplier__c = true;
        line8.UNITY_Part_Location__c = loc.Id;
        UNITY_Proposal_Line_Item__c line9 = new UNITY_Proposal_Line_Item__c();
        line9.UNITY_Proposal__c = p.Id;
        line9.UNITY_Product__c = PRODUCTID;
        line9.UNITY_Quantity__c = 2;
        line9.UNITY_Activity_Type__c = 'Vendor Services';
        line9.UNITY_Type__c = 'Non Billable';
        line9.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line9.UNITY_Customer_Holiday_Multiplier__c = true;
        line9.UNITY_Part_Location__c = loc.Id;
        line9.UNITY_Is_Vendor_Supply__c = true;
        line9.UNITY_Not_Billable__c = true;
        pLines.add(line1);pLines.add(line2);
        //oLines.add(line3);
        pLines.add(line4);pLines.add(line5);pLines.add(line6);pLines.add(line7);pLines.add(line8);
        pLines.add(line9);

        insert pLines;
        update pLines;

        //Stop the test
        test.stopTest();

    }

    //Test 3 - POLI pricing test (labor, travel, part) menu price service contract Asset Light
    public static TestMethod void test3(){
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
        String tradeId = [SELECT Id FROM FSO__Skill__c WHERE Name = 'Glass, Board up, Mirrors & Displays' LIMIT 1].Id;
        //Get the service contracts and create lines of each record type
        UNITY_Service_Contract__c custSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        custSC.UNITY_Contract_Sub_type__c = 'Menu Pricing';
        update custSC;
        UNITY_Service_Contract__c vendSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :vend.Id LIMIT 1];
        List<UNITY_Service_Contract_Line_Item__c> sclis = new List<UNITY_Service_Contract_Line_Item__c>();
        UNITY_Service_Contract_Line_Item__c custLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 75,
            UNITY_Trip_Charge__c = 50,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(custLine1);
        UNITY_Service_Contract_Line_Item__c custLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 50,
            UNITY_Cost_Plus__c = 10
        ); sclis.add(custLine2);
        UNITY_Service_Contract_Line_Item__c custLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_NTE_RECORDTYPE,
            UNITY_Trade__c =  tradeId,
            Unity_NTE__c = 500
        ); sclis.add(custLine3);
        UNITY_Service_Contract_Line_Item__c custLine4 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine4);
        UNITY_Service_Contract_Line_Item__c vendLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 50,
            UNITY_Trip_Charge__c = 35,
            UNITY_Trip_Charge_Type__c = 'Flat Fee',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(vendLine1);
        UNITY_Service_Contract_Line_Item__c vendLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine2);
        insert sclis;
        //Insert the Account Pricing Matrix
        UNITY_Account_Pricing_Matrix__c apm = new UNITY_Account_Pricing_Matrix__c();
        apm.UNITY_Broad__c = 'Glass';
        apm.UNITY_Business_Unit_Account__c = bu.Id;
        apm.UNITY_Customer_Size__c = 'Huge';
        apm.UNITY_Cost_Plus__c = 20;
        insert apm;
        UNITY_BU_Markup_Junction__c bum = new UNITY_BU_Markup_Junction__c();
        bum.UNITY_BU_Account__c = bu.Id;
        bum.UNITY_Product__c = PRODUCTID;
        bum.UNITY_Markup__c = 15;
        insert bum;
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        //Create a WO
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = custSC.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.UNITY_Trade__c = tradeId;
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;

        wo.OwnerId = UserInfo.getUserId();
        update wo;

        //Create an Order
        Order o = new Order();
        o.RecordTypeId = urRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.UNITY_Vendor_Contract__c = vendSC.Id;
        o.Type = 'Usage Request PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();

        //Start the test
        test.startTest();

        insert o;//insert the order

        //create order lines
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem line1 = new orderItem();
        line1.OrderId = o.Id;
        line1.PricebookEntryId = PRICEBOOKENTRYID_L;
        line1.Quantity = 2;
        line1.UnitPrice = 10;
        line1.UNITY_Activity_Type__c = 'Vendor Services';
        line1.UNITY_Type__c = 'Vendor Standard Labor';
        line1.UNITY_Vendor_OT_Multiplier__c = true;
        OrderItem line2 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_P;
        line2.Quantity = 2;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line2.UNITY_Type__c = 'Vendor Services';
        OrderItem line3 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_T;
        line2.Quantity = 1;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Vendor Services';
        line2.UNITY_Type__c = 'Vendor Standard Travel';
        OrderItem line4 = new orderItem();
        line4.OrderId = o.Id;
        line4.PricebookEntryId = PRICEBOOKENTRYID_L;
        line4.Quantity = 2;
        line4.UnitPrice = 10;
        line4.UNITY_Activity_Type__c = 'Vendor Services';
        line4.UNITY_Type__c = 'Vendor Standard Labor';
        line4.UNITY_Number_of_Techs__c = '2 Technicians';
        line4.UNITY_Customer_OT_Multiplier__c = true;
        OrderItem line5 = new orderItem();
        line5.OrderId = o.Id;
        line5.PricebookEntryId = PRICEBOOKENTRYID_L;
        line5.Quantity = 2;
        line5.UnitPrice = 10;
        line5.UNITY_Activity_Type__c = 'Vendor Services';
        line5.UNITY_Type__c = 'Vendor Standard Labor';
        line5.UNITY_Number_of_Techs__c = 'Multi-Tech';
        line5.UNITY_Vendor_Holiday_Multiplier__c = true;
        OrderItem line6 = new orderItem();
        line6.OrderId = o.Id;
        line6.PricebookEntryId = PRICEBOOKENTRYID_L;
        line6.Quantity = 2;
        line6.UnitPrice = 10;
        line6.UNITY_Activity_Type__c = 'Vendor Services';
        line6.UNITY_Type__c = 'Vendor Standard Labor';
        line6.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line6.UNITY_Customer_Holiday_Multiplier__c = true;
        OrderItem line7 = new orderItem();
        line7.OrderId = o.Id;
        line7.PricebookEntryId = PRICEBOOKENTRYID_P;
        line7.Quantity = 2;
        line7.UnitPrice = 10;
        line7.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line7.UNITY_Type__c = 'Non Billable';
        oLines.add(line1);oLines.add(line2);
        //oLines.add(line3);
        oLines.add(line4);oLines.add(line5);oLines.add(line6);oLines.add(line7);

        insert oLines;
        update oLines;

        //Stop the test
        test.stopTest();

    }

    //Test 4 - POLI pricing test (labor, travel, part) contract pricing service contract Asset Light
    public static TestMethod void test4(){
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
        String tradeId = [SELECT Id FROM FSO__Skill__c WHERE Name = 'Glass, Board up, Mirrors & Displays' LIMIT 1].Id;
        //Get the service contracts and create lines of each record type
        UNITY_Service_Contract__c custSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        custSC.UNITY_Contract_Sub_type__c = 'Contract Pricing';
        UNITY_Service_Contract__c vendSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :vend.Id LIMIT 1];
        vendSC.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
        update new List<UNITY_Service_Contract__c>{custSC,vendSC};
        List<UNITY_Service_Contract_Line_Item__c> sclis = new List<UNITY_Service_Contract_Line_Item__c>();
        UNITY_Service_Contract_Line_Item__c custLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 75,
            UNITY_Trip_Charge__c = 50,
            UNITY_Trip_Charge_Type__c = 'Hourly Rate',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(custLine1);
        UNITY_Service_Contract_Line_Item__c custLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 50,
            UNITY_Cost_Plus__c = 10,
            UNITY_Inclusion__c = true,
            UNITY_Exclude__c = false
        ); sclis.add(custLine2);
        UNITY_Service_Contract_Line_Item__c custLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_NTE_RECORDTYPE,
            UNITY_Trade__c =  tradeId,
            Unity_NTE__c = 500
        ); sclis.add(custLine3);
        UNITY_Service_Contract_Line_Item__c custLine4 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine4);
        UNITY_Service_Contract_Line_Item__c vendLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 50,
            UNITY_Trip_Charge__c = 35,
            UNITY_Trip_Charge_Type__c = 'Hourly Rate',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(vendLine1);
        UNITY_Service_Contract_Line_Item__c vendLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine2);
        insert sclis;
        //Insert the Account Pricing Matrix
        UNITY_Account_Pricing_Matrix__c apm = new UNITY_Account_Pricing_Matrix__c();
        apm.UNITY_Broad__c = 'Glass';
        apm.UNITY_Business_Unit_Account__c = bu.Id;
        apm.UNITY_Customer_Size__c = 'Huge';
        apm.UNITY_Cost_Plus__c = 20;
        insert apm;
        UNITY_BU_Markup_Junction__c bum = new UNITY_BU_Markup_Junction__c();
        bum.UNITY_BU_Account__c = bu.Id;
        bum.UNITY_Product__c = PRODUCTID;
        bum.UNITY_Markup__c = 15;
        insert bum;
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        //Create a WO
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = custSC.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.UNITY_Trade__c = tradeId;
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;

        wo.OwnerId = UserInfo.getUserId();
        update wo;

        //Create an Order
        Order o = new Order();
        o.RecordTypeId = urRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.UNITY_Vendor_Contract__c = vendSC.Id;
        o.Type = 'Usage Request PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();

        //Start the test
        test.startTest();

        insert o;//insert the order

        //create order lines
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem line1 = new orderItem();
        line1.OrderId = o.Id;
        line1.PricebookEntryId = PRICEBOOKENTRYID_L;
        line1.Quantity = 2;
        line1.UnitPrice = 10;
        line1.UNITY_Activity_Type__c = 'Vendor Services';
        line1.UNITY_Type__c = 'Vendor Standard Labor';
        line1.UNITY_Vendor_OT_Multiplier__c = true;
        OrderItem line2 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_P;
        line2.Quantity = 2;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line2.UNITY_Type__c = 'Vendor Services';
        OrderItem line3 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_T;
        line2.Quantity = 1;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Vendor Services';
        line2.UNITY_Type__c = 'Vendor Standard Travel';
        OrderItem line4 = new orderItem();
        line4.OrderId = o.Id;
        line4.PricebookEntryId = PRICEBOOKENTRYID_L;
        line4.Quantity = 2;
        line4.UnitPrice = 10;
        line4.UNITY_Activity_Type__c = 'Vendor Services';
        line4.UNITY_Type__c = 'Vendor Standard Labor';
        line4.UNITY_Number_of_Techs__c = '2 Technicians';
        line4.UNITY_Customer_OT_Multiplier__c = true;
        OrderItem line5 = new orderItem();
        line5.OrderId = o.Id;
        line5.PricebookEntryId = PRICEBOOKENTRYID_L;
        line5.Quantity = 2;
        line5.UnitPrice = 10;
        line5.UNITY_Activity_Type__c = 'Vendor Services';
        line5.UNITY_Type__c = 'Vendor Standard Labor';
        line5.UNITY_Number_of_Techs__c = 'Multi-Tech';
        line5.UNITY_Vendor_Holiday_Multiplier__c = true;
        OrderItem line6 = new orderItem();
        line6.OrderId = o.Id;
        line6.PricebookEntryId = PRICEBOOKENTRYID_L;
        line6.Quantity = 2;
        line6.UnitPrice = 10;
        line6.UNITY_Activity_Type__c = 'Vendor Services';
        line6.UNITY_Type__c = 'Vendor Standard Labor';
        line6.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line6.UNITY_Customer_Holiday_Multiplier__c = true;
        OrderItem line7 = new orderItem();
        line7.OrderId = o.Id;
        line7.PricebookEntryId = PRICEBOOKENTRYID_P;
        line7.Quantity = 2;
        line7.UnitPrice = 10;
        line7.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line7.UNITY_Type__c = 'Non Billable';
        oLines.add(line1);oLines.add(line2);
        //oLines.add(line3);
        oLines.add(line4);oLines.add(line5);oLines.add(line6);oLines.add(line7);

        insert oLines;
        update oLines;

        //Stop the test
        test.stopTest();

    }

    //Test 5 - POLI pricing test (labor, travel, part) contract pricing service contract MSP BU
    public static TestMethod void test5(){
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
        String tradeId = [SELECT Id FROM FSO__Skill__c WHERE Name = 'Glass, Board up, Mirrors & Displays' LIMIT 1].Id;
        //Get the service contracts and create lines of each record type
        UNITY_Service_Contract__c custSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :cust.Id LIMIT 1];
        UNITY_Service_Contract__c vendSC = [SELECT Id FROM UNITY_Service_Contract__c WHERE UNITY_Account__c = :vend.Id LIMIT 1];
        List<UNITY_Service_Contract_Line_Item__c> sclis = new List<UNITY_Service_Contract_Line_Item__c>();
        UNITY_Service_Contract_Line_Item__c custLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 75,
            UNITY_Trip_Charge__c = 50,
            UNITY_Trip_Charge_Type__c = 'Hourly Rate',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(custLine1);
        UNITY_Service_Contract_Line_Item__c custLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 50,
            UNITY_Cost_Plus__c = 10,
            UNITY_Inclusion__c = true,
            UNITY_Exclude__c = false
        ); sclis.add(custLine2);
        UNITY_Service_Contract_Line_Item__c custLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_NTE_RECORDTYPE,
            UNITY_Trade__c =  tradeId,
            Unity_NTE__c = 500
        ); sclis.add(custLine3);
        UNITY_Service_Contract_Line_Item__c custLine4 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine4);
        UNITY_Service_Contract_Line_Item__c custLine5 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = custSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNITY_Labor_Hours__c = 1,
            UNTIY_Material_Cost__c = 250,
            UNITY_Labor_Cost__c = 75
        ); sclis.add(custLine5);
        UNITY_Service_Contract_Line_Item__c vendLine1 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE,
            UNITY_Labor_Cost__c = 50,
            UNITY_Trip_Charge__c = 35,
            UNITY_Trip_Charge_Type__c = 'Hourly Rate',
            UNITY_Holiday_Multiplier__c = 1.25,
            UNITY_OT_Multiplier__c = 1.25,
            UNITY_Holiday_Travel_Multiplier__c = 1.25,
            UNITY_OT_Travel_Multiplier__c = 1.25,
            UNITY_Trade__c =  tradeId
        ); sclis.add(vendLine1);
        UNITY_Service_Contract_Line_Item__c vendLine2 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_PRODUCT_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine2);
        UNITY_Service_Contract_Line_Item__c vendLine3 = new UNITY_Service_Contract_Line_Item__c(
            UNITY_Service_Contract__c = vendSC.Id,
            RecordTypeId = UNITY_Constants.SCLI_MENU_PRICING_RECORDTYPE,
            UNITY_Product__c = PRODUCTID,
            UNTIY_Material_Cost__c = 25
        ); sclis.add(vendLine3);
        insert sclis;
        //Insert the Account Pricing Matrix
        UNITY_Account_Pricing_Matrix__c apm = new UNITY_Account_Pricing_Matrix__c();
        apm.UNITY_Broad__c = 'Glass';
        apm.UNITY_Business_Unit_Account__c = bu.Id;
        apm.UNITY_Customer_Size__c = 'Huge';
        apm.UNITY_Cost_Plus__c = 20;
        insert apm;
        UNITY_BU_Markup_Junction__c bum = new UNITY_BU_Markup_Junction__c();
        bum.UNITY_BU_Account__c = bu.Id;
        bum.UNITY_Product__c = PRODUCTID;
        bum.UNITY_Markup__c = 15;
        insert bum;
        //Get the case
        Case c = [SELECT Id FROM Case LIMIT 1];
        //Create a WO
        WorkOrder wo = new WorkOrder();
        wo.AccountId = cust.Id;
        wo.UNITY_Accepted_Vendor__c = vend.Id;
        wo.UNITY_Business_Unit_Account__c = bu.Id;
        wo.UNITY_Business_Unit__c = 'NSBS';
        wo.UNITY_Customer__c = cust.Id;
        wo.UNITY_Customer_Service_Contract__c = custSC.Id;
        wo.UNITY_Skill_Broad__c = 'Glass';
        wo.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo.UNITY_Trade__c = tradeId;
        wo.Priority = '24 Hour Response';
        wo.Status = 'New';
        wo.RecordTypeId = woRTId;
        wo.CaseId = c.Id;
        insert wo;

        wo.OwnerId = UserInfo.getUserId();
        update wo;

        //Create an Order
        Order o = new Order();
        o.RecordTypeId = urRTId;
        o.AccountId = cust.Id;
        o.UNITY_Vendor__c = vend.Id;
        o.UNITY_Vendor_Contract__c = vendSC.Id;
        o.Type = 'Usage Request PO';
        o.UNITY_Business_Unit__c = 'NSBS';
        o.UNITY_Business_Unit_Account__c = bu.Id;
        o.Status = 'Draft';
        o.FSO__WorkOrder__c = wo.Id;
        o.EffectiveDate = Date.today();

        FSO__Location__c loc = new FSO__Location__c();
        loc.Name = 'Miner Nashville Warehouse';
        loc.FSO__Geolocation__Latitude__s = 1.0;
        loc.FSO__Geolocation__Longitude__s = 1.0;
        insert(loc);

        FSO__LocationStock__c locStock = new  FSO__LocationStock__c();
        locStock.FSO__Location__c = loc.Id;
        locStock.FSO__Product__c = PRODUCTID;
        locStock.UNITY_Min__c = 500.0;
        locStock.FSO__Quantity__c = 500;
        insert(locStock); 

        FSO__LocationStock__c locStock2 = new  FSO__LocationStock__c();
        locStock2.FSO__Location__c = loc.Id;
        locStock2.FSO__Product__c = PRODUCTID_L;
        locStock2.UNITY_Min__c = 500.0;
        locStock2.FSO__Quantity__c = 500;
        insert(locStock2); 

        FSO__LocationStock__c locStock3 = new  FSO__LocationStock__c();
        locStock3.FSO__Location__c = loc.Id;
        locStock3.FSO__Product__c = PRODUCTID_T;
        locStock3.UNITY_Min__c = 500.0;
        locStock3.FSO__Quantity__c = 500;
        insert(locStock3); 

        //Start the test
        test.startTest();

        bu.MSPFS_Is_MSP_BU__c = true;
        bu.UNITY_Business_Unit__c = 'MSP Nashville';
        update bu;

        insert o;//insert the order

        //create order lines
        List<OrderItem> oLines = new List<Orderitem>();
        OrderItem line1 = new orderItem();
        line1.OrderId = o.Id;
        line1.PricebookEntryId = PRICEBOOKENTRYID_L;
        line1.Quantity = 2;
        line1.UnitPrice = 10;
        line1.UNITY_Activity_Type__c = 'Vendor Services';
        line1.UNITY_Type__c = 'Vendor Standard Labor';
        line1.UNITY_Vendor_OT_Multiplier__c = true;
        OrderItem line2 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_P;
        line2.Quantity = 2;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line2.UNITY_Type__c = 'Vendor Services';
        OrderItem line3 = new orderItem();
        line2.OrderId = o.Id;
        line2.PricebookEntryId = PRICEBOOKENTRYID_T;
        line2.Quantity = 1;
        line2.UnitPrice = 10;
        line2.UNITY_Activity_Type__c = 'Vendor Services';
        line2.UNITY_Type__c = 'Vendor Standard Travel';
        OrderItem line4 = new orderItem();
        line4.OrderId = o.Id;
        line4.PricebookEntryId = PRICEBOOKENTRYID_L;
        line4.Quantity = 2;
        line4.UnitPrice = 10;
        line4.UNITY_Activity_Type__c = 'Vendor Services';
        line4.UNITY_Type__c = 'Vendor Standard Labor';
        line4.UNITY_Number_of_Techs__c = '2 Technicians';
        line4.UNITY_Customer_OT_Multiplier__c = true;
        OrderItem line5 = new orderItem();
        line5.OrderId = o.Id;
        line5.PricebookEntryId = PRICEBOOKENTRYID_L;
        line5.Quantity = 2;
        line5.UnitPrice = 10;
        line5.UNITY_Activity_Type__c = 'Vendor Services';
        line5.UNITY_Type__c = 'Vendor Standard Labor';
        line5.UNITY_Number_of_Techs__c = 'Multi-Tech';
        line5.UNITY_Vendor_Holiday_Multiplier__c = true;
        OrderItem line6 = new orderItem();
        line6.OrderId = o.Id;
        line6.PricebookEntryId = PRICEBOOKENTRYID_L;
        line6.Quantity = 2;
        line6.UnitPrice = 10;
        line6.UNITY_Activity_Type__c = 'Vendor Services';
        line6.UNITY_Type__c = 'Vendor Standard Labor';
        line6.UNITY_Number_of_Techs__c = '1 Technician + Apprentice';
        line6.UNITY_Customer_Holiday_Multiplier__c = true;
        line6.UNITY_Not_Billable__c = true;
        OrderItem line7 = new orderItem();
        line7.OrderId = o.Id;
        line7.PricebookEntryId = PRICEBOOKENTRYID_P;
        line7.Quantity = 2;
        line7.UnitPrice = 10;
        line7.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line7.UNITY_Type__c = 'Non Billable';
        OrderItem line8 = new orderItem();
        line8.OrderId = o.Id;
        line8.PricebookEntryId = PRICEBOOKENTRYID_P;
        line8.Quantity = 2;
        line8.UnitPrice = 10;
        line8.UNITY_Activity_Type__c = 'Parts - Service and Remodel';
        line8.UNITY_Type__c = 'Parts';    
        line8.UNITY_Part_Location__c =  loc.Id;   
        oLines.add(line1);oLines.add(line2);
        //oLines.add(line3);
        oLines.add(line4);oLines.add(line5);oLines.add(line6);oLines.add(line7);oLines.add(line8);

        insert oLines;
        update oLines;

        //Stop the test
        test.stopTest();

    }
}