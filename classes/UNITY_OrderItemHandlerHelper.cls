public with sharing class UNITY_OrderItemHandlerHelper {
/*
    public static void checkIsVendorSupply(Set<Id> orderItemIdList){
        
        List<OrderItem> updatedOrderLineItems = new List<OrderItem>();
        
        List<OrderItem> orderItemList = [select id, OrderId, PricebookEntry.Product2.UNITY_Product_Type__c from OrderItem where id in:orderItemIdList];
        
        Map<Id, Id> orderItemOrderMap = new Map<Id, Id>();
        
        for (OrderItem iter: orderItemList){
            
            orderItemOrderMap.put(iter.Id, iter.OrderId);        
        }
        
        List<Order> relatedOrderList = [select id, UNITY_Vendor__r.RecordTypeId, FSO__WorkOrder__r.UNITY_Assigned_Vendor__c, FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId from Order where id in:orderItemOrderMap.values()];
        
        Map<Id, Order> orderMap = new Map<Id, Order>();
        
        for (Order iter: relatedOrderList){
            
            orderMap.put(iter.Id, iter);                
        }
        
        for (OrderItem iter: orderItemList){
            
            Id relatedOrderId = orderItemOrderMap.get(iter.Id);
            
            Order relatedOrder = orderMap.get(relatedOrderId);
            
            if (iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Labor' || iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Travel'){
                
                System.debug('#relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId '+relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId);
                System.debug('#UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE '+UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE);
                
                iter.UNITY_Is_Vendor_Supply__c = (relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId == UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE);
                
                updatedOrderLineItems.add(iter);
            }
            else if (iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Part'){
                
                System.debug('#relatedOrder.UNITY_Vendor__c '+relatedOrder.UNITY_Vendor__c);
                System.debug('#relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__c '+relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__c);
                
                iter.UNITY_Is_Vendor_Supply__c = (relatedOrder.UNITY_Vendor__c == relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__c);
                
                updatedOrderLineItems.add(iter);
            }
        }
        
        update updatedOrderLineItems;
    }
    */
    // 
    public static Map<id,OrderItem> checkIsVendorSupply(Map<id,OrderItem> orderItemsMap){
        
        //List<OrderItem> updatedOrderLineItems = new List<OrderItem>();
        Map<id,OrderItem> orderItemUpdatedMap = new Map<id,OrderItem>();
        
       // List<OrderItem> orderItemList = [select id, OrderId, PricebookEntry.Product2.UNITY_Product_Type__c from OrderItem where id in:orderItemsMap.keySet()];
        List<OrderItem> orderItemList = orderItemsMap.values();
        Map<Id, Id> orderItemOrderMap = new Map<Id, Id>();
        
        for (OrderItem iter: orderItemList){
            
            orderItemOrderMap.put(iter.Id, iter.OrderId);        
        }
        
        List<Order> relatedOrderList = [select id, FSO__WorkOrder__r.RecordTypeId, UNITY_Vendor__r.RecordTypeId, FSO__WorkOrder__r.UNITY_Assigned_Vendor__c, FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId, RecordTypeId from Order where id in:orderItemOrderMap.values()];
        
        Map<Id, Order> orderMap = new Map<Id, Order>();
        
        for (Order iter: relatedOrderList){
            
            orderMap.put(iter.Id, iter);                
        }
        
        for (OrderItem iter: orderItemList){
            
            Id relatedOrderId = orderItemOrderMap.get(iter.Id);
            
            Order relatedOrder = orderMap.get(relatedOrderId);
            
            if(!iter.UNITY_Is_Vendor_Supply__c){
                if (iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Labor' || iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Travel'){
                    
                    System.debug('#relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId '+relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId);
                    System.debug('#UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE '+UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE);
                    
                    //iter.UNITY_Is_Vendor_Supply__c = (relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__r.RecordTypeId == UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE);
                    iter.UNITY_Is_Vendor_Supply__c = (relatedOrder.UNITY_Vendor__r.RecordTypeId == UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE);
                    //updatedOrderLineItems.add(iter);
                    orderItemUpdatedMap.put(iter.id, iter);
                }
                //else if (iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Part' && relatedOrder.RecordTypeId!=UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE && relatedOrder.FSO__WorkOrder__r.RecordTypeId != UNITY_Constants.WO_NON_WORK_RECORDTYPE){
                //    
                //    System.debug('#relatedOrder.UNITY_Vendor__c '+relatedOrder.UNITY_Vendor__c);
                //  iter.UNITY_Is_Vendor_Supply__c = (relatedOrder.UNITY_Vendor__c == relatedOrder.FSO__WorkOrder__r.UNITY_Assigned_Vendor__c);
                    //updatedOrderLineItems.add(iter);
                //     orderItemUpdatedMap.put(iter.id, iter);
                //}
            }
        }
        
        //update updatedOrderLineItems;
        return orderItemUpdatedMap;
    }
    
    
    public static Map<id,OrderItem> checkOrderItemFields(Map<id,OrderItem> orderItemsMap){
        
        Map<id,OrderItem> orderItemUpdatedMap = new Map<id,OrderItem>();
        
        //List<OrderItem> orderItemList = [select id, OrderId, Order.UNITY_Vendor_Contract__c, Order.FSO__WorkOrder__c, PricebookEntry.Product2.UNITY_Product_Type__c, UNITY_Customer_Holiday_Multiplier__c, UNITY_Customer_OT_Multiplier__c, UNITY_Vendor_OT_Multiplier__c, UNITY_Vendor_Holiday_Multiplier__c from OrderItem where id in:orderItemIdList];
        List<OrderItem> orderItemList = orderItemsMap.values();
        
        Map<Id, Id> orderItemWorkOrderMap = new Map<Id, Id>();
        Set<Id> vendorSCList = new Set<Id>();
        
        for (OrderItem iter: orderItemList){
            vendorSCList.add(iter.Order.UNITY_Vendor_Contract__c);
            orderItemWorkOrderMap.put(iter.Id, iter.Order.FSO__WorkOrder__c);        
        }
        
        System.debug(LoggingLevel.INFO,'<AK> : vendorSCList : '+vendorSCList);
        
        List<WorkOrder> relatedWorkOrders = [select 
                                                    id, 
                                                    UNITY_Account_Time_Zone__c,
                                                    UNITY_Work_Window_Begin__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Monday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Monday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Monday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Tuesday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Tuesday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Tuesday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Wednesday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Wednesday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Wednesday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Thursday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Thursday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Thursday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Friday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Friday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Friday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Saturday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Saturday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Saturday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Sunday_Multiplier__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Sunday_OT_End_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Sunday_OT_Start_Time__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Monday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Tuesday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Wednesday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Thursday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Friday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Saturday_No_Hours__c,
                                                    UNITY_Customer_Service_Contract__r.UNITY_Sunday_No_Hours__c
                                                    
                                            from WorkOrder where id in:orderItemWorkOrderMap.values()];
        
        Map<Id, UNITY_Service_Contract__c> VendorSCMap = new Map<Id, UNITY_Service_Contract__c>([Select 
                                                                Id, 
                                                                UNITY_Monday_Multiplier__c,
                                                                UNITY_Monday_OT_End_Time__c,
                                                                UNITY_Monday_OT_Start_Time__c,
                                                                UNITY_Tuesday_Multiplier__c,
                                                                UNITY_Tuesday_OT_End_Time__c,
                                                                UNITY_Tuesday_OT_Start_Time__c,
                                                                UNITY_Wednesday_Multiplier__c,
                                                                UNITY_Wednesday_OT_End_Time__c,
                                                                UNITY_Wednesday_OT_Start_Time__c,
                                                                UNITY_Thursday_Multiplier__c,
                                                                UNITY_Thursday_OT_End_Time__c,
                                                                UNITY_Thursday_OT_Start_Time__c,
                                                                UNITY_Friday_Multiplier__c,
                                                                UNITY_Friday_OT_End_Time__c,
                                                                UNITY_Friday_OT_Start_Time__c,
                                                                UNITY_Saturday_Multiplier__c,
                                                                UNITY_Saturday_OT_End_Time__c,
                                                                UNITY_Saturday_OT_Start_Time__c,
                                                                UNITY_Sunday_Multiplier__c,
                                                                UNITY_Sunday_OT_End_Time__c,
                                                                UNITY_Sunday_OT_Start_Time__c,
                                                                UNITY_Monday_No_Hours__c,
                                                                UNITY_Tuesday_No_Hours__c,
                                                                UNITY_Wednesday_No_Hours__c,
                                                                UNITY_Thursday_No_Hours__c,
                                                                UNITY_Friday_No_Hours__c,
                                                                UNITY_Saturday_No_Hours__c,
                                                                UNITY_Sunday_No_Hours__c
                                                            from UNITY_Service_Contract__c where id in:vendorSCList]);

        System.debug(LoggingLevel.INFO,'<AK> : VendorSCMap : '+VendorSCMap);

                                                            
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        
        for (WorkOrder iter: relatedWorkOrders){
            
            workOrderMap.put(iter.Id, iter);
        }
        
        for (OrderItem iter: orderItemList){
            
            if (iter.Order.FSO__WorkOrder__c != null){
                
                WorkOrder relatedWorkOrder = workOrderMap.get(iter.Order.FSO__WorkOrder__c);
                
                if (relatedWorkOrder.UNITY_Work_Window_Begin__c != null && relatedWorkOrder.UNITY_Account_Time_Zone__c != null){
                                        
                    String OTEndTimeFieldName = getOTFieldName(relatedWorkOrder.UNITY_Work_Window_Begin__c, 'UNITY_[DAY_OF_THE_WEEK]_OT_End_Time__c', relatedWorkOrder.UNITY_Account_Time_Zone__c);
                    String OTStartTimeFieldName = getOTFieldName(relatedWorkOrder.UNITY_Work_Window_Begin__c, 'UNITY_[DAY_OF_THE_WEEK]_OT_Start_Time__c', relatedWorkOrder.UNITY_Account_Time_Zone__c);
                    
                    String noHoursFieldName = getOTFieldName(relatedWorkOrder.UNITY_Work_Window_Begin__c, 'UNITY_[DAY_OF_THE_WEEK]_No_Hours__c', relatedWorkOrder.UNITY_Account_Time_Zone__c);
                    
                    String dayMultiplierFieldName = getDayMultiplierFieldName(relatedWorkOrder.UNITY_Work_Window_Begin__c, 'UNITY_[DAY_OF_THE_WEEK]_Multiplier__c', relatedWorkOrder.UNITY_Account_Time_Zone__c);
                    
                    String OTTime = getFormattedTime(relatedWorkOrder.UNITY_Work_Window_Begin__c, relatedWorkOrder.UNITY_Account_Time_Zone__c);
                    
                    System.debug('#OTEndTimeFieldName '+OTEndTimeFieldName);
                    System.debug('#OTStartTimeFieldName '+OTStartTimeFieldName);
                    System.debug('#dayMultiplierFieldName '+dayMultiplierFieldName);
                    System.debug('#noHoursFieldName '+noHoursFieldName);
                    System.debug('#OTTime '+OTTime);
                    
                    UNITY_Service_Contract__c customerSC = relatedWorkOrder.UNITY_Customer_Service_Contract__r;
                    UNITY_Service_Contract__c vendorSC = VendorSCMap.get(iter.Order.UNITY_Vendor_Contract__c);
    
                    System.debug(LoggingLevel.INFO,'<AK> : customerSC : '+customerSC);
                    System.debug(LoggingLevel.INFO,'<AK> : vendorSC : '+vendorSC);
    
                    
                    //Customer Contract
                    if (customerSC != null){
                        
                        String OTStartTime = (String)customerSC.get(OTStartTimeFieldName);
                        String OTEndTime = (String)customerSC.get(OTEndTimeFieldName);
                        Boolean noHours = (Boolean)customerSC.get(noHoursFieldName);
                        
                        String multiplierType = (String)customerSC.get(dayMultiplierFieldName);
                        
                        if (noHours || OTStartTime > OTTime ||  OTTime > OTEndTime){
                            
                            if (multiplierType == 'Overtime'){
                                
                                iter.UNITY_Customer_OT_Multiplier__c = true;
                            }
                            else if (multiplierType == 'Holiday'){
                                
                                iter.UNITY_Customer_Holiday_Multiplier__c = true;
                            }
                        }
                    }
                    // Vendor Contract
                    if (vendorSC != null){
                        
                        String vendorOTStartTime = (String)vendorSC.get(OTStartTimeFieldName);
                        String vendorOTEndTime = (String)vendorSC.get(OTEndTimeFieldName);
                        String vendorMultiplierType = (String)vendorSC.get(dayMultiplierFieldName);
                        Boolean noHours = (Boolean)vendorSC.get(noHoursFieldName);
                        
                        if (noHours || vendorOTStartTime > OTTime ||  OTTime > vendorOTEndTime){
                            
                            if (vendorMultiplierType == 'Overtime'){
                                
                                iter.UNITY_Vendor_OT_Multiplier__c = true;
                            }
                            else if (vendorMultiplierType == 'Holiday'){
                                
                                iter.UNITY_Vendor_Holiday_Multiplier__c = true;
                            }
                        }
                    }
                
                    orderItemUpdatedMap.put(iter.Id, iter);
                }        
            }    
        }
        
        return orderItemUpdatedMap;
    }
    
    public static Map<id,OrderItem> populateFieldsFromServiceContractLineItems(Map<id,OrderItem> orderItemsMap){
        
        Map<id,OrderItem> orderItemUpdatedMap = new Map<id,OrderItem>();
        
        List<OrderItem> orderItemList = orderItemsMap.values();
        
        Map<Id, Id> orderItemWorkOrderMap = new Map<Id, Id>();
        Set<Id> vendorSCList = new Set<Id>();
        
        for (OrderItem iter: orderItemList){
            orderItemWorkOrderMap.put(iter.Id, iter.Order.FSO__WorkOrder__c);
        }
        
        List<WorkOrder> relatedWorkOrderList = [select Id, UNITY_Include__c, UNITY_Customer_Service_Contract__c from WorkOrder where id in: orderItemWorkOrderMap.values()];
        
        Map<Id, WorkOrder> workerOrderMap = new Map<Id, WorkOrder>();
        Map<Id, Id> customerServiceContractMap = new Map<Id, Id>();
        
        for(WorkOrder iter: relatedWorkOrderList){
            if(String.isNotBlank(iter.UNITY_Customer_Service_Contract__c)){
                customerServiceContractMap.put(iter.Id, iter.UNITY_Customer_Service_Contract__c);
                workerOrderMap.put(iter.Id, iter); 
            }
        }
        
        Map<Id, Map<Id, UNITY_Service_Contract_Line_Item__c>> serviceContractLineItemMap = new Map<Id, Map<Id, UNITY_Service_Contract_Line_Item__c>>();
        
        List<UNITY_Service_Contract__c> serviceContractList = [SELECT Id, (SELECT Id,UNITY_Exclude__c,UNITY_Inclusion__c,UNITY_Product__r.Id from UNITY_Service_Contract_Line_Items__r WHERE RecordType.DeveloperName = 'UNITY_Product_Pricing') 
                                                               FROM UNITY_Service_Contract__c WHERE Id IN :customerServiceContractMap.values() AND UNITY_Contract_Sub_type__c = :UNITY_Constants.SC_CONTRACT_PRICING_STATUS];
    
        for (UNITY_Service_Contract__c iter: serviceContractList){
            
            serviceContractLineItemMap.put(iter.Id, new Map<Id, UNITY_Service_Contract_Line_Item__c>());
            
            for (UNITY_Service_Contract_Line_Item__c scli: iter.UNITY_Service_Contract_Line_Items__r){
                
                serviceContractLineItemMap.get(iter.Id).put(scli.UNITY_Product__r.Id, scli);
            }
        }
        
        System.debug('#serviceContractLineItemMap '+serviceContractLineItemMap);
        
        for (OrderItem iter: orderItemList){
            
            Id WorkOrderId = orderItemWorkOrderMap.get(iter.Id);
            
            WorkOrder relatedWO = workerOrderMap.get(WorkOrderId);
            
            Id serviceContractId = customerServiceContractMap.get(WorkOrderId);
            
            if(relatedWO != null && serviceContractId != null){
                if (iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Part'){
                    if(serviceContractId != null && serviceContractLineItemMap.containsKey(serviceContractId) && relatedWO.UNITY_Include__c){
                        if(serviceContractLineItemMap.get(serviceContractId).containsKey(iter.PricebookEntry.Product2Id)){
                            if(serviceContractLineItemMap.get(serviceContractId).get(iter.PricebookEntry.Product2Id).UNITY_Exclude__c){
                            //System.debug('Izay: Excluded because of SCLI... POLI: ' + iter.OrderItemNumber);
                            iter.UNITY_Include__c = false;
                            }else if(serviceContractLineItemMap.get(serviceContractId).get(iter.PricebookEntry.Product2Id).UNITY_Inclusion__c){
                                //System.debug('Izay: Included because of SCLI... POLI: ' + iter.OrderItemNumber);
                                iter.UNITY_Include__c = true;
                            }else{
                                //System.debug('Izay: ' + (relatedWO.UNITY_Include__c ? 'Included' : 'Excluded') + ' because of Work Order... POLI: ' + iter.OrderItemNumber);
                                iter.UNITY_Include__c = relatedWO.UNITY_Include__c;
                            }
                            orderItemUpdatedMap.put(iter.Id, iter);
                        }else{
                            iter.UNITY_Include__c = relatedWO.UNITY_Include__c;
                        }
                    }else{
                        iter.UNITY_Include__c = relatedWO.UNITY_Include__c;
                    }
                }else if(iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Labor' || iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Travel' || iter.PricebookEntry.Product2.UNITY_Product_Type__c == 'Part'){
                    iter.UNITY_Include__c = relatedWO.UNITY_Include__c;
                }
            }
        }
        
        return orderItemUpdatedMap;
    }
    
    
    public static String getOTFieldName(Datetime workWindowBegin, String fieldNameTemplate, String customerTimezone){
    
        String day = workWindowBegin.format('EEEE', customerTimezone); 
        
        String OTStrTemplate = fieldNameTemplate; 
        
        String OTFieldName = fieldNameTemplate.replace('[DAY_OF_THE_WEEK]', day);
        
        return OTFieldName;
    }
    
    public static String getDayMultiplierFieldName(Datetime workWindowBegin, String fieldNameTemplate, String customerTimezone){
        
        String day = workWindowBegin.format('EEEE', customerTimezone); 
        
        String OTStrTemplate = fieldNameTemplate; 
        
        String OTFieldName = fieldNameTemplate.replace('[DAY_OF_THE_WEEK]', day);
        
        return OTFieldName;
    }
    
    public static String getFormattedTime(Datetime workWindowBegin, String customerTimezone){
        
        return workWindowBegin.format('kk:mm', customerTimezone); 
    }
    
    public static void setPMFieldValuesBasedOnType(OrderItem item, PricebookEntry pbe){
        if(String.isNotBlank(pbe.Product2.UNITY_Product_Type__c)){
            //Defaults for all others ***LABOR***
            item.UNITY_Number_of_Techs__c = null;
            item.UNITY_Is_Vendor_Supply__c = true;
            if(pbe.Product2.UNITY_Product_Type__c.contains('Labor') ){
                item.UNITY_Type__c = 'Vendor Services';
                item.UNITY_Activity_Type__c = 'Vendor Standard Labor';
            //Default for all others ***TRAVEL***
            }else if(pbe.Product2.UNITY_Product_Type__c.contains('Travel')){
                item.UNITY_Type__c = 'Vendor Services';
                item.UNITY_Activity_Type__c = 'Vendor Standard Travel';
            //Default for ALL ***PARTS***
            }else if(pbe.Product2.UNITY_Product_Type__c.contains('Part')){
                item.UNITY_Type__c = 'Vendor Services';
                item.UNITY_Activity_Type__c = 'Field Supplies';
            //Default for ALL ***FREIGHT***
            }else if(pbe.Product2.UNITY_Product_Type__c.contains('Freight')){
                item.UNITY_Type__c = 'Parts';
                item.UNITY_Activity_Type__c = 'Freight - Service and Remodel';
            }else if(pbe.Product2.UNITY_Product_Type__c.contains('Rental')){
                item.UNITY_Type__c = 'Rental';
                item.UNITY_Activity_Type__c = 'Rental - Services and Remodel';
            }
        }            
    }
            
}