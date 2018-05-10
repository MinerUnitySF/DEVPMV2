public class UNITY_OrderLinePDFExtension  {
    
    public Order order {get;set;}
    public ID id {get;set;}
    Public WorkOrder workOrder {get;set;}
    public String MinerFooterDocument {get;set;}
    public  String WarningMessage {get;set;}
    public Boolean VendorAcceptedStatus {get;set;}
    public Boolean WorkOrderPreventativeMaintenance {get;set;}
    
    public UNITY_OrderLinePDFExtension(ApexPages.StandardController controller) {
        order= (Order)controller.getRecord();
        id = (ID) controller.getRecord().get('id');
       
        Map<string,UNITY_General_Settings__c> generalSettings = UNITY_General_Settings__c.getAll();
        Set<String> delimitedInvoiceableStatuses = new Set<String>();
        UNITY_General_Settings__c generalSetting = generalSettings.get(UNITY_Constants.PO_INVOICEABLE_STATUSES);
        
        String POInvoiceableStatuses;
        
        if (generalSetting!=null){
            POInvoiceableStatuses = generalSetting.UNITY_Value__c;
        }
        if (POInvoiceableStatuses!=null){
            delimitedInvoiceableStatuses = new Set<String>(POInvoiceableStatuses.split(UNITY_Constants.PO_INVOICEABLE_STATUSES_DELIMITER));
        }
        
        VendorAcceptedStatus = false; 
        WorkOrderPreventativeMaintenance = false;
        system.debug('>>>> delimitedInvoiceableStatuses >>> ' + delimitedInvoiceableStatuses);
        
       try{
        order = [SELECT id, FSO__WorkOrder__c, FSO__WorkOrder__r.Status, UNITY_Total_Cost__c, Status, OrderNumber, CreatedDate, Description
                       FROM order 
                       WHERE id =:id AND 
                           Status IN :delimitedInvoiceableStatuses 
                             AND FSO__WorkOrder__r.Status != 'Canceled'];
       }
       catch(Exception ex){
            order = new order();
       }
                             
        system.debug('>>>> neli FSO__WorkOrder__r.Status >>>> ' + order.FSO__WorkOrder__r.Status);
        system.debug('>>>> neli FSO__WorkOrder__c >>>> ' + order.FSO__WorkOrder__c);
        system.debug('>>>> Status >>>> ' + order.Status);
        system.debug('>>>> neli id >>>> ' + order.id);
        system.debug('>>>> neli OrderNumber >>>> ' + order.OrderNumber);
        system.debug('>>>> neli order >>>> ' + order);
          
        if ( order.id != null){
                workOrder = [SELECT ID, UNITY_Email_Logo_URL__c,UNITY_Assigned_Vendor__r.Name,RecordTypeId,
                        UNITY_Assigned_Vendor__r.BillingStreet, UNITY_Assigned_Vendor__r.BillingCity, 
                        UNITY_Assigned_Vendor__r.BillingState, UNITY_Assigned_Vendor__r.BillingPostalCode,
                        RecordType.DeveloperName, Account.Name,Account.ShippingStreet,Account.UNITY_LOC__c,
                         Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode,UNITY_Vendor_Status__c,
                         UNITY_Current_PO__r.Description,UNITY_Current_PO__c, UNITY_Email_Document_Footer__c
                           FROM WorkOrder
                           WHERE ID =: order.FSO__WorkOrder__c]; //AND  UNITY_Vendor_Status__c = 'Accepted'];
              
              MinerFooterDocument = workOrder.UNITY_Email_Document_Footer__c;
              MinerFooterDocument = MinerFooterDocument.replace('<br>', '<br/>'); 
              
               if ( workOrder.UNITY_Vendor_Status__c == 'Accepted'){
                   VendorAcceptedStatus = true;
               }
               
               if (workOrder.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
                   WorkOrderPreventativeMaintenance = true;
               }
          }
          WarningMessage = 'This Work Order has not been accepted. Please return to the Home tab to accept.';
          system.debug('>>> work order >>>' + workorder);
    }
}