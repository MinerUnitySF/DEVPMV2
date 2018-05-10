@isTest(seeAllData=true)
public class SVMX_VF_Invoice_Preview_Extension_Test {


	private static testmethod void testController(){
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
        wod.SVMXC__Line_Status__c = 'Completed';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Warranty';
        wod.SVMXC__Actual_Quantity2__c = 1.75;
        wod.SVMXC__Actual_Price2__c = 5.00;
        wod.Vendor_Cost_Per_Unit__c = 62;
        wod.SVMXC__Is_Billable__c = true;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Completed';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Warranty';
        wod1.SVMXC__Actual_Quantity2__c = 1.75;
        wod1.SVMXC__Actual_Price2__c = 2.00;
        wod1.Vendor_Cost_Per_Unit__c = 62;
        wod1.SVMXC__Is_Billable__c = true;
        insert wod1;
        
        PageReference pr = Page.SVMX_VF_Invoice_Preview;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        SVMX_VF_Invoice_Preview_Extension controller = new SVMX_VF_Invoice_Preview_Extension(sc);
        
        //System.assert(controller.revenue  == 12.25); 
	}
    
    private static testmethod void testController2(){
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
        wo.Work_Order_Type__c = 'Time and Materials';
        insert wo;
        
        SVMXC__Service_Order_Line__c wod = new SVMXC__Service_Order_Line__c();
        wod.SVMXC__Line_Type__c = 'Travel';
        wod.SVMXC__Line_Status__c = 'Completed';
        wod.SVMXC__Service_Order__c = wo.Id;
        wod.SVMXC__Activity_Type__c = 'Standard Labor';
        wod.SVMXC__Actual_Quantity2__c = 1.0;
        wod.SVMXC__Actual_Price2__c = 5.00;
        wod.Vendor_Cost_Per_Unit__c = 4.00;
        wod.SVMXC__Is_Billable__c = true;
        wod.Invoice_Qty__c = 1;
        wod.Invoice_Unit_Price__c = 5;
        insert wod;
        
        SVMXC__Service_Order_Line__c wod1 = new SVMXC__Service_Order_Line__c();
        wod1.SVMXC__Line_Type__c = 'Labor';
        wod1.SVMXC__Line_Status__c = 'Completed';
        wod1.SVMXC__Service_Order__c = wo.Id;
        wod1.SVMXC__Activity_Type__c = 'Standard Labor';
        wod1.SVMXC__Actual_Quantity2__c = 4.00;
        wod1.SVMXC__Actual_Price2__c = 20.00;
        wod1.Vendor_Cost_Per_Unit__c = 62;
        wod1.SVMXC__Is_Billable__c = true;
        wod1.Invoice_Qty__c = 4.00;
        wod1.Invoice_Unit_Price__c = 20.00;
        insert wod1;
        
        PageReference pr = Page.SVMX_VF_Invoice_Preview;
        pr.getParameters().put('id', String.valueOf(wo.Id));
        
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        SVMX_VF_Invoice_Preview_Extension controller = new SVMX_VF_Invoice_Preview_Extension(sc);
        
        //System.assert(controller.revenue  == 12.25);
        System.assert(controller.invRevenue == 85.00);
    }
}