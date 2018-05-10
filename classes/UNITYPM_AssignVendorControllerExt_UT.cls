@isTest
public class UNITYPM_AssignVendorControllerExt_UT {

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
        wo.UNITY_Assigned_Vendor__c = vend.Id;
        insert wo; 
        
	    PageReference pr = Page.UNITYPM_AssignVendor;
    	pr.getParameters().put('id',  String.valueOf(wo.Id));
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wo);
        UNITYPM_AssignVendorControllerExtension controller = new UNITYPM_AssignVendorControllerExtension(sc);
        
        List<SelectOption> vendors = controller.getVendorAccounts();
        system.assert(vendors.size() > 0);
        
        List<SelectOption> sel = controller.getVendorAccounts();
        system.assert(sel.size() > 0);
        
        controller.assignVendor();
		
        wo.Status = 'In Progress';
        update wo;
        controller.assignVendor();
        
        boolean check = controller.hasError;
        
    }
    
    
}