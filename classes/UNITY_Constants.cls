/*
*   @programer:    Samuel Astol
*   @description:  Common static variables.
*   @date:         11/17/2015
* =====================================================
* Change Log
* =====================================================
* @description: Added ContractType enum and CONTRACT_RTID_MAP to standardize passign and finding contract types to methods
* @programer:   Izay Ramos
* @date:        9/7/2016
* @version:     1.05
* =====================================================
* @description: Added IntegrationType enum standardize passign and finding object integration types
* @programer:   Izay Ramos
* @date:        9/30/2016
* @version:     1.06
* =====================================================
*/
global class UNITY_Constants {
    
    public static final Schema.Describesobjectresult SC_SObjectResult                = UNITY_Service_Contract__c.SObjectType.getDescribe();
    public static final Schema.Describesobjectresult SCLI_SObjectResult              = UNITY_Service_Contract_Line_Item__c.SObjectType.getDescribe();
    public static final Schema.Describesobjectresult Account_SObjectResult           = Account.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult WO_SObjectResult                = WorkOrder.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult TemplateConfig_SObjectResult    = UNITY_Template_Configuration__c.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult Order_SObjectResult             = Order.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult Case_SObjectResult              = Case.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult Task_SObjectResult              = Task.SObjectType.getDescribe(); 
    public static final Schema.Describesobjectresult Proposal_SObjectResult          = UNITY_Proposal__c.SObjectType.getDescribe();
    public static final Schema.Describesobjectresult Invoice_SObjectResult           = UNITY_Invoice__c.SObjectType.getDescribe();
    public static final Schema.Describesobjectresult workOrderLineItem_SObjectResult = WorkOrderLineItem.SObjectType.getDescribe();
    
    // limit country vendors
    public static final Set<String> allowVendorCountries = new Set<String>{'CA','MX','US'};
        
        // Scheduled Job Settings 
        public static final String VendorScoreCalculation_DelayInDays_WO_KEY = 'VendorScoreCalculation-DelayInDays-WO';
    public static final String VendorScoreCalculation_DelayInDays_VA_KEY = 'VendorScoreCalculation-DelayInDays-VA';
    public static final String VendorScoreCalculation_DelayInDays_DEFAULT = '5';
    public static final String VendorScoreCalculation_PeriodInDays_WO_KEY = 'VendorScoreCalculation-PeriodInDays-WO';
    public static final String VendorScoreCalculation_PeriodInDays_VA_KEY = 'VendorScoreCalculation-PeriodInDays-VA';
    public static final String VendorScoreCalculation_PeriodInDays_DEFAULT = '31';
    
    //  UNITY Service Contract
    public static final String SC_SERVICE_REQUEST = 'Service Request';
    public static final String SC_SITE_SURVEY_NAME          = 'Site Survey';
    public static final String SC_PROJECT_MANAGEMENT_NAME   = 'Project Management';
    public static final String SC_PREVENTATIVE_MAINTENANCE_NAME   = 'Preventative Maintenance';
    public static final String SC_CONTRACT_PRICING_STATUS   = 'Contract Pricing';
    
    //Enum of Contract Types
    public enum ContractType {
       SERVICE_REQUEST,
       SITE_SURVEY,
       PROJECT_MANAGEMENT,
       PREVENTATIVE_MAINTENANCE
    }
    
    //Enum of Types of Objects for Integration
    public enum IntegrationType{
        CUSTOMER,
        VENDOR,
        INVOICE,
        PURCHASE_ORDER,
        CASE1,
        CASE_COMMENT
    }
    /*
    global enum TaxType{
        INVOICE,
        QUOTE,
        PO,
        SERV_CHARGE
    }
    */
    public static final String SC_SERVICE_REQUEST_RECORDTYPE  = (SC_SObjectResult != null 
                                                                 && SC_SObjectResult.getRecordTypeInfosByName() != null 
                                                                 && SC_SObjectResult.getRecordTypeInfosByName().get(SC_SERVICE_REQUEST) != null)?
        SC_SObjectResult.getRecordTypeInfosByName().get(SC_SERVICE_REQUEST).getRecordTypeId():null;
    public static final String SC_SITE_SURVEY_RECORDTYPE      = (SC_SObjectResult != null 
                                                                 && SC_SObjectResult.getRecordTypeInfosByName() != null 
                                                                 && SC_SObjectResult.getRecordTypeInfosByName().get(SC_SITE_SURVEY_NAME) != null)?
        SC_SObjectResult.getRecordTypeInfosByName().get(SC_SITE_SURVEY_NAME).getRecordTypeId():null;
    public static final String SC_PROJECT_MANAGEMENT_RECORDTYPE   = (SC_SObjectResult != null 
                                                                     && SC_SObjectResult.getRecordTypeInfosByName() != null 
                                                                     && SC_SObjectResult.getRecordTypeInfosByName().get(SC_PROJECT_MANAGEMENT_NAME) != null)?
        SC_SObjectResult.getRecordTypeInfosByName().get(SC_PROJECT_MANAGEMENT_NAME).getRecordTypeId():null;
    public static final String SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE  = (SC_SObjectResult != null 
                                                                        && SC_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && SC_SObjectResult.getRecordTypeInfosByName().get(SC_PREVENTATIVE_MAINTENANCE_NAME) != null)?
                                                                        SC_SObjectResult.getRecordTypeInfosByName().get(SC_PREVENTATIVE_MAINTENANCE_NAME).getRecordTypeId():null;
    //A map of Contract Record Type Id by enum Contract Type
    public static final Map<UNITY_Constants.ContractType,String> CONTRACT_RTID_MAP = new Map<UNITY_Constants.ContractType,String>();
    static{
        for(UNITY_Constants.ContractType cType :UNITY_Constants.ContractType.values()){
            if(cType == UNITY_Constants.ContractType.SERVICE_REQUEST){
                CONTRACT_RTID_MAP.put(cType,SC_SERVICE_REQUEST_RECORDTYPE);
            }else if(cType == UNITY_Constants.ContractType.SITE_SURVEY){
                CONTRACT_RTID_MAP.put(cType,SC_SITE_SURVEY_RECORDTYPE);
            }else if(cType == UNITY_Constants.ContractType.PROJECT_MANAGEMENT){
                CONTRACT_RTID_MAP.put(cType,SC_PROJECT_MANAGEMENT_RECORDTYPE);
            }else if(cType == UNITY_Constants.ContractType.PREVENTATIVE_MAINTENANCE){
                CONTRACT_RTID_MAP.put(cType,SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE);
            }
        }
    }
   //  UNITY Service Contract Line Item
    
   public static final String SCLI_DISTRIBUTOR_TO_FLEET = 'Distributor to Fleet';
   public static final String SCLI_FLEET_TO_ACCOUNT     = 'Fleet to Account';
   public static final String SCLI_GENERAL_WORK         = 'General Work';
   public static final String SCLI_SERVICE_CHARGE        = 'Service Charge/Service Fee';
   public static final String SCLI_INTERNATIONAL_REQUIREMENTS = 'International Requirements';
   public static final String SCLI_NTE = 'NTE';
   public static final String SCLI_HOURLY_RATE = 'Hourly Rate';
   public static final String SCLI_PRODUCT_PRICING = 'Product Pricing';
   public static final String SCLI_MENU_PRICING = 'Menu Pricing';
   public static final String SCLI_ASSET_TYPE_RATE = 'Asset Type Rate'; 
   public static final String SCLI_PM_PRODUCT = 'PM Product'; 

   public static final String SCLI_PRODUCT_PRICING_RULE_RT = 'UNITY_Product_Pricing_Rule';
   public static final String SCLI_HOURLY_RATE_RT = 'UNITY_Hourly_Rate'; 
   public static final String SCLI_NTE_RT = 'UNITY_NTE'; 
   public static final String SCLI_MENU_PRICING_RT = 'UNITY_Menu_Pricing'; 
   public static final String SCLI_ASSET_TYPE_RATE_RT = 'UNITYPM_Asset_Type_Rate'; 
   public static final String SCLI_PM_PRODUCT_RT = 'UNITYPM_PM_Product'; 
    
   public static final String SCLI_HOURLY_RATE_RECORDTYPE          = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_HOURLY_RATE) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_HOURLY_RATE).getRecordTypeId():null;
   
    public static final String SCLI_MENU_PRICING_RECORDTYPE         = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_MENU_PRICING) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_MENU_PRICING).getRecordTypeId():null;                                                                  

   public static final String SCLI_PRODUCT_PRICING_RECORDTYPE      = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_PRODUCT_PRICING) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_PRODUCT_PRICING).getRecordTypeId():null;

    
   public static final String SCLI_DISTRIBUTOR_TO_FLEET_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_DISTRIBUTOR_TO_FLEET) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_DISTRIBUTOR_TO_FLEET).getRecordTypeId():null;
    public static final String SCLI_FLEET_TO_ACCOUNT_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_FLEET_TO_ACCOUNT) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_FLEET_TO_ACCOUNT).getRecordTypeId():null;
    public static final String SCLI_GENERAL_WORK_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_GENERAL_WORK) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_GENERAL_WORK).getRecordTypeId():null;
    public static final String SCLI_INTERNATIONAL_REQUIREMENTS_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_INTERNATIONAL_REQUIREMENTS) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_INTERNATIONAL_REQUIREMENTS).getRecordTypeId():null;
    public static final String SCLI_NTE_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_NTE) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_NTE).getRecordTypeId():null;
    public static final String SCLI_SERVICE_CHARGE_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_SERVICE_CHARGE) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_SERVICE_CHARGE).getRecordTypeId():null;
    public static final String SCLI_ASSET_TYPE_RATE_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_ASSET_TYPE_RATE) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_ASSET_TYPE_RATE).getRecordTypeId():null;
    public static final String SCLI_PM_PRODUCT_RECORDTYPE = (SCLI_SObjectResult != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_PM_PRODUCT) != null)?
                                                                    SCLI_SObjectResult.getRecordTypeInfosByName().get(SCLI_PM_PRODUCT).getRecordTypeId():null;
    
    // Account 
    public static final String ACCOUNT_CUSTOMER = 'Customer';
    public static final String ACCOUNT_MINER    = 'Miner';
    public static final String ACCOUNT_VENDOR   = 'Vendor';
    
    public static final Map<integer,list<String>> ACCOUNT_OPERATION_HOURS = new Map<integer,list<String>>{0=> new list<String>{'UNITY_Sunday_Start_Time__c'   ,'UNITY_Sunday_End_Time__c'},
                                                                                                          1=> new list<String>{'UNITY_Monday_Start_Time__c'   ,'UNITY_Monday_End_Time__c'},
                                                                                                          2=> new list<String>{'UNITY_Tuesday_Start_Time__c'  ,'UNITY_Tuesday_End_Time__c'},
                                                                                                          3=> new list<String>{'UNITY_Wednesday_Start_Time__c','UNITY_Wednesday_End_Time__c'},
                                                                                                          4=> new list<String>{'UNITY_Thursday_Start_Time__c' ,'UNITY_Thursday_End_Time__c'},
                                                                                                          5=> new list<String>{'UNITY_Friday_Start_Time__c'   ,'UNITY_Friday_End_Time__c'},
                                                                                                          6=> new list<String>{'UNITY_Saturday_Start_Time__c' ,'UNITY_Saturday_End_Time__c'}};
    
    public static final String ACCOUNT_CUSTOMER_RECORDTYPE = (Account_SObjectResult != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_CUSTOMER) != null)?
                                                                    Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_CUSTOMER).getRecordTypeId():null;
    public static final String ACCOUNT_MINER_RECORDTYPE   = (Account_SObjectResult != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_MINER) != null)?
                                                                    Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_MINER).getRecordTypeId():null;
    public static final String ACCOUNT_VENDOR_RECORDTYPE   = (Account_SObjectResult != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName() != null 
                                                                    && Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_VENDOR) != null)?
                                                                    Account_SObjectResult.getRecordTypeInfosByName().get(ACCOUNT_VENDOR).getRecordTypeId():null;
    // Work Order 
   
    public static final Map<String,String> VENDORS_RECORDTYPE_MAP = new Map<String,String>{'Preventative Maintenance'=>'PM','Project Management'=>'Project','Service Request'=>'SR','Site Survey'=>'SS'};
    
    public static final String WO_SITE_SURVEY_NAME          = 'Site Survey';
    public static final String WO_SERVICE_REQUEST_NAME      = 'Service Request';
    public static final String WO_PROJECT_MANAGEMENT_NAME   = 'Project Management';
    public static final String WO_PREVENTATIVE_MAINTENANCE_NAME   = 'Preventative Maintenance';
    public static final String WO_NON_WORK_NAME = 'Non-Work';
    
    public static final Map< String, String > WO_RECORDTYPE_ABBR = new Map<String,String>{WO_PREVENTATIVE_MAINTENANCE_NAME=>'PM',WO_PROJECT_MANAGEMENT_NAME=>'Project',WO_SERVICE_REQUEST_NAME => 'SR',WO_SITE_SURVEY_NAME=>'SS'};
    public static final Map< String, String > WO_ABBR_RECORDTYPE = new Map<String,String>{'PM'=>WO_PREVENTATIVE_MAINTENANCE_NAME,'Project'=>WO_PROJECT_MANAGEMENT_NAME,'SR'=>WO_SERVICE_REQUEST_NAME,'SS'=>WO_SITE_SURVEY_NAME};
    
    public static final String WO_SERVICE_REQUEST_RECORDTYPE = (WO_SObjectResult != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName().get(WO_SERVICE_REQUEST_NAME) != null)?
                                                                WO_SObjectResult.getRecordTypeInfosByName().get(WO_SERVICE_REQUEST_NAME).getRecordTypeId():null;

    public static final String WO_NON_WORK_RECORDTYPE = (WO_SObjectResult != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName().get(WO_NON_WORK_NAME) != null)?
                                                                WO_SObjectResult.getRecordTypeInfosByName().get(WO_NON_WORK_NAME).getRecordTypeId():null;
    public static final String WO_SITE_SURVEY_RECORDTYPE = (WO_SObjectResult != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName().get(WO_SITE_SURVEY_NAME) != null)?
                                                                WO_SObjectResult.getRecordTypeInfosByName().get(WO_SITE_SURVEY_NAME).getRecordTypeId():null;

    public static final String WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE = (WO_SObjectResult != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && WO_SObjectResult.getRecordTypeInfosByName().get(WO_PREVENTATIVE_MAINTENANCE_NAME) != null)?
                                                                WO_SObjectResult.getRecordTypeInfosByName().get(WO_PREVENTATIVE_MAINTENANCE_NAME).getRecordTypeId():null;

    public static final String WO_VENDOR_STATUS_ASSIGNED = 'Assigned';
    public static final String WO_VENDOR_STATUS_ACCEPTED = 'Accepted';
    public static final String WO_VENDOR_STATUS_REJECTED = 'Rejected';
    public static final String WO_VENDOR_STATUS_CANDIDATE_OFF_HOURS = 'Candidate-Off Hours';
    public static final String WO_VENDOR_STATUS_REJECTED_NO_RESPONSE = 'Rejected-No Response';
    public static final String WO_VENDOR_STATUS_REJECTED_OTHER = 'Rejected-Other';
    public static final String WO_VENDOR_STATUS_NO_CANDIDATE = 'No Auto-Dispatch Candidate';
    public static final String WO_VENDOR_STATUS_CANDIDATE = 'Candidate';
    
    public static final String WO_STATUS_NEW      = 'New';
    public static final String WO_STATUS_ASSIGNED = 'Assigned';
    public static final String WO_STATUS_ACCEPTED = 'Accepted';
    public static final String WO_STATUS_REJECTED = 'Rejected';
    
    // Work Order Line Item
    public static final String WOLI_ADD_A_PART = 'Add a Part';
    public static final String WOLI_ADD_AN_EXPENSE = 'Add an Expense';
    public static final String WOLI_WORK_ORDER_LINE_ITEM = 'Work Order Line Item';
    
    public static final String WOLI_ADD_A_PART_RECORDTYPE = (workOrderLineItem_SObjectResult != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_ADD_A_PART) != null)?
                                                                workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_ADD_A_PART).getRecordTypeId():null;
    public static final String WOLI_ADD_AN_EXPENSE_RECORDTYPE = (workOrderLineItem_SObjectResult != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_ADD_AN_EXPENSE) != null)?
                                                                workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_ADD_AN_EXPENSE).getRecordTypeId():null;
    public static final String WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE = (workOrderLineItem_SObjectResult != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName() != null 
                                                                && workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_WORK_ORDER_LINE_ITEM) != null)?
                                                                workOrderLineItem_SObjectResult.getRecordTypeInfosByName().get(WOLI_WORK_ORDER_LINE_ITEM).getRecordTypeId():null;
    
    // Vendor Assignment
    public static final String VENDOR_ASSIGNMENT_STATUS_ASSIGNED = 'Assigned';
    public static final String VENDOR_ASSIGNMENT_STATUS_ACCEPTED = 'Accepted';
    public static final String VENDOR_ASSIGNMENT_STATUS_REJECTED = 'Rejected';
    public static final String VENDOR_ASSIGNMENT_STATUS_CANDIDATE_OFF_HOURS = 'Candidate-Off Hours';
    public static final String VENDOR_ASSIGNMENT_STATUS_REJECTED_NO_RESPONSE = 'Rejected-No Response';
    public static final String VENDOR_ASSIGNMENT_STATUS_REJECTED_OTHER = 'Rejected-Other';
    public static final String VENDOR_ASSIGNMENT_STATUS_CANDIDATE_BELOW_MARGIN = 'Candidate-Below Margin';
    public static final String VENDOR_ASSIGNMENT_STATUS_CANDIDATE = 'Candidate'; 
    
    
    // Template configuration 
    public static final String TEMPLATE_CONFIGURATION_PROJECT             = 'Project';
    public static final String TEMPLATE_CONFIGURATION_PROPOSAL_LINE_ITEMS = 'Proposal Line Items';
    public static final String TEMPLATE_CONFIGURATION_PURCHASE_ORDER      = 'Purchase Order';
   
    public static final String TEMPLATE_CONFIG_PROJECT_RECORDTYPE = (TemplateConfig_SObjectResult != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PROJECT) != null)?
                                                                        TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PROJECT).getRecordTypeId():null;
    public static final String TEMPLATE_CONFIG_PROPOSAL_LINE_ITEMS_RECORDTYPE = (TemplateConfig_SObjectResult != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PROPOSAL_LINE_ITEMS) != null)?
                                                                        TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PROPOSAL_LINE_ITEMS).getRecordTypeId():null;
    public static final String TEMPLATE_CONFIG_PURCHASE_ORDER_RECORDTYPE = (TemplateConfig_SObjectResult != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PURCHASE_ORDER) != null)?
                                                                        TemplateConfig_SObjectResult.getRecordTypeInfosByName().get(TEMPLATE_CONFIGURATION_PURCHASE_ORDER).getRecordTypeId():null;
    
   
    // Order 
    
    public static final String ORDER_PURCHASE_ORDER = 'Purchase Order';
    public static final String ORDER_USAGE_REQUEST  = 'Usage Request';
    public static final String ORDER_STOCKING_PURCHASE_ORDER = 'Stocking Purchase Order';
    public static final String PART_SOURCING_PURCHASE_ORDER = 'Parts Sourcing Purchase Order';
    public static final String ADJUSTMENT_PURCHASE_ORDER = 'Adjustment Purchase Order';
    
    public static final String SERVICE_FEE_POLI_TYPE_CS_KEY = 'Service Fee POLI Type';
    public static final String SERVICE_FEE_POLI_ACTIVITY_TYPE_CS_KEY = 'Service Fee POLI Activity Type';
    public static final String SERVICE_FEE_PRODUCT_NAME_CS_KEY = 'Service Fee Product name';
    public static final String SERVICE_FEE_PRODUCT_TYPE_CS_KEY = 'Service Fee Product Type';
    public static final String NON_BILLABLE_POLI_TYPE_CS_KEY = 'Non Billable POLI Type';
    
    public static final String ORDER_STATUS_SUBMITTED_TO_MINER = 'Submitted to Miner';
    
    public static final String ORDER_STATUS_DRAFT      = 'Draft';
    public static final String ORDER_STATUS_PO_CREATED = 'PO Created';
    public static final String ORDER_STATUS_REJECTED   = 'Rejected';
    public static final String ORDER_STATUS_FINAL      = 'Rejected';
    public static final String ORDER_STATUS_ACCEPTED   = 'Accepted';
    public static final String ORDER_STATUS_IN_QUOTE_PROCESS = 'In Quote Process';
    public static final String ORDER_STATUS_PART_SOURCE_NEEDED = 'Parts Sourcing Required';
    public static final String ORDER_STATUS_PART_ORDER_REQUIRED = 'Parts Order Required';
    public static final String ORDER_STATUS_PART_SOURCE_IDENTIFIED = 'Parts Source Identified';
	public static final String ORDER_STATUS_FINAL_FINAL = 'Final';
    public static final String ORDER_STATUS_COMPLETED = 'Completed';
    public static final String ORDER_STATUS_PARTS_BEING_DELIVERED = 'Parts Being Delivered';
    public static final String ORDER_STATUS_READY_TO_SHIP = 'Ready to Ship';    
    
    public static final String ORDER_PURCHASE_ORDER_RECORDTYPE = (Order_SObjectResult != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_PURCHASE_ORDER) != null)?
                                                                        Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_PURCHASE_ORDER).getRecordTypeId():null;
    
    public static final String ORDER_USAGE_REQUEST_RECORDTYPE = (Order_SObjectResult != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_USAGE_REQUEST) != null)?
                                                                        Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_USAGE_REQUEST).getRecordTypeId():null;


    public static final String ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE = (Order_SObjectResult != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_STOCKING_PURCHASE_ORDER) != null)?
                                                                        Order_SObjectResult.getRecordTypeInfosByName().get(ORDER_STOCKING_PURCHASE_ORDER).getRecordTypeId():null;

    public static final String PART_SOURCING_PURCHASE_ORDER_RECORDTYPE = (Order_SObjectResult != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName().get(PART_SOURCING_PURCHASE_ORDER) != null)?
                                                                        Order_SObjectResult.getRecordTypeInfosByName().get(PART_SOURCING_PURCHASE_ORDER).getRecordTypeId():null;
    
    public static final String ADJUSTMENT_PURCHASE_ORDER_RECORDTYPE = (Order_SObjectResult != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Order_SObjectResult.getRecordTypeInfosByName().get(ADJUSTMENT_PURCHASE_ORDER) != null)?
                                                                        Order_SObjectResult.getRecordTypeInfosByName().get(ADJUSTMENT_PURCHASE_ORDER).getRecordTypeId():null;
    
    // Case 
  
    public static final String CASE_PROJECT_MANAGEMENT = 'Project Management';  
    public static final String CASE_PROJECT_PHASE = 'Project Phase';
    public static final String CASE_SERVICE_REQUEST = 'Service Request';
    public static final String CASE_PREVENTATIVE_MAINTENANCE = 'Preventative Maintenance';
    public static final String CASE_PORTAL_SOURCE_SERVICE_CHANNEL = 'Service Channel';
    public static final String CASE_PROGRAM_CASE = 'Program Case';
    
    public static final String CASE_PROJECT_MANAGEMENT_RECORDTYPE = (Case_SObjectResult != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROJECT_MANAGEMENT) != null)?
                                                                        Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROJECT_MANAGEMENT).getRecordTypeId():null;
    public static final String CASE_PROJECT_PHASE_RECORDTYPE = (Case_SObjectResult != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROJECT_PHASE) != null)?
                                                                        Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROJECT_PHASE).getRecordTypeId():null;
    public static final String CASE_SERVICE_REQUEST_RECORDTYPE = (Case_SObjectResult != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName().get(CASE_SERVICE_REQUEST) != null)?
                                                                        Case_SObjectResult.getRecordTypeInfosByName().get(CASE_SERVICE_REQUEST).getRecordTypeId():null;
    public static final String CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE = (Case_SObjectResult != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PREVENTATIVE_MAINTENANCE) != null)?
                                                                        Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PREVENTATIVE_MAINTENANCE).getRecordTypeId():null;
    
    public static final String CASE_PROGRAM_CASE_RECORDTYPE = (Case_SObjectResult != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROGRAM_CASE) != null)?
                                                                        Case_SObjectResult.getRecordTypeInfosByName().get(CASE_PROGRAM_CASE).getRecordTypeId():null;
    
    // task 
    public static final String TASK_UNITY_TASK = 'UNITY Task'; 
    public static final String TASK_UNITY_TASK_RECORDTYPE = (Task_SObjectResult != null 
                                                                        && Task_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Task_SObjectResult.getRecordTypeInfosByName().get(TASK_UNITY_TASK) != null)?
                                                                        Task_SObjectResult.getRecordTypeInfosByName().get(TASK_UNITY_TASK).getRecordTypeId():null;

  
    // fields to capture from the parent record per SObject type
          
    
    public static final list<String> CASE_CAPTURE_PARENT_FIELDS = new list<String>{'UNITY_Customer__c'};
    
    public static final Map< String , String > WO_CAPTURE_PARENT_CASE_FIELDS = new Map< String , String >{  'AccountId'           => 'AccountId',
                                                                                                            'ContactId'           => 'ContactId',
                                                                                                            'UNITY_Not_To_Exceed_NTE__c'=> 'UNITY_NTE_Threshold__c',
                                                                                                            'UNITY_Business_Unit__c'    => 'UNITY_Business_Unit__c',
                                                                                                            'UNITY_Customer_Service_Contract__c' => 'UNITY_Customer_Service_Contract__c',
                                                                                                            'UNITY_Customer__c'         => 'UNITY_Customer__c'
                                                                                                         };
        
        
       
    //  Proposal 
    public static final String PROPOSAL_CUSTOMER_PROPOSAL = 'Sub Quote';    
    public static final String PROPOSAL_MASTER_PROPOSAL = 'Master Quote'; 
        
    public static final String PROPOSAL_CUSTOMER_PROPOSAL_RECORDTYPE = (Proposal_SObjectResult != null 
                                                                        && Proposal_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Proposal_SObjectResult.getRecordTypeInfosByName().get(PROPOSAL_CUSTOMER_PROPOSAL) != null)?
                                                                        Proposal_SObjectResult.getRecordTypeInfosByName().get(PROPOSAL_CUSTOMER_PROPOSAL).getRecordTypeId():null;    
    
    public static final String PROPOSAL_MASTER_PROPOSAL_RECORDTYPE = (Proposal_SObjectResult != null 
                                                                        && Proposal_SObjectResult.getRecordTypeInfosByName() != null 
                                                                        && Proposal_SObjectResult.getRecordTypeInfosByName().get(PROPOSAL_MASTER_PROPOSAL) != null)?
                                                                        Proposal_SObjectResult.getRecordTypeInfosByName().get(PROPOSAL_MASTER_PROPOSAL).getRecordTypeId():null;    
    
    public static final Map< String , list<String> > CAPTURE_VENDOR_FILTER_DATA_FROM = new Map< String , list<String> >{    'WorkOrder' => new list<String>{'AccountId','Account.ShippingPostalCode','Account.ShippingCountryCode','FSO__Skills__c'} ,
                                                                                                                        'Account' => new list<String>{'ShippingPostalCode','ShippingCountryCode'}  };
    
                                                                                                                            
    public static final String QT_CUSTOMER_STATUS_ACCEPT            = 'Accepted'; // RCQ
    public static final String QT_CUSTOMER_STATUS_REJECT            = 'Rejected'; // RCQ
    public static final String QT_STATUS_SENT_TO_CUSTOMER           = 'Sent to Customer';
    public static final String QT_STATUS_PA_AND_SC                  = 'Proposal Amended & Sent to Customer';

    public static final String QT_STATUS_QUOTE_CREATION        = 'Quote Creation';
    public static final String QT_STATUS_AGENT_REVIEW_COMPLETE    = 'Agent Review Complete';
    public static final String QT_STATUS_READY_TO_SEND        = 'Ready to Send';
    public static final String QT_STATUS_READY_TO_SEND_TO_CUSTOMER  = 'Ready to Send to Customer';
    public static final String QT_STATUS_CUSTOMER_APPROVED        = 'Customer Approved';
    public static final String QT_STATUS_CUSTOMER_REJECTED      = 'Customer Rejected';
    public static final String QT_STATUS_PENDING_MANAGER_APPROVAL  = 'Pending Manager Approval';
    public static final String QT_STATUS_MANAGER_APPROVED        = 'Approved by Manager';
    public static final String QT_STATUS_MANAGER_REJECTED      = 'Rejected by Manager';
    public static final String QT_STATUS_PENDING_CUSTOMER_REVIEW  = 'Pending Customer Review';
    public static final String QT_STATUS_COMPLETED          = 'Completed';
    public static final String QT_STATUS_CANCELLED          = 'Cancelled';
    public static final String QT_STATUS_QUOTE_FINALIZED      = 'Quote Finalized';    

    // Profile
    public static final String PROFILE_PARTNER_TECHNICIAN_VENDOR_NAME = 'UNITY_Partner_Technician';
    public static final String PROFILE_TECHNICIAN_SELF_PERFORM_NAME        = 'UNITY_Technician(Self Perform)';
    public static final String PROFILE_CUSTOMER_PORTAL_USER_NAME      = 'Customer Portal User';
    public static final String PROFILE_READ_ONLY_ACCESS_NAME          = 'Read Only Access';
    
    public static final String PROFILE_TYPE_POWER_CUSTOMER_SUCCESS = 'PowerCustomerSuccess';
    // Invoice
    
     
    public static final String INVOICE_VENDOR_NAME = 'UNITY Invoice';
    
    public static final String INVOICE_VENDOR_RECORDTYPE = (Invoice_SObjectResult != null 
                                                            && Invoice_SObjectResult.getRecordTypeInfosByName() != null 
                                                            && Invoice_SObjectResult.getRecordTypeInfosByName().get(INVOICE_VENDOR_NAME) != null)?
                                                            Invoice_SObjectResult.getRecordTypeInfosByName().get(INVOICE_VENDOR_NAME).getRecordTypeId():null;
    
    public static final String INV_CUSTOMER_STATUS_ACCEPT   = 'Accepted'; // RCQ
    public static final String INV_CUSTOMER_STATUS_REJECT   = 'Rejected'; // RCQ
    public static final String INV_SENT_TO_CUSTOMER         = 'Sent to Customer';
    public static final String INV_COMPLETED        = 'Completed';
    public static final String INV_FINALIZED        = 'Invoice Finalized';
    public static final String PO_INVOICEABLE_STATUSES    = 'PO_Invoiceable_Statuses';
    public static final String PO_INVOICEABLE_STATUSES_DELIMITER    = ',';
    
    // Vendor Preference
    public static final String VENDOR_PREFERENCE_PREFERRED   = 'Preferred';   
    public static final String VENDOR_PREFERENCE_DO_NOT_USE  = 'Do Not Use';

    // Barcode Parsing Status
    public static final String DOCUMENT_STAGING_STATUS_UPLOADED   = 'Processing';
    public static final String DOCUMENT_STAGING_STATUS_PARSED   = 'Parsed';
    public static final String DOCUMENT_STAGING_STATUS_ATTACHED   = 'Attached';
    public static final String DOCUMENT_STAGING_STATUS_FAILED  = 'Failed';
    public static final String DOCUMENT_STAGING_STATUS_COMPLETE  = 'Complete';
    public static final String DOCUMENT_STAGING_STATUS_NEW  = 'New';


    // The Agent can edit this Date Time fields by customer or local Time Zone 
    public static final Map<SObjectType,list<String>> SOBJECT_DATETIME_FIELDS = new  Map<SObjectType,list<String>>{ WorkOrder.getSObjectType() => new list<String>{'UNITY_Work_Window_Begin__c','StartDate','FSO__Start_Travel_Date__c','FSO__Check_In_Date__c','FSO__Completed_Date__c'},
                                                              Case.getSObjectType()      => new list<String>{'UNITY_Work_Window_Begin__c', 'UNITY_Service_Completed_Date_Time__c' }};
    
    
    
    // trigger context
    public static final Map<String, Boolean> isExecutingContext = new Map<String, Boolean>();
    
    public static Boolean isExecutingContext(String contextName){
 
       if(isExecutingContext.get(contextName) == null || isExecutingContext.get(contextName) == false ){
           isExecutingContext.put(contextName, true);
           return false;
       }else{
           return true;
       }
    }
    
    // trigger context
    public static final Map<String, Integer> executionsPerTrigger = new Map<String, Integer>();
    
    public static Integer counterCycle = 0;
    
    public static Integer MAX_TRIGGER_EXECUTION = 12;
    
    public static Boolean isExecutingTooMany(String contextName) {
        if(executionsPerTrigger.get(contextName) == null) {
            executionsPerTrigger.put(contextName,0);
        }
        executionsPerTrigger.put(contextName, executionsPerTrigger.get(contextName)+1);
        System.debug(' >>> contextName '+contextName+' times : '+executionsPerTrigger.get(contextName));
      return executionsPerTrigger.get(contextName) > MAX_TRIGGER_EXECUTION;
    }
    
    public static Id standardPriceBookId;
    
    public static Id getStandardPriceBookId(){
        
        if (standardPriceBookId == null){
            
            if(Test.isRunningTest())
                standardPriceBookId = Test.getStandardPricebookId();
            else
                standardPriceBookId = [SELECT id FROM Pricebook2 WHERE Name = 'Standard Price Book'][0].Id;
        }
        
        return standardPriceBookId;
    }


    public static Set<String> notReevaluateRecord = new Set<String>();
    public static Boolean wasRecordEvaluated(String context) {
      Boolean toReturn = false;
      if(notReevaluateRecord.contains(context)) 
        toReturn = true; 

      notReevaluateRecord.add(context);
      return toReturn;
    }

  
    public enum JOB_LOG_SEVERITY {INFO, WARNING, ERROR}
}