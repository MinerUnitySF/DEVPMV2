/*=======================================================
* Change Log
* ========================================================
* @description: Updated synchronizeActualPoliWithZeroPoliAsync method to update the PO status when all parts are delivered
* @programmer:  Izay Ramos-Irizarry
* @date:        9/24/2015
* ========================================================
* @description: Updated synchronizeActualPoliWithZeroPoliAsync and synchronizeRelatedObjects methods
                - Fixed bug with updating Non-Work Work Orders when not related to Service Request work order
                - Optimized process
* @programmer:  Izay Ramos-Irizarry
* @date:        2/10/2017
* ========================================================
*/
public with sharing class UNITY_OrderItemHandler extends UNITY_BaseHandler{
    
    // store all the order Items that need to be queried 
    private Map<id,OrderItem> orderItemsQueried_map = new Map<id,OrderItem>();
    
    // store all the order Items to Update
    private Map<id,OrderItem> orderItemsToUpdate_map = new Map<id,OrderItem>();
    
    // Order Items for Price Calculation 
    private Map<id,OrderItem> orderItemsPriceCalculation_map = new Map<id,OrderItem>();

    // Order Items for Check Order Items (Multipliers) 
    private Map<id,OrderItem> orderItemsMultipliers_map = new Map<id,OrderItem>();

    
    // Order Items for Update Stock Quantity
    private Map<id,OrderItem> orderItemsUpdateStockQuantity_map = new Map<id,OrderItem>();
    
    // Order Items for is vendor supply
    private Map<id,OrderItem> orderItemIsVendorSupply_map    = new Map<id,OrderItem>();
    
    // Order Items to populate fields from SCLI
    private Map<id,OrderItem> orderItemToPopulateFieldsFromSCLI_map    = new Map<id,OrderItem>();
    
    // Order Items for  Populate Shimpent Received 
    private Map<id,OrderItem> orderItemsPopulateShimpentReceived_map = new Map<id,OrderItem>();
    
    private List<Id> relatedPricebookEntryList = new List<Id>();
    
    private Set<Id> updatedOrderLineItemIdSet = new Set<Id>();
    
    private List<Id> shipmentReceivedOrderItems = new List<Id>();
    
    // map order -> work order
    private Map<Id,Id> orderWoMap = new Map<Id,Id>();
    
    // map work order -> set (assets)
    private Map<Id,Set<Id>> workOrderAssetsMap = new Map<Id,Set<Id>>();
    
    // map to keep the part location with the quantity per product id
    private Map<Id,Map<Id,FSO__LocationStock__c>> locationProductQuantity = new Map<Id,Map<Id,FSO__LocationStock__c>>();
    
    /*
     * Name  : beforeInsert
     * Param : SObjct
     */
    public override void beforeInsert(SObject so){
        
        OrderItem orderProd = (OrderItem) so;
        
        //UNITYPM Exclude PM Orders
        if (!orderProd.UNITYPM_Is_WO_Preventative_Maintenance__c){
            orderProd.UNITY_Is_Part_Source_Identified__c = orderProd.UNITY_Part_Source__c != NULL;
            
            orderProd.UNITY_Invalid_Asset__c =  orderProd.UNITY_Type__c == 'Parts' &&
                                                (orderProd.UNITY_Asset__c == null ||
                                                orderWoMap.get(orderProd.OrderId) == null || 
                                                workOrderAssetsMap.get(orderWoMap.get(orderProd.OrderId)) == null ||
                                                !workOrderAssetsMap.get(orderWoMap.get(orderProd.OrderId)).contains(orderProd.UNITY_Asset__c));
           
            if(orderProd.UNITY_Order_Record_Type_Id__c == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE) {
                if(orderProd.UNITY_Order_All_Parts_On_Truck__c) {
                    orderProd.UNITY_Part_Location__c = orderProd.UNITY_WO_Truck_on_site__c;
                    orderProd.UNITY_Part_Source__c  = orderProd.UNITY_Truck_on_Site_Account__c;    
                }
                populateLocationQuantityonOrderItem(orderProd);
            }
        }
    }
    
    /*
     * Name  : beforeUpdate
     * Params : SObjct
     */
    public override void beforeUpdate(SObject oldso, SObject so){
        
        OrderItem orderProd = (OrderItem) so;
        OrderItem oldOrderProd = (OrderItem) so;
        
        //UNITYPM Exclude PM Orders
        if (!orderProd.UNITYPM_Is_WO_Preventative_Maintenance__c){
            orderProd.UNITY_Is_Part_Source_Identified__c = orderProd.UNITY_Part_Source__c != NULL;
            if(orderProd.UNITY_Order_Record_Type_Id__c == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE) {
                 populateLocationQuantityonOrderItem(orderProd);
            }
            
            
            if(orderProd.UNITY_Asset__c != null && orderProd.UNITY_Asset__c != oldOrderProd.UNITY_Asset__c) {
                orderProd.UNITY_Invalid_Asset__c =  orderProd.UNITY_Type__c == 'Parts' &&
                                                (orderProd.UNITY_Asset__c == null ||
                                                orderWoMap.get(orderProd.OrderId) == null || 
                                                workOrderAssetsMap.get(orderWoMap.get(orderProd.OrderId)) == null ||
                                                !workOrderAssetsMap.get(orderWoMap.get(orderProd.OrderId)).contains(orderProd.UNITY_Asset__c));   
            }
        }
    }
    
    /*
     * Name  : bulkBefore
     */
    public override void bulkBefore(){
        system.debug('>>>>>> ORDER ITEM HANDLER B BEFORE Limits.getQueries() '+Limits.getQueries());
        
        if (trigger.isInsert){
            UNITY_AutopopulateChildController.autopopulateFieldsIfApplicableBulkified(trigger.new, 'OrderItem');
        } 
        
        // collect all the quantity per product associated to a location
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //collect the orderId which order product are parts only
            List<Id> orderIds = new List<Id>();
            for(OrderItem orderItem : (List<OrderItem>)Trigger.new) {
                if(orderItem.UNITY_Type__c == 'Parts' && !orderItem.UNITYPM_Is_WO_Preventative_Maintenance__c)
                    orderIds.add(orderItem.OrderId);
            }
            
            if(!orderIds.isEmpty()) {
                // map order -> workorder
                for(Order order : [SELECT Id,FSO__WorkOrder__c 
                                   FROM Order 
                                   WHERE 
                                   (RecordTypeId =: UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE OR
                                   RecordTypeId =: UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE) AND
                                   Id IN :orderIds]) {
                    
                    orderWoMap.put(order.Id, order.FSO__WorkOrder__c);
                }
                
                // map work order -> set(Assets) 
                for(WorkOrderLineItem woli : [SELECT AssetId,WorkOrderId 
                                              FROM WorkOrderLineItem 
                                              WHERE WorkOrderId IN :orderWoMap.values() AND AssetId != null ]) 
                {
                    if(workOrderAssetsMap.get(woli.WorkOrderId) == null){
                        workOrderAssetsMap.put(woli.WorkOrderId, new Set<Id>());
                    }  
                    workOrderAssetsMap.get(woli.WorkOrderId).add(woli.AssetId);
                }    
            }
            
            retrieveQuantityProductPerLocation((List<OrderItem>)Trigger.new);
        }
    }
    
    /*
     * Name  : bulkAfter
     */
    public override void bulkAfter(){
        system.debug('>>>>>> ORDER ITEM HANDLER B AFTER Limits.getQueries() '+Limits.getQueries());
        
        Set<id> aux_orderItemsIdToQueryFor        = new Set<id>();
        Set<id> aux_orderItemsForPriceCalculation = new Set<id>();
        Set<id> aux_orderItemsForMultipliers      = new Set<id>();
        Set<id> aux_orderItemsForIsVendorSupply   = new Set<id>();
        Set<id> aux_orderItemsUpdateStockQuantity = new Set<id>();
        Set<id> aux_ordersTopopulateFieldsFromServiceContractLineItems = new Set<Id>();
        
        Map<String,Set<id>> aux_useOrderItemFor   = new Map<String,Set<id>>();
        
        //UNITYPM Exclude PM Orders - Map
        Map<Id,OrderItem> newOINoPMMap = new Map<Id,OrderItem>();
        if (Trigger.newMap != null){
            for (SObject sobj: Trigger.newMap.values()){
                OrderItem oi = (OrderItem)sobj;
                if (!oi.UNITYPM_Is_WO_Preventative_Maintenance__c)
                    newOINoPMMap.put(oi.Id, oi);
            }
        }
        //UNITYPM Exclude PM Orders - List
        List<OrderItem> newOINoPMList = new List<OrderItem>();
        if (Trigger.new != null){
            for (SObject sobj: Trigger.new){
                OrderItem oi = (OrderItem)sobj;
                if (!oi.UNITYPM_Is_WO_Preventative_Maintenance__c)
                    newOINoPMList.add(oi);
            }
        }
        
        if(Trigger.isInsert){
            aux_orderItemsForPriceCalculation.addAll(newOINoPMMap.keySet());
            aux_orderItemsForMultipliers.addAll(newOINoPMMap.keySet());
            aux_ordersTopopulateFieldsFromServiceContractLineItems.addAll(newOINoPMMap.keySet());
            
            for(SObject so :newOINoPMList){
                OrderItem newOI =  (OrderItem)so;
                if(!newOI.UNITY_Is_Vendor_Supply__c) 
                    aux_orderItemsForIsVendorSupply.add(newOI.id);
                if(newOI.UNITY_Part_Delivered__c || newOI.UNITY_Shipment_Received__c) 
                    aux_orderItemsUpdateStockQuantity.add(newOI.id);
            }
        }else if(Trigger.isUpdate){
            aux_orderItemsForPriceCalculation.addAll(newOINoPMMap.keySet());
            if(!UNITY_Constants.isExecutingContext('synchronizeRelatedObjects'))
                if(!System.isBatch() && !System.isFuture())
                    synchronizeRelatedObjects((List<OrderItem>)newOINoPMList);

            for(SObject so : newOINoPMList){
                OrderItem newOI =  (OrderItem)so;
                OrderItem oldOI =  (OrderItem)Trigger.oldMap.get(so.Id);//Izay: U[pdated to look at the actual old line
                if(!newOI.UNITY_Is_Vendor_Supply__c && (newOI.UNITY_Is_Vendor_Supply__c != oldOI.UNITY_Is_Vendor_Supply__c)) 
                    aux_orderItemsForIsVendorSupply.add(newOI.id);
                if((newOI.UNITY_Part_Delivered__c && (newOI.UNITY_Part_Delivered__c != oldOI.UNITY_Part_Delivered__c)) || 
                   (newOI.UNITY_Shipment_Received__c && (newOI.UNITY_Shipment_Received__c != oldOI.UNITY_Shipment_Received__c))) 
                        aux_orderItemsUpdateStockQuantity.add(newOI.id);
            }

            system.debug( '########## aux_orderItemsUpdateStockQuantity.size(): '+aux_orderItemsUpdateStockQuantity.size());
        }
        //Izay: Updated code to make it readable and check for values
        if(Trigger.isInsert || Trigger.isUpdate ){
            if(!aux_orderItemsForPriceCalculation.isEmpty()){
                aux_orderItemsIdToQueryFor.addAll(aux_orderItemsForPriceCalculation);
                aux_useOrderItemFor.put('pricecalculation', aux_orderItemsForPriceCalculation);
            }
            if(!aux_orderItemsForMultipliers.isEmpty()){
                aux_orderItemsIdToQueryFor.addAll(aux_orderItemsForMultipliers);
                aux_useOrderItemFor.put('multipliers', aux_orderItemsForMultipliers);
            }
            if(!aux_orderItemsForIsVendorSupply.isEmpty()){
                aux_orderItemsIdToQueryFor.addAll(aux_orderItemsForIsVendorSupply);
                aux_useOrderItemFor.put('isvendorsupply', aux_orderItemsForIsVendorSupply);
            }
            if(!aux_ordersTopopulateFieldsFromServiceContractLineItems.isEmpty()){
                aux_orderItemsIdToQueryFor.addAll(aux_ordersTopopulateFieldsFromServiceContractLineItems);
                aux_useOrderItemFor.put('populateFieldsFromSCLI', aux_ordersTopopulateFieldsFromServiceContractLineItems);
            }
            if(!aux_orderItemsUpdateStockQuantity.isEmpty()){
                aux_orderItemsIdToQueryFor.addAll(aux_orderItemsUpdateStockQuantity);
                aux_useOrderItemFor.put('updatestockquantity', aux_orderItemsUpdateStockQuantity);
            }

            system.debug( '########## aux_useOrderItemFor.size(): '+aux_useOrderItemFor.size());
        }

        if(!aux_orderItemsIdToQueryFor.isEmpty())
            getOrderItems(aux_orderItemsIdToQueryFor);
        if(!aux_useOrderItemFor.isEmpty())
            collectOrderItems(aux_useOrderItemFor);
    }
    
    /*
     * Name  : afterInsert
     */
    public override void afterInsert(Sobject so){
        
        System.debug('#newOrderItem '+so);
        OrderItem oi = (OrderItem)so;
        if (!oi.UNITYPM_Is_WO_Preventative_Maintenance__c){
        	relatedPricebookEntryList.add(oi.PricebookEntryId);
        	updatedOrderLineItemIdSet.add(oi.Id);
        }
    }
    
    /*
     * Name  : afterUpdate
     */
    public override void afterUpdate(Sobject so, Sobject oldSo){
        OrderItem oi = (OrderItem)so;
        OrderItem oiOld = (OrderItem)oldSo;
        
        if (!oi.UNITYPM_Is_WO_Preventative_Maintenance__c){
            
            relatedPricebookEntryList.add(oi.PricebookEntryId);
            relatedPricebookEntryList.add(oiOld.PricebookEntryId);
            
            updatedOrderLineItemIdSet.add(oi.Id);
            
        }
    }
    
    /*
     * Name  : afterDelete
     */
    public override void afterDelete(Sobject so){
        relatedPricebookEntryList.add(((OrderItem)so).PricebookEntryId);
    }
    
    /*
     * Name  : andFinally
     */
    public override void andFinally(){
        
        if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
            
            updateStockQuantity();
            setIsVendorSupply();
            checkMultiplierFields();
            populateFieldsFromSCLI();
            recalculatePricing();
            handleStockingPurchaseOrder();

            // updates only the records that where modified.
            system.debug('>>>>>> orderItemsToUpdate_map '+orderItemsToUpdate_map.size());
            updateRecords();
        }
        
        
        system.debug('>>>>>> ORDER ITEM HANDLER FINALLY Limits.getQueries() '+Limits.getQueries());
    }
    
    /*
     * Name    : getOrderItems
     * Parem 1 : Set<id> order items id 
     * Return  : Map< Order Item id  , Order Item record >
     * Note    : query for all the order items required one time, and use it for ask parent field data which is not available on the trigger context 
     */
    public Map<id,OrderItem> getOrderItems(Set<id> orderItemsId ){ 
        orderItemsQueried_map = new Map<id,OrderItem>([SELECT  id,
                                                               OrderId, 
                                                               Order.Type,
                                                               Order.RecordTypeId,
                                                               Order.RecordType.DeveloperName,
                                                               Order.UNITY_Location__c,
                                                               Order.FSO__WorkOrder__c,
                                                               Order.FSO__WorkOrder__r.UNITY_Trade__c, 
                                                               Order.FSO__WorkOrder__r.UNITY_Business_Unit__c,
                                                               Order.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId,
                                                               Order.UNITY_Vendor_Contract__c,
                                                               Order.UNITY_Vendor__r.MSPFS_Is_MSP_BU__c,
                                                               Order.UNITY_Business_Unit_Account__c,
                                                               Order.UNITY_Originating_Usage_Request__c,
                                                               Quantity,
                                                               PricebookEntry.Name, 
                                                               PricebookEntry.UnitPrice, 
                                                               PricebookEntry.Product2Id, 
                                                               PricebookEntry.Product2.UNITY_Landed_Cost__c, 
                                                               PricebookEntry.Product2.UNITY_Product_Type__c, 
                                                               PricebookEntry.Product2.Broad__c,
                                                               PricebookEntry.Product2.Unity_Is_Stockable__c,
                                                               UNITY_Vendor_Adjusted_Quantity__c, 
                                                               UNITY_Customer_Adjusted_Quantity__c, 
                                                               UNITY_Cost__c,
                                                               UNITY_Part_Delivered__c,
                                                               UNITY_Customer_OT_Multiplier__c,
                                                               UNITY_Customer_Holiday_Multiplier__c,
                                                               UNITY_Vendor_OT_Multiplier__c,
                                                               UNITY_Vendor_Holiday_Multiplier__c,
                                                               UNITY_Number_of_Techs__c,
                                                               UNITY_Price__c,
                                                               UNITY_Is_Vendor_Supply__c,
                                                               UNITY_Related_Order_Product__c,
                                                               UNITY_Part_Source__c,
                                                               UNITY_Type__c,
                                                               UNITY_Include__c,
                                                               UNITY_Shipment_Received__c,
                                                               UNITY_Actual_Quantity__c,
                                                               UNITY_Part_Location__c,
                                                               MSPFS_Technician__c,
                                                               MSPFS_Technician2__c
                                                               
                                                       FROM    OrderItem 
                                                       WHERE   id IN :orderItemsId]);
        return orderItemsQueried_map;
    }// End getOrderItems
    
    /*
     * Name    : collectOrderItems
     * Parem 1 : Set<id> order items id 
     * Note    : query for all the order items required one time, and use it for ask parent field data which is not available on the trigger context 
     */
    public void collectOrderItems(Map<String,Set<id>> userOrderItemFor ){
        
        if( (orderItemsQueried_map!=null) && !orderItemsQueried_map.isEmpty()){
            for(OrderItem onOrderItem :orderItemsQueried_map.values()){
                
                if(ckeckUseFor('isvendorsupply',onOrderItem.id,userOrderItemFor))
                    orderItemIsVendorSupply_map.put(onOrderItem.id,onOrderItem);
                if(ckeckUseFor('pricecalculation',onOrderItem.id,userOrderItemFor))         
                    orderItemsPriceCalculation_map.put(onOrderItem.id,onOrderItem);
                if(ckeckUseFor('multipliers',onOrderItem.id,userOrderItemFor) && recalculateMultipliersFilter(onOrderItem))              
                    orderItemsMultipliers_map.put(onOrderItem.id,onOrderItem);
                if(ckeckUseFor('updatestockquantity',onOrderItem.id,userOrderItemFor) && updateStockQuantityFilter(onOrderItem)) 
                    orderItemsUpdateStockQuantity_map.put(onOrderItem.id,onOrderItem);

                Boolean check = ckeckUseFor('updatestockquantity',onOrderItem.id,userOrderItemFor);

                system.debug('######## ckeckUseFor(updatestockquantity,onOrderItem.id,userOrderItemFor): '+ check);

                system.debug('######## updateStockQuantityFilter(onOrderItem): '+updateStockQuantityFilter(onOrderItem) );
                 if(ckeckUseFor('populateFieldsFromSCLI',onOrderItem.id,userOrderItemFor))
                   orderItemToPopulateFieldsFromSCLI_map.put(onOrderItem.id, onOrderItem); 
            }
        }
        system.debug('>>>> orderItemsPriceCalculation_map '+orderItemsPriceCalculation_map.size());
        system.debug('>>>> orderItemIsVendorSupply_map '+orderItemIsVendorSupply_map.size());
    }
    
    public boolean recalculateMultipliersFilter(OrderItem onOrderItem){
        
        if (trigger.isInsert && onOrderItem.Order.UNITY_Originating_Usage_Request__c == null){
            return true;
        }
        
        return false;
    }
    
    /*
     * Name    : updateRecords
     */
    public boolean ckeckUseFor(String contx, id objId, Map<String,Set<id>> userOrderItemFor){ 
        if(userOrderItemFor.get(contx) ==  null) return false;
        return userOrderItemFor.get(contx).contains(objId);
    }
    
    /*
     * Name    : updateRecords
     * //Izay: Added try catch  and check for exception type to display friendlier errors on page
     */
    public void updateRecords(){ 
        try{
            if((orderItemsToUpdate_map!=null)&&(!orderItemsToUpdate_map.isEmpty())) 
                update orderItemsToUpdate_map.values();
        }catch(Exception e){
            if(e.getTypeName() == 'System.DmlException'){
                Trigger.new[0].addError(e.getDMLMessage(0));
            }else{
                Trigger.new[0].addError(e.getMessage());
            }
        }
        
    }
    
    /*
     * Name  : recalculatePricing
     */
    public void recalculatePricing(){
        Map<id, OrderItem> aux_orderItems = new Map<id, OrderItem>();
        if (!updatedOrderLineItemIdSet.isEmpty() && !UNITY_Constants.isExecutingContext('UNITY_PriceCalculation.recalculatePricing')){
            //<AK> UNITY_PriceCalculation.recalculateOrderItemPricing(updatedOrderLineItemIdSet);
            aux_orderItems = UNITY_PriceCalculation.recalculateOrderItemPricing(orderItemsPriceCalculation_map);
            if((aux_orderItems!=null)&&(!aux_orderItems.isEmpty())){
                orderItemsToUpdate_map.putAll(aux_orderItems);
            }
        }
    }
    
    /*
     * Name  : setIsVendorSupply
     */
    public void setIsVendorSupply(){
        Map<id, OrderItem> aux_orderItems = new Map<id, OrderItem>();
        if (!updatedOrderLineItemIdSet.isEmpty() && !UNITY_Constants.isExecutingContext('Order Item -> Set Is Vendor Supply?')){
            //<AK> UNITY_OrderItemHandlerHelper.checkIsVendorSupply(updatedOrderLineItemIdSet);
            aux_orderItems = UNITY_OrderItemHandlerHelper.checkIsVendorSupply(orderItemIsVendorSupply_map);
            if((aux_orderItems!=null)&&(!aux_orderItems.isEmpty())){
                orderItemsToUpdate_map.putAll(aux_orderItems);
            }
        }
    }
    
    public void checkMultiplierFields(){
        Map<id, OrderItem> aux_orderItems = new Map<id, OrderItem>();
        if (!updatedOrderLineItemIdSet.isEmpty() && !UNITY_Constants.isExecutingContext('Order Item -> checkMultiplierFields')){
            aux_orderItems = UNITY_OrderItemHandlerHelper.checkOrderItemFields(orderItemsMultipliers_map);
            if((aux_orderItems!=null)&&(!aux_orderItems.isEmpty())){
                orderItemsToUpdate_map.putAll(aux_orderItems);
            }
        }
    }
    
    public void populateFieldsFromSCLI(){
        Map<id, OrderItem> aux_orderItems = new Map<id, OrderItem>();
        if (!updatedOrderLineItemIdSet.isEmpty() && !UNITY_Constants.isExecutingContext('Order Item -> populateFieldsFromSCLI')){
            aux_orderItems = UNITY_OrderItemHandlerHelper.populateFieldsFromServiceContractLineItems(orderItemToPopulateFieldsFromSCLI_map);
            if((aux_orderItems!=null)&&(!aux_orderItems.isEmpty())){
                orderItemsToUpdate_map.putAll(aux_orderItems);
            }
        }
        
    }
    
    /* ********************************************************************
    ******** Izay: Check if line is good to adjust inventory **************
    ********************************************************************* */
    /**This method checks if an order item is ready to adjust inventory */
    public boolean updateStockQuantityFilter(OrderItem onOrderItem){
        
        if(trigger.isInsert && trigger.isAfter){
            if(onOrderItem.UNITY_Part_Delivered__c && onOrderItem.PricebookEntry.Product2.Unity_Is_Stockable__c && 
               onOrderItem.Order.recordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE && 
               String.isNotBlank(onOrderItem.UNITY_Part_Location__c)){
                    return true;
            }else if(onOrderItem.UNITY_Shipment_Received__c && 
                     onOrderItem.PricebookEntry.Product2.Unity_Is_Stockable__c && 
                     onOrderItem.Order.recordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE &&
                     String.isNotBlank(onOrderItem.UNITY_Part_Location__c)){
                        return true;
            }
        }else if (trigger.isUpdate && trigger.isAfter){

            OrderItem oldOrderItem = (OrderItem)trigger.oldMap.get(onOrderItem.Id);

            if(oldOrderItem.UNITY_Part_Delivered__c != onOrderItem.UNITY_Part_Delivered__c && 
               onOrderItem.UNITY_Part_Delivered__c && 
               onOrderItem.PricebookEntry.Product2.Unity_Is_Stockable__c && 
               onOrderItem.Order.recordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE &&
               String.isNotBlank(onOrderItem.UNITY_Part_Location__c)){
                    return true;
            }else if(oldOrderItem.UNITY_Shipment_Received__c != onOrderItem.UNITY_Shipment_Received__c && 
                     onOrderItem.UNITY_Shipment_Received__c && 
                     onOrderItem.PricebookEntry.Product2.Unity_Is_Stockable__c && 
                     onOrderItem.Order.recordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE &&
                     String.isNotBlank(onOrderItem.Order.UNITY_Location__c)){
                        return true;
            } else if ( onOrderItem.Order.UNITY_Vendor__r.MSPFS_Is_MSP_BU__c && onOrderItem.UNITY_Part_Delivered__c &&
                    onOrderItem.UNITY_Part_Delivered__c != oldOrderItem.UNITY_Part_Delivered__c &&
                    String.IsNotBlank(onOrderItem.UNITY_Part_Location__c) && onOrderItem.Order.RecordType.DeveloperName == 'UNITY_Purchase_Order' ) {
                        return true;
            }
        }
        return false;
    }
    
    public void updateStockQuantity(){
        
        List<OrderItem> orderItems = orderItemsUpdateStockQuantity_map.values();
        system.debug('########## updateStockQuantity orderItems / '+orderItems.size());
        if(!orderItems.isEmpty()){
            
            Set<Id> productIdSet = new Set<Id>();
            Set<String> businessUnitSet = new Set<String>();//Izay: Holds the business unit ids
            Set<Id> locationIds = new Set<Id>();//Izay: Holds the location ids
            
            for(OrderItem oi : orderItems){
                System.debug('##########:Izay UNITY_Location__c = ' + oi.Order.UNITY_Location__c);
                productIdSet.add(oi.PricebookEntry.Product2Id);
                businessUnitSet.add(oi.Order.FSO__WorkOrder__r.UNITY_Business_Unit__c);
                if(oi.Order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE)
                    locationids.add(oi.Order.UNITY_Location__c);
                else if(oi.Order.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE)
                    locationids.add(oi.UNITY_Part_Location__c);
                // #############################################   
                // Izay: Need to add logic for Self Perform here
                // #############################################
            }
            
            List<FSO__LocationStock__c> stockLocations = [SELECT Id,UNITY_Business_Unit__c,FSO__Quantity__c,FSO__Product__c,UNITY_MAC__c,FSO__Location__c
                                                          FROM FSO__LocationStock__c WHERE FSO__Product__c IN: productIdSet 
                                                          AND FSO__Location__c IN :locationIds];
            Map<Id, Map<Id,FSO__LocationStock__c>> orderItemIdToLocation = new Map<Id, Map<Id,FSO__LocationStock__c>>();
            for(FSO__LocationStock__c ls : stockLocations){
                if(!orderItemIdToLocation.containsKey(ls.FSO__Location__c)){
                    orderItemIdToLocation.put(ls.FSO__Location__c,new Map<Id,FSO__LocationStock__c>());
                }
                orderItemIdToLocation.get(ls.FSO__Location__c).put(ls.FSO__Product__c,ls);
            }

            List<FSO__LocationStock__c> locationsToUpdate = new List<FSO__LocationStock__c>();
            List<FSO__LocationStock__c> locationsToInsert = new List<FSO__LocationStock__c>();
            for(OrderItem oi : orderItems){

                system.debug('########## oi: '+oi);

                if((oi.UNITY_Part_Delivered__c || oi.UNITY_Shipment_Received__c)){
                    /*if(orderItemIdToLocation.get(oi.Id) == null){
                        oi.addError('No stock location for this order item');
                    }*/
                    if(oi.Order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE){
                        system.debug('########## stocking po rec type ');
                        Boolean foundSLine = false;
                        if(orderItemIdToLocation.containsKey(oi.Order.UNITY_Location__c)){
                            if(orderItemIdToLocation.get(oi.Order.UNITY_Location__c).containskey(oi.PricebookEntry.Product2Id)){
                                foundSLine = true;
                                FSO__LocationStock__c stock = orderItemIdToLocation.get(oi.Order.UNITY_Location__c).get(oi.PricebookEntry.Product2Id);
                                Double actQty = oi.UNITY_Actual_Quantity__c != null ? oi.UNITY_Actual_Quantity__c : 0;
                                Decimal lineCost = oi.UNITY_Cost__c != null ? oi.UNITY_Cost__c : 0;
                                Double oldQty = stock.FSO__Quantity__c != null ? stock.FSO__Quantity__c : 0;
                                Double oldMAC = stock.UNITY_MAC__c != null ? stock.UNITY_MAC__c : 0;
                                Double newQty = (oldQty + actQty);
                                Double allCost = ((oldQty * oldMAC) + (actQty  * lineCost));

                                if(newQty != null && newQty !=0 && allCost != null && allCost !=0){
                                    stock.UNITY_MAC__c = (oldMAC != null && oldMAC != 0) ? allCost/newQty : allCost/(newQty-oldQty);
                                }

                                stock.FSO__Quantity__c = newQty;
                                stock.UNITY_Quantity_Update_Reason__c = 'Restocking';
                                stock.UNITY_Last_Action_PO__c = oi.OrderId;
                                stock.UNITY_Last_Purchase_Order_Quantity__c = actQty;
                                stock.UNITY_Last_Purchase_Order_Unit_Cost__c = lineCost;

                                locationsToUpdate.add(stock);
                            }
                        }
                        if(!foundSLine){
                            FSO__LocationStock__c stock = new FSO__LocationStock__c();
                            stock.FSO__Quantity__c = oi.UNITY_Actual_Quantity__c != null ? oi.UNITY_Actual_Quantity__c : oi.Quantity;
                            stock.UNITY_MAC__c = oi.UNITY_Cost__c;
                            stock.FSO__Location__c = oi.Order.UNITY_Location__c;
                            stock.FSO__Product__c = oi.PricebookEntry.Product2Id;
                            stock.UNITY_Last_Action_PO__c = oi.OrderId;
                            stock.UNITY_Quantity_Update_Reason__c = 'Restocking';
                            locationsToInsert.add(stock);
                        }
                            
                    }else if(oi.Order.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE){
                        system.debug('########## part sourcing po rec type ');
                        if(orderItemIdToLocation.containsKey(oi.UNITY_Part_Location__c)){
                            if(orderItemIdToLocation.get(oi.UNITY_Part_Location__c).containskey(oi.PricebookEntry.Product2Id)){
                                FSO__LocationStock__c stock = orderItemIdToLocation.get(oi.UNITY_Part_Location__c).get(oi.PricebookEntry.Product2Id);
                                if(stock.FSO__Quantity__c < oi.UNITY_Actual_Quantity__c){
                                    trigger.new[0].addError('Quantity is bigger than the stock');
                                }else{
                                    stock.FSO__Quantity__c = stock.FSO__Quantity__c - (oi.UNITY_Actual_Quantity__c != null ? oi.UNITY_Actual_Quantity__c : oi.Quantity);
                                    stock.UNITY_Quantity_Update_Reason__c = 'PO Usage';
                                    stock.UNITY_Last_Action_PO__c = oi.OrderId;
                                    stock.UNITY_Last_Purchase_Order_Quantity__c = oi.UNITY_Actual_Quantity__c != null ? oi.UNITY_Actual_Quantity__c : oi.Quantity;
                                    stock.UNITY_Last_Purchase_Order_Unit_Cost__c = oi.UNITY_Cost__c;
                                    locationsToUpdate.add(stock);
                                }
                            }
                        }                        
                    }
                }
            }
            try{
                if(!locationsToUpdate.isEmpty())
                    update locationsToUpdate;
                if(!locationsToInsert.isEmpty())
                    insert locationsToInsert;
            }catch(Exception e){
                orderItems[0].addError(' Error: ' + e.getMessage());
            }
            
         }
    }
    
    /*
     * Name   : shimpentReceivedOrderItemsFilter 
     * Param  : OrderItem to filter
     * Note   : this method should be called for update only 
     */
    public boolean populateShimpentReceivedOrderItemsFilter(OrderItem orderItem){
        
        OrderItem newOrderItem = (OrderItem)trigger.newMap.get(orderItem.id);
        OrderItem oldOrderItem = (OrderItem)trigger.oldMap.get(orderItem.id);
                
        System.debug('#newOrderItem '+newOrderItem);
        System.debug('#stocking record type '+orderItem.Order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE);
                    
        if (orderItem.Order.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE){ 
            if ((newOrderItem.UNITY_Shipment_Received__c != oldOrderItem.UNITY_Shipment_Received__c) && newOrderItem.UNITY_Shipment_Received__c == true){  
                //shipmentReceivedOrderItems.add(newOrderItem.Id);
                return true;
            }
        }   
        return false;   
    }
    
    /*
     * Name  : handleStockingPurchaseOrder 
     */
    public void handleStockingPurchaseOrder(){
        
        System.debug('#shipmentReceivedOrderItems '+shipmentReceivedOrderItems);
        
        if (!shipmentReceivedOrderItems.isEmpty() && !UNITY_Constants.isExecutingContext('UNITY_PriceCalculation.updateLocationStock')){
            //UNITY_PriceCalculation.updateLocationStock(orderItemsPopulateShimpentReceived_map);
        }    
    }
    
    /**
     *  Keep synchronized the poli related by field UNIYT_Order_Product field.
     *
     *  $0 POLI to Actual POLI:
     *  UNITY_Shipment_Received__c,UNITY_Actual_Quantity__c,UNITY_Actual_Ship_Date__c
     *
     *  Actual POLI to $0 POLI:
     *  UNITY_Expected_Ship_Date__c, UNITY_Shipping_Provider__c, UNITY_Tracking_Number__c, UNITY_Tracking_URL__c, UNITY_Expected_Quantity__c
     */
    @future
    private static void synchronizeActualPoliWithZeroPoliAsync(Set<Id> orderItemIds) {
        if(!orderItemIds.isEmpty()){
            List<OrderItem> orderItems = [SELECT Id,UNITY_Shipment_Received__c,UNITY_Actual_Quantity__c,UNITY_Actual_Ship_Date__c,
                                                                                UNITY_Expected_Ship_Date__c,UNITY_Shipping_Provider__c,UNITY_Tracking_Number__c, 
                                                                                UNITY_Tracking_URL__c,UNITY_Expected_Quantity__c,UNITY_Type__c,OrderId,UNITY_Related_Order_Product__c
                                                                        FROM OrderItem
                                                                        WHERE Id IN: orderItemIds];
            List<OrderItem> relatedActualAndZeroOrderItems = new List<OrderItem>();
            Set<Id> relatedOrderIds = new Set<Id>();
            Map<Id,OrderItem> relatedOrderItems = new Map<Id,OrderItem>([SELECT Id,UNITY_Shipment_Received__c,UNITY_Actual_Quantity__c,UNITY_Actual_Ship_Date__c,
                                                                                UNITY_Expected_Ship_Date__c,UNITY_Shipping_Provider__c,UNITY_Tracking_Number__c, 
                                                                                UNITY_Tracking_URL__c,UNITY_Expected_Quantity__c,UNITY_Type__c,OrderId
                                                                        FROM OrderItem
                                                                        WHERE Id IN: UNITY_Utils.joiningByFieldList(orderItems,'UNITY_Related_Order_Product__c')]);
            
            for(OrderItem orderItem : orderItems){
                relatedOrderIds.add(orderItem.OrderId);
                if(orderItem.UNITY_Related_Order_Product__c != null) {
                    OrderItem relatedOrderProduct = relatedOrderItems.get(orderItem.UNITY_Related_Order_Product__c);
                    relatedOrderIds.add(relatedOrderProduct.OrderId);
                    // check any change on these fields to prevent infinite execution of this method on update trigger.
                    if(orderItem.UNITY_Type__c == 'Non Billable'){
                        relatedOrderProduct.UNITY_Shipment_Received__c  = orderItem.UNITY_Shipment_Received__c;
                        relatedOrderProduct.UNITY_Actual_Quantity__c    = orderItem.UNITY_Actual_Quantity__c;
                        relatedOrderProduct.UNITY_Actual_Ship_Date__c   = orderItem.UNITY_Actual_Ship_Date__c;
                        relatedActualAndZeroOrderItems.add(relatedOrderProduct);
                    }else{
                        relatedOrderProduct.UNITY_Expected_Ship_Date__c = orderItem.UNITY_Expected_Ship_Date__c;
                        relatedOrderProduct.UNITY_Shipping_Provider__c  = orderItem.UNITY_Shipping_Provider__c;
                        relatedOrderProduct.UNITY_Tracking_Number__c    = orderItem.UNITY_Tracking_Number__c;
                        relatedOrderProduct.UNITY_Tracking_URL__c       = orderItem.UNITY_Tracking_URL__c;
                        relatedOrderProduct.UNITY_Expected_Quantity__c  = orderItem.UNITY_Expected_Quantity__c;
                        relatedOrderProduct.UNITY_Actual_Quantity__c    = orderItem.UNITY_Actual_Quantity__c;
                        relatedOrderProduct.UNITY_Actual_Ship_Date__c   = orderItem.UNITY_Actual_Ship_Date__c;
                        relatedActualAndZeroOrderItems.add(relatedOrderProduct);
                    }
                }
            }
            
            system.debug('Izay: relatedActualAndZeroOrderItems >>> '+ JSON.serializePretty(relatedActualAndZeroOrderItems));
            system.debug('Izay: relatedOrderIds >>> '+ JSON.serializePretty(relatedOrderIds));
            update relatedActualAndZeroOrderItems;
            List<Order> toUpdateStatus = new List<Order>();
            if(!relatedOrderIds.isEmpty()){
                List<Order> orders = [SELECT Id,UNITY_All_Parts_Delivered__c,RecordTypeId,Status FROM Order WHERE Id IN :relatedOrderIds AND RecordTypeId = :UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE];
                for(Order o :orders){
                    if(o.UNITY_All_Parts_Delivered__c){
                        o.Status = 'Completed';
                        toUpdateStatus.add(o);
                    }else if(o.Status == 'Completed'){
                        o.Status = 'Parts Being Delivered';
                        toUpdateStatus.add(o);
                    }
                }
            }
            if(!toUpdateStatus.isEmpty()){
                update toUpdateStatus;
            }
        }
    }
  
    private void synchronizeRelatedObjects(List<OrderItem> orderItemList) {
        Set<Id> orderItemChangedFieldsList = new Set<Id>();
        OrderItem oldOrderItem;
        for(OrderItem orderItem : orderItemList) {
            oldOrderItem = (OrderItem)Trigger.oldMap.get(orderItem.Id);
            if(oldOrderItem != null) {
                if(orderItem.UNITY_Type__c == 'Non Billable' && 
                   (orderItem.UNITY_Shipment_Received__c != oldOrderItem.UNITY_Shipment_Received__c ||
                   orderItem.UNITY_Actual_Quantity__c != oldOrderItem.UNITY_Actual_Quantity__c ||
                   orderItem.UNITY_Actual_Ship_Date__c != oldOrderItem.UNITY_Actual_Ship_Date__c)) {
                       orderItemChangedFieldsList.add(orderItem.Id);
                   } 
                else if(orderItem.UNITY_Expected_Ship_Date__c != oldOrderItem.UNITY_Expected_Ship_Date__c ||
                        orderItem.UNITY_Shipping_Provider__c != oldOrderItem.UNITY_Shipping_Provider__c ||
                        orderItem.UNITY_Tracking_Number__c != oldOrderItem.UNITY_Tracking_Number__c ||
                        orderItem.UNITY_Tracking_URL__c != oldOrderItem.UNITY_Tracking_URL__c ||
                        orderItem.UNITY_Expected_Quantity__c != oldOrderItem.UNITY_Expected_Quantity__c ||
                        orderItem.UNITY_Shipment_Received__c != oldOrderItem.UNITY_Shipment_Received__c ||
                        orderItem.UNITY_Actual_Quantity__c != oldOrderItem.UNITY_Actual_Quantity__c ||
                        orderItem.UNITY_Actual_Ship_Date__c != oldOrderItem.UNITY_Actual_Ship_Date__c
                       ) {
                           orderItemChangedFieldsList.add(orderItem.Id);
                       }
            } 
        }
        if(!orderItemChangedFieldsList.isEmpty()/* && !System.isFuture()*/) {
            System.debug(' >>> serialize for : '+orderItemChangedFieldsList);
            synchronizeActualPoliWithZeroPoliAsync(orderItemChangedFieldsList);
        }
    }
    
    private void retrieveQuantityProductPerLocation(List<OrderItem> orderItems) {
        System.debug('<RB> orderItems :' + orderItems);
        List<Id> productIds = new List<Id>();
        for(OrderItem orderItem : (List<OrderItem>) Trigger.new) {
            if(orderItem.UNITY_Order_Record_Type_Id__c   == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE) {
                productIds.add(orderItem.UNITY_Product_Id__c);   
            }
        }
        System.debug('<RB> productIds :' + productIds);
        if(!productIds.isEmpty()) {
            // retrieve the location with their location stock for these product ids for the current orderitem
            for(FSO__Location__c location : [SELECT Id, 
                                         (SELECT Id,FSO__Product__c,FSO__Quantity__c  
                                          FROM FSO__LocationStocks__r
                                          WHERE FSO__Product__c IN: productIds AND
                                                FSO__Quantity__c != null) 
                                         FROM FSO__Location__c 
                                         WHERE Id IN :UNITY_Utils.joiningByFieldList(Trigger.new, 'UNITY_Part_Location__c')]) 
            {
                if(locationProductQuantity.get(location.Id) == null) {
                    locationProductQuantity.put(location.Id, new Map<Id,FSO__LocationStock__c>());
                }
                for(FSO__LocationStock__c  locationStock : location.FSO__LocationStocks__r){
                    locationProductQuantity.get(location.Id).put(locationStock.FSO__Product__c,locationStock);   
                }
            }
            System.debug('<RB> locationProductQuantity :' + locationProductQuantity);
        }
    }
    
    private void populateLocationQuantityonOrderItem(OrderItem orderItem) {
        System.debug('<RB> orderItem :' + orderItem);
        if(
           orderItem.UNITY_Product_Id__c != NULL &&
           orderItem.UNITY_Part_Location__c != NULL && 
           locationProductQuantity.get(orderItem.UNITY_Part_Location__c) != NULL &&
           locationProductQuantity.get(orderItem.UNITY_Part_Location__c).get(orderItem.UNITY_Product_Id__c) != NULL) 
        {
            FSO__LocationStock__c currentLocationStock = locationProductQuantity.get(orderItem.UNITY_Part_Location__c).get(orderItem.UNITY_Product_Id__c);
            orderItem.UNITY_Location_AvailableQuantity__c = currentLocationStock.FSO__Quantity__c;
            orderItem.UNITY_Location_QOH_LastChecked__c = Datetime.now();
        }
    }
    
}