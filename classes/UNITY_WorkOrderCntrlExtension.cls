public class UNITY_WorkOrderCntrlExtension {
    public workOrder workorder {get;set;}
    public ID id {get;set;}
    public User contactUser { set; get;}
    public String CreatedDate{get;set;}
    public String AssignedDate{get;set;}
    public String Window_Begin{get;set;}
    public String Window_End {get;set;}
    public String MinerFooterDocument {get;set;}
    public String JobSite {get;set;}
    public Boolean VendorAcceptedStatus {get;set;}
    public Decimal POtotalCost {get;set;}
    public String CustomerStoreLocation {get;set;}
    public  String WarningMessage {get;set;}
    public string  MinerImage {get;set;} 
    public string  WorkOrderShippingCity {get;set;} 
    public string  WorkOrderShippingStreet {get;set;}
    public string  WorkOrderShippingState {get;set;}
    public string  WorkOrderShippingPostalCode {get;set;}
    public string  WorkOrderCustomerPO {get;set;}
    public string WorkOrderContact {get;set;} 
    
    public UNITY_WorkOrderCntrlExtension(ApexPages.StandardController controller) {
       WarningMessage = 'This Work Order has not been accepted. Please return to the Home tab to accept.';
       workorder= (Workorder)controller.getRecord();
       id = (ID) controller.getRecord().get('id');
       system.debug('@@@@@@   workorder  @@@ ' + workorder);
       system.debug('@@@@@@   workorder id  @@@ ' + id);
       
          try{
              
              WorkOrder wo = new WorkOrder();
               wo= [SELECT Account.UNITY_TimeZoneSidKey__c, Case.CreatedDate, UNITY_Vendor_Last_Assigned__c,UNITY_Job_Site__c,
                                UNITY_Work_Window_Begin__c,UNITY_Work_Window_End__c, UNITY_Email_Document_Footer__c,UNITY_Vendor_Status__c,
                                  UNITY_Current_PO__r.UNITY_Total_Cost__c, Account.UNITY_LOC__c, UNITY_Email_Logo_URL__c,Contact.Name,
                                  Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, case.UNITY_Customer_PO__c
                                                       FROM WorkOrder
                                                                       WHERE id =: id];
                                                                       
             
            
              MinerFooterDocument = wo.UNITY_Email_Document_Footer__c;
              MinerFooterDocument = MinerFooterDocument.replace('<br>', '<br/>');
              
              JobSite = wo.UNITY_Job_Site__c;
              JobSite = JobSite.replace('BR()', '<br/>');
              MinerImage = wo.UNITY_Email_Logo_URL__c;
              WorkOrderShippingCity = wo.Account.ShippingCity;
              WorkOrderShippingStreet = wo.Account.ShippingStreet;
              WorkOrderShippingState = wo.Account.ShippingState;
              WorkOrderShippingPostalCode = wo.Account.ShippingPostalCode;
              WorkOrderCustomerPO = wo.case.UNITY_Customer_PO__c;
              WorkOrderContact = wo.Contact.Name;
              
              UNITY_Utils.DateTimeZone dtzCreatedDate = UNITY_Utils.getDateTime(wo.Case.CreatedDate, null, wo.Account.UNITY_TimeZoneSidKey__c);
              UNITY_Utils.DateTimeZone dtzAssignedDate;
        
              if (wo.UNITY_Vendor_Last_Assigned__c != null)
                  dtzAssignedDate = UNITY_Utils.getDateTime(wo.UNITY_Vendor_Last_Assigned__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
              else
                  dtzAssignedDate = dtzCreatedDate;
        
              UNITY_Utils.DateTimeZone dtzWindow_Begin = UNITY_Utils.getDateTime(wo.UNITY_Work_Window_Begin__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
              UNITY_Utils.DateTimeZone dtzWindow_End = UNITY_Utils.getDateTime(wo.UNITY_Work_Window_End__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
        
              CreatedDate = dtzCreatedDate.format; 
              AssignedDate = dtzAssignedDate.format; 
              Window_Begin = dtzWindow_Begin.format + ' ' + dtzWindow_Begin.displayname;
              Window_End = dtzWindow_End.format + ' ' + dtzWindow_End.displayname;
              POtotalCost = wo.UNITY_Current_PO__r.UNITY_Total_Cost__c;
              CustomerStoreLocation = wo.Account.UNITY_LOC__c;
               VendorAcceptedStatus = false;
               
               if ( wo.UNITY_Vendor_Status__c != 'Accepted'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This Work Order has not been accepted. Please return to the Home tab to accept.'));
              }
               else {
                   VendorAcceptedStatus = true;
               }
          }
          catch(exception ex){
              system.debug('*** ERROR from UNITY_WorkOrderCntrlExtension **** ' + ex);
          }
        }
    }