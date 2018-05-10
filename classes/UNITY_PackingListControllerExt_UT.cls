@isTest
public class UNITY_PackingListControllerExt_UT {
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
    
    public static testMethod void testPackingListController(){
        
        //Get the accounts
        String custRTId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
        String vendRTId = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        String buRTId = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        String woRTId = UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE;
        String urRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
        String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
        String pspoRTId = UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE;
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
        
        WorkOrder woRefresh = [SELECT WorkOrderNumber FROM WorkOrder WHERE Id = :wo.Id];
        
        Order urORd = new Order();
        urORd.RecordTypeId = urRTId;
        urORd.AccountId = cust.Id;
        urORd.UNITY_Vendor__c = vend.Id;
        urORd.Type = 'Usage Request PO';
        urORd.UNITY_Business_Unit__c = 'NSBS';
        urORd.UNITY_Business_Unit_Account__c = bu.Id;
        urORd.Status = 'PO Created';
        urORd.FSO__WorkOrder__c = wo.Id;
        urORd.EffectiveDate = Date.today();
		insert urORd;

        List<Order> ords = new List<Order>();

        Order poOrd = new Order();
        poOrd.RecordTypeId = poRTId;
        poOrd.AccountId = cust.Id;
        poOrd.UNITY_Vendor__c = vend.Id;
        poOrd.Type = 'Vendor PO';
        poOrd.UNITY_Business_Unit__c = 'NSBS';
        poOrd.UNITY_Business_Unit_Account__c = bu.Id;
        poOrd.Status = 'Accepted';
        poOrd.FSO__WorkOrder__c = wo.Id;
        poOrd.UNITY_Originating_Usage_Request__c = urORd.Id;
        poOrd.EffectiveDate = Date.today();
        ords.add(poOrd); 
        
        Order pspoOrd = new Order();
        pspoOrd.RecordTypeId = pspoRTId;
        pspoOrd.AccountId = cust.Id;
        pspoOrd.UNITY_Vendor__c = vend.Id;
        pspoOrd.Type = 'Parts';
        pspoOrd.UNITY_Business_Unit__c = 'NSBS';
        pspoOrd.UNITY_Business_Unit_Account__c = bu.Id;
        pspoOrd.Status = 'Ready to Ship';
        pspoOrd.FSO__WorkOrder__c = wo.Id;
        pspoOrd.EffectiveDate = Date.today();
        pspoOrd.UNITY_Originating_Usage_Request__c = urORd.Id;
        ords.add(pspoOrd);
        
        insert ords;
        
        Order poOrdRefresh = [SELECT OrderNumber FROM Order WHERE Id = :poOrd.Id];
        
        PageReference pageRef = Page.UNITY_PackingList;
        pageRef.getParameters().put('id', string.valueOf(pspoOrd.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pspoOrd);
        UNITY_PackingListControllerExt ext = new UNITY_PackingListControllerExt(sc);
        
        
        system.debug('@@@ relatedServiceWONo' + ext.relatedServiceWONo);
		system.debug('@@@ relatedServiceWOPO' + ext.relatedServiceWOPO);
        
        system.assert(ext.relatedServiceWONo == String.valueOf(woRefresh.WorkOrderNumber));
        system.assert(ext.relatedServiceWOPO == String.valueOf(poOrdRefresh.OrderNumber));

    }
}