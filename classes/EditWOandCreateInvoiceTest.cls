@isTest(seeAllData=true)
public with sharing class EditWOandCreateInvoiceTest {

    private static testmethod void test1(){
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
        Account ac = TestDataProvider.getAccounts(1,'Customer Account','Customer')[0];
        insert ac;
        
        Account ac1 = TestDataProvider.getAccounts(1,'Vendor Account','Vendor')[0];
        insert ac1;
        
        SVMXC__Installed_Product__c IP1 = new SVMXC__Installed_Product__c();
        IP1.Name = 'ip1';
        IP1.SVMXC__Company__c = ac.id;
        insert IP1;
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        
        wo.SVMXC__Company__c = ac.id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Parts Orders';
        wo.SVMXC__Component__c = IP1.id;
        insert wo;
        
        Map<String,String> prodMap = TestDataProvider.getProductAndPriceBookEntry(1);
        String pId = '';
        for(String key :prodMap.keySet()){
            pId = key;
			break;
        }
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.Vendor__c = ac1.id;
        wod.SVMXC__Service_Order__c = wo.id;
        wod.SVMXC__Line_Type__c = 'Parts';
        wod.SVMXC__Activity_Type__c = 'Parts - Service and Remodel';
        wod.recordTypeId = rtid;
        wod.Sort_Order__c = 1;
        wod.SVMXC__Product__c = pId;
        wod.SVMXC__Actual_Quantity2__c = 1;
        wod.SVMXC__Actual_Price2__c = 100;
        wod.Vendor_Cost_Per_Unit__c = 100;
        wod.SVMXC__Is_Billable__c = true;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.Vendor__c = ac1.id;
        wod1.SVMXC__Service_Order__c = wo.id;
        wod1.SVMXC__Line_Type__c = 'Parts';
        wod1.SVMXC__Activity_Type__c = 'Parts - Service and Remodel';
        wod1.recordTypeId = rtid;
        wod1.SVMXC__Product__c = pId;
        wod1.SVMXC__Actual_Quantity2__c = 1;
        wod1.SVMXC__Actual_Price2__c = 100;
        wod1.Vendor_Cost_Per_Unit__c = 100;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.SVMXC__Is_Billable__c = true;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        
        controller.quickSave();
        
        controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Product__c = pId;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 100;
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 100;
        controller.workOrderLines[0].line.SVMXC__Activity_Type__c = 'Standard Labor';
        controller.workOrderLines[0].line.SVMXC__Is_Billable__c = true;
        controller.workOrderLines[0].invoice = true;
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        ac.MH_SL_CustID__c = '1234567';
        update ac;
        controller.updateAndCreateInvoice();
        test.stopTest();
        
    }
    
    /*private static testmethod void test2(){
        
        //Create Account
        Account acct = TestDataProvider.getAccounts(1,'Prospect Accounts', 'Customer')[0];
        acct.MH_SL_CustID__c = '1234567';
        insert acct;
        //Create service group
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c(
            Name = 'Test Service Group',
            SVMXC__Active__c = true,
            Super_Center__c = 'Miner-Houston',
            Segment__c = 'New Orleans'
        );
        insert sgroup;
        System.debug('===================== sgroup.id: ' + sgroup.Id);
        //Create service group member
        SVMXC__Service_Group_Members__c member = new SVMXC__Service_Group_Members__c(
            SVMXC__Service_Group__c = sgroup.Id,
            SVMXC__Salesforce_User__c = UserInfo.getUserId(),
            SVMXC__Fixed_Cost__c = 25,
            SVMXC__Active__c = true,
            SVMXC__Email__c = 'test@domain.com',
            SVMXC__Role__c = 'Technician',
            Name = 'Test Tech'
        ); 
        insert member;
        //Create location
        SVMXC__Site__c  location = TestDataProvider.getLocations(1,'Location Site','SPSC',acct.Id)[0];
        insert location;
        //create Work Order
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = acct.Id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Service-RES';
        wo.SVMXC__Site__c = location.id;
        wo.SVMXC__Problem_Description__c = 'desc';
        wo.Location__c = location.Id;
        wo.Business_Unit__c = 'Miner Corp';
        wo.SVMXC__Service_Group__c = sgroup.Id;
        wo.Work_Order_Type__c = 'Quoted';
        wo.Quoted_Total__c = 1000;
        insert wo;
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.SVMXC__Line_Type__c = 'Travel';
        wod.SVMXC__Line_Status__c = 'Open';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Standard Labor';
        wod.Quoted__c = true;
        wod.Quoted_Unit_Cost__c = 10;
        wod.Quoted_Unit_Price__c = 15;
        wod.Quoted_Quantity__c = 2;
        wod.SVMXC__Is_Billable__c = true;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Open';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.Quoted__c = true;
        wod1.Quoted_Unit_Cost__c = 10;
        wod1.Quoted_Unit_Price__c = 15;
        wod1.Quoted_Quantity__c = 2;
        wod1.SVMXC__Is_Billable__c = true;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        controller.workOrderLines[0].quotedChanged();
        
        controller.quickSave();
        
        controller.completeLines();
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.requestEditQuote();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        test.stopTest();
    }
*/
/*	private static testmethod void test3(){
        
        //Create Account
        Account acct = TestDataProvider.getAccounts(1,'Prospect Accounts', 'Customer')[0];
        acct.MH_SL_CustID__c = '1234567';
        insert acct;
        //Create service group
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c(
            Name = 'Test Service Group',
            SVMXC__Active__c = true,
            Super_Center__c = 'Miner-Houston',
            Segment__c = 'New Orleans'
        );
        insert sgroup;
        System.debug('===================== sgroup.id: ' + sgroup.Id);
        //Create service group member
        SVMXC__Service_Group_Members__c member = new SVMXC__Service_Group_Members__c(
            SVMXC__Service_Group__c = sgroup.Id,
            SVMXC__Salesforce_User__c = UserInfo.getUserId(),
            SVMXC__Fixed_Cost__c = 25,
            SVMXC__Active__c = true,
            SVMXC__Email__c = 'test@domain.com',
            SVMXC__Role__c = 'Technician',
            Name = 'Test Tech'
        ); 
        insert member;
        //Create location
        SVMXC__Site__c  location = TestDataProvider.getLocations(1,'Location Site','SPSC',acct.Id)[0];
        insert location;
        //create Work Order
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = acct.Id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Service-RES';
        wo.SVMXC__Site__c = location.id;
        wo.SVMXC__Problem_Description__c = 'desc';
        wo.Location__c = location.Id;
        wo.Business_Unit__c = 'Miner Corp';
        wo.SVMXC__Service_Group__c = sgroup.Id;
        wo.Work_Order_Type__c = 'Warranty';
        wo.Quoted_Total__c = 1000;
        insert wo;
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.SVMXC__Line_Type__c = 'Travel';
        wod.SVMXC__Line_Status__c = 'Open';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Warranty';
        wod.SVMXC__Actual_Quantity2__c = 1.75;
        wod.Vendor_Cost_Per_Unit__c = 62;
        wod.SVMXC__Is_Billable__c = false;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Open';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Warranty';
        wod1.SVMXC__Actual_Quantity2__c = 1.75;
        wod1.Vendor_Cost_Per_Unit__c = 62;
        wod1.SVMXC__Is_Billable__c = false;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        controller.workOrderLines[0].billableChanged();
        
        controller.quickSave();
        
        controller.completeLines();
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        test.stopTest();
    }
*/
/*    private static testmethod void test4(){
        
        //Create Account
        Account acct = TestDataProvider.getAccounts(1,'Prospect Accounts', 'Customer')[0];
        acct.MH_SL_CustID__c = '1234567';
        insert acct;
        //Create service group
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c(
            Name = 'Test Service Group',
            SVMXC__Active__c = true,
            Super_Center__c = 'Miner-Houston',
            Segment__c = 'New Orleans'
        );
        insert sgroup;
        System.debug('===================== sgroup.id: ' + sgroup.Id);
        //Create service group member
        SVMXC__Service_Group_Members__c member = new SVMXC__Service_Group_Members__c(
            SVMXC__Service_Group__c = sgroup.Id,
            SVMXC__Salesforce_User__c = UserInfo.getUserId(),
            SVMXC__Fixed_Cost__c = 25,
            SVMXC__Active__c = true,
            SVMXC__Email__c = 'test@domain.com',
            SVMXC__Role__c = 'Technician',
            Name = 'Test Tech'
        ); 
        insert member;
        //Create location
        SVMXC__Site__c  location = TestDataProvider.getLocations(1,'Location Site','SPSC',acct.Id)[0];
        insert location;
        //create Work Order
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = acct.Id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Service-RES';
        wo.SVMXC__Site__c = location.id;
        wo.SVMXC__Problem_Description__c = 'desc';
        wo.Location__c = location.Id;
        wo.Business_Unit__c = 'Miner Corp';
        wo.SVMXC__Service_Group__c = sgroup.Id;
        wo.Work_Order_Type__c = 'Quoted';
        wo.Quoted_Total__c = 1000;
        insert wo;
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.SVMXC__Line_Type__c = 'Travel';
        wod.SVMXC__Line_Status__c = 'Open';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Standard Labor';
        wod.Quoted__c = true;
        wod.Quoted_Unit_Cost__c = 10;
        wod.Quoted_Unit_Price__c = 15;
        wod.Quoted_Quantity__c = 2;
        wod.SVMXC__Is_Billable__c = true;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Open';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.Quoted__c = true;
        wod1.Quoted_Unit_Cost__c = 10;
        wod1.Quoted_Unit_Price__c = 15;
        wod1.Quoted_Quantity__c = 2;
        wod1.SVMXC__Is_Billable__c = true;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        controller.workOrderLines[0].quotedChanged();
        
        controller.quickSave();
        
        controller.completeLines();
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.requestUpdateQuotedTotal();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        test.stopTest();
    }
*/
/*    private static testmethod void test5() {
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
     //Create Account
        Account acct = TestDataProvider.getAccounts(1,'Prospect Accounts', 'Customer')[0];
        acct.MH_SL_CustID__c = '1234567';
        insert acct;
        //Create service group
        SVMXC__Service_Group__c sgroup = new SVMXC__Service_Group__c(
            Name = 'Test Service Group',
            SVMXC__Active__c = true,
            Super_Center__c = 'Miner-Houston',
            Segment__c = 'New Orleans'
        );
        insert sgroup;
        System.debug('===================== sgroup.id: ' + sgroup.Id);
        //Create service group member
        SVMXC__Service_Group_Members__c member = new SVMXC__Service_Group_Members__c(
            SVMXC__Service_Group__c = sgroup.Id,
            SVMXC__Salesforce_User__c = UserInfo.getUserId(),
            SVMXC__Fixed_Cost__c = 25,
            SVMXC__Active__c = true,
            SVMXC__Email__c = 'test@domain.com',
            SVMXC__Role__c = 'Technician',
            Name = 'Test Tech'
        ); 
        insert member;
        //Create location
        SVMXC__Site__c  location = TestDataProvider.getLocations(1,'Location Site','SPSC',acct.Id)[0];
        insert location; 
        //create Work Order
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = acct.Id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Service-DDM';
        wo.SVMXC__Site__c = location.id;
        wo.SVMXC__Problem_Description__c = 'desc';
        wo.Location__c = location.Id;
        wo.Business_Unit__c = 'Miner Corp';
        wo.SVMXC__Service_Group__c = sgroup.Id;
        wo.Work_Order_Type__c = 'Quoted';
        wo.Customer_P_O__c = 'TestPO';
        wo.Quoted_Total__c = 1000;
        insert wo;
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.RecordTypeId = rtid;
        wod.SVMXC__Line_Type__c = 'Labor';
        wod.SVMXC__Line_Status__c = 'Open';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Standard Labor';
        wod.Quoted__c = true;
        wod.Quoted_Unit_Cost__c = 65;
        wod.Quoted_Unit_Price__c = 100;
        wod.Quoted_Quantity__c = 2;
        wod.SVMXC__Is_Billable__c = true;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.RecordTypeId = rtid;
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Open';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.SVMXC__Actual_Quantity2__c = 1;
        wod1.SVMXC__Actual_Price2__c = 100;
        wod1.Invoice_Qty__c = 2;
        wod1.Invoice_Unit_Price__c = 100;
        wod1.SVMXC__Is_Billable__c = true;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        
        controller.quickSave();
        
        controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 100;
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 100;
        controller.workOrderLines[0].line.SVMXC__Line_Type__c = 'Labor';
        controller.workOrderLines[0].line.SVMXC__Activity_Type__c = 'Standard Labor';
        controller.workOrderLines[0].line.SVMXC__Is_Billable__c = true;
        controller.workOrderLines[0].invoice = true;
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        acct.MH_SL_CustID__c = '1234567';
        update acct;
        controller.updateAndCreateInvoice();
        test.stopTest();
        
    }
*/
    private static testmethod void test2(){
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
        Account ac = TestDataProvider.getAccounts(1,'Customer Account','Customer')[0];
        insert ac;
        
        Account ac1 = TestDataProvider.getAccounts(1,'Vendor Account','Vendor')[0];
        insert ac1;
        
        SVMXC__Installed_Product__c IP1 = new SVMXC__Installed_Product__c();
        IP1.Name = 'ip1';
        IP1.SVMXC__Company__c = ac.id;
        insert IP1;
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        
        wo.SVMXC__Company__c = ac.id;
    	wo.Work_Order_Type__c = 'Warranty';
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Service-DDM';
        wo.SVMXC__Component__c = IP1.id;
        insert wo;
        
        Map<String,String> prodMap = TestDataProvider.getProductAndPriceBookEntry(1);
        String pId = '';
        for(String key :prodMap.keySet()){
            pId = key;
			break;
        }
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.Vendor__c = ac1.id;
        wod.SVMXC__Service_Order__c = wo.id;
        wod.SVMXC__Line_Type__c = 'Labor';
        wod.SVMXC__Activity_Type__c = 'Standard Labor';
        wod.recordTypeId = rtid;
        wod.Sort_Order__c = 1;
        wod.SVMXC__Actual_Quantity2__c = 1;
        wod.SVMXC__Actual_Price2__c = 0;
        wod.Vendor_Cost_Per_Unit__c = 65;
        wod.SVMXC__Is_Billable__c = false;
        insert wod;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        
        controller.quickSave();
        
        controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Product__c = pId;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 100;
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 100;
        controller.workOrderLines[0].line.SVMXC__Activity_Type__c = 'Standard Labor';
        controller.workOrderLines[0].line.SVMXC__Is_Billable__c = true;
        controller.workOrderLines[0].invoice = true;
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        ac.MH_SL_CustID__c = '1234567';
        update ac;
        controller.updateAndCreateInvoice();
        test.stopTest();
    }
   
    private static testmethod void testInvoiceCallout(){
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
        Account ac = TestDataProvider.getAccounts(1,'Customer Account','Customer')[0];
        insert ac;
        
        Account ac1 = TestDataProvider.getAccounts(1,'Vendor Account','Vendor')[0];
        insert ac1;
        
        SVMXC__Installed_Product__c IP1 = new SVMXC__Installed_Product__c();
        IP1.Name = 'ip1';
        IP1.SVMXC__Company__c = ac.id;
        insert IP1;
        
        Map<String,String> prodMap = TestDataProvider.getProductAndPriceBookEntry(1);
        String pId = '';
        for(String key :prodMap.keySet()){
            pId = key;
			break;
        }
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = ac.id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c ='Parts Orders'; // 'Sales-EQUIP';
        wo.SVMXC__Component__c = IP1.id;
        wo.Work_Order_Type__c = 'Quoted';
        wo.Quoted_Total__c = 1000;
        wo.NTEThreshold__c = 350;       
        wo.Contract_Amount__c  = 150;
        wo.Change_Order_Amt__c  = 25;
        insert wo;
                
        SVMXC__RMA_Shipment_Order__c oRSO= new SVMXC__RMA_Shipment_Order__c();
        SVMXC__RMA_Shipment_Order__c o1;       
        oRSO.SVMXC__Service_Order__c = wo.id;
        oRSO.SVMXC__Order_Status__c = 'Open';
        insert oRSO; 
     
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
      
        //controller.workOrderLines[0].enableCheckbox();
        //controller.workOrderLines[0].changePart();
        //controller.workOrderLines[0].togglePart();
        
        //controller.quickSave();
        //controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Product__c = pId;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 10;
        controller.workOrderLines[0].line.SVMXC__Line_Status__c = 'Open';  
        controller.workOrderLines[0].line.Invoice_Unit_Price__c = 300;
        controller.workOrderLines[0].line.Invoice_Qty__c = 2;
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 50;
        //controller.workOrderLines[0].line.Sales_Tax__c= 5;
        //controller.workOrderLines[0].line.Invoice_Unit_Price__c=25;   
       
        //Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.calculateTotals();
       
        //controller.callAvatax();
        //controller.saveAndClose();
        controller.updateAndCreateInvoice();
        ac.MH_SL_CustID__c = '1234567';
        
        update ac;
       
        controller.updateAndCreateInvoice();
        test.stopTest();
        
    } 
/*private static testmethod void test3(){
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
        Account ac = TestDataProvider.getAccounts(1,'Customer Account','Customer')[0];
        insert ac;
        
        Account ac1 = TestDataProvider.getAccounts(1,'Vendor Account','Vendor')[0];
        insert ac1;
        
        SVMXC__Installed_Product__c IP1 = new SVMXC__Installed_Product__c();
        IP1.Name = 'ip1';
        IP1.SVMXC__Company__c = ac.id;
        insert IP1;
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        
        wo.SVMXC__Company__c = ac.id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Parts Orders';
        wo.SVMXC__Component__c = IP1.id;
        insert wo;
        
        Map<String,String> prodMap = TestDataProvider.getProductAndPriceBookEntry(1);
        String pId = '';
        for(String key :prodMap.keySet()){
            pId = key;
			break;
        }
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.Vendor__c = ac1.id;
        wod.SVMXC__Service_Order__c = wo.id;
        wod.SVMXC__Line_Type__c = 'Parts';
        wod.SVMXC__Activity_Type__c = 'Parts - Service and Remodel';
        wod.recordTypeId = rtid;
        wod.Sort_Order__c = 1;
        wod.SVMXC__Product__c = pId;
        wod.SVMXC__Actual_Quantity2__c = 1;
        wod.SVMXC__Actual_Price2__c = 100;
        wod.Vendor_Cost_Per_Unit__c = 100;
        wod.SVMXC__Is_Billable__c = true;
    	wod.Invoice_Qty__c = 1;
    	wod.Invoice_Unit_Price__c = 100;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Service_Order__c = wo.id;
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.recordTypeId = rtid;
        wod1.SVMXC__Actual_Quantity2__c = 1;
        wod1.SVMXC__Actual_Price2__c = 100;
        wod1.Vendor_Cost_Per_Unit__c = 100;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.SVMXC__Is_Billable__c = true;
    	wod1.Invoice_Qty__c = 1;
    	wod1.Invoice_Unit_Price__c = 100;
        insert wod1;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        
        controller.quickSave();
        
        controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Product__c = pId;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 100;
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 100;
        controller.workOrderLines[0].line.SVMXC__Activity_Type__c = 'Standard Labor';
        controller.workOrderLines[0].line.SVMXC__Is_Billable__c = true;
        controller.workOrderLines[0].invoice = true;
        
        Decimal subtotal = controller.workOrderLines[0].subTotal;
        controller.callAvatax();
        controller.saveAndClose();
        controller.updateAndCreateInvoice();
        ac.MH_SL_CustID__c = '1234567';
        update ac;
        controller.updateAndCreateInvoice();
        test.stopTest();
        
    }
*/
    
        public static testMethod void testCalculateTotals(){
        String rtid = [Select Id From RecordType  Where SobjectType = 'SVMXC__Service_Order_Line__c' and DeveloperName = 'UsageConsumption'].id;
        
        Account ac = TestDataProvider.getAccounts(1,'Customer Account','Customer')[0];
        insert ac;
        
        Account ac1 = TestDataProvider.getAccounts(1,'Vendor Account','Vendor')[0];
        insert ac1;
        
        SVMXC__Installed_Product__c IP1 = new SVMXC__Installed_Product__c();
        IP1.Name = 'ip1';
        IP1.SVMXC__Company__c = ac.id;
        insert IP1;  
        
        Map<String,String> prodMap = TestDataProvider.getProductAndPriceBookEntry(1);
        String pId = '';
        for(String key :prodMap.keySet()){
            pId = key;
			break;
        }
        
        SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
        wo.SVMXC__Company__c = ac.id;
        wo.SVMXC__Order_Status__c = 'Open';
        wo.SVMXC__Order_Type__c = 'Parts Orders';
        wo.SVMXC__Component__c = IP1.id;
        wo.Work_Order_Type__c = 'Quoted';
        wo.Quoted_Total__c = 100;
           
        insert wo;
        
        PageReference pr = Page.EditWOandCreateInvoice;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        EditWOandCreateInvoice controller = new EditWOandCreateInvoice(sc);
        
        test.startTest();
        
        controller.add10MoreLines();
        
        controller.workOrderLines[0].enableCheckbox();
        controller.workOrderLines[0].changePart();
        controller.workOrderLines[0].togglePart();
        
        controller.quickSave();
        
        controller.completeLines();
        
        controller.workOrderLines[0].line.recordTypeId = rtid;
        controller.workOrderLines[0].line.SVMXC__Product__c = pId;
        controller.workOrderLines[0].line.SVMXC__Actual_Quantity2__c = 1;
        controller.workOrderLines[0].line.SVMXC__Actual_Price2__c = 100;
        controller.workOrderLines[0].line.SVMXC__Line_Status__c = 'Open';

        controller.calculateTotals();
        System.debug('@@@controller.revenue'+ controller.revenue);
		System.assert(controller.revenue == 100);

        controller.workOrderLines[0].line.Sales_Tax__c = 25;
        controller.calculateTotals();
        System.assert(controller.orderTotal == 125);
        
        controller.workOrderLines[0].line.Vendor_Cost_Per_Unit__c = 1;
        controller.workOrderLines[0].line.Invoice_Unit_Price__c = 200;
        controller.workOrderLines[0].line.Invoice_Qty__c =3;
        controller.calculateTotals();
        System.debug('@@@controller.invRevenue'+ controller.revenue);
        System.assert(controller.invRevenue == 600);
        
        wo.Work_Order_Type__c = 'Warranty';
        controller.calculateTotals();
        System.assert(controller.orderTotal == 125);
        
        test.stopTest();
    }
    
    private static testMethod void variousTests(){
        SVMXC__Service_Order__c workOrder = new SVMXC__Service_Order__c();
        SVMXC__Service_Order_Line__c workOrderLine = new SVMXC__Service_Order_Line__c();
        
        //Make sure line is not editable when status is cancelled
        workOrder.SVMXC__Order_Status__c = 'Invoice Completed';
        workOrderLine.SVMXC__Line_Status__c = 'Canceled';
        EditWOandCreateInvoice.WorkOrderLineWrapper wrapper = new EditWOandCreateInvoice.WorkOrderLineWrapper(workOrderLine, workOrder);
		System.debug('@@@wrapper.edit:'+wrapper.edit);
        System.assert(wrapper.edit == false);

        //Test if quoted, line is from iPad
        workOrderLine.Quoted__c = true;
        wrapper.quotedChanged();
        System.assert(workOrderLine.Line_from_iPad__c == false);
        workOrderLine.Quoted__c = false;
        wrapper.quotedChanged();
        System.assert(workOrderLine.Line_from_iPad__c == true);
        
        //If line status changed to Completed, it should be invoicable
        wrapper.line.SVMXC__Line_Status__c = 'Completed';
        wrapper.enableCheckbox();
        System.assert(wrapper.canInvoice == true);
        
        //If line status changed to a non-invoicable status, make sure it's not set to invoicable and fields are initialized
        wrapper.line.SVMXC__Line_Status__c = 'Open';
        wrapper.enableCheckbox();
        System.assert(wrapper.canInvoice == false);
        
        wrapper.line.SVMXC__Line_Status__c = 'Canceled';
        wrapper.line.SVMXC__Is_Billable__c = true;
        wrapper.line.Quoted_Unit_Cost__c = 5;
        wrapper.line.Quoted_Quantity__c = 5;
        wrapper.enableCheckbox();
        System.assert(wrapper.canInvoice == false);
        System.assert(wrapper.line.SVMXC__Actual_Price2__c == 0);
        System.assert(wrapper.line.Quoted_Unit_Cost__c == 0);
        System.assert(wrapper.line.Quoted_Quantity__c == 0);
        
        wrapper.line.Quoted_Unit_Price__c = 5;
        wrapper.enableCheckbox();
        System.assert(wrapper.line.Quoted_Unit_Price__c == 0);    
        
        //If Line Type changes, fields are initialized
        workOrder.Labor_Standard_DDM__c = 9;
        wrapper.line.SVMXC__Line_Type__c = 'Parts';
        wrapper.togglePart();
        System.assert(wrapper.isPart == true);

        //Test populateInventory method
        SVMXC__Product_Stock__c inv = [SELECT SVMXC__Location__c, SVMXC__Product__c, SVMXC__Available_Qty__c 
                                       FROM SVMXC__Product_Stock__c WHERE SVMXC__Status__c = 'Available' AND SVMXC__Available_Qty__c > 0 LIMIT 1];
        System.debug('@@@inv'+inv);
        if (inv != null){
            wrapper.line.SVMXC__Product__c = inv.SVMXC__Product__c;
            wrapper.line.SVMXC__Consumed_From_Location__c = inv.SVMXC__Location__c;
            wrapper.populateInventory();
            System.assert(wrapper.inv1 == (integer)inv.SVMXC__Available_Qty__c);
        }
        
        //Test invoice total field
        //Returs 0 if invoice qty is null
        wrapper.line.Invoice_Qty__c = null;
        System.Assert(wrapper.invTotal == 0);
        
        //Returns quoted if not null
        wrapper.line.Invoice_Qty__c = 0;
        wrapper.line.Invoice_Unit_Price__c = 0;
        wrapper.line.Quoted_Quantity__c = 5;
        wrapper.line.Quoted_Unit_Price__c = 100;
        System.Assert(wrapper.invTotal == 500);
        
        //Returns invoice if quoted is null
        wrapper.line.Quoted_Quantity__c = null;
        wrapper.line.Quoted_Unit_Price__c = null;        
        wrapper.line.Invoice_Qty__c = 6;
        wrapper.line.Invoice_Unit_Price__c = 100;
        System.Assert(wrapper.invTotal == 600);
        
        //Test invoice sub-total field
        //Returs 0 if invoice qty is null
        wrapper.line.SVMXC__Actual_Quantity2__c = null;
        System.Assert(wrapper.subTotal == 0);
        
        //Returns quoted if not null
        wrapper.line.SVMXC__Actual_Quantity2__c = 0;
        wrapper.line.SVMXC__Actual_Price2__c = 0;
        wrapper.line.Quoted_Quantity__c = 5;
        wrapper.line.Quoted_Unit_Price__c = 100;
        System.Assert(wrapper.subTotal == 500);
        
        //Returns invoice if quoted is null
        wrapper.line.Quoted_Quantity__c = null;
        wrapper.line.Quoted_Unit_Price__c = null;        
        wrapper.line.SVMXC__Actual_Quantity2__c = 6;
        wrapper.line.SVMXC__Actual_Price2__c = 100;
        System.Assert(wrapper.subTotal == 600);
    }
    
}