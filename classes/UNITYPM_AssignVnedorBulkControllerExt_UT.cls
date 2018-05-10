@isTest
public class UNITYPM_AssignVnedorBulkControllerExt_UT {

    private static String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
    private static String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
	private static String woRTId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
    private static Account cust;
    private static Account vend;
	private static List<WorkOrder> woList = new List<WorkOrder>();

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
        WorkOrder wo = new WorkOrder();
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
        woList.add(wo);
        
        WorkOrder wo2 = new WorkOrder();
        wo2.AccountId = cust.Id;
        wo2.UNITY_Business_Unit__c = 'MNS';
        wo2.UNITY_Customer__c = cust.Id;
        wo2.UNITY_Skill_Broad__c = 'Glass';
        wo2.UNITY_Skill_Group__c = 'Glass Installation/Repair';
        wo2.UNITY_Skill_Type__c = 'Glass, Board up, Mirrors & Displays';
        wo2.Priority = '24 Hour Response';
        wo2.Status = 'New';
        wo2.RecordTypeId = woRTId;
        wo2.CaseId = testCase.Id;
        wo2.Description = 'Test Test Test';
        wo2.UNITY_Work_Description__c = 'Test Test Test';
        wo2.UNITY_Work_Window_Begin__c = DateTime.now();
        woList.add(wo2);
        
        insert woList; 
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(woList);
        UNITYPM_AssignVendorBulkControllerExt controller = new UNITYPM_AssignVendorBulkControllerExt(sc);
        
        List<SelectOption> vendors = controller.getVendorAccounts();
        system.assert(vendors.size() > 0);
        
        sc.setSelected(woList);
        controller.assignVendor();
		boolean check = controller.hasError;
        
    }
}