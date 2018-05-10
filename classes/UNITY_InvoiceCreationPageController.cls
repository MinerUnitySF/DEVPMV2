public class UNITY_InvoiceCreationPageController{
    public List<WorkOrder> workOrders;
    public List<Order> orders;
    public List<OrderItem> orderProducts;
    public List<WorkOrderWrapper> wrappers {get;set;}
    public Decimal discount_per {get;private set;}
    public Decimal discount_amt {get;private set;}
    public UNITY_Service_Contract__c sContract;
    public Case context {get;set;}
    public Boolean noOrdersToInvoice {get;set;}
    public Boolean noOrders {get;set;}
    public Boolean displayPOCheckbox {get;set;}
    public Boolean poCheckbox {get;set;}
    public Map<Id, Boolean> isInvoiceableMap {get;set;}
    public Map<Id, Boolean> isInvoiceableWorkOrderMap {get;set;}
    public Map<Id,List<Order>> workOrderOrdersMap {get;set;}
    public static Map<string,UNITY_General_Settings__c> generalSettings = UNITY_General_Settings__c.getAll();
    public User u; 
    public UNITY_InvoiceCreationPageController(ApexPages.StandardController controller){
        noOrdersToInvoice = true;
        this.discount_per = 0;
        this.discount_amt = 0;
        u = [SELECT FirstName,LastName
             FROM User
             WHERE Id = :UserInfo.getUserId()];
        context = [SELECT Id, ContactId, CaseNumber, 
                          AccountId,
                          Account.Account_Email__c,
                          Account.UNITY_Bill_To_Account__c,
                          Account.UNITY_Bill_To_Account__r.Account_Email__c,
                          Account.UNITY_Bill_to_Self__c,
                          Account.MSPFS_MSP_Bill_to_Account__c,
                          Account.MSPFS_MSP_Bill_to_Account__r.Account_Email__c,
                          Account.MSPFS_MSP_Bill_to_Self__c,
                          UNITY_Customer__c, 
                          UNITY_Customer__r.Account_Email__c, 
                          UNITY_Customer__r.UNITY_Is_AR_Account__c,
                          UNITY_Customer__r.UNITY_Bill_To_Account__c,
                          UNITY_Customer__r.UNITY_Bill_To_Account__r.Account_Email__c,
                          UNITY_Business_Unit_Account__c,
                          UNITY_Business_Unit_Account__r.MSPFS_Is_MSP_BU__c,
                          UNITY_Customer_Service_Contract__c,
                          UNITY_Partial_Invoice_Reason__c,
                          UNITY_Partial_Invoiced_User__c,
                          UNITY_Agent_ID__c,
                          RecordTypeId 
                   FROM Case 
                   WHERE Id =: controller.getRecord().Id];
        workOrders = [SELECT Id, CaseId, AccountId, WorkOrderNumber,
                             UNITY_Attachment_Compliant__c,RecordTypeId, UNITY_Order_Type__c
                      FROM WorkOrder 
                      WHERE CaseId =: context.Id                       
                      AND UNITY_Attachment_Compliant__c = true];
        sContract = [SELECT Id, UNITY_Margin__c, UNITY_Miner_OT_Start_Time_Hour__c,
                            UNITY_Miner_OT_End_Time_Hour__c,UNITY_Miner_OT_Start_Time_Minute__c,
                            UNITY_Miner_OT_End_Time_Minute__c, UNITY_OT_Multiplier__c, UNITY_Max_Allowable_Trip_Charges__c, 
                            UNITY_Holiday_Multiplier__c 
                     FROM UNITY_Service_Contract__c 
                     WHERE Id =: context.UNITY_Customer_Service_Contract__c];
        system.debug('@@@ : UNITY_Margin__c : '+sContract.UNITY_Margin__c);
        Set<Id> workOrderIdSet = new Set<Id>();
        Set<Id> workOrderIdAccountSet = new Set<Id>();
        for(WorkOrder wo : workOrders){
            //UNITYPM if PMO/PMA, Case SHOULD EE of Type Service Request 
            if (context.RecordTypeId != UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE || (wo.UNITY_Order_Type__c != 'PMO' && wo.UNITY_Order_Type__c  != 'PMA')){
              workOrderIdSet.add(wo.id);
              workOrderIdAccountSet.add(wo.AccountId);          
            }
        }
        Set<String> delimitedInvoiceableStatuses = new Set<String>();
        UNITY_General_Settings__c generalSetting = generalSettings.get(UNITY_Constants.PO_INVOICEABLE_STATUSES);
        String POInvoiceableStatuses;
        if (generalSetting!=null){
            POInvoiceableStatuses = generalSetting.UNITY_Value__c;
        }
        if (POInvoiceableStatuses!=null){
            delimitedInvoiceableStatuses = new Set<String>(POInvoiceableStatuses.split(UNITY_Constants.PO_INVOICEABLE_STATUSES_DELIMITER));
        }
        /*
        RecordType purchaseOrderRT = [SELECT Id 
                                      FROM RecordType 
                                      WHERE DeveloperName = 'UNITY_Purchase_Order' 
                                      AND SobjectType ='Order'];
                */
        orders = [SELECT Id, UNITY_Invoice__c, UNITY_Assigned_Vendor__c, 
                  UNITY_Customer__r.Account_Email__c,UNITY_Customer__r.Name, 
                  UNITY_Ship_To_Account__c, UNITY_Customer__c, UNITY_Total_Amount__c, 
                  UNITY_Total_Cost__c, FSO__WorkOrder__c, FSO__WorkOrder__r.WorkOrderNumber,
                  UNITY_Invoiced__c, AccountId, Account.Name, Status,UNITY_Final_Price__c,
                  UNITY_Line_Item_Discounted_Price__c,UNITY_Discount__c,UNITY_Discount_Amount__c
                  FROM Order 
                  WHERE FSO__WorkOrder__c IN: workOrderIdSet 
                  //AND RecordTypeId =: purchaseOrderRT.Id
                  AND (RecordTypeId =: UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE OR RecordTypeId =: UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE)
                  AND Status IN: delimitedInvoiceableStatuses
                  AND FSO__WorkOrder__r.Status != 'Canceled'
                  AND MSPFS_Intercompany_Transfer__c = false];
        if(orders.size() == 0){
            noOrders = true;
            noOrdersToInvoice = true;
            return;
        }
        System.debug('#delimitedInvoiceableStatuses '+delimitedInvoiceableStatuses);
        
        isInvoiceableMap = new Map<Id,Boolean>();
        workOrderOrdersMap = new Map<Id,List<Order>>();
        isInvoiceableWorkOrderMap = new Map<Id,Boolean>();
        Set<Id> orderIdSet = new Set<Id>();
        for(Order o : orders){
            if(!workOrderOrdersMap.containskey(o.FSO__WorkOrder__c)){
                workOrderOrdersMap.put(o.FSO__WorkOrder__c, new List<Order>());
            }
            System.debug('#order '+o);
            workOrderOrdersMap.get(o.FSO__WorkOrder__c).add(o);
            if (!o.UNITY_Invoiced__c && delimitedInvoiceableStatuses.contains(o.status) 
        //    && o.UNITY_Assigned_Vendor__c != null
            
            ){
                isInvoiceableMap.put(o.id,true);
            }else{
                isInvoiceableMap.put(o.id,false);
            }
            
            if(!o.UNITY_Invoiced__c){
                noOrdersToInvoice = false;
            }
            orderIdSet.add(o.Id);
        }
        System.debug('#workOrders '+workOrders);
        System.debug('#workOrderOrdersMap '+workOrderOrdersMap);
        
        for(WorkOrder wo: workOrders){
            boolean isWOInvoiceable =true;
            if(workOrderOrdersMap.get(wo.Id) != null && 
               ((wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE && wo.UNITY_Attachment_Compliant__c) || 
                wo.RecordTypeId == UNITY_Constants.WO_NON_WORK_RECORDTYPE||
                wo.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE)){
                    for(Order o : workOrderOrdersMap.get(wo.Id)){
                        if(isInvoiceableMap.containsKey(o.Id)){
                            if(!isInvoiceableMap.get(o.Id)){
                                isWOInvoiceable =true;
                                break;
                            } 
                        }  
                    }
             }else{
                 isWOInvoiceable =false;
             }
            isInvoiceableWorkOrderMap.put(wo.Id,isWOInvoiceable);

        }
        System.debug('#isInvoiceableMap '+isInvoiceableMap);
        //Izay: Added additional fields to query to get all required fields for SL Integration
        orderProducts = [SELECT Id, UNITY_Sales_Tax__c, OrderId, 
                         UNITY_Tax_Code__c, UNITY_Price__c, 
                         UNITY_Total_Cost__c, UNITY_Total_Price__c,
                         UNITY_Discount__c,UNITY_Discount_Amount__c,PricebookEntry.Product2Id, 
                         PricebookEntry.Product2.UNITY_Product_Type__c, Quantity, 
                         UNITY_Customer_Adjusted_Quantity__c, UNITY_Is_Vendor_Supply__c, UNITY_Subtype__c, UNITY_Type__c,
                         UNITY_GL_Revenue_Account__c,UNITY_GL_Tax_Account__c,UNITY_GL_Sub_Account__c,UNITY_Activity_Type__c,
                         UNITY_Asset__c,UNITY_Unknown_Part_Description__c,UNITY_Not_Billable__c, UNITYPM_Is_Preventative_Maintenance__c
                         FROM OrderItem 
                         WHERE OrderId IN: orderIdSet order by createdDate];
        Map<Id, List<OrderItem>> orderIdToOrderItemMap = new Map<Id, List<OrderItem>>();
        for(OrderItem oi : orderProducts){
            if(!orderIdToOrderItemMap.containsKey(oi.OrderId)){
                orderIdToOrderItemMap.put(oi.OrderId, new List<OrderItem>());
            }
            orderIdToOrderItemMap.get(oi.OrderId).add(oi);
        }
        
        System.debug('#orders '+orders);
        wrappers = createWorkOrderWrappers(workOrders, orders, orderIdToOrderItemMap);
        
        System.debug('#wrappers '+wrappers);
        
        List<Account> accounts = [SELECT Id 
                                  FROM Account 
                                  WHERE Id IN: workOrderIdAccountSet];
        Set<Id> accountIdSet = new Set<Id>();
        for(Account acc : accounts){
            accountIdSet.add(acc.Id);
        }

    }

    public PageReference poCheckboxCheck(){
        if(poCheckbox){
            displayPOCheckbox = true;
        }
        else{
            displayPOCheckbox = false;
        }
        return null;
    }
    public PageReference backToCase(){
        PageReference pageRef = new PageReference('/' + context.Id);
        return pageRef;
    }

    /**
     * @description: 
     * 
     *
     */
    public PageReference createInvoice() {
        Savepoint sp;

        UNITY_Invoice__c invoice = new UNITY_Invoice__c();

        try {
            sp = Database.setSavepoint();

            invoice.UNITY_Case__c = context.Id;

            if (String.isNotBlank(context.AccountId) && String.isNotBlank(context.UNITY_Customer__c) && String.isNotBlank(context.UNITY_Business_Unit_Account__c)) {
                //Izay: If the account and customer are the same...
                if(context.AccountId == context.UNITY_Customer__c){
                    //Izay: If the BU is MSP BU and the account is MSP Bill to Self...
                    if(context.UNITY_Business_Unit_Account__r.MSPFS_Is_MSP_BU__c && context.Account.MSPFS_MSP_Bill_to_Self__c ){
                        invoice.UNITY_Customer__c = context.AccountId;
                        invoice.UNITY_Customer_Email__c = context.Account.Account_Email__c;
                    //Izay: If the BU is MSP BU and the account has a MSP Bill to Account populated...
                    }else if(context.UNITY_Business_Unit_Account__r.MSPFS_Is_MSP_BU__c && String.isNotBlank(context.Account.MSPFS_MSP_Bill_To_Account__c)){
                        invoice.UNITY_Customer__c = context.Account.MSPFS_MSP_Bill_To_Account__c;
                        invoice.UNITY_Customer_Email__c = context.Account.MSPFS_MSP_Bill_to_Account__r.Account_Email__c;
                    //Izay: if the account is Bill to Self (NOT MSP BU)
                    }else if(context.Account.UNITY_Bill_to_Self__c ){
                        invoice.UNITY_Customer__c = context.AccountId;
                        invoice.UNITY_Customer_Email__c = context.Account.Account_Email__c;
                    //Izay: Otherwise, default to the bill to account on the site/location
                    }else{
                        invoice.UNITY_Customer__c = context.Account.UNITY_Bill_To_Account__c;
                        invoice.UNITY_Customer_Email__c = context.Account.UNITY_Bill_To_Account__r.Account_Email__c;
                    }
                //Izay: Otherwise, it is a 3rd party customer...
                }else{
                    invoice.UNITY_Customer__c = context.UNITY_Customer__c;
                    invoice.UNITY_Customer_Email__c = context.UNITY_Customer__r.Account_Email__c;
                }
            }

            invoice.UNITY_Status__c = 'Invoice Creation';
            invoice.UNITY_Customer_Service_Contract__c = context.UNITY_Customer_Service_Contract__c;
            invoice.UNITY_Service_Contract_Margin_Value__c = sContract.UNITY_Margin__c;
            invoice.UNITY_Agent__c = UserInfo.getUserId();
            invoice.UNITY_Vendor_Service_Fee__c = 0;
            invoice.UNITY_Discount_from_POs__c = this.discount_per;
            invoice.UNITY_Discount_Amount__c = this.discount_amt;
            invoice.UNITY_Business_Unit_Account__c = context.UNITY_Business_Unit_Account__c;

            insert invoice;

            invoice = [SELECT Id, UNITY_Vendor_Service_Fee__c FROM UNITY_Invoice__c WHERE Id =: invoice.Id];

            Decimal travelHoursProcessed = 0;

            List<UNITY_Invoice_Line_Item__c> invoiceLineItems = new List<UNITY_Invoice_Line_Item__c>();
            for ( WorkOrderWrapper wrapper : wrappers ) {
                if ( !wrapper.assignToInvoice ) continue;

                for ( OrderWrapper oWrapper : wrapper.oWrappers ) {
                    if ( !oWrapper.assignToInvoice || oWrapper.orderItems == null ) continue;

                    for ( OrderItem oi : oWrapper.orderItems ) {
                        if ( oi.UNITY_Not_Billable__c || generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY)==null ) continue;

                        UNITY_General_Settings__c setting = generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY);
                        //Vendor Service Fee
                        if ( oi.PricebookEntry.Product2.UNITY_Product_Type__c == setting.UNITY_Value__c ) {
                            invoice.UNITY_Vendor_Service_Fee__c -= oi.UNITY_Total_Cost__c;
                        }
                        if ( oi.PricebookEntry.Product2.UNITY_Product_Type__c != setting.UNITY_Value__c && oi.UNITY_Type__c != setting.UNITY_Value__c) {
                            if ( oi.PricebookEntry.Product2.UNITY_Product_Type__c == 'Travel' && oi.UNITY_Subtype__c == 'Hourly Rate' ) {
                                if ( travelHoursProcessed >= sContract.UNITY_Max_Allowable_Trip_Charges__c ) {
                                    continue;
                                }
                                travelHoursProcessed += oi.UNITY_Customer_Adjusted_Quantity__c;
                            }
                            UNITY_Invoice_Line_Item__c ili = new UNITY_Invoice_Line_Item__c();
                            ili.UNITY_Invoice__c = invoice.Id;
                            ili.UNITY_Total_Price__c = oi.UNITY_Total_Price__c;
                            //<AK> <TO-DO> - Cost should be Cost and Total Cost should be Total Cost ??????
                            ili.UNITY_Cost__c = oi.UNITY_Total_Cost__c;
                            ili.UNITY_Sales_Tax__c = oi.UNITY_Sales_Tax__c;
                            ili.UNITY_PO_Price__c = oi.UNITY_Price__c; 
                            ili.UNITY_Quantity__c = oi.Quantity;
            
                            if ( oi.PricebookEntry.Product2.UNITY_Product_Type__c == 'Travel' && oi.UNITY_Subtype__c == 'Hourly Rate' && travelHoursProcessed > sContract.UNITY_Max_Allowable_Trip_Charges__c ) {
                                ili.UNITY_Adjusted_Quantity__c = sContract.UNITY_Max_Allowable_Trip_Charges__c - (travelHoursProcessed - oi.UNITY_Customer_Adjusted_Quantity__c);
                            } else {
                                ili.UNITY_Adjusted_Quantity__c = oi.UNITY_Customer_Adjusted_Quantity__c;
                            }
                            //Izay: Added his additional fields to the invoice ceration
                            //to support SL Integration
                            ili.UNITY_Discount__c = oi.UNITY_Discount__c;
                            ili.UNITY_Discount_Amount__c = oi.UNITY_Discount_Amount__c;
                            ili.Product__c = oi.PricebookEntry.Product2Id;
                            ili.UNITY_Tax_Code__c = oi.UNITY_Tax_Code__c;
                            ili.UNITY_Is_Vendor_Supply__c = oi.UNITY_Is_Vendor_Supply__c;
                            ili.UNITY_GL_Revenue_Account__c = oi.UNITY_GL_Revenue_Account__c;
                            ili.UNITY_GL_Tax_Account__c = oi.UNITY_GL_Tax_Account__c;
                            ili.UNITY_GL_Sub_Account__c = oi.UNITY_GL_Sub_Account__c;
                            ili.UNITY_Type__c = oi.UNITY_Type__c;
                            ili.UNITY_Activity_Type__c = oi.UNITY_Activity_Type__c;
                            ili.UNITY_WorkOrder__c = wrapper.wo.Id;
                            ili.UNITY_Asset__c = oi.UNITY_Asset__c;
                            ili.UNITY_Description__c = oi.UNITY_Unknown_Part_Description__c;
                            ili.UNITY_PO_Has_Discount__c = (((oWrapper.order.UNITY_Discount__c != null) && (oWrapper.order.UNITY_Discount__c > 0)) ||((oWrapper.order.UNITY_Discount_Amount__c != null) && (oWrapper.order.UNITY_Discount_Amount__c > 0)));
                            ili.UNITY_Discount_from_PO__c = ((oWrapper.order.UNITY_Discount__c != null) ? oWrapper.order.UNITY_Discount__c : 0);
                            ili.UNITYPM_Is_Preventative_Maintenance__c = oi.UNITYPM_Is_Preventative_Maintenance__c;

                            if ( oi.PricebookEntry.Product2.UNITY_Product_Type__c == 'Labor' ) {
                                String minerOTStartHour = sContract.UNITY_Miner_OT_Start_Time_Hour__c;
                                String minerOTStartMinute = sContract.UNITY_Miner_OT_Start_Time_Minute__c;
                                String minerOTEndHour = sContract.UNITY_Miner_OT_End_Time_Hour__c;
                                String minerOTEndMinute = sContract.UNITY_Miner_OT_End_Time_Minute__c;
                                Decimal minerOTMultiplier = sContract.UNITY_OT_Multiplier__c;
                                Decimal minerHolidayMultiplier = sContract.UNITY_Holiday_Multiplier__c;
                            }
                            invoiceLineItems.add(ili);
                        }
                    }
                }
            }
            context.UNITY_Partial_Invoiced_User__c = u.FirstName+' '+u.LastName;
            context.Status = 'Pending Billing';
            update context;
            DataBase.insert( invoiceLineItems, false ); 
            update invoice;
        } catch (Exception ex){
            Database.rollback(sp);
            throw ex;
        } 

        List<Order> ordersToUpdateList = new List<Order>();

        for ( WorkOrderWrapper wrapper : wrappers ) {
            for ( OrderWrapper oWrapper : wrapper.oWrappers ) {
                if ( oWrapper.assignToInvoice ) {
                    oWrapper.order.UNITY_Invoiced__c = true;
                    if (invoice.id != null) {
                        oWrapper.order.UNITY_Invoice__c = invoice.id;
                    }    
                    ordersToUpdateList.add(oWrapper.order);
                }
            }
        }
        update ordersToUpdateList;

        PageReference pageRef = new PageReference('/' + context.Id);
        return pageRef;
    }

    @Future(callout=true)
    public static void callAvataxForInvoice(List<Id> invoiceIdList){
        
        if (!UNITY_Constants.isExecutingContext('UNITY_InvoiceCreationPageController.callAvataxForInvoice')){
            UNITY_CallAvatax.AvataxResult taxResult = UNITY_CallAvatax.getTaxInvoice(invoiceIdList,false);
            
            System.debug('#taxResult '+taxResult);
        
            if(!taxResult.success){
                System.debug('#error in Avatax call '+taxResult.message);
            }
        }
    }
    
    private List<WorkOrderWrapper> createWorkOrderWrappers(List<WorkOrder > workOrders, List<Order> orders, Map<Id, List<OrderItem>> orderIdToOrderItemMap){
        Set<Id> woWithOrdersIdSet = new Set<Id>();
        //.setScale(2,System.RoundingMode.HALF_DOWN)
        Decimal invTotal = 0;
        this.discount_amt = 0;
        this.discount_per = 0;
        for(Order o :orders){
            invTotal += o.UNITY_Line_Item_DIscounted_Price__c;
            System.debug('#####Izay: o.UNITY_Line_Item_DIscounted_Price__c = ' + o.UNITY_Line_Item_DIscounted_Price__c);
            this.discount_amt += (o.UNITY_Discount_Amount__c != null) ? o.UNITY_Discount_Amount__c : 0;
            woWithOrdersIdSet.add(o.FSO__WorkOrder__c);
        }
        System.debug('#####Izay: (Final) invTotal = ' + invTotal);
        //Need to calculate invoice total discount in %
        for(Order o :orders){
            Decimal thisPercent = 0;
            Decimal myRepPercent = 0;
            if(o.UNITY_Discount__c != null && o.UNITY_Discount__c != 0 && o.UNITY_Line_Item_Discounted_Price__c != 0){
                System.debug('#####Izay: o.UNITY_Discount__c = ' + o.UNITY_Discount__c);
                System.debug('#####Izay: o.UNITY_Final_Price__c = ' + o.UNITY_Final_Price__c);
                System.debug('#####Izay: o.UNITY_Line_Item_Discounted_Price__c = ' + o.UNITY_Line_Item_Discounted_Price__c);
                this.discount_per +=  o.UNITY_Line_Item_Discounted_Price__c - o.UNITY_Final_Price__c;
                System.debug('#####Izay: discount_per = ' + discount_per);
            }
        }
        System.debug('#isInvoiceableWorkOrderMap '+isInvoiceableWorkOrderMap);
        List<WorkOrderWrapper> result = new List<WorkOrderWrapper>();
        for(WorkOrder  wo : workOrders){
            if(!woWithOrdersIdSet.contains(wo.Id)){
                continue;
            }
            // Krishna
            if(isInvoiceableWorkOrderMap.get(wo.Id))result.add(new WorkOrderWrapper(wo));
        }
        
        for(Order o : orders){
            
            for(WorkOrderWrapper woWrapper : result ){
                if(o.FSO__WorkOrder__c == woWrapper.wo.Id){
                    woWrapper.oWrappers.add(new OrderWrapper(o, orderIdToOrderItemMap.get(o.Id)));
                    break;
                }
            }
            
        }
        return result;
    }
    
    public class WorkOrderWrapper{
        public List<OrderWrapper> oWrappers {get;set;}
        public String name {get;set;}
        public WorkOrder wo {get;set;}
        public Boolean assignToInvoice {get;set;}

        public WorkOrderWrapper(WorkOrder wo){
            oWrappers = new List<OrderWrapper>();
            this.name = wo.WorkOrderNumber;
            this.wo = wo;
            this.assignToInvoice = true;

        }
    }
    
    public class OrderWrapper{
        public Order order {get;set;}
        public List<OrderItem> orderItems {get;set;}
        
        public String accountName {get;set;}
        public Id accountId {get;set;}
        public Boolean invoiced {get{return order.UNITY_Invoiced__c;}}
        public Boolean assignToInvoice {get; set;}

        public OrderWrapper(Order order, List<OrderItem> orderItems){
            this.order = order;
            this.orderItems  = orderItems;
            this.accountName = order.Account.Name;
            this.assignToInvoice = true;
            this.accountId =order.AccountId;
        }
    }
}