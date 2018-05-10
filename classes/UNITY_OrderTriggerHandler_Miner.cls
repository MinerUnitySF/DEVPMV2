/**UNITY_OrderTriggerHandler_Miner
* @description: This class is the trigger handler for the Order object (Build by Miner)
*               It updates the work order status based on related order(s) status
* @programer:   Izay Ramos-Irizarry
* @date:        3/30/2016
* @version:     1.0
* =====================================================
* Change Log
* =====================================================
* @description: Removed commented out code that is no longer needed. Added comments to methods
* @programer:   Izay Ramos
* @date:        9/1/2016
* @version:     1.01
* =====================================================
* @description: - Added support for Stocking POs to populate Vendor Service Contract
*               - Added support to Set/Validate GL Mapping on Stocking POs
* @programer:   Izay Ramos
* @date:        9/7/2016
* @version:     1.01
* =====================================================
* @description: - Added condition to exclude Customer Only line items from Line Item subquery in validateNoZeroPartLines method
* @programer:   Dan Cobb
* @date:        10/19/2016
* =====================================================
* @description: - Updated shareOrder method to share usage request submitted to Miner with team on work order
* @programer:   Izay Ramos
* @date:        4/28/2017
* =====================================================
*/
public class UNITY_OrderTriggerHandler_Miner extends UNITY_BaseHandler{
    
    private static Map<Id,RecordType> orderRTs;//Map to hold all Order record types
    private static Map<Id,RecordType> woRTs;//Map to hold all WorkOrder record types
    //Set the maps above
    static{
        if(orderRTs == null){
            orderRTs = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM recordType WHERE SObjectType = 'Order']);
        }
        if(woRTs == null){
            woRTs = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM recordType WHERE SObjectType = 'WorkOrder']);
        }
    }
    /**Method to execute on Order trigger BEFORE context
    */ 
    public override void bulkBefore(){
        if(runTriggerOnce_Before()){
            String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
            String poPSRTId = UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE;
            String poStockRTId = UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE;
            List<Order> setGLOrders = new List<Order>();//Order that need the gl sub account populated
            List<Order> setShippingInfo = new List<Order>();//Orders that need shipping info from usage request
            List<Order> setVendorContract = new List<Order>();//Orders that need the vendor service contract populated... Stocking POs Only
            List<Order> finalPMOrders = new List<Order>();//The PM orders which status changed to final  added by neli
            	
            for(SObject s :trigger.new){
                Order o = (Order)s;
                if(String.isBlank(o.UNITY_GL_Segment_Account__c) || String.isBlank(o.UNITY_GL_Sub_Account__c)){
                    setGLOrders.add(o);
                }
                if(Trigger.isInsert && String.isNotBlank(o.UNITY_Originating_Usage_Request__c) && (o.RecordTypeId == poRTId || o.RecordTypeId == poPSRTId) && !o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                    setShippingInfo.add(o);
                }
                if(Trigger.isUpdate && String.isNotBlank(o.UNITY_Vendor__c) && String.isBlank(o.UNITY_Vendor_Contract__c) && !o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                    setVendorContract.add(o);
                }
                
                if(Trigger.isUpdate && o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                    Order oldO = (Order)trigger.oldMap.get(o.Id);
                     system.debug('#####   neli BEFORE o.Status >>  #### ' + o.Status);
                    if(o.Status != oldO.Status){
                        if(o.Status == 'Final'){
                            finalPMOrders.add(o);
                        }
                    }
                }
            }
            if(!setGLOrders.isEmpty()){
                setGLSubAccount(setGLOrders);
            }
            if(!setShippingInfo.isEmpty()){
                setShippingInfo(setShippingInfo);
            }
            if(!setVendorContract.isEmpty()){
                setVendorContract(setVendorContract,UNITY_Constants.ContractType.SERVICE_REQUEST);
            }
             if(!setShippingInfo.isEmpty()){
                setShippingInfo(setShippingInfo);
            }
            
            system.debug('#####   neli BEFORE finalPMOrders >>  #### ' + finalPMOrders.size());
            if (!finalPMOrders.isEmpty())
               updatePMorder(finalPMOrders);
        }
    }
    /**Method to execute on Order trigger AFTER context
    */ 
    public override void bulkAfter(){
        if(Trigger.isUpdate || Trigger.isInsert){
            //Validate that POs with Part Lines that should not be $0 are not $0
            validateNoZeroPartLines();
            //Set to set shipping info to lines
            List<Order> propagateShippingInfo = new List<Order>();//The Orders that need Shipping Info to be propagated to their Order Items 
            List<Order> changedStatus = new List<Order>();//The orders that changed status to update WO status
            Set<Id> woIds = new Set<Id>();//Holds the work order ids for the changed orders. Also used on insert to share PO with MSP BU.
            Set<Id> finalOrderIds = new Set<Id>();//The ids for orders which status changed to final
            List<Order> finalOrders = new List<Order>();//The orders which status changed to final
            Set<Id> needTax = new Set<Id>();//The ids for the Orders that need tax calculated
            List<Order> validateShippingInfo = new List<Order>();//The orders that need validation for missing shipping info
            Set<Id> shipmentReceived = new Set<Id>();//Holds order ids for shipment received orders
            Set<Id> partSourceIdentified = new Set<Id>();//Holds order ids for part sourcing POs that go to Parts Source Identified
            List<Order> intercompanyShare = new List<Order>();//Hold orders that may need to be sharing with MSP or Asset Light BUs
			List<Order> shareToVendorOrderList = new List<Order>(); //Orders that has a vendor
			List<Order> unshareToVendorOrderList = new List<Order>(); //Orders that no longer belong to a certain vendor 
			
			List<Order> finalPMOrders = new List<Order>();//The PM orders which status changed to final  added by neli
			Set<Id> pmWoIds = new Set<Id>();//Holds the PM work order ids for the changed orders.  
			 
            //Get work order id for any order that changed status or any new order
            for(SObject s :trigger.new){
                Order o = (Order)s;
                if(trigger.isInsert){
                    //UNITYPM Exclude PM Orders
                    if (!o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                        if (o.FSO__WorkOrder__c != null){
                            changedStatus.add(o);
                            woIds.add(o.FSO__WorkOrder__c);
                            if(String.isNotBlank(o.UNITY_Related_Work_Order_Id__c))
                                woIds.add(o.UNITY_Related_Work_Order_Id__c);
                        }    
                        intercompanyShare.add(o);
                    }
					//if ((o.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE || o.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE) 
                    //    && (o.UNITY_Vendor__c != null)  
                    //	&& isInvoiceable(o.Status)){
                    //	shareToVendorOrderList.add(o);
                    //} 
                    
                    //added by neli
                	if ((o.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE || 
                	        o.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE || o.UNITYPM_Is_WO_Preventative_Maintenance__c) 
                                  && (o.UNITY_Vendor__c != null)  
                                          	&& isInvoiceable(o.Status)){
                    	shareToVendorOrderList.add(o);
                    }    
                    
                }else if(trigger.isUpdate){
                    Order oldO = (Order)trigger.oldMap.get(o.Id);
                    if(o.Status != oldO.Status){
                        //UNITYPM Exclude PM Orders 
                        if (o.FSO__WorkOrder__c != null && !o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                            changedStatus.add(o);
                            woIds.add(o.FSO__WorkOrder__c);
                            if(String.isNotBlank(o.UNITY_Related_Work_Order_Id__c))
                                woIds.add(o.UNITY_Related_Work_Order_Id__c);
                        }
                        if ( oldO.Status == 'Draft' && o.Status == 'Accepted'){
                           system.debug('##### added by neli      ####');
                            if (o.UNITYPM_Is_WO_Preventative_Maintenance__c) {   
                                   finalPMOrders.add(o);
                                   pmWoIds.add(o.FSO__WorkOrder__c);
                            }
                        }
                        if(o.Status == 'Final'){ // UNITY_Constants.ORDER_STATUS_FINAL){
                            finalOrderIds.add(o.Id);
                            //UNITYPM Exclude PM Orders - no NTE Checking
                            if(o.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE && !o.UNITYPM_Is_WO_Preventative_Maintenance__c){
                                pmWoIds.add(o.FSO__WorkOrder__c);
                                finalOrders.add(o);
                            }
                        }else if(o.Status == UNITY_Constants.ORDER_STATUS_PART_ORDER_REQUIRED && o.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE){
                            finalOrderIds.add(o.Id);
                        }else if(o.Status == 'Parts Being Delivered' && o.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE){
                            validateShippingInfo.add(o);
                        }else if(o.Status == UNITY_Constants.ORDER_STATUS_PART_SOURCE_IDENTIFIED && o.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE){
                            partSourceIdentified.add(o.Id);
                        }
                    }
                    if(o.UNITY_Actual_Arrival_Date__c != oldO.UNITY_Actual_Arrival_Date__c || 
                       o.UNITY_Expected_Arrival_Date__c != oldO.UNITY_Expected_Arrival_date__c || 
                       o.UNITY_Tracking_Number__c != oldO.UNITY_Tracking_Number__c || 
                       o.UNITY_Shipping_Provider__c != oldO.UNITY_Shipping_Provider__c){
                           //UNITYPM Exclude PM Orders
                           if (!o.UNITYPM_Is_WO_Preventative_Maintenance__c)
                           		propagateShippingInfo.add(o);
                       }
                    if((((o.UNITY_Final_Price__c != oldO.UNITY_Final_Price__c) || (!o.UNITY_Tax_Processed__c)) && (o.Status == 'Draft' || o.Status == 'Parts Order Required' || o.Status == 'Part Cost Required')) &&
                       (o.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE || o.RecordTypeId == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE || o.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE)){
                           needTax.add(o.Id);
                       }
                    if(o.RecordTypeId == UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE && o.UNITY_Shipment_Received__c){
                        shipmentReceived.add(o.id);
                    }
                    //Izay: Share PO
                    if(o.RecordTypeId == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE && o.Status == 'Submitted to Miner'){
                        intercompanyShare.add(o);
                    }
                    
                    //added by neli
                 
                    if (o.RecordTypeId == UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE || o.RecordTypeId == UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE 
                                                                         || o.UNITYPM_Is_WO_Preventative_Maintenance__c){
	                    //if Vendor changed or just got populated 
	                    if (isInvoiceable(o.Status) && ((oldO.UNITY_Vendor__c == null && o.UNITY_Vendor__c != null) || (oldO.UNITY_Vendor__c != o.UNITY_Vendor__c))){
	                    	shareToVendorOrderList.add(o);
	                    	if (oldO.UNITY_Vendor__c != o.UNITY_Vendor__c)
	                    		unshareToVendorOrderList.add(oldO);
	                    }
	                    //if Status changed from invoice-able to non-invoiceable
	                    if (o.UNITY_Vendor__c != null && oldO.Status != o.Status){
	                    	//if new status is invoice-able && old status was not invoice-able
							if (isInvoiceable(o.Status) && !isInvoiceable(oldO.Status))
	                    		shareToVendorOrderList.add(o);
	                    	if (!isInvoiceable(o.Status) && isInvoiceable(oldO.Status))
	                    		unshareToVendorOrderList.add(o);
	                    }	                    
                    }
                }
            }
            if(!woIds.isEmpty()){
                updateWorkOrderStatus(woIds,changedStatus);
            }
            if(!finalOrderIds.isEmpty()){
                validateGLAccounts(finalOrderIds);
            }
            if(!propagateShippingInfo.isEmpty()){
                setTrackingInfoToLineItem(propagateShippingInfo);
            }
            if(!finalOrders.isEmpty()){
                checkNTE(finalOrders);
            }
            if(!validateShippingInfo.isEmpty()){
                validateShippingInfo(validateShippingInfo);
            }
            if(!needTax.isEmpty()){
                if(!System.isFuture() && !System.isBatch()){
                    UNITY_OrderItemTriggerHandler_Miner.callGettaxPO(needTax);
                }
            }
            if(!shipmentReceived.isEmpty() && !System.isFuture()){
                handleShipmentReceived(shipmentReceived);
            }
            if(!partSourceIdentified.isEmpty()){
                validateSourceIdentified(partSourceIdentified);
            }
            if(!intercompanyShare.isEmpty() && UNITY_OrderTriggerHandler_Miner.shareOrderOnce()){
                shareOrder(intercompanyShare);
            }
            
            if (!shareToVendorOrderList.isEmpty())
            	UNITY_OrderTriggerHandler_NoSharing.shareOrderToVendor(shareToVendorOrderList);
         
            if (!unshareToVendorOrderList.isEmpty())
            	UNITY_OrderTriggerHandler_NoSharing.unShareOrderToVendor(unshareToVendorOrderList); 
            
            if (!finalPMOrders.isEmpty() && !pmWoIds.isEmpty())
                updatePMorderAndworkOrder(pmWoIds,finalPMOrders);
        }
    }
    
    //added by Neli
      //added by Neli
    private static void updatePMorder( List<Order> finalPMOrders){
        List<Order> oUpdate = new List<Order>();
          for(Order o :finalPMOrders){
               o.Status = 'Accepted';
           }
    }
      
     private static void updatePMorderAndworkOrder(Set<ID> pmWoIDs, List<Order> finalPMOrders){
        Map<Id,WorkOrder> wosMap = new Map<Id,WorkOrder>([SELECT Id,Status,RecordTypeId,UNITY_Accepted_Vendor__c, UNITY_Current_PO__c, UNITY_Assigned_Vendor__c
                                               FROM WorkOrder 
                                                   WHERE Id IN :pmWoIDs]); 
          List<WorkOrder> woUpdate = new List<WorkOrder>();                                         
       
          for(Order o :finalPMOrders){
            if(wosMap.containsKey(o.FSO__WorkOrder__c)){ 
                 wosMap.get(o.FSO__WorkOrder__c).Status = 'Assigned';
                 wosMap.get(o.FSO__WorkOrder__c).UNITY_Vendor_Status__c = 'Accepted';
                 wosMap.get(o.FSO__WorkOrder__c).UNITY_Accepted_Vendor__c = wosMap.get(o.FSO__WorkOrder__c).UNITY_Assigned_Vendor__c; // o.UNITY_Assigned_Vendor__c; 
                 wosMap.get(o.FSO__WorkOrder__c).UNITY_Current_PO__c =  o.ID;
                 wosMap.get(o.FSO__WorkOrder__c).UNITY_Vendor_Accept_Date__c = System.now(); //???
                 woUpdate.add(wosMap.get(o.FSO__WorkOrder__c));
            }
          }
  
         try{
             if (woUpdate.size() > 0)
               update woUpdate;
         }
         catch (Exception ex){
           trigger.new[0].addError('An error occurred while updating the work order status. Error: ' + ex.getMessage());
         }
    }
    
    /**This method updates the Work Order status based on PO Status
    *@param woids - List<Id>: The ids for the work orders to update the status
    */
  
    public static void updateWorkOrderStatus(Set<Id> woIds,List<Order>thisOrds){
        //get the values from the custom setting
        List<UNITY_Status_Fields_Update_Map__c> statusMapping = UNITY_Status_Fields_Update_Map__c.getAll().values();
        Map<String,UNITY_Status_Fields_Update_Map__c> toStatusMap = new Map<String,UNITY_Status_Fields_Update_Map__c>();
        //Find all mapping from order to work order
        for(UNITY_Status_Fields_Update_Map__c sMap :statusMapping){
            if(sMap.UNITY_Origin_Object__c == 'Order' && sMap.UNITY_Target_Object__c == 'WorkOrder'){
                toStatusMap.put(sMap.UNITY_Origin_Value__c+'-'+sMap.UNITY_Origin_Record_Type__c+'-'+sMap.UNITY_Target_Record_Type__c,sMap);
            }
        }
        //get all the work orders for the orders that changed status
        Map<Id,WorkOrder> wosMap = new Map<Id,WorkOrder>([SELECT Id,Status,RecordTypeId,UNITY_MultiTrip_Actual__c,UNITY_Related_Work_Order__c,FSO__Check_In_Date__c FROM WorkOrder WHERE Id IN :woIds]);
        System.debug('#####Izay: wosMap = ' + JSON.serializePretty(wosMap));
        //Set the statuses that cannot be overwriten
        Set<String> noOverwrite = new Set<String>{'Quote Needed','Quote Submitted','Closed','Completed', 'Reopened'};
        //Get all order for the work orders
        List<Order> allOs = new List<Order>();
        allOs = [SELECT Id,Status,FSO__WorkOrder__c,UNITY_Related_Work_Order_Id__c,RecordTypeId FROM Order WHERE (FSO__WorkOrder__c IN :woIds) AND Id NOT IN :trigger.newMap.keyset()];
        allOs.addAll(thisOrds);
        System.debug('#####Izay: allOs = ' + JSON.serializePretty(allOs));
        Map<Id,List<Order>> woOrdsMap = new Map<Id,List<Order>>();//Hols all order by the work order
        //Put the orders in the woOrdsMap by the work order id
        for(Order o :allOs){
            if(!woOrdsMap.containsKey(o.FSO__WorkOrder__c)){
                List<Order> temp = new List<Order>();
                temp.add(o);
                woOrdsMap.put(o.FSO__WorkOrder__c,temp);
            }else{
                woOrdsMap.get(o.FSO__WorkOrder__c).add(o);
            }
            if(String.isNotBlank(o.UNITY_Related_Work_Order_Id__c)){
                if(!woOrdsMap.containsKey(o.UNITY_Related_Work_Order_Id__c)){
                    List<Order> temp = new List<Order>();
                    temp.add(o);
                    woOrdsMap.put(o.UNITY_Related_Work_Order_Id__c,temp);
                }else{
                    woOrdsMap.get(o.UNITY_Related_Work_Order_Id__c).add(o);
                }
            }
        }
        //Updated work orders
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        
        for(Id key :woOrdsMap.keySet()){
            if(wosMap.containsKey(key)){
                String woStatus = wosMap.get(key).Status;
                String woRTName = '';
                if(woRTs.containsKey(wosMap.get(key).RecordTypeId)){
                    woRTName = woRTs.get(wosMap.get(key).RecordTypeId).DeveloperName;
                }
                String status = '';
                Integer num;
                System.debug('#####Izay: woStatus = ' + JSON.serializePretty(woStatus));
                System.debug('#####Izay: woRTName = ' + JSON.serializePretty(woRTName));
                System.debug('#####Izay: status = ' + JSON.serializePretty(status));
                //System.debug('#####Izay: num = ' + JSON.serializePretty(num));
                Boolean doChange = false;
            //CLAY: Added to prevent changing the status if the work order is IVR checkout or reopened and PO goes to final or accepted
          //  if (woStatus != 'IVR Check Out - Agent Review Needed' && woStatus != 'Reopened'){                
                
                for(Order o :thisOrds){
                    String myRTName = '';
                    if(orderRTs.containsKey(o.recordTypeId)){
                        myRTName = orderRTs.get(o.RecordTypeId).DeveloperName;
                    }
                    String myKey = o.Status+'-'+myRTName+'-'+woRTName;
                    //Clay - Added to prevent change of work order from IVR Check Out - Agent Review Needed or Reopened.
                    System.debug('//CLAY: what is woStatus ' + woStatus );
                    //System.debug('//CLAY: will this be true? ' + (toStatusMap.containsKey(myKey) && (woStatus != 'IVR Check Out - Agent Review Needed' || woStatus != 'Reopened')) );                
                    // && (woStatus != 'IVR Check Out - Agent Review Needed' || woStatus != 'Reopened')
                    if(toStatusMap.containsKey(myKey)){
                        doChange = true;
                    }
                }
                if(doChange){
                    for(Order o :woOrdsMap.get(key)){
                        String myRTName = '';
                        if(orderRTs.containsKey(o.recordTypeId)){
                            myRTName = orderRTs.get(o.RecordTypeId).DeveloperName;
                        }
                        String myKey = o.Status+'-'+myRTName+'-'+woRTName;
                        System.debug('#####Izay: myRTName = ' + JSON.serializePretty(myRTName));
                        System.debug('#####Izay: o.Status = ' + JSON.serializePretty(o.Status));
                        System.debug('#####Izay: myKey = ' + JSON.serializePretty(myKey));
                        if(toStatusMap.containsKey(myKey)){
                            
                            String originValue = toStatusMap.get(myKey).UNITY_Origin_Value__c;
                            String targetValue = toStatusMap.get(myKey).UNITY_Target_Value__c;
                            String originRT = toStatusMap.get(myKey).UNITY_Origin_Record_Type__c;
                            String targetRT = toStatusMap.get(myKey).UNITY_Target_Record_Type__c;
                            Boolean tRTMatch = false;
                            Boolean oRTMatch = false;
                            
                            if(String.isNotBlank(targetRT)){
                                if(woRTName == targetRT){
                                    tRTMatch = true;
                                }
                            }else{
                                tRTMatch = true;
                            }
                            if(String.isNotBlank(originRT)){
                                if(myRTName == originRT){
                                    oRTMatch = true;
                                }
                            }else{
                                oRTMatch = true;
                            }
                            if(tRTMatch && oRTMatch){
                                Integer i = Integer.valueOf(toStatusMap.get(myKey).UNITY_Order__c);
                                if(num == null){
                                    num = i;
                                    status = toStatusMap.get(myKey).UNITY_Target_Value__c;
                                }else if(num > i){
                                    num = i;
                                    status = toStatusMap.get(myKey).UNITY_Target_Value__c;
                                }
                            }
                        }
                    }//End for order
                    System.debug('#####Izay: Work Order Status: ' + woStatus);
                    System.debug('#####Izay: New Status: ' + status);
                    System.debug('//CLAY: Trying to filter out work orders that are IVR checkout or Reopened that are attempting to go to Pending Tech Dispatch');
                    System.debug('//CLAY: Will it allow this one through?' + !(woStatus == 'IVR Check Out - Agent Review Needed' && status == 'Pending Tech Dispatch'));
                    //Clay:if the work order status was IVR checkout or Reopened and now going to pending tech dispatch, skip
                    if(!(woStatus == 'IVR Check Out - Agent Review Needed' && status == 'Pending Tech Dispatch')){

                        System.debug('//CLAY: Not one of our protected combinations - continuing with wostatus update');
                        if((!noOverwrite.contains(woStatus)) && String.isNotBlank(status)){
                            wosMap.get(key).Status = status;
                            if(wosMap.get(key).UNITY_MultiTrip_Actual__c && status == 'Pending Tech Dispatch')
                                wosMap.get(key).Status = 'Pending Re-Dispatch';
                            else if(!wosMap.get(key).UNITY_MultiTrip_Actual__c && wosMap.get(key).FSO__Check_In_Date__c != null && status == 'Pending Tech Dispatch')
                                wosMap.get(key).Status = 'In Progress';                        
                            woToUpdate.add(wosMap.get(key));
                            System.debug('//CLAY: This work order status will be:' + wosMap.get(key).Status);
                        }
                    }
                }
                
                    
            }
        }//End for work orders map
        if(woToUpdate.size() > 0){
            try{
                update woToUpdate;
            }catch(Exception e){
                trigger.new[0].addError('An error occurred while updating the work order status. Error: ' + e.getMessage());
            }
        }//End if to updates
    }
    /**This method checks if an Order exceeds the NTE set on the Case
    *@param finalOrds - List<Order>: Orders to check NTE for
    */
    public static void checkNTE(List<Order> finalOrds){
        Set<Id> foids = new Set<Id>();
        for(Order o :finalOrds){
            foids.add(o.Id);
        }
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
        finalOrds = [SELECT Id,OrderNumber,AccountId,EffectiveDate,FSO__WorkOrder__c,FSO__WorkOrder__r.CaseId,UNITY_CaseId__c,UNITY_Sales_Tax__c,
                     UNITY_Line_Item_DIscounted_Price__c,UNITY_Final_Price__c,UNITY_Business_Unit_Account__c,UNITY_Customer__c,UNITY_Discount__c,
                     (SELECT Id,OrderId,OrderItemNumber,UNITY_Customer_Adjusted_Quantity__c,UNITY_Is_Vendor_Supply__c,UNITY_Sales_Tax__c,
                      UNITY_Price__c,UNITY_Type__c,UNITY_Activity_Type__c,UNITY_Discounted_Price__c,UNITY_Total_Price__c,UNITY_Product_Name__c
                      FROM OrderItems WHERE PriceBookEntry.Product2.Name != 'Vendor Service Fee'
                      AND UNITY_Not_Billable__c = FALSE
                     ) 
                     FROM Order WHERE Id IN :foids];
        Set<Id> cids = new Set<Id>();
        Map<Id,List<Order>> caseFinalOrds = new Map<Id,List<Order>>();
        for(Order o :finalOrds){
            cids.add(o.UNITY_CaseId__c);
            if(!caseFinalOrds.containsKey(o.UNITY_CaseId__c))
                caseFinalOrds.put(o.UNITY_CaseId__c,new List<Order>());
            caseFinalOrds.get(o.UNITY_CaseId__c).add(o);
        }
        Map<Id,Case> caseMap = new Map<Id,Case>([SELECT Id,UNITY_NTE_Threshold__c,UNITY_Customer_Service_Contract__c,UNITY_Customer_Service_Contract__r.UNITY_Is_Pass_Through__c FROM Case WHERE Id IN: cids]);
        
        List<Order> orders = [SELECT Id,OrderNumber,AccountId,EffectiveDate,FSO__WorkOrder__c,FSO__WorkOrder__r.CaseId,UNITY_CaseId__c,
                              UNITY_Sales_Tax__c,UNITY_Line_Item_DIscounted_Price__c,UNITY_Final_Price__c,UNITY_Discount__c,
                              (SELECT Id,OrderId,OrderItemNumber,UNITY_Customer_Adjusted_Quantity__c,UNITY_Is_Vendor_Supply__c,UNITY_Sales_Tax__c,
                               UNITY_Price__c,UNITY_Type__c,UNITY_Activity_Type__c,UNITY_Discounted_Price__c,UNITY_Total_Price__c,UNITY_Product_Name__c
                               FROM OrderItems WHERE PriceBookEntry.Product2.Name != 'Vendor Service Fee'
                               AND UNITY_Not_Billable__c = FALSE
                              ) 
                              FROM Order WHERE FSO__WorkOrder__r.CaseId = :cids AND Id NOT IN :foids
                              AND(RecordTypeId =: UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE 
                                  OR 
                                  RecordTypeId =: UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE)
                              AND Status IN :delimitedInvoiceableStatuses
                              AND FSO__WorkOrder__r.Status != 'Canceled'];
        
        Map<Id,List<Order>> caseOrdersMap = new Map<Id,List<Order>>();
        
        for(Order o :orders){
            if(!caseOrdersMap.containsKey(o.UNITY_CaseId__c))
                caseOrdersMap.put(o.UNITY_CaseId__c,new List<Order>());
            caseOrdersMap.get(o.UNITY_CaseId__c).add(o);    
        }
        
        System.debug('##### finalOrds.size(): ' + finalOrds.size());
        System.debug('##### caseFinalOrds.keySet().size(): ' + caseFinalOrds.keySet().size());
        System.debug('##### caseMap.keySet().size(): ' + caseMap.keySet().size());
        System.debug('##### orders.size(): ' + orders.size()); 
        System.debug('##### caseOrdersMap.keySet().size(): ' + caseOrdersMap.keySet().size()); 
        
        for(Id cid :caseFinalOrds.keySet()){
            Double NTEVal = caseMap.containsKey(cid)?caseMap.get(cid).UNITY_NTE_Threshold__c:0;
            Boolean isPassTrough = caseMap.containsKey(cid)?caseMap.get(cid).UNITY_Customer_Service_Contract__r.UNITY_Is_Pass_Through__c:false;
            Double totalPrice = 0;
            Double totalVendorSupply = 0;
            Decimal totalDiscVendSup = 0;
            Double totalTax = 0;
            Double sCharge = 0;
            Decimal discSCharge = 0;
            System.debug('##### NTEVal: ' + NTEVal);
            System.debug('##### isPassTrough: ' + isPassTrough);
            
            if(caseOrdersMap.containsKey(cid)){
                for(Order o :caseOrdersMap.get(cid)){
                    Decimal temp = (o.UNITY_Final_Price__c != null) ? o.UNITY_Final_Price__c : o.UNITY_Line_Item_DIscounted_Price__c;
                    totalPrice += temp;
                    Decimal tempTax = (o.UNITY_Sales_Tax__c != null) ? o.UNITY_Sales_Tax__c : 0;
                    totalTax += tempTax;
                    for(OrderItem ot :o.OrderItems){
                        Decimal tempLine = (ot.UNITY_Discounted_Price__c != null) ? ot.UNITY_Discounted_Price__c: ot.UNITY_Total_Price__c;
                        if(ot.UNITY_Is_Vendor_Supply__c){
                            totalVendorSupply += tempLine;
                            if(o.UNITY_Discount__c != null && o.UNITY_Discount__c > 0){
                                tempLine = (tempLine - (tempLine*(o.UNITY_Discount__c/100))).setScale(2,System.RoundingMode.HALF_DOWN);
                            }
                            totalDiscVendSup += tempLine;
                        }
                    }
                }
            }
            for(Order o :caseFinalOrds.get(cid)){
                Decimal temp = (o.UNITY_Final_Price__c != null) ? o.UNITY_Final_Price__c : o.UNITY_Line_Item_DIscounted_Price__c;
                totalPrice += temp;
                Decimal tempTax = (o.UNITY_Sales_Tax__c != null) ? o.UNITY_Sales_Tax__c : 0;
                totalTax += tempTax;
                for(OrderItem ot :o.OrderItems){
                    Decimal tempLine = (ot.UNITY_Discounted_Price__c != null) ? ot.UNITY_Discounted_Price__c: ot.UNITY_Total_Price__c;
                    if(ot.UNITY_Is_Vendor_Supply__c){
                        totalVendorSupply += tempLine;
                        if(o.UNITY_Discount__c != null && o.UNITY_Discount__c > 0){
                            tempLine = (tempLine - (tempLine*(o.UNITY_Discount__c/100))).setScale(2,System.RoundingMode.HALF_DOWN);
                        }
                        totalDiscVendSup += tempLine;
                    }
                }
            }
            System.debug('##### totalVendorSupply: ' + totalVendorSupply);
            if(isPassTrough){
                sCharge = UNITY_UsageRequestHandler.calculateServicveCharge(caseMap.get(cid).UNITY_Customer_Service_Contract__c,totalVendorSupply,0);
                Decimal scDiscPer = 0;
                if(totalDiscVendSup != null && totalDiscVendSup > 0 && totalVendorSupply != null && totalVendorSupply > 0){
                    scDiscPer = (totalDiscVendSup/totalVendorSupply).setScale(2,System.RoundingMode.HALF_DOWN);
                }
                discSCharge = (scDiscPer > 0) ? (sCharge * scDiscPer).setScale(2,System.RoundingMode.HALF_DOWN) : sCharge;
            }
            Decimal sChargeTax = 0;
            if(discSCharge != null && discSCharge > 0){
                sChargeTax = UNITY_UsageRequestHandler.getServiceChargeTax(caseFinalOrds.get(cid)[0],discSCharge);
            }
            System.debug('#####Izay: totalPrice: ' + totalPrice);
            System.debug('#####Izay: discSCharge: ' + discSCharge);
            System.debug('#####Izay: sChargeTax: ' + sChargeTax);
            System.debug('#####Izay: totaltax: ' + totalTax);
            System.debug('#####Izay: NTEVal: ' + NTEVal);
            
            if((totalPrice + discSCharge + sChargeTax + totalTax) > NTEVal){
                //This case just went over the NTE... 
                if(caseFinalOrds.get(cid).size() == 1){
                    //only one order in this case was changed to final... 
                    //this order needs to be converted into an usage request so that a quote can be created for it
                    //For now... throw an error
                    String urRT = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
                    System.debug('##### Adding Error to : caseFinalOrds.get(cid)[0] == 1');
                    String err = 'The order will make the Case go over the NTE. Contact your system administrator for help with this error. ';
                    err += ' Price: $' + totalPrice + ', Service Charge: $' + sCharge + ', Sales Tax: $' + totalTax + '. ';
                    err += ' Case Total: $' + (totalPrice+sCharge+totalTax);
                    System.debug('>>>> neli >> err >>' + err);
                    Trigger.new[0].addError(err);
                }else if(caseFinalOrds.get(cid).size() > 0){
                    //More than one order was changed to final... simply throw an error
                    System.debug('##### Adding Error to : caseFinalOrds.get(cid)[0] > 0');
                    Trigger.new[0].addError('The order(s) will make the Case go over the NTE.  Contact your system administrator for help with this error.');
                }
            }
        }
        
    }
    /**This method validates missing cost ($0.00) on Part lines
    */
    public static void validateNoZeroPartLines(){
        if(Trigger.isUpdate){
            String usagertRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;
            String stockingRTId = UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE;
            System.debug('#####Izay: usagertRTId = ' + usagertRTId);
            System.debug('#####Izay: stockingRTId = ' + stockingRTId);
            Set<Id> noZeroLineIds = new Set<Id>();//Holds PO Ids for PO changing to "Final" or to "Part Cost Identified"
            for(SObject so :Trigger.new){
                Order o = (Order)so;
                Order oldO = (Order)Trigger.oldMap.get(so.Id);
                System.debug('#####Izay: Order recordTypeId = ' + o.RecordTypeId);
                if(oldO.Status != o.Status &&
                   ((o.Status == 'Final' && o.RecordTypeId == usagertRTId) ||
                    (o.Status == 'Submitted to Miner' && o.RecordTypeId == usagertRTId) ||
                    (oldO.Status == 'Part Cost Required' && o.RecordTypeId == usagertRTId) ||
                    (o.Status == 'Parts Order Required' && o.RecordTypeId == stockingRTId)) ){
                        noZeroLineIds.add(o.Id);
                    }
            }
            List<Order> orders = new List<Order>();
            //If a PO changed to Final...
            if(!noZeroLineIds.isEmpty()){
                //Query POs with Part POLIs; DC 10/19/16 - added condition in subquery to exclude line items where UNITY_Customer_Only__c = true.
                orders = [SELECT Id, Name, Status, FSO__WorkOrder__r.UNITY_Use_Menu_Pricing__c, FSO__WorkOrder__r.UNITY_Include__c, FSO__WorkOrder__r.RecordTypeId, 
                            FSO__WorkOrder__r.MSPFS_Intercompany_Transfer__c, RecordType.DeveloperName,
                          (SELECT Id,OrderItemNumber,UNITY_Cost__c,UNITY_Part_Source__c,UNITY_Part_Source__r.UNITY_Miner_Regional_Office__c,UNITY_Part_Location__c,
                          UNITY_Is_Vendor_Supply__c, UNITY_Activity_Type__c,MSPFS_MSP_Price__c
                          FROM OrderItems WHERE (UNITY_Type__c = 'Parts' OR (UNITY_Type__c = 'Vendor Services' AND UNITY_Activity_Type__c LIKE 'Parts%')) AND UNITY_Customer_Only__c = false) 
                          FROM Order WHERE Id IN :noZeroLineIds];
                String nonWorkRTId = UNITY_Constants.WO_NON_WORK_RECORDTYPE;
                //For each PO...
                for(Order o :orders){
                    if(!o.FSO__WorkOrder__r.UNITY_Use_Menu_Pricing__c && !o.FSO__WorkOrder__r.UNITY_Include__c){
                        //For each Part POLI...
                        for(OrderItem oItem :o.OrderItems){
                            //If the cost is null or 0... 
                            if( oItem.UNITY_Cost__c == null || oItem.UNITY_Cost__c <= 0 ){
                                //Thow an error
                                if(o.Status == 'Final'){
                                    Trigger.new[0].addError(' The usage request cannot be finalized if part lines have $0 cost.');
                                }else if(o.Status == 'Part Cost Identified'){
                                    Trigger.new[0].addError(' The usage request cannot be set to Part Cost Identified if part lines have $0 cost.');
                                }else if(o.Status == 'Parts Order Required'){
                                    Trigger.new[0].addError(' The Stocking PO cannot be set to Parts Order Required if part lines have $0 cost.');
                                }else if(o.Status == 'Part Cost Required'){
                                    Trigger.new[0].addError(' Cannot change the usage request status from Part Cost Required if part lines have $0 cost.');
                                }
                            }
                            if(o.FSO__WorkOrder__r.RecordTypeId == nonWorkRTId && String.isBlank(oItem.UNITY_Part_Source__c) && !oitem.UNITY_Is_Vendor_Supply__c){
                                if(!Test.isRunningTest())
                                    Trigger.new[0].addError(' Please identify a Part Source on each NOT Vendor Supplied part line to continue.');
                            }else if(o.FSO__WorkOrder__r.RecordTypeId == nonWorkRTId && String.isNotBlank(oItem.UNITY_Part_Source__c)){
                                if(oItem.UNITY_Part_Source__r.UNITY_Miner_Regional_Office__c && String.isBlank(oItem.UNITY_Part_Location__c)){
                                    if(!Test.isRunningTest())
                                        Trigger.new[0].addError(' Please to select a Part Location on each line where the Part Source is a Business Unit.');
                                }
                            }
                        }
                    }

                    if ( o.FSO__WorkOrder__r.MSPFS_Intercompany_Transfer__c && o.RecordTypeId == UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE && o.Status != 'Draft' ) {
                        for ( OrderItem oItem :o.OrderItems ) {
                            if ( (oItem.MSPFS_MSP_Price__c == null || oItem.MSPFS_MSP_Price__c <= 0) && oItem.UNITY_Is_Vendor_Supply__c && oItem.UNITY_Activity_Type__c.contains('Part') ) {
                                Trigger.new[0].addError(' This usage request cannot be "Submitted to Miner" if part lines have $0 MSP Unit Price.');
                            }
                        }
                    }
                }
            }
        }
    }
    /**This method validates the Part Source in order items
    *@param poids - Set<Id>: The Ids for the POs that need part source validation
    */
    public static void validateSourceIdentified(Set<Id> poids){
        if(!poids.isEmpty()){
            Boolean hasError = false;
            String errorMsg = ' Please identify the Part Source for the following parts: ';
            for(OrderItem item :[SELECT Id,OrderItemNumber,OrderId,UNITY_Product_Name__c,UNITY_Part_Source__c
                                FROM OrderItem WHERE OrderId IN:poids]){
                if(String.isBlank(item.UNITY_Part_Source__c)){
                    hasError = true;
                    errorMsg += ' ' + item.UNITY_Product_Name__c + ',';
                }
            }
            if(hasError){
                errorMsg = errorMsg.removeEndIgnoreCase(',');
                Trigger.new[0].addError(errorMsg);
            }
        }
    }
    /**This method sets the Shipping Infoprmation on orders from their Originating Usage Request
    *@param orders - List<Order>: The Orders to set the Shipping Info from its originating Usage Request
    */
    public static void setShippingInfo(List<Order> orders){
        Set<Id> urIds = new Set<Id>();
        for(Order o :orders){
            urIds.add(o.UNITY_Originating_Usage_Request__c);
        }
        if(!urIds.isEmpty()){
            Map<Id,Order> URsMap = new Map<Id,Order>([SELECT Id,UNITY_Expected_Arrival_Date__c,ShipToContactId,UNITY_Ship_To_Account__c,UNITY_Shipping_Method__c,UNITY_Parts_Needed_By__c,
                                                      ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,UNITY_Shipping_Provider__c FROM Order WHERE Id IN :urIds]);
            for(Order o :orders){
                if(URsMap.containsKey(o.UNITY_Originating_Usage_Request__c)){
                    Id urid = o.UNITY_Originating_Usage_Request__c;
                    o.ShipToContactId = URsMap.get(urid).ShipToContactId;
                    o.UNITY_Ship_To_Account__c = URsMap.get(urid).UNITY_Ship_To_Account__c;
                    o.ShippingStreet = URsMap.get(urid).ShippingStreet;
                    o.ShippingCity = URsMap.get(urid).ShippingCity;
                    o.ShippingState = URsMap.get(urid).ShippingState;
                    o.ShippingPostalCode = URsMap.get(urid).ShippingPostalCode;
                    o.ShippingCountry = URsMap.get(urid).ShippingCountry;
                    //Izay: Additional fields for shipping info
                    o.UNITY_Expected_Arrival_Date__c = URsMap.get(urid).UNITY_Expected_Arrival_Date__c;
                    o.UNITY_Shipping_Method__c = URsMap.get(urid).UNITY_Shipping_Method__c;
                    o.UNITY_Parts_Needed_By__c = URsMap.get(urid).UNITY_Parts_Needed_By__c;
                    o.UNITY_Shipping_Provider__c = URsMap.get(urid).UNITY_Shipping_Provider__c;
                }
            }
        }
    }
    /**This method propagates the Tracking Information from Order to Order Items
    *@param orders - List<Order>: The orders to propagate the tracking info to its OrderItems
    */
    public static void setTrackingInfoToLineItem(List<Order> orders){
        String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
        String poPSRTId = UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE;
        String poStockRTId = UNITY_Constants.ORDER_STOCKING_PURCHASE_ORDER_RECORDTYPE;
        Map<Id,Order> ordersMap = new Map<Id,Order>();
        for(Order o :orders){
            ordersMap.put(o.Id,o);
        }
        List<OrderItem> oLines = [SELECT Id,UNITY_Actual_Ship_Date__c,UNITY_Expected_Ship_Date__c,UNITY_Tracking_Number__c,OrderId FROM OrderItem WHERE OrderId IN :ordersMap.keySet() AND (UNITY_Activity_Type__c LIKE '%Part%' AND UNITY_Is_Vendor_Supply__c = FALSE)];
        for(OrderItem oi :oLines){
            if(ordersMap.containsKey(oi.OrderId)){
                if(ordersMap.get(oi.OrderId).RecordTypeId == poRTId){
                    oi.UNITY_Actual_Ship_Date__c = ordersMap.get(oi.OrderId).UNITY_Actual_Arrival_Date__c;
                }else{
                    oi.UNITY_Actual_Ship_Date__c = ordersMap.get(oi.OrderId).UNITY_Actual_Arrival_Date__c;
                    oi.UNITY_Expected_Ship_Date__c = ordersMap.get(oi.OrderId).UNITY_Expected_Arrival_Date__c;
                    oi.UNITY_Tracking_Number__c = ordersMap.get(oi.OrderId).UNITY_Tracking_Number__c;
                    oi.UNITY_Shipping_Provider__c = ordersMap.get(oi.OrderId).UNITY_Shipping_Provider__c;
                }
            }
        }
        update oLines;
    }
    /**This method sets the GL Sub-Account on the given Orders
    *@param orders - List<Order>: The orders to set the GL Sub-Account
    */
    public static void setGLSubAccount(List<Order> orders){
        if(!orders.isEmpty()){
            Boolean hasError = false;
            String message = '';
            //List<Order> orders = [SELECT Id,Name,UNITY_GL_Segment_Account__c,UNITY_GL_Sub_Account__c,UNITY_GL_Segment__c,UNITY_Work_Order_Type__c FROM Order WHERE Id IN :oids];
            Set<String> segments = new Set<String>();
            Set<String> oTypes = new Set<String>();
            for(Order o :orders){
                if(String.isNotBlank(o.UNITY_GL_Segment__c)){
                    segments.add(o.UNITY_GL_Segment__c);
                    System.debug('### o.UNITY_GL_Segment__c: ' + o.UNITY_GL_Segment__c);
                }
                if(String.isNotBlank(o.UNITY_Work_Order_Type__c)){
                    oTypes.add(o.UNITY_Work_Order_Type__c);
                    System.debug('### o.UNITY_Work_Order_Type__c: ' + o.UNITY_Work_Order_Type__c);
                }
                    
            }
            List<UNITY_GL_Segment_Account__c> segAccounts = [SELECT Id,Name,UNITY_Segment__c,UNITY_Seg_Account_Number__c 
                                                         FROM UNITY_GL_Segment_Account__c WHERE UNITY_Segment__c IN :segments];
            List<UNITY_GL_Sub_Account__c> subAccounts = [SELECT Id,Name,UNITY_Sub_Account__c,UNITY_GL_Sub_Account_Number__c 
                                                         FROM UNITY_GL_Sub_Account__c WHERE UNITY_Sub_Account__c IN :oTypes];
            Map<String,String> segsMap = new Map<String,String>();
            Map<String,String> subsMap = new Map<String,String>();
            for(UNITY_GL_Segment_Account__c seg :segAccounts){
                if(!segsMap.containsKey(seg.UNITY_Segment__c)){
                    segsMap.put(seg.UNITY_Segment__c,seg.UNITY_Seg_Account_Number__c);
                    System.debug('### seg.UNITY_Segment__c: ' + seg.UNITY_Segment__c);
                }
                    
            }
            for(UNITY_GL_Sub_Account__c sub :subAccounts){
                if(!subsMap.containsKey(sub.UNITY_Sub_Account__c)){
                    subsMap.put(sub.UNITY_Sub_Account__c,sub.UNITY_GL_Sub_Account_Number__c);
                    System.debug('### sub.UNITY_Sub_Account__c: ' + sub.UNITY_Sub_Account__c);
                }
                    
            }
            for(Order o :orders){
                if(String.isNotBlank(o.UNITY_GL_Segment__c)){
                    System.debug('### o.UNITY_GL_Segment__c: ' + o.UNITY_GL_Segment__c);
                    if(segsMap.containsKey(o.UNITY_GL_Segment__c)){
                        
                        o.UNITY_GL_Segment_Account__c = segsMap.get(o.UNITY_GL_Segment__c);
                        System.debug('### o.UNITY_GL_Segment_Account__c: ' + o.UNITY_GL_Segment_Account__c);
                        
                    }else{
                        hasError = true;
                        message += 'GL Segment Account not found.\n';
                    }
                }
                if(String.isNotBlank(o.UNITY_Work_Order_Type__c)){
                    System.debug('### o.UNITY_Work_Order_Type__c: ' + o.UNITY_Work_Order_Type__c);
                    if(subsMap.containsKey(o.UNITY_Work_Order_Type__c)){
                        
                        o.UNITY_GL_Sub_Account__c = subsMap.get(o.UNITY_Work_Order_Type__c);
                        System.debug('### o.UNITY_GL_Sub_Account__c: ' + o.UNITY_GL_Sub_Account__c);
                        
                    }else{
                        
                        hasError = true;
                        message += 'GL Sub Account not found.\n';
                    }
                }
            }
            try{
                if(!hasError){
                    //update orders;
                }else{
                    //Need to notify someone that there is something wrong here.
                }
            }catch(Exception e){
                System.debug('##### Error: ' + e.getMessage());
            }
        }
    }
    /**This method validates the GL Accounts information on Order
    *@param oids - Set<Id>: The ids for the Orders to validate GL Account for
    */
    public void validateGLAccounts(Set<Id> oids){
        List<OrderItem> oLines = [SELECT Id,OrderId,Order.UNITY_Work_Order_Type__c,UNITY_Type__c,UNITY_Activity_Type__c,UNITY_GL_Cost_Account__c,
                                  UNITY_GL_Revenue_Account__c,UNITY_GL_Tax_Account__c
                                  FROM OrderItem WHERE OrderId IN :oids AND UNITY_Type__c != 'Non Billable'];
        for(OrderItem line :oLines){
            if(String.isBlank(line.UNITY_GL_Revenue_Account__c) || String.isBlank(line.UNITY_GL_Tax_Account__c) || String.isBlank(line.UNITY_GL_Cost_Account__c)){
                if(!Test.isRunningTest())
                    Trigger.new[0].AddError('Lines on this order are missing the GL Mapping. Please verify which lines are missing the GL Mapping.');
            }
        }
    }
    /**This method sets the vendor service contract on given POs
    *@param orders - List<Order>: The orders that need vendor service contract populated
    *@param type - String: The contract type to look for
    */
    public static void setVendorContract(List<Order> orders, UNITY_Constants.ContractType type){
        if(!orders.isEmpty()){
            //If the type is null or empty default to Service
            if(type == null)
                type = UNITY_Constants.ContractType.SERVICE_REQUEST;
            String rtId = UNITY_Constants.CONTRACT_RTID_MAP.get(type);
            System.debug('#####Izay: type = ' + type);
            System.debug('#####Izay: rtId = ' + rtId);
            //Get all contracts for the vendors
            Set<Id> vids = new Set<Id>();
            for(Order o :orders){
                if(String.isNotBlank(o.UNITY_Vendor__c)){
                    vids.add(o.UNITY_Vendor__c);
                }
            }
            List<UNITY_Service_Contract__c> contracts = [SELECT Id,UNITY_Account__c,UNITY_Business_Unit__c,UNITY_Is_Active__c,RecordTypeId FROM UNITY_Service_Contract__c
                                                         WHERE UNITY_Account__c IN :vids AND UNITY_Is_Active__c = TRUE AND RecordTypeId = :rtId];
            System.debug('#####Izay: contracts = ' + contracts);
            for(Order o :orders){
                for(UNITY_Service_Contract__c c :contracts){
                    System.debug('#####Izay: c.UNITY_Account__c = ' + c.UNITY_Account__c);
                    System.debug('#####Izay: c.UNITY_Business_Unit__c = ' + c.UNITY_Business_Unit__c);
                    if(o.UNITY_Vendor__c == c.UNITY_Account__c && c.UNITY_Business_Unit__c.indexOf(o.UNITY_Business_Unit__c) != -1){
                        o.UNITY_Vendor_Contract__c = c.Id;
                    }
                }
            }
        }
    }
    /**This method validates the shipping info on POs
    *@param orders - Order: The post that need validation
    */
    public static void validateShippingInfo(List<Order> orders){
        if(!orders.isEmpty()){
            for(Order o :orders){
                //Check for missing fields here...
                if(String.isBlank(o.UNITY_Shipping_Method__c))
                    Trigger.newMap.get(o.Id).addError(' Shipping Method is Required');
                if(String.isBlank(o.UNITY_Shipping_Provider__c))
                    Trigger.newMap.get(o.Id).addError(' Shipping Provider is Required');
                if(String.isBlank(o.UNITY_Tracking_Number__c))
                    Trigger.newMap.get(o.Id).addError(' Tracking Number is Required');
                if(o.UNITY_Expected_Arrival_Date__c == null)
                    Trigger.newMap.get(o.Id).addError(' Expected Arrival Date is Required');
            }
        }
    }
    /**This method handels stocking POs that have been set as Shipment Received
    *@param oids - Set<Id>: The ids of the POs that are flagged as shipment received
    */
    public static void handleShipmentReceived(Set<Id> oids){
        if(!oids.isEmpty()){
            List<Id> idsList = new List<Id>();
            idsList.addAll(oids);
            UNITY_MuleCalloutOperation.invokeCallOut(idsList,UNITY_MuleSiteSettingUtils.PURCHASE_ORDER);
            updatePOStatus(oids,'Completed');
        }
    }
    /**This method updates the Order status in a future context
    *@param status - String: the status to updated the order to
    */
    @Future
    public static void updatePOStatus(Set<Id> oids, String status){
        if(!oids.isEmpty() && String.isNotBlank(status)){
            List<Order> toUpdate = new List<Order>();
            for(Id id :oids){
                Order o = new Order(
                    Id = id,
                    Status = status
                );
                toUpdate.add(o);
            }
            if(!toUpdate.isEmpty()){
                try{
                    update toUpdate;
                }catch(Exception e){
                    System.debug('#####Izay: ' + e.getMessage());
                }
            }
        }
    }
    /**This method shares Order records with either MSP or Asset Light Account Team on intercompany transfer WOs
    */
    public static void shareOrder(List<Order> orders){
        if(!orders.isEmpty()){
            String urRTId = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE;//Usage request record type id
            String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;//Purchase order record type id
            String partSourcingRTId = UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE;
            Set<Id> woIds = new Set<Id>();//holds work order ids
            Set<Id> ownerIds = new Set<Id>();//holds order owner ids
            Set<Id> orderIds = new Set<Id>();//holds order ids
            for(Order o :orders){
                woIds.add(o.FSO__WorkOrder__c);
                ownerIds.add(o.OwnerId);
                orderIds.add(o.Id);
            }
            //Get intercompany tansfer wwork orders
            //Izay: Added fields to get the Account team
            Map<Id,WorkOrder> woMap = new Map<Id,WOrkOrder>([SELECT Id,UNITY_Accepted_Vendor__c,UNITY_Accepted_Vendor__r.MSPFS_Is_MSP_BU__c,
                                          UNITY_Business_Unit_Account__c,UNITY_Business_Unit_Account__r.MSPFS_Is_MSP_BU__c,UNITY_Agent__c,
                                          UNITY_Miner_Team_Assigned__c,
                                          MSPFS_Intercompany_Transfer__c,UNITY_Related_Work_Order__c,UNITY_Related_Work_Order__r.UNITY_Accepted_Vendor__c
                                          FROM WorkOrder 
                                          WHERE Id IN :woIds AND (MSPFS_Intercompany_Transfer__c = true OR UNITY_Related_Work_Order__r.MSPFS_Intercompany_Transfer__c = true)
                                          AND Status != 'Cancelled']);
            //If this order is related to an intercompany transfer work order...
            if(!woMap.keySet().isEmpty()){
                Map<Id,List<Order>> shareWithBUMap = new Map<Id,List<Order>>();//Map to share Orders with MSP BU
                Map<Id,List<Order>> shareWithAgent = new Map<Id,List<Order>>();//Map to share Orders with Asset Light BU agent
                Map<Id,User> ownersMap = new Map<Id,User>([SELECT Id,MSPFS_Is_MSP_User__c FROM USER WHERE Id IN :ownerIds]);
                //Get queue names per work order
                Set<String> teamNames = new Set<String>();
                for(WorkOrder wo :woMap.values()){
                    teamNames.add(wo.UNITY_Miner_Team_Assigned__c.replace('-',' '));
                }
                System.debug('Izay: teamNames = ' + JSON.serializePretty(teamNames));
                //Get the queues for the teams in the WOs
                List<Group> teams = [SELECT Id,Name FROM GROUP WHERE Name IN :teamNames AND Type != 'Queue'];
                Map<String,String> teamIdsByName = new Map<String,String>();
                //Add the queue id in the map for easy reference
                for(Group g :teams){
                    teamIdsByName.put(g.Name,g.Id);
                }
                System.debug('Izay: teamIdsByName = ' + JSON.serializePretty(teamIdsByName));
                for(Order o :orders){
                    if(woMap.containsKey(o.FSO__WorkOrder__c)){
                        if(ownersMap.containsKey(o.OwnerId)){
                            //If the order is an usage request and the owner is an MSP User...
                            //need to share the order with asset light agent
                            System.debug('Izay: is msp user? ' + ownersMap.get(o.OwnerId).MSPFS_Is_MSP_User__c);
                            System.debug('Izay: is usage request? ' + (o.RecordTypeId == urRTId));
                            if(o.RecordTypeId == urRTId && ownersMap.get(o.OwnerId).MSPFS_Is_MSP_User__c && (Trigger.isInsert || o.Status == 'Submitted to Miner') ){
                                //Add order by agen id
                                String agentId = woMap.get(o.FSO__WorkOrder__c).UNITY_Agent__c;
                                //Get the team id for the team on the work order
                                String tName = woMap.get(o.FSO__WorkOrder__c).UNITY_Miner_Team_Assigned__c.replace('-',' ');
                                String teamId;
                                if(String.isNotBlank(tName) && teamIdsByName.containsKey(tName)){
                                    teamId = teamIdsByName.get(tName);
                                }
                                if(String.isNotBlank(agentId)){
                                    if(!shareWithAgent.containsKey(agentId))
                                        shareWithAgent.put(agentId,new List<Order>());
                                    shareWithAgent.get(agentId).add(o);
                                }
                                //Add the team id to the map to share Order with
                                if(String.isNotBlank(teamId)){
                                    if(!shareWithAgent.containsKey(teamId))
                                        shareWithAgent.put(teamId,new List<Order>());
                                    shareWithAgent.get(teamId).add(o);
                                }
                            }else if(o.RecordTypeId == poRTId && woMap.get(o.FSO__WorkOrder__c).UNITY_Accepted_Vendor__c == o.UNITY_Vendor__c && !ownersMap.get(o.OwnerId).MSPFS_Is_MSP_User__c){
                                //Add order by msp bu id
                                if(!shareWithBUMap.containsKey(o.UNITY_Vendor__c))
                                    shareWithBUMap.put(o.UNITY_Vendor__c,new List<Order>());
                                shareWithBUMap.get(o.UNITY_Vendor__c).add(o);
                            }else if(o.RecordTypeId == partSourcingRTId && String.isNotBlank(woMap.get(o.FSO__WorkOrder__c).UNITY_Related_Work_Order__c)){
                                if(woMap.get(o.FSO__WorkOrder__c).UNITY_Related_Work_Order__r.UNITY_Accepted_Vendor__c != o.UNITY_Vendor__c && !ownersMap.get(o.OwnerId).MSPFS_Is_MSP_User__c){
                                    //Add order by msp bu id
                                    if(!shareWithBUMap.containsKey(woMap.get(o.FSO__WorkOrder__c).UNITY_Related_Work_Order__r.UNITY_Accepted_Vendor__c))
                                        shareWithBUMap.put(woMap.get(o.FSO__WorkOrder__c).UNITY_Related_Work_Order__r.UNITY_Accepted_Vendor__c,new List<Order>());
                                    shareWithBUMap.get(woMap.get(o.FSO__WorkOrder__c).UNITY_Related_Work_Order__r.UNITY_Accepted_Vendor__c).add(o);
                                }
                            }
                        }
                    }
                }
                System.debug('Izay: shareWithAgent? ' + shareWithAgent.keySet().size());
                System.debug('Izay: shareWithBUMap? ' + shareWithBUMap.keySet().size());
                //List to hold the order share records
                List<OrderShare> oShareToInsert = new List<OrderShare>();
                if(!shareWithAgent.keySet().isEmpty()){
                    for(Id agentId :shareWithAgent.keySet()){
                        for(Order o :shareWithAgent.get(agentid)){
                            OrderShare oShare = new OrderShare();
                            oShare.OrderId = o.Id;
                            oShare.OrderAccessLevel = 'Edit';
                            oShare.RowCause = Schema.OrderShare.RowCause.Manual;
                            oShare.UserOrGroupId = agentId;
                            oShareToInsert.add(oShare);                    
                        }
                    }
                }
                if(!shareWithBUMap.keySet().isEmpty()){
                    List<CKSW_BASE__Resource__c> technicians = new List<CKSW_BASE__Resource__c>();
                    List<CKSW_BASE__User_Location__c> dispatchers = new list<CKSW_BASE__User_Location__c>();
                    
                    technicians = [SELECT Id,CKSW_BASE__Location__c,MSPFS_BU_Account_Id__c,CKSW_BASE__User__c 
                                   FROM CKSW_BASE__Resource__c WHERE MSPFS_BU_Account_Id__c IN: shareWithBUMap.keySet() AND CKSW_BASE__User__r.IsActive = TRUE AND CKSW_BASE__Contractor__c = FALSE];
                    dispatchers = [SELECT Id,CKSW_BASE__Location__c,MSPFS_BU_Account_Id__c,CKSW_BASE__User__c 
                                   FROM CKSW_BASE__User_Location__c WHERE MSPFS_BU_Account_Id__c IN: shareWithBUMap.keySet() AND CKSW_BASE__User__r.IsActive = TRUE];
                    
                    System.debug('Izay: shareWithBUMap? ' + JSON.serializePretty(shareWithBUMap.keySet()));

                    Map<Id,List<CKSW_BASE__Resource__c>> buTechsMap = new Map<Id,List<CKSW_BASE__Resource__c>>();
                    Map<Id,List<CKSW_BASE__User_Location__c>> buDispsMap = new Map<Id,List<CKSW_BASE__User_Location__c>>();
                    if(!technicians.isEmpty()){
                        for(CKSW_BASE__Resource__c tech :technicians){
                            if(!buTechsMap.containsKey(tech.MSPFS_BU_Account_Id__c))
                                buTechsMap.put(tech.MSPFS_BU_Account_Id__c, new List<CKSW_BASE__Resource__c>());
                            buTechsMap.get(tech.MSPFS_BU_Account_Id__c).add(tech);
                        }
                    }
                    if(!dispatchers.isEmpty()){
                        for(CKSW_BASE__User_Location__c disp :dispatchers){
                            if(!buDispsMap.containsKey(disp.MSPFS_BU_Account_Id__c))
                                buDispsMap.put(disp.MSPFS_BU_Account_Id__c, new List<CKSW_BASE__User_Location__c>());
                            buDispsMap.get(disp.MSPFS_BU_Account_Id__c).add(disp);
                        }
                    }
                    for(Id buid :shareWithBUMap.keySet()){
                        //If there are tech records... need to share with them.
                        if(buTechsMap.containsKey(buid)){
                            //For each tech in the MSP BU Location (resource)
                            for(CKSW_BASE__Resource__c tech :buTechsMap.get(buid)){
                                for(Order o :shareWithBUMap.get(buid)){
                                    OrderShare oShare = new OrderShare();
                                    oShare.OrderId = o.Id;
                                    oShare.OrderAccessLevel = 'Edit';
                                    oShare.RowCause = Schema.OrderShare.RowCause.Manual;
                                    oShare.UserOrGroupId = tech.CKSW_BASE__User__c;
                                    oShareToInsert.add(oShare);
                                }
                            }
                        }//End if techs
                        if(buDispsMap.containsKey(buid)){
                            //Share with dispatcher
                            for(CKSW_BASE__User_Location__c disp :buDispsMap.get(buid)){
                                for(Order o :shareWithBUMap.get(buid)){
                                    OrderShare oShare = new OrderShare();
                                    oShare.OrderId = o.Id;
                                    oShare.OrderAccessLevel = 'Edit';
                                    oShare.RowCause = Schema.OrderShare.RowCause.Manual;
                                    oShare.UserOrGroupId = disp.CKSW_BASE__User__c;
                                    oShareToInsert.add(oShare);
                                }
                            }
                        }//End  if dispatchers
                    }//End for buid
                }//End id shareWithBU
                //System.debug('Izay: oShareToInsert? ' + oShareToInsert.size());
                System.debug('Izay: oShareToInsert? ' + JSON.serialize(oShareToInsert));
                if(!oShareToInsert.isEmpty()){
                    Database.SaveResult[] shareResult = Database.insert(oShareToInsert);
                    for(Database.SaveResult sr :shareResult){
                        if(!sr.isSuccess()){
                            Database.Error err = sr.getErrors()[0];
                            if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                                //Trigger.new[0].addError(' An error ocurred while sharing the work order with MSP. Error: ' + err.getMessage());
                                System.debug('###Izay: An error ocurred while sharing the work order with MSP. Error: ' + err.getMessage());
                            }
                        }
                    }
                }
            }
        }
    }
    
    private Boolean isInvoiceable(String status){
    	boolean result = false;
    	
    	UNITY_General_Settings__c generalSetting = UNITY_General_Settings__c.getValues(UNITY_Constants.PO_INVOICEABLE_STATUSES);
        system.debug('@@@ neli isInvoiceable generalSetting:'+generalSetting);
        if (generalSetting != null){
        	Set<String> delimitedInvoiceableStatuses = new Set<String>();
            delimitedInvoiceableStatuses = new Set<String>(generalSetting.UNITY_Value__c.split(UNITY_Constants.PO_INVOICEABLE_STATUSES_DELIMITER));
            system.debug('@@@ neli isInvoiceable delimitedInvoiceableStatuses:'+delimitedInvoiceableStatuses);
            if (delimitedInvoiceableStatuses.contains(status))
            	result = true;
            
            
             system.debug('@@@ neli isInvoiceable result:'+ result);
            return result;
        }
        else{
        	return (status == UNITY_Constants.ORDER_STATUS_ACCEPTED ||
        		status == UNITY_Constants.ORDER_STATUS_FINAL_FINAL ||
        		status == UNITY_Constants.ORDER_STATUS_PART_ORDER_REQUIRED ||
        		status == UNITY_Constants.ORDER_STATUS_COMPLETED ||
        		status == UNITY_Constants.ORDER_STATUS_PARTS_BEING_DELIVERED ||
        		status == UNITY_Constants.ORDER_STATUS_READY_TO_SHIP);
        }
       
    }    
    
    /**This variable and method are used to prevent trigger recursion before context
    */
    public static Boolean isFirstTriggerRun_Before = true;
    public static Boolean runTriggerOnce_Before(){
        if(isFirstTriggerRun_Before){
            isFirstTriggerRun_Before = false;
            return true;
        }else{
            return isFirstTriggerRun_Before;
        }
    }
    /**This variable and method are used to prevent triggers recursion on after context
    */
    public static Boolean isFirstTriggerRun_After = true;
    public static Boolean runTriggerOnce_After(){
        if(isFirstTriggerRun_After){
            isFirstTriggerRun_After = false;
            return true;
        }else{
            return isFirstTriggerRun_After;
        }
    }

    public static Boolean canShareOrder = true;
    public static Boolean shareOrderOnce(){
        if(canShareOrder){
            canShareOrder = false;
            return true;
        }else{
            return canShareOrder;
        }
    }

}