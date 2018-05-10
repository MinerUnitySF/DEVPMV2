/**UNITY_OrderTriggerHandler
* @description: This class is the trigger handler for the Order object (Build by Miner)
*               It updates the work order status based on related order(s) status
* @programer:   SFDC
* @date:        4/17/2016 - Date deployed in prod
* @version:     1.0
* =====================================================
* Change Log
* =====================================================
* @description: Commented Out code that clears Business Unit Account when the Order is not related to a Work Order
* @programer:   Izay Ramos
* @date:        9/7/2016
* @version:     1.01
*/
public class UNITY_OrderTriggerHandler extends UNITY_BaseHandler{

    private id standardPriceBookId{get;set;}
    private List<Order> orderWithTemplate;
    private List<Id> modifiedOrderIdList = new List<Id>();
    private Map<Id, WorkOrder> relatedWorkOrderMap = new Map<Id, WorkOrder>();

    private List<Order> newUsageRequestOrders = new List<Order>();

    private List<Order> usageRequestPartVenodrIdentified = new List<Order>();
    private static Map<Id, UNITY_Service_Contract__c> vendorServiceContracts = new Map<Id, UNITY_Service_Contract__c>();
    private Map<Id,Order> ordersWithServiceFeePoliMap = new Map<Id,Order>();
    private List<OrderItem> serviceFeePolisToAdd = new List<OrderItem>();
    private List<OrderItem> serviceFeePolisToUpdate = new List<OrderItem>();

    private static Map<string,UNITY_General_Settings__c> generalSettings = UNITY_General_Settings__c.getAll();
    private static PriceBookEntry vendorServiceFeePBE;
    static {
        if(generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_NAME_CS_KEY)!=null){
            vendorServiceFeePBE = [SELECT Id, Product2Id,Pricebook2Id,UnitPrice FROM PriceBookEntry where product2Id in (select Id from product2 where name =: generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_NAME_CS_KEY).UNITY_Value__c) Limit 1];
        }
    }

    private List<Order> usageRequestSubmittedToMiner = new List<Order>();

    // store order <-> work order, where the order change from Draft to Final status and then popuate the parent
    // WO.Current_PO = child order and set WO.Action = 'Send PO'
    // key : order id
    // value : work order id
    private Map<id,id> sendPOOrders = new Map<id,id>();

    public UNITY_OrderTriggerHandler(){

        if(Test.isRunningTest()){
            standardPriceBookId = Test.getStandardPricebookId();
        }else{
            standardPriceBookId = UNITY_Constants.getStandardPriceBookId();
        }
    }

    private Map< id, id> recordIdTemplateId = new Map< id, id>();

    public override void beforeInsert(SObject so){
        system.debug('>>>>>> ORDER  HANDLER B INSERT Limits.getQueries() '+Limits.getQueries());
        Order onOrder = (Order) so;

        if(onOrder.Pricebook2Id == null){
            onOrder.Pricebook2Id = standardPriceBookId;
        }

        if (onOrder.RecordTypeId == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE){
            newUsageRequestOrders.add(onOrder);
        }

        setBusinessUnitAccount(onOrder);

    }

    public override void afterInsert(SObject  so){

        Order onOrder = (Order) so;

        //UNITYPM Exclude PM Orders
        if (!onOrder.UNITYPM_Is_WO_Preventative_Maintenance__c)
        {
            if( (onOrder.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE ) && (onOrder.UNITY_PO_Template__c != null) ){
                recordIdTemplateId.put(onOrder.id, onOrder.UNITY_PO_Template__c);
            }
        }

         modifiedOrderIdList.add(onOrder.Id);

    }

    public override void afterUpdate(SObject oldSo, SObject newSo){

        Order onOrder = (Order) newSo;
        Order onOldOrder = (Order) oldSo;

        if ((onOrder.UNITY_Total_Amount__c != onOldOrder.UNITY_Total_Amount__c) || (onOrder.UNITY_Total_Cost__c != onOldOrder.UNITY_Total_Cost__c) /*|| (onOrder.UNITY_Sales_Tax__c != onOldOrder.UNITY_Sales_Tax__c)*/ 
            || (onOrder.Status != onOldOrder.Status && onOrder.Status == 'Accepted') || (onOrder.Status != onOldOrder.Status && onOrder.Status == 'Final') 
            || (onOrder.Status != onOldOrder.Status && onOrder.Status == 'Completed')){
            modifiedOrderIdList.add(newSo.Id);
        }
        if (onOrder.Status != onOldOrder.Status && onOrder.Status == UNITY_Constants.ORDER_STATUS_PART_SOURCE_IDENTIFIED){

            usageRequestPartVenodrIdentified.add(onOrder);
        }

        if (onOrder.Status != onOldOrder.Status && onOrder.Status == UNITY_Constants.ORDER_STATUS_SUBMITTED_TO_MINER){
            usageRequestSubmittedToMiner.add(onOrder);
        }


        System.debug(LoggingLevel.INFO,'<AK> : onOrder.RecordTypeId : '+onOrder.RecordTypeId);
        System.debug(LoggingLevel.INFO,'<AK> : UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE : '+UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE);
        System.debug(LoggingLevel.INFO,'<AK> : onOrder.UNITY_Total_Cost__c : '+onOrder.UNITY_Total_Cost__c);
        System.debug(LoggingLevel.INFO,'<AK> : onOldOrder.UNITY_Total_Cost__c : '+onOldOrder.UNITY_Total_Cost__c);
        System.debug(LoggingLevel.INFO,'<AK> : vendorServiceContracts : '+vendorServiceContracts);
        System.debug(LoggingLevel.INFO,'<AK> : onOrder.UNITY_Vendor_Contract__c : '+onOrder.UNITY_Vendor_Contract__c);

        UNITY_Service_Contract__c vendorSC = vendorServiceContracts.get(onOrder.UNITY_Vendor_Contract__c);

        System.debug(LoggingLevel.INFO,'<AK> : vendorSC : '+vendorSC);
        System.debug(LoggingLevel.INFO,'<AK> : vendorServiceFeePBE : '+vendorServiceFeePBE);

        System.debug(LoggingLevel.INFO,'<AK> : ordersWithServiceFeePoliMap : '+ordersWithServiceFeePoliMap);
        System.debug(LoggingLevel.INFO,'<AK> : ordersWithServiceFeePoliMap.get(onOrder.Id) : '+ordersWithServiceFeePoliMap.get(onOrder.Id));

        if(ordersWithServiceFeePoliMap!=null
            && ordersWithServiceFeePoliMap.get(onOrder.Id) !=null
            && onOrder.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE
            && onOrder.UNITY_Total_Cost__c != onOldOrder.UNITY_Total_Cost__c){


            if (vendorSC!=null){
                Decimal finalServiceFee = 0;
                Decimal existingServiceFee = 0;
                if (!ordersWithServiceFeePoliMap.get(onOrder.Id).OrderItems.isEmpty()){
                  existingServiceFee = ordersWithServiceFeePoliMap.get(onOrder.Id).OrderItems[0].UNITY_Total_Cost__c;
                }
                Decimal orderTotalCost = onOrder.UNITY_Total_Cost__c - existingServiceFee;
                for (UNITY_Service_Contract_Line_Item__c scli: vendorSC.UNITY_Service_Contract_Line_Items__r){
                    System.debug(LoggingLevel.INFO,'<AK> : scli.UNITY_Threshold_Start__c : '+scli.UNITY_Threshold_Start__c);
                    System.debug(LoggingLevel.INFO,'<AK> : scli.UNITY_Threshold_End__c : '+scli.UNITY_Threshold_End__c);

                    if(orderTotalCost >= scli.UNITY_Threshold_Start__c && (scli.UNITY_Threshold_End__c == null || orderTotalCost <= scli.UNITY_Threshold_End__c)){
                        Decimal serviceFeePercentage = 0;
                        Decimal serviceFeeAmount = 0;

                        if (scli.UNITY_Service_Charge_Percentage__c!=null){
                            serviceFeePercentage = scli.UNITY_Service_Charge_Percentage__c;
                        }
                        if (scli.UNITY_Service_Charge_Amount__c!=null){
                            serviceFeeAmount = scli.UNITY_Service_Charge_Amount__c;
                        }
                        if ((orderTotalCost * (serviceFeePercentage/100)) >= serviceFeeAmount){
                            finalServiceFee = orderTotalCost * (serviceFeePercentage/100);
                        }else {
                            finalServiceFee = serviceFeeAmount;
                        }
                        break;
                    }
                }
                System.debug(LoggingLevel.INFO,'<AK> : finalServiceFee : '+finalServiceFee);

                if(vendorServiceFeePBE!=null && finalServiceFee>0){
                if (ordersWithServiceFeePoliMap.get(onOrder.Id).OrderItems.isEmpty()){
                    OrderItem serviceFeePoli = new OrderItem();
                    serviceFeePoli.OrderId = onOrder.Id;
                    serviceFeePoli.Quantity = 1;
                    serviceFeePoli.PricebookEntryId = vendorServiceFeePBE.Id;
                    serviceFeePoli.UnitPrice = vendorServiceFeePBE.UnitPrice;
                    serviceFeePoli.UNITY_Cost__c = 0 - finalServiceFee;
                    serviceFeePoli.UNITY_Total_Cost__c = serviceFeePoli.UNITY_Cost__c;
                    serviceFeePoli.UNITY_Vendor_Adjusted_Quantity__c = 1;
                    serviceFeePoli.UNITY_Customer_Adjusted_Quantity__c = 1;

                      if (generalSettings.get(UNITY_Constants.SERVICE_FEE_POLI_TYPE_CS_KEY)!=null){
                          serviceFeePoli.UNITY_Type__c = generalSettings.get(UNITY_Constants.SERVICE_FEE_POLI_TYPE_CS_KEY).UNITY_Value__c;
                      }

                      if (generalSettings.get(UNITY_Constants.SERVICE_FEE_POLI_ACTIVITY_TYPE_CS_KEY)!=null){
                          serviceFeePoli.UNITY_Activity_Type__c = generalSettings.get(UNITY_Constants.SERVICE_FEE_POLI_ACTIVITY_TYPE_CS_KEY).UNITY_Value__c;
                      }
                      System.debug(LoggingLevel.INFO,'<AK> : serviceFeePoli : '+serviceFeePoli);
                      serviceFeePolisToAdd.add(serviceFeePoli);
                }else{
                  OrderItem existingServiceFeePoli = ordersWithServiceFeePoliMap.get(onOrder.Id).OrderItems[0];
                  existingServiceFeePoli.UNITY_Cost__c = 0 - finalServiceFee;
                      existingServiceFeePoli.UNITY_Total_Cost__c = existingServiceFeePoli.UNITY_Cost__c;

                      System.debug(LoggingLevel.INFO,'<AK> : existingServiceFeePoli : '+existingServiceFeePoli);
                      serviceFeePolisToUpdate.add(existingServiceFeePoli);
                }
                }
            }
        }
        System.debug('#modifiedOrderIdList '+modifiedOrderIdList);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        system.debug('>>>>>> ORDER  HANDLER  B UPDATE Limits.getQueries() '+Limits.getQueries());
        Order onOrder = (Order) so;
        Order onOldOrder = (Order) oldSo;

        //UNITYPM Exclude PM Orders
        if (!onOrder.UNITYPM_Is_WO_Preventative_Maintenance__c)
        {
            if( (onOldOrder.Status == 'Draft') && (onOrder.Status == 'Final') && (onOrder.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE) )
                 sendPOOrders.put(onOrder.id, onOrder.FSO__WorkOrder__c );
        }
    }

    public override void bulkAfter(){
        if (Trigger.isInsert || Trigger.isUpdate){
            applyTemplates();
        }
        if (Trigger.isUpdate) {
            getExistingServiceFeePOLI();
            populateVendorServiceContractsMap();
        }
    }

    public override void bulkBefore(){

        if (trigger.isInsert){
            setRelatedWorkOrderMap();
            System.debug('#populateVendorServiceContract ');
            UNITY_AutopopulateChildController.autopopulateFieldsIfApplicableBulkified(Trigger.New, 'Order');
            populateVendorServiceContract();
        }
    }

    public override void andFinally(){

        if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){

            System.debug('#modifiedOrderIdList '+modifiedOrderIdList);
            if(!System.isFuture() && !System.isBatch() && !modifiedOrderIdList.isEmpty()){
                System.debug('#call UNITY_PriceCalculation.recalculateWorkOrderPricingFields ');
                UNITY_PriceCalculation.recalculateWorkOrderPricingFields(modifiedOrderIdList);
            }
        }

        if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
            popoulateFieldsInNewUsageRequestOrders();
        }

        if(trigger.isBefore && trigger.isUpdate ){
            sendPO();
        }

        if(trigger.isAfter && trigger.isUpdate){

            processUsageRequestPartVendorIdentified();
            System.debug(LoggingLevel.INFO,'<AK> : serviceFeePolisToAdd : '+serviceFeePolisToAdd);
            System.debug(LoggingLevel.INFO,'<AK> : serviceFeePolisToAdd.size() : '+serviceFeePolisToAdd.size());
            createServiceFeePolis();
            updateServiceFeePolis();
        }

        system.debug('>>>>>> ORDER  HANDLER Limits.getQueries() '+Limits.getQueries());

    }

    public void populateVendorServiceContractsMap(){
        List<Id> vendorSCIdList = new List<Id>();
        for (sObject iter: trigger.new){
            Order currentOrder = (Order)iter;
            if(vendorServiceContracts.get(currentOrder.UNITY_Vendor_Contract__c)==null)
              vendorSCIdList.add(currentOrder.UNITY_Vendor_Contract__c);
        }
        if(!vendorSCIdList.isEmpty())
          vendorServiceContracts = new Map<Id, UNITY_Service_Contract__c>([Select Id, (Select id,  UNITY_Threshold_Start__c, UNITY_Threshold_End__c, UNITY_Service_Charge_Percentage__c, UNITY_Service_Charge_Amount__c from UNITY_Service_Contract_Line_Items__r where RecordTypeId=:UNITY_Constants.SCLI_SERVICE_CHARGE_RECORDTYPE) from UNITY_Service_Contract__c where Id in :vendorSCIdList]);
    }

    public void createServiceFeePolis(){

        System.debug(LoggingLevel.INFO,'<AK> : in Create Service Fee POLI : serviceFeePolisToAdd : '+serviceFeePolisToAdd);

        if(!serviceFeePolisToAdd.isEmpty()) {
            try {
                UNITY_OrderItemTriggerHandler_Miner.isFirstTriggerRun_Before = true;
                insert serviceFeePolisToAdd;
                System.debug(LoggingLevel.INFO,'<AK> : done with insert POLI : ');
            } catch (Exception e) {
                System.debug('Error inserting Service Fee POLIs');
            }
        }
    }

    public void updateServiceFeePolis(){

        System.debug(LoggingLevel.INFO,'<AK> : in Update Service Fee POLI : serviceFeePolisToUpdate : '+serviceFeePolisToUpdate);

        if(!serviceFeePolisToUpdate.isEmpty()) {
            try {
                update serviceFeePolisToUpdate;
                System.debug(LoggingLevel.INFO,'<AK> : done with update POLI : ');

            } catch (Exception e) {
                System.debug('Error updating Service Fee POLIs');
            }

        }
    }

    public void processUsageRequestPartVendorIdentified(){

        if (!usageRequestPartVenodrIdentified.isEmpty()){
            UNITY_UsageRequestHandler.processUsageRequestPartVendorIdentified(usageRequestPartVenodrIdentified);
        }

        if (!usageRequestSubmittedToMiner.isEmpty()){
            UNITY_UsageRequestHandler.createPOFromUsageRequestBulkified(usageRequestSubmittedToMiner);
        }
    }


    public void setRelatedWorkOrderMap(){

        Set<Id> workOrderIdSet = new Set<Id>();

        for (SObject iter: trigger.new){
            workOrderIdSet.add(((Order)iter).FSO__WorkOrder__c);
        }

        List<WorkOrder> workOrderList = [select id, UNITY_Business_Unit_Account__c, UNITY_Customer_Service_Contract__c from WorkOrder where id in:workOrderIdSet];

        for (WorkOrder iter: workOrderList){
            relatedWorkOrderMap.put(iter.id, iter);
        }
    }

    public void setBusinessUnitAccount(Order orderRecord){

        if (relatedWorkOrderMap.get(orderRecord.FSO__WorkOrder__c) != null){
            orderRecord.UNITY_Business_Unit_Account__c = relatedWorkOrderMap.get(orderRecord.FSO__WorkOrder__c).UNITY_Business_Unit_Account__c;
        }
    }

    public void applyTemplates(){

        for (sObject iter: trigger.new){

            Order orderRecord = (Order)iter;

            orderWithTemplate = new List<Order>();

            if(orderRecord.UNITY_PO_Template__c  != null){
                recordIdTemplateId.put(orderRecord.id, orderRecord.UNITY_PO_Template__c );
                orderWithTemplate.add(orderRecord);
            }
        }

        UNITY_Utils.applyTemplates(recordIdTemplateId, orderWithTemplate, 'UNITY_PO_Template__c', 'Order');
    }


    /*
     * Note :
     *        For all the PO updated from Draft to Final we need to update the parent WO fields, WO.UNITY_Current_PO and WO.UNITY_Action
     *         -  WO.UNITY_Current_PO = PO.id (updated)
     *         -  WO.UNITY_Action = 'Send PO'
     *         -  if WO status is "Accepted"  change the PO status to "Accepted"
     */
    public void sendPO(){

        if(sendPOOrders.size()>0){
            Map<id,WorkOrder> workOrders = new Map<id,WorkOrder>([SELECT  id,
                                                                          UNITY_Action__c,
                                                                          UNITY_Vendor_PO_Sent_Date__c,
                                                                          UNITY_Current_PO__c,
                                                                          UNITY_PO_Review_Pending__c,
                                                                          UNITY_Vendor_Status__c
                                                                  FROM WorkOrder
                                                                  WHERE id IN :sendPOOrders.values()]);
            Map<Id,WorkOrder> toUpdate = new Map<Id,WorkOrder>();
            System.debug('#####Izay: In Send PO Method...');
            for(id orderId :sendPOOrders.keySet()){
                Order aux_order = (Order)trigger.newMap.get(orderId);
                if((workOrders.get(sendPOOrders.get(orderId)) != null))
                    if((workOrders.get(sendPOOrders.get(orderId)).UNITY_Current_PO__c != null)&&(workOrders.get(sendPOOrders.get(orderId)).UNITY_Current_PO__c != orderId) && !aux_order.MSPFS_Intercompany_Transfer__c){
                        
                        workOrders.get(sendPOOrders.get(orderId)).UNITY_Current_PO__c = orderId;

                        if(workOrders.get(sendPOOrders.get(orderId)).UNITY_Vendor_PO_Sent_Date__c!=null)
                            workOrders.get(sendPOOrders.get(orderId)).UNITY_Action__c = 'Send PO';

                        toUpdate.put(workOrders.get(sendPOOrders.get(orderId)).Id,workOrders.get(sendPOOrders.get(orderId)));

                        if(workOrders.get(sendPOOrders.get(orderId)).UNITY_Vendor_Status__c == UNITY_Constants.VENDOR_ASSIGNMENT_STATUS_ACCEPTED) 
                            aux_order.Status ='Accepted';
                    }
            }
            //Izay: To fix duplicate records when updating WOs
            update toUpdate.values();
        }
    }

    public void getExistingServiceFeePOLI(){
        System.debug(LoggingLevel.INFO,'<AK> : generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY) : '+generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY));
        System.debug(LoggingLevel.INFO,'<AK> : generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY).UNITY_Value__c : '+generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY).UNITY_Value__c);
        System.debug(LoggingLevel.INFO,'<AK> : Trigger.NewMap : '+Trigger.NewMap);

        List<Id> relevantOrderId = new List<Id>();
        ordersWithServiceFeePoliMap = new Map<Id,Order>();

        for (sObject iter: trigger.new){

            Order newOrder = (Order)iter;
            Order oldOrder = (Order)trigger.oldMap.get(iter.id);

            if ((newOrder.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE)
                && (newOrder.UNITY_Total_Cost__c != oldOrder.UNITY_Total_Cost__c)){
                relevantOrderId.add(iter.Id);
            }
        }

        if (!relevantOrderId.isEmpty()&&(generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY)!=null)){
            ordersWithServiceFeePoliMap = new Map<Id,Order>([SELECT id, (Select Id,UNITY_Cost__c,UNITY_Total_Cost__c from OrderItems where PricebookEntry.Product2.UNITY_Product_Type__c =:generalSettings.get(UNITY_Constants.SERVICE_FEE_PRODUCT_TYPE_CS_KEY).UNITY_Value__c) from Order where id in :relevantOrderId]);
        }
    }

    public void populateVendorServiceContract(){

        List<Id> vendorList = new List<Id>();

        for (sObject iter: trigger.new){

            Order currentOrder = (Order)iter;

            vendorList.add(currentOrder.UNITY_Vendor__c);
        }


        //Map<Vendor Id, ServiceContract>
        Map<Id, List<UNITY_Service_Contract__c>> vendorContractMap = new Map<Id, List<UNITY_Service_Contract__c>>();

        List<UNITY_Service_Contract__c>  vendorContractList = [Select Id, UNITY_Business_Unit__c, UNITY_Account__c, (Select id,  UNITY_Threshold_Start__c, UNITY_Threshold_End__c, UNITY_Service_Charge_Percentage__c, UNITY_Service_Charge_Amount__c from UNITY_Service_Contract_Line_Items__r where RecordTypeId=:UNITY_Constants.SCLI_SERVICE_CHARGE_RECORDTYPE) from UNITY_Service_Contract__c where UNITY_Account__c in :vendorList and UNITY_IS_Active__c = true and UNITY_Service_Contract__c.RecordTypeId =:UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE];

        for (UNITY_Service_Contract__c iter: vendorContractList){

            if (vendorContractMap.get(iter.UNITY_Account__c) == null){

                vendorContractMap.put(iter.UNITY_Account__c, new List<UNITY_Service_Contract__c>());
            }

            vendorContractMap.get(iter.UNITY_Account__c).add(iter);
        }

        for (sObject iter: trigger.new){

            Order currentOrder = (Order)iter;

            List<UNITY_Service_Contract__c> relatedVendorContract = vendorContractMap.get(currentOrder.UNITY_Vendor__c);

            if (relatedVendorContract != null){

                for (UNITY_Service_Contract__c contract: relatedVendorContract){

                    if (contract.UNITY_Business_Unit__c != null){

                        Set<String> businessUnitValues = new Set<String>(contract.UNITY_Business_Unit__c.split(';'));

                        if(businessUnitValues.contains(currentOrder.UNITY_Business_Unit__c)){
                            currentOrder.UNITY_Vendor_Contract__c = contract.Id;
                            break;
                        }
                    }
                }
            }
        }

        System.debug('#order->trigger.new '+trigger.new);
    }

    public void popoulateFieldsInNewUsageRequestOrders(){

        if (!newUsageRequestOrders.isEmpty()){
            UNITY_UsageRequestHandler.autopopulateFieldsOnOrder(newUsageRequestOrders);
        }
    }

    private void pushStockingAndDropshipPOForPartReceivedToSL(List<Order> oldOrders, List<Order> orders) {
        List<Id> stockingPoIds = new List<Id>();
        Order oldOrder, order;
        for(Integer i=0; i<orders.size(); i++) {
            oldOrder = oldOrders.get(i);
            order = orders.get(i);
            // For Stocking PO, when parts received, we push to SL immediately, no invoice needed.
            if(order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE &&
               order.UNITY_Shipment_Received__c && !oldOrder.UNITY_Shipment_Received__c) {
               stockingPoIds.add(order.Id);
            // Ensure PO receipt for Invoice (parts received)
            } else if (order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE &&
               order.UNITY_Shipment_Received__c && order.Type == 'OEM Dropship PO') {
               stockingPoIds.add(order.Id);
            }
        }
        UNITY_MuleCalloutOperation.invokeCallOut(stockingPoIds,UNITY_MuleSiteSettingUtils.PURCHASE_ORDER);
    }

}