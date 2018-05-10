/*------------------------------------------------------------
Name:          AttachmentUtilities
Author:        Krishna Kameneni
Company:       Miner
Description:   This is Main utility class for Attachment object.
History:
12/16/2015     Krishna Kameneni(Perficient)    Added/Modified comments
                                               Created event handling methods
------------------------------------------------------------*/
public without sharing class UNITY_OrderUtilities{
    public static void onAfterInsert(List<Order> ordersNew) {
        UNITY_OrderUtilities.updateMissingRequiredDocumentation(ordersNew,null);
    }
    public static void onAfterUpdate(List<Order> ordersNew,Map<Id,Order>oldMap) {
        UNITY_OrderUtilities.updateMissingRequiredDocumentation(ordersNew,oldMap);
    }
    public static void onAfterDelete(List<Order> ordersNew) {
        UNITY_OrderUtilities.updateMissingRequiredDocumentation(ordersNew,null);
    }
    public static void updateMissingRequiredDocumentation(List<Order> ordersNew,Map<Id,Order>oldMap){
        system.debug('>>>>>> UNITY_OrderUtilities  BEFORE Limits.getQueries() '+Limits.getQueries());
        Set<Id> invoiceIds = new Set<Id>();
        // get the WorkOrder Ids updated / inserted to be used in the following query
        for (Order orderObj : ordersNew){
            if(oldMap==null)
                invoiceIds.add(orderObj.UNITY_Invoice__c);
            else if(orderObj.UNITY_Related_WO_Document_Compli_Text__c!=oldMap.get(orderObj.Id).UNITY_Related_WO_Document_Compli_Text__c)
                invoiceIds.add(orderObj.UNITY_Invoice__c);
        }
        if(!invoiceIds.isEmpty()) {
            List <UNITY_Invoice__c>invoices=[SELECT id ,UNITY_Missing_Required_Documentation__c, 
                                                   (Select id,UNITY_Related_WO_Document_Compli_Text__c from Orders__R )  
                                            FROM UNITY_Invoice__c 
                                            WHERE Id In :invoiceIds]; 
            List<UNITY_Invoice__c>invoicesToUpdate=new List<UNITY_Invoice__c>();
            for(UNITY_Invoice__c invoiceObj : invoices){
                boolean initialValue=invoiceObj.UNITY_Missing_Required_Documentation__c;
                invoiceObj.UNITY_Missing_Required_Documentation__c=false;
                for(Order orderObj : invoiceObj.Orders__R){
                  if(orderObj.UNITY_Related_WO_Document_Compli_Text__c ==false){
                      invoiceObj.UNITY_Missing_Required_Documentation__c=true;
                      break;
                  }
                } 
                if(initialValue!=invoiceObj.UNITY_Missing_Required_Documentation__c)
                    invoicesToUpdate.add(invoiceObj);
             }  
            update invoicesToUpdate;    
        }
        system.debug('>>>>>> UNITY_OrderUtilities AFTER Limits.getQueries() '+Limits.getQueries());
    }
    
    public static void updatePMPO(List<WorkOrder> woList){

        String errorMessage = '';

        //Check for existing PO        
        Set<Id> workOrderIds = new Set<Id>();
        for(WorkOrder wo: woList){
            workOrderIds.add(wo.Id);
        }

        List<WorkOrder> workOrders = [SELECT Id, UNITY_Assigned_Vendor__c, AccountId, UNITY_Customer__c, UNITY_Business_Unit_Account__c, UNITY_Business_Unit__c, UNITY_Vendor_Contract__c, 
         	                          (SELECT Id, UNITY_Vendor__c, Status
                                      FROM FSO__Orders__r WHERE RecordTypeId = :UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE),
                                      (SELECT Asset__c, Work_Order__c, Work_Plan__c FROM UNITYPM_Work_Order_Assets_junctions__r)
                                    FROM WorkOrder WHERE Id in :workOrderIds];
        system.debug('@@@updatePMPO workOrders:'+workOrders);

        Map<WorkOrder, Order> woOrderMap = new Map<WorkOrder, Order>();
        List<Order> ordersToUpsert = new List<Order>();
        Set<Id> ordersWithOrderItemsToDelete = new Set<Id>();

        for (WorkOrder wo: workOrders){
            boolean orderExists = false;
            if (wo.FSO__Orders__r != null && wo.FSO__Orders__r.size() > 0){
                for (Order o: wo.FSO__Orders__r){
                    if (o.UNITY_Vendor__c == wo.UNITY_Assigned_Vendor__c){
                        orderExists = true;
                        if (o.Status == 'Cancelled')
                            o.Status = 'Draft';
                        ordersWithOrderItemsToDelete.add(o.Id);
                        system.debug('@@@updatePMPO order exists! o:'+o);
                        ordersToUpsert.add(o);
                        woOrderMap.put(wo, o);
                    }
                    else {
                        o.Status = 'Cancelled';
                        ordersToUpsert.add(o);
                    }
                }
            }
            if (!orderExists){
                //If there are no records in the Work Order Assets Junction table, don't create anything
                if (wo.UNITYPM_Work_Order_Assets_junctions__r != null && wo.UNITYPM_Work_Order_Assets_junctions__r.size() > 0 && wo.UNITY_Assigned_Vendor__c != null){
                    system.debug('@@@updatePMPO order DOES NOT exists and there are no records in the Work Order Assets Junction table!');
                    Order newOrder = createPO(wo);
                    ordersToUpsert.add(newOrder);
                    woOrderMap.put(wo, newOrder);
                }
                else {
                    system.debug('@@@updatePMPO order DOES NOT exists but NO Work Order Assets Junction records!');
                }
            }            
        }
        system.debug('@@@updatePMPO ordersToUpsert'+ordersToUpsert);
        Database.UpsertResult[] resultOUpsert = Database.upsert(ordersToUpsert, false);
        system.debug('@@@updatePMPO resultOUpsert'+resultOUpsert);
        
        system.debug('@@@updatePMPO ordersWithOrderItemsToDelete'+ordersWithOrderItemsToDelete);
        //Delete existing POLIs
        if (ordersWithOrderItemsToDelete.size() > 0){
            List<OrderItem> orderItemsToDelete = [SELECT Id FROM OrderItem 
                                                    WHERE OrderID in :ordersWithOrderItemsToDelete
                                                    AND UNITYPM_Is_Preventative_Maintenance__c = true];
            delete orderItemsToDelete;
        }

        //Create POLIs
        //Get all asset id
        Set<Id> assetIds = new Set<Id>();
        for (WorkOrder wo: woOrderMap.keySet()){
            if (wo.UNITYPM_Work_Order_Assets_junctions__r == null || wo.UNITYPM_Work_Order_Assets_junctions__r.size() == 0)
                continue;
            for (UNITYPM_Work_Order_Assets_Junction__c woa: wo.UNITYPM_Work_Order_Assets_junctions__r)
                assetIds.add(woa.Asset__c);
        }                
        system.debug('@@@updatePMPO woOrderMap assetIds'+assetIds);

        List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
        for (WorkOrder wo: woOrderMap.keySet()){
            Map<Id, PricebookEntry> assetAndPBEMap = getPriceBookEntriesForAssetIds(assetIds);
            if (assetAndPBEMap.size() > 0){
                List<OrderItem> newPOLIs = createPOLIs(wo, woOrderMap.get(wo), assetAndPBEMap);
                orderItemsToUpsert.addAll(newPOLIs);
            }
        }
        system.debug('@@@updatePMPO orderItemsToUpsert'+orderItemsToUpsert);
        if (orderItemsToUpsert.size() > 0){
            Database.UpsertResult[] resultOIUpsert = Database.upsert(orderItemsToUpsert, false);
            system.debug('@@@updatePMPO resultOIUpsert'+resultOIUpsert);
            //Set pricing
            applyCustomerServiceContractPricing(orderItemsToUpsert);
        }
    }

    public static Order createPO(WorkOrder wo){
        Order newOrder = new Order();
        newOrder.RecordTypeId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
        newOrder.FSO__WorkOrder__c = wo.Id;
        newOrder.AccountId = wo.AccountId;
        newOrder.UNITY_Customer__c = wo.UNITY_Customer__c; 
        newOrder.UNITY_GL_Sub_Account__c = null;
        newOrder.UNITY_GL_Segment_Account__c = null;
        newOrder.UNITY_Business_Unit__c = wo.UNITY_Business_Unit__c;
        newOrder.UNITY_Business_Unit_Account__c = wo.UNITY_Business_Unit_Account__c;
        newOrder.UNITY_Invoiced__c = false;
        newOrder.EffectiveDate = Date.today();
        newOrder.Status = 'Draft';
        newOrder.UNITY_Vendor__c = wo.UNITY_Assigned_Vendor__c;
        newOrder.UNITY_Vendor_Contract__c = wo.UNITY_Vendor_Contract__c;
        return newOrder;
    }

    public static List<OrderItem> createPOLIs(WorkOrder wo, Order o, Map<Id, PricebookEntry> assetAndPBEMap){
        system.debug('@@@createPOLIs wo:'+wo);
        system.debug('@@@createPOLIs o:'+o);
        system.debug('@@@createPOLIs wo.UNITYPM_Work_Order_Assets_junctions__r:'+wo.UNITYPM_Work_Order_Assets_junctions__r);
        if (wo.UNITYPM_Work_Order_Assets_junctions__r == null || wo.UNITYPM_Work_Order_Assets_junctions__r.size() == 0)
            return new List<OrderItem>();

        Map<Id, OrderItem> assetOIMap = new Map<Id, OrderItem>();

        //Create PO lines based on Assets in WOLI        
        for (UNITYPM_Work_Order_Assets_Junction__c woa:wo.UNITYPM_Work_Order_Assets_junctions__r){
            if (assetOIMap.containsKey(woa.Asset__c))
                continue;
            OrderItem newOrderItem = new OrderItem();
            newOrderItem.OrderId = o.Id;
            newOrderItem.UNITY_Asset__c = woa.Asset__c;
            newOrderItem.Quantity = 1;
            newOrderItem.PricebookEntryId  = assetAndPBEMap.get(woa.Asset__c).Id;
            newOrderItem.UnitPrice = 100;
            newOrderItem.UNITY_Is_Vendor_Supply__c = true;
            UNITY_OrderItemHandlerHelper.setPMFieldValuesBasedOnType(newOrderItem, assetAndPBEMap.get(woa.Asset__c));
            newOrderitem.UNITY_Customer_Adjusted_Quantity__c = 1;
            newOrderitem.UNITY_Vendor_Adjusted_Quantity__c = 1;
            newOrderitem.UNITYPM_Is_Preventative_Maintenance__c = true;
            assetOIMap.put(woa.Asset__c, newOrderItem);
        }
        return assetOIMap.values();
    }

    public static Map<Id, PricebookEntry> getPriceBookEntriesForAssetIds(Set<Id> assetIds){
        //Get all assets
        Map<Id, Asset> assetAndTypeMap = new Map<Id, Asset>([SELECT Id, UNITY_Asset_Type__c FROM Asset WHERE Id in :assetIds]);
        system.debug('@@@updatePMPO getPriceBookEntriesForAssetIds assetAndTypeMap'+assetAndTypeMap);

        Map<String, UNITYPM_Asset_Type_Details__c> assetTypeList = UNITYPM_Asset_Type_Details__c.getAll();

        //Get asset type and product ID map
        Map<String, String> assetTypeProductMap = new Map<String, String>();
        for (UNITYPM_Asset_Type_Details__c ad: assetTypeList.values()){
            assetTypeProductMap.put(ad.Name, ad.Product_ID__c);
        }
        system.debug('@@@updatePMPO getPriceBookEntriesForAssetIds assetTypeProductMap'+assetTypeProductMap);

        //Get all PriceBookEntry
        List<PricebookEntry> pbEntryList = [SELECT Id, Pricebook2Id, Product2Id, Product2.UNITY_Product_Type__c, Product2.ProductCode, Product2.Name 
                                            FROM PriceBookEntry WHERE Product2Id in :assetTypeProductMap.values()];

        Map<Id, PricebookEntry> productPBMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe: pbEntryList){
            productPBMap.put(pbe.Product2Id, pbe);
        }

        Map<Id, PricebookEntry> assetAndPBEMap = new Map<Id, PricebookEntry>();
        for(Id assetId : assetAndTypeMap.keySet()){
            string assetType = assetAndTypeMap.get(assetId).UNITY_Asset_Type__c;
            string productId = assetTypeProductMap.get(assetType);
            PricebookEntry pbe = productPBMap.get(productId);
            if (assetid != null && pbe != null)
                assetAndPBEMap.put(assetId, pbe);
        }

        system.debug('@@@updatePMPO getPriceBookEntriesForAssetIds assetAndPBEMap'+assetAndPBEMap);

        return assetAndPBEMap;
    }

    public static List<OrderItem> applyCustomerServiceContractPricing(List<OrderItem> oiList){

        Set<id> oiIdSet = new Set<Id>();
        for (OrderItem oi: oiList){
            oiIdSet.add(oi.Id);
        }
        
        Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([SELECT Id, Order.FSO__WorkOrder__r.UNITY_Customer_Service_Contract__c, Order.FSO__WorkOrder__r.UNITY_Vendor_Contract__c, 
                                                                        UNITYPM_Is_Preventative_Maintenance__c, UNITY_Asset__c, UNITY_Asset_Type__c, PricebookEntry.Product2Id, Quantity
                                                                    FROM OrderItem WHERE Id in :oiIdSet
                                                                    ORDER BY OrderItemNumber ASC]);

        System.debug('@@@applyCustomerServiceContractPricing orderItemList:'+orderItemMap);

        Map<Id, Id> orderItemCustomerSCMap = new Map<Id, Id>();
        for (OrderItem iter: orderItemMap.values()){
            orderItemCustomerSCMap.put(iter.Id, iter.Order.FSO__WorkOrder__r.UNITY_Customer_Service_Contract__c);
        }

        System.debug('@@@applyCustomerServiceContractPricing orderItemCustomerSCMap:'+orderItemCustomerSCMap);

        Map<Id, Id> orderItemVendorSCMap = new Map<Id, Id>();
        for (OrderItem iter: orderItemMap.values()){
            orderItemVendorSCMap.put(iter.Id, iter.Order.FSO__WorkOrder__r.UNITY_Vendor_Contract__c);

        System.debug('@@@applyCustomerServiceContractPricing orderItemVendorSCMap:'+orderItemVendorSCMap);
        }

        Map<Id,UNITY_Service_Contract__c> serviceContractList = new Map<Id,UNITY_Service_Contract__c>([SELECT Id, (SELECT Id, Asset_Type__c, UNITY_Product__r.Id, RecordTypeId, UNITY_Labor_Cost__c, UNITYPM_Additional_PM_Rate__c  
                                                                    FROM UNITY_Service_Contract_Line_Items__r 
                                                                    WHERE RecordTypeId = :UNITY_Constants.SCLI_ASSET_TYPE_RATE_RECORDTYPE OR RecordTypeId = :UNITY_Constants.SCLI_PM_PRODUCT_RECORDTYPE)
                                                               FROM UNITY_Service_Contract__c WHERE (Id IN :orderItemCustomerSCMap.values() OR Id IN :orderItemVendorSCMap.values())
                                                               AND RecordTypeId = :UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE
                                                               AND UNITY_IS_Active__c = true]);
    
        system.debug('@@@applyCustomerServiceContractPricing serviceContractList'+serviceContractList);

        
        //Get customer and vendor SCLIs for each Order Item
        Map<Id, UNITY_Service_Contract_Line_Item__c> orderItemCustomerSCLIMap = new Map<Id, UNITY_Service_Contract_Line_Item__c>();
        Map<Id, UNITY_Service_Contract_Line_Item__c> orderItemVendorSCLIMap = new Map<Id, UNITY_Service_Contract_Line_Item__c>();

        for (Id orderItemId: orderItemMap.keySet()){
            OrderItem oi = orderItemMap.get(orderItemId);

            Id customerSCId = orderItemCustomerSCMap.get(orderItemId);
            UNITY_Service_Contract_Line_Item__c customerSCLI = getSCLIForOrderItem(oi, serviceContractList.get(customerSCId));
            if (customerSCLI != null)
                orderItemCustomerSCLIMap.put(oi.Id, customerSCLI);

            Id vendforSCId = orderItemVendorSCMap.get(orderItemId);
            UNITY_Service_Contract_Line_Item__c vendorSCLI= getSCLIForOrderItem(oi, serviceContractList.get(vendforSCId));
            if (vendorSCLI != null)
                orderItemVendorSCLIMap.put(oi.Id, vendorSCLI);
        }    
       
        //Apply SCLI to OrderItem

        List<OrderItem> orderItemToUpdate = new List<OrderItem>();        
        for (OrderItem oi: orderItemMap.values()){
            UNITY_Service_Contract_Line_Item__c customerSCLI = orderItemCustomerSCLIMap.get(oi.Id);
            UNITY_Service_Contract_Line_Item__c vendorSCLI = orderItemVendorSCLIMap.get(oi.Id);
            calculatePMPricing(oi, orderItemMap.values(), customerSCLI, vendorSCLI);

            if (customerSCLI != null || vendorSCLI != null)
                orderItemToUpdate.add(oi);   
        }
        update orderItemToUpdate;
        System.debug('@@@applyCustomerServiceContractPricing orderItemToUpdate:' + orderItemToUpdate);
        return orderItemToUpdate;
        

    }

    public static UNITY_Service_Contract_Line_Item__c getSCLIForOrderItem(OrderItem oi, UNITY_Service_Contract__c sc){

        System.debug('@@@applyCustomerServiceContractPricing sc:'+ sc);
        System.debug('@@@applyCustomerServiceContractPricing oi.UNITYPM_Is_Preventative_Maintenance__c:'+oi.UNITYPM_Is_Preventative_Maintenance__c);

        if (sc == null || sc.UNITY_Service_Contract_Line_Items__r == null || sc.UNITY_Service_Contract_Line_Items__r.size() == 0)
            return null;

        for (UNITY_Service_Contract_Line_Item__c scli: sc.UNITY_Service_Contract_Line_Items__r){
            System.debug('@@@applyCustomerServiceContractPricing scli.UNITY_Product__r.Id :'+scli.UNITY_Product__r.Id );
            System.debug('@@@applyCustomerServiceContractPricing oi.PricebookEntry.Product2Id:'+oi.PricebookEntry.Product2Id);

            if (  (oi.UNITYPM_Is_Preventative_Maintenance__c && scli.Asset_Type__c == oi.UNITY_Asset_Type__c && scli.RecordTypeId == UNITY_Constants.SCLI_ASSET_TYPE_RATE_RECORDTYPE)
                || (!oi.UNITYPM_Is_Preventative_Maintenance__c && scli.UNITY_Product__r.Id != null && scli.UNITY_Product__r.Id == oi.PricebookEntry.Product2Id && scli.RecordTypeId == UNITY_Constants.SCLI_PM_PRODUCT_RECORDTYPE)){
                return scli;
            }
        }
        return null;
    }

    public static UNITY_Service_Contract_Line_Item__c getSCLIForPriceBookEntry(PriceBookEntry pbe, UNITY_Service_Contract__c sc){

        if (sc == null || sc.UNITY_Service_Contract_Line_Items__r == null || sc.UNITY_Service_Contract_Line_Items__r.size() == 0)
            return null;

        for (UNITY_Service_Contract_Line_Item__c scli: sc.UNITY_Service_Contract_Line_Items__r){
            system.debug('@@@getSCLIForPriceBookEntry scli.UNITY_Product__r.Id:'+scli.UNITY_Product__r.Id);
            system.debug('@@@getSCLIForPriceBookEntry pbe.Product2Id:'+pbe.Product2Id);
            if ( (scli.UNITY_Product__r.Id != null && scli.UNITY_Product__r.Id == pbe.Product2Id)){
                system.debug('@@@getSCLIForPriceBookEntry:'+scli);
                return scli;
            }
        }
        return null;
    }

    public static OrderItem calculatePMPricing(OrderItem oi, List<OrderItem> oiList, UNITY_Service_Contract_Line_Item__c customerSCLI, UNITY_Service_Contract_Line_Item__c vendorSCLI ){

        if (oi.UNITYPM_Is_Preventative_Maintenance__c && oi.UNITY_Asset_Type__c != null){
            oi.UNITY_Price__c = (customerSCLI == null ? 0 : getAssetRate(oi, oiList, customerSCLI, false));
            system.debug('@@@calculatePMPricing PM asset rate oi.UNITY_Price__c:'+oi.UNITY_Price__c);
            system.debug('@@@calculatePMPricing PM asset rate oi.Quantity:'+oi.Quantity);
            if (oi.UNITY_Price__c != null && oi.Quantity != null)       
                oi.UNITY_Total_Price__c = oi.UNITY_Price__c * oi.Quantity;

            
            oi.UNITY_Cost__c = (vendorSCLI == null ? 0 :  getAssetRate(oi, oiList, vendorSCLI, true));
            system.debug('@@@calculatePMPricing PM asset rate oi.UNITY_Cost__c:'+oi.UNITY_Cost__c);
            system.debug('@@@calculatePMPricing PM asset rate oi.Quantity:'+oi.Quantity);     
            if (oi.UNITY_Cost__c != null && oi.Quantity != null)       
                oi.UNITY_Total_Cost__c = oi.UNITY_Cost__c * oi.Quantity;
        }
        else{
            system.debug('@@@calculatePMPricing non-PM product rate customerSCLI:'+customerSCLI);
            oi.UNITY_Price__c = (customerSCLI == null ? 0 : customerSCLI.UNITY_Labor_Cost__c);
            if (oi.UNITY_Price__c != null && oi.UNITY_Customer_Adjusted_Quantity__c != null)
                oi.UNITY_Total_Price__c = oi.UNITY_Price__c * oi.UNITY_Customer_Adjusted_Quantity__c;

            system.debug('@@@calculatePMPricing non-PM product rate vendorSCLI:'+vendorSCLI);
            oi.UNITY_Cost__c = (vendorSCLI == null ? 0 : vendorSCLI.UNITY_Labor_Cost__c);
            if (oi.UNITY_Cost__c != null && oi.UNITY_Vendor_Adjusted_Quantity__c != null)
                oi.UNITY_Total_Cost__c = oi.UNITY_Cost__c * oi.UNITY_Vendor_Adjusted_Quantity__c;
        }
        
        return oi;
    }

    public static Decimal getAssetRate(OrderItem oi, List<OrderItem> oiList, UNITY_Service_Contract_Line_Item__c scli, Boolean isCost){

        Id firstRecordIdWithSameAsset = null;
        for(OrderItem orderItem:oiList){
            if (orderItem.UNITY_Asset_Type__c == oi.UNITY_Asset_Type__c){
                firstRecordIdWithSameAsset = orderItem.Id;
                break;
            }
        }

        Boolean useAdditionalPMRate = false;
        if (firstRecordIdWithSameAsset != null && firstRecordIdWithSameAsset != oi.Id)
            useAdditionalPMRate = true;

        system.debug('@@@getAssetRate useAdditionalPMRate'+useAdditionalPMRate);

        return useAdditionalPMRate  && scli.UNITYPM_Additional_PM_Rate__c != null ? scli.UNITYPM_Additional_PM_Rate__c : scli.UNITY_Labor_Cost__c;
    }

    private class CreatePOLIException Extends Exception{}
}