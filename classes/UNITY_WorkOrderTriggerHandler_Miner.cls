/**UNITY_WorkOrderTriggerHandler_Miner
 * @description: This class updates date time fields to a given time zone
 * @programer:   Izay Ramos-Irizarry
 * @date:        3/23/2016
 * @version:     1.0
 *
 * Functionalities
 * - Reassign Cases to custoimer team queue for second pahse GNC.
 * - Checks for Attachment Complance. Flags case when all Service WO under the case are Attachment Compliance.
 * - Validations on Work Order when it is set to 'Completed'.
 *
 * ========================================================================
 * Changelog
 * ========================================================================
 * @description: Added validateCompletedWO method to handle work order validations when they are completed.
 *               - Validates that all Orders under the work order are at a valid status.
 * @programmer:  Izay Ramos-Irizarry
 * @date:        9/24/2016
 * ========================================================================
 * @description: Added [... AND Status != 'Rejected' ...] when querying POs for validation.
 *               Removed the html tags on the error message for the validation error.
 * @programmer:  Izay Ramos-Irizarry
 * @date:        9/24/2016
 * ========================================================================
 * @description: Removed check for Work Order record type of Service Request from if condition 
 *                  that determines records to process in bulkAfter method.
 * @programmer:  Dan Cobb
 * @date:        10/18/2016
 * ========================================================================
 * @description: Added [... AND Status != 'Part Source Identified' ...] when querying POs for validation on WO completion.
 *               Added to check related WO record type to be non-work
 * @programmer:  Izay Ramos-Irizarry
 * @date:        3/23/2017
 * ========================================================================
 * 
 */
public class UNITY_WorkOrderTriggerHandler_Miner extends UNITY_BaseHandler{
    
    public override void bulkBefore(List<SObject> newList_WorkOrder, List<SObject> oldList_WorkOrder, Map<Id,SObject> oldMap_WorkOrder, Map<Id,SObject> newMap_WorkOrder){
        //if(runTriggerOnce_Before()){
            //System.debug('###### UNITY_WorkOrderTriggerHandler_Miner in bulkBefore: ');
            if(trigger.isInsert){
                UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_WorkOrder,null,'WorkOrder',true);
            }
            if(trigger.isUpdate){
                UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_WorkOrder,oldMap_WorkOrder,'WorkOrder',true);
                //Need to validation before completing the Work Order.
                List<WorkOrder> compWOs = new List<WorkOrder>();
                List<WOrkOrder> ownerChangedWO = new List<WorkOrder>(); 
                List<WorkOrder> syncEndDate = new List<WorkOrder>();
                Map<Id,WorkOrder> woCaseChangeMap = new Map<Id,WorkOrder>();                
                for(SObject obj :newList_WorkOrder){
                    WorkOrder wo = (WorkOrder)obj;
                    WorkOrder oldWO = (WorkOrder)oldMap_WorkOrder.get(wo.Id);
                    System.debug('//CLAY: OldWO:' + oldWO.Status + ' ' + oldWO.SFPS_FS_AllTasks_Completed__c + ' ' + oldWO.UNITY_Next_Step__c);
                    System.debug('//CLAY: New WO:'+ wo.Status + ' ' + wo.SFPS_FS_AllTasks_Completed__c + ' ' + wo.UNITY_Next_Step__c) ;
                    //if(wo.Status == 'Completed' && wo.Status != oldWO.Status && wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE)
                    //if(wo.Status == 'Completed' && wo.SFPS_FS_OverallStatus__c != oldWO.SFPS_FS_OverallStatus__c && wo.SFPS_FS_OverallStatus__c == 'Completed' && wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE)
                    //CLAY: trying to head off the entire process builder that completes all tasks. Instead of checking for status completed/overall status, lets try using the debrief fields
                    if(wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE && (wo.Status == 'IVR Check Out - Agent Review Needed' || wo.Status == 'Reopened') && (oldWO.SFPS_FS_AllTasks_Completed__c != 'All Tasks Completed/Verified'
                                                                                                && wo.SFPS_FS_AllTasks_Completed__c == 'All Tasks Completed/Verified' 
                                                                                                && oldWO.UNITY_Next_Step__c != 'Completion Confirmed' 
                                                                                                && wo.UNITY_Next_Step__c == 'Completion Confirmed')){
                             compWOs.add(wo);
                              
                            DateTime completedDate = null;
                            DateTime currentDateTime = System.now();
                            String userName = UserInfo.getName();
                            TimeZone tz =  UserInfo.getTimeZone();
                            String tsDisplay = tz.getDisplayName();
                          
                            String tempCompletedDate = UNITY_TimeInput_Ctlr.convertDateTime(currentDateTime, tz.toString());
                            completedDate = DateTime.parse(tempCompletedDate);
                                 
                           if( wo.SFPS_FS_LastCheckOut__c != null){ 
                              Decimal minNum =  ((completedDate.getTime())/1000/60) - ((wo.SFPS_FS_LastCheckOut__c.getTime())/1000/60);              
                              wo.UNITY_Time_to_Debrief__c = minNum;
                              wo.UNITY_Date_Time_Debrief_Completed__c = completedDate;
                           }
                           
                            
                            if (wo.SFPS_FS_AllTasks_Completed__c == 'All Tasks Completed/Verified' && wo.UNITY_Debrief_Agent__c == null){
                                wo.UNITY_Debrief_Agent__c = userName;
                            }
                         }                        
                     
                    if(wo.OwnerId != oldWO.OwnerId && !wo.MSPFS_Intercompany_Transfer__c){
                        ownerChangedWO.add(wo);
                    }
                    
                     //if(wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE && wo.SFPS_FS_AllTasks_Completed__c == 'Job Complete; Reopen for Usage Request') {
                     //    wo.Status = 'Reopened';
                     //}
                         
                    //Populate the EndDate
                    if((wo.StartDate != null && wo.StartDate != oldWO.StartDate) || 
                       (String.isNotBlank(wo.UNITY_Tech_ETA_Date_Cust__c) && wo.UNITY_Tech_ETA_Date_Cust__c != oldWO.UNITY_Tech_ETA_Date_Cust__c) || 
                       (wo.StartDate != null && wo.EndDate == null) || 
                       (String.isNotBlank(wo.UNITY_Tech_ETA_Date_Cust__c) && wo.EndDate == null)){
                            if(String.isNotBlank(wo.UNITY_Business_Unit__c) && String.isNotBlank(wo.UNITY_Account_Time_Zone__c)){
                                if(!wo.MSPFS_Intercompany_Transfer__c && !wo.UNITY_Business_Unit__c.contains('MSP')){
                                    DateTime startDate = null;
                                    if(String.isNotBlank(wo.UNITY_Tech_ETA_Date_Cust__c)){
                                        startDate = UNITY_TimeInput_Ctlr.convertDateTime(wo.UNITY_Tech_ETA_Date_Cust__c,wo.UNITY_Account_Time_Zone__c);
                                    }else if(wo.StartDate != null){
                                        startDate = wo.StartDate;
                                    }
                                    DateTime endDate = startDate != null ? startDate.addMinutes(60) : null;
                                    wo.StartDate = startDate;
                                    wo.EndDate = endDate;
                                }
                            }
                                
                    }else if ((wo.StartDate == null && wo.StartDate != oldWO.StartDate) ||
                              (wo.UNITY_Tech_ETA_Date_Cust__c == null && wo.UNITY_Tech_ETA_Date_Cust__c != oldWO.UNITY_Tech_ETA_Date_Cust__c) ){
                                    wo.StartDate = null;
                                    wo.EndDate = null;
                    }

                    if (wo.CaseId != oldWO.CaseId && (wo.UNITY_Order_Type__c == 'PMO' || wo.UNITY_Order_Type__c == 'PMA')){
                      woCaseChangeMap.put(wo.Id, wo);
                    }

                }
                if(!compWOs.isEmpty())
                    validateCompletedWO(compWOs);

                if(!ownerChangedWO.isEmpty()){
                    revertOwnerChange(ownerChangedWO);
                }
                if (woCaseChangeMap.size() > 0)
                    evaluateAndSetExpectingCaseFlag(woCaseChangeMap); 
            }//End if trigger.isUpdate
            //populate ultimate parent text field that is used for community sharing
            if (newMap_WorkOrder != null){
                Map<Id,WorkOrder> customerMap = new  Map<Id,WorkOrder>([SELECT Id, UNITY_Customer__r.UNITY_Company__c 
                                                        FROM WorkOrder WHERE Id in :newMap_WorkOrder.keySet()]);
                
                for(SObject obj :newList_WorkOrder){
                    WorkOrder wo = (WorkOrder)obj;
                    WorkOrder woCustomer = customerMap.get(wo.Id);
                    if (wo.UNITY_Customer__c != null && woCustomer.UNITY_Customer__c != null)
                        wo.Customer_Ultimate_Parent_Text__c = woCustomer.UNITY_Customer__r.UNITY_Company__c;
                }
            }
        //}
    }
    
    public override void bulkAfter(List<SObject> newList_WorkOrder, List<SObject> oldList_WorkOrder, Map<Id,SObject> oldMap_WorkOrder, Map<Id,SObject> newMap_WorkOrder){
        //if(runTriggerOnce_After()){
            //Set of case id to check for Attachment Compliant
            Set<Id> aComp = new Set<Id>();
			List<WorkOrder> shareToVendorList = new List<WorkOrder>(); //WOs that has an assigned vendor
			List<WorkOrder> unshareToVendorList = new List<WorkOrder>(); //WOs that's no longer assigned to a certain vendor                
            //List of Work Orders to recognize revenuw on intercompany transfer process
            if(Trigger.isUpdate){
                //This portion of code is to find out if Vendor Assignment Status changed to Assigned
                //to assign the related Case to the BU Customer Team after Vendor Accepts initial WO 
                //List<WorkOrder> acceptedWOs = new List<WorkOrder>();
                Set<Id> cids = new Set<Id>();
                for(SObject so :newList_WorkOrder){
                    WorkOrder wo = (WorkOrder)so;
                    WorkOrder oldWO = (WorkOrder)oldMap_WorkOrder.get(wo.Id);
                    System.debug('##### Vendor Status: ' + wo.UNITY_Vendor_Status__c);
                    System.debug('##### Status: ' + wo.Status);
                    System.debug('##### old Vendor Status: ' + oldWO.UNITY_Vendor_Status__c);
                    System.debug('##### old Status: ' + oldWO.Status);
                    if(wo.UNITY_Vendor_Status__c == 'Accepted' && (wo.UNITY_Vendor_Status__c != oldWO.UNITY_Vendor_Status__c)){
                        //acceptedWOs.add(wo);
                        cids.add(wo.CaseId);
                    }
                    if(((wo.UNITY_Attachment_Compliant__c && !oldWO.UNITY_Attachment_Compliant__c) || 
                        (wo.Status == 'Completed' && wo.Status != oldWO.Status) || 
                        (wo.Status == 'Canceled' && wo.Status != oldWO.Status))
                      ){
                          aComp.add(wo.CaseId);
                    }
                    if (wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE || wo.RecordTypeId == UNITY_Constants.WO_NON_WORK_RECORDTYPE || wo.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
                    	if (oldWO.UNITY_Assigned_Vendor__c != wo.UNITY_Assigned_Vendor__c){	
                            system.debug('@@@WorkOrderTrigger share assignedVendorChanged');
		                	if (wo.UNITY_Assigned_Vendor__c != null)
		                		shareToVendorList.add(wo);
		                	if (oldWO.UNITY_Assigned_Vendor__c != wo.UNITY_Assigned_Vendor__c)
		                		unshareToVendorList.add(oldWO);
                    	}
                        if (oldWO.OwnerID != wo.OwnerId){
                            system.debug('@@@WorkOrderTrigger share owner changed');
                    		shareToVendorList.add(wo);
                        }
                        if (oldWO.Status != wo.Status && wo.Status == 'Canceled'){
                            system.debug('@@@WorkOrderTrigger share status changed');
                            unshareToVendorList.add(oldWO);
                        }
                    }
                }
                //Now that we have determined that there are Work Orders that got accepted...
                //We need to verify that it is the initial Work Order in the Case. If so,
                //We need to assign that case to the specific quote for the team. 
                //We'll use the reassignCase method to do that passing the case Ids
                if(cids.size() > 0){
                    if(!System.isFuture())
                        reassignCaseToCustTeam(cids);
                }
                
            }else if(Trigger.isInsert){
                for(SObject so :newList_WorkOrder){
                    WorkOrder wo = (WorkOrder)so;
                    aComp.add(wo.CaseId);
                    if ((wo.RecordTypeId == UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE || wo.RecordTypeId == UNITY_Constants.WO_NON_WORK_RECORDTYPE || wo.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE) && wo.UNITY_Assigned_Vendor__c != null)
                    	shareToVendorList.add(wo);
                }
            }
            //Check if there are cases to check for attachment compliant
            System.debug('#####Izay: aComp = ' + aComp);
            if(!aComp.isEmpty()){
                if(!System.isFuture())
                    processAttachmentCompliant(aComp);
            }
			if (unshareToVendorList.size() > 0)
            	UNITY_WorkOrderTriggerHandler_NoSharing.unshareToVendor(unshareToVendorList);
            if (shareToVendorList.size() > 0)
            	UNITY_WorkOrderTriggerHandler_NoSharing.shareToVendor(shareToVendorList);             
        //}
    }

    private static Boolean validationHasRun = false;

    /**This Method validates a work order when it is completed.
    *@param wos - List<WorkOrder> : The list of work orders that need validation
    */
    public static void validateCompletedWO(List<WorkOrder> wos){

        if ( validationHasRun ) return;
        validationHasRun = true;

        if(!wos.isEmpty()){
            Map<Id,WorkOrder> wosMap = new Map<Id,WorkOrder>();//Map to hold work orders by their Ids
            Map<Id,Id> woVendorMap = new Map<Id,Id>();//Map to hold the assigned vendor on the wo by the wo id
            String poRTId = UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE;
            String partSourceRTId = UNITY_Constants.PART_SOURCING_PURCHASE_ORDER_RECORDTYPE;
            String nonWorkRTId = UNITY_Constants.WO_NON_WORK_RECORDTYPE;
            String urRectype = UNITY_Constants.ORDER_USAGE_REQUEST_RECORDTYPE; 
            for(WorkOrder wo :wos){
                wosMap.put(wo.Id, wo);
                woVendorMap.put(wo.Id,wo.UNITY_Assigned_Vendor__c);
            }
            System.debug('#####Izay: woVendorMap = ' + JSON.serializePretty(woVendorMap));
            //Need to get all POs under this Work Order to include those part sourcing under related Non-Work WOs
            //###Izay: Updated query to exclude POs in "Part Source Identified" status
            List<Order> orders = [SELECT Id, OrderNumber, UNITY_Vendor__c, Status, RecordTypeId, FSO__WorkOrder__r.Status, 
                                    FSO__WorkOrder__c, FSO__WorkOrder__r.UNITY_Related_Work_Order__c, FSO__WorkOrder__r.RecordTypeId, FSO__WorkOrder__r.SFPS_FS_OverallStatus__c
                                  FROM Order WHERE
                                  (FSO__WorkOrder__c IN :wosMap.keySet() OR FSO__WorkOrder__r.UNITY_Related_Work_Order__c IN :wosMap.keySet())
                                  AND Status != 'Cancelled' AND Status != 'Rejected' AND Status != 'Parts Source Identified' 
                                  AND ((RecordTypeId = :poRTId  OR RecordTypeId = :partSourceRTId) OR (RecordTypeId =: urRectype AND Status != 'PO Created'))];
            System.debug('#####Izay: orders = ' + JSON.serializePretty(orders));
            //Put all the order by their work order id
            Map<Id,List<Order>> ordWOMap = new Map<Id,List<Order>>();
            for(Order o :orders){
                //###Izay: Changed to not exclude part sourcing POs and use the WO id to identify that the PO belongs to the WO beinf completed 
                if(!ordWOMap.containsKey(o.FSO__WorkOrder__c) && wosMap.containsKey(o.FSO__WorkOrder__c)/* && o.RecordTypeId == poRTId*/){
                    ordWOMap.put(o.FSO__WorkOrder__c,new List<Order>());
                    ordWOMap.get(o.FSO__WorkOrder__c).add(o);
                //###Izay: Added to check related WO record type to be non-work
                }else if(o.RecordTypeId == partSourceRTId && wosMap.containsKey(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c) &&
                         !ordWOMap.containsKey(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c) && o.FSO__WorkOrder__r.RecordTypeId == nonWorkRTId){
                    ordWOMap.put(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c,new List<Order>());
                    ordWOMap.get(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c).add(o);
                }else if(wosMap.containsKey(o.FSO__WorkOrder__c)/*o.RecordTypeId == poRTId*/ && ordWOMap.containsKey(o.FSO__WorkOrder__c)){
                    ordWOMap.get(o.FSO__WorkOrder__c).add(o);
                }else if(wosMap.containsKey(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c) && o.RecordTypeId == partSourceRTId && 
                         ordWOMap.containsKey(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c) && o.FSO__WorkOrder__r.RecordTypeId == nonWorkRTId){
                    ordWOMap.get(o.FSO__WorkOrder__r.UNITY_Related_Work_Order__c).add(o);
                }else if( o.RecordTypeId == urRectype ){
                    if (!ordWOMap.containsKey(o.FSO__WorkOrder__c)) ordWOMap.put(o.FSO__WorkOrder__c,new List<Order>());
                    ordWOMap.get(o.FSO__WorkOrder__c).add(o);
                }
            }
            System.debug('#####Izay: ordWOMap = ' + JSON.serializePretty(ordWOMap));
            //Now find if all the POs in the WO are in the correct status (any invoiceable status)
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
            System.debug('#####Izay: delimitedInvoiceableStatuses = ' + JSON.serializePretty(delimitedInvoiceableStatuses));
            
            for(Id id :ordWOMap.keySet()){
                Boolean pass = true;
                Boolean showMsg1 = false;
                Boolean showMsg2 = false;
                String msg = 'The following order(s) need to be finalized or completed: ';
                String msg2 = ' The following usage request(s) need to be cancelled or po created: ';
                String oNum = '';
                for(Order o :ordWOMap.get(id)){
                    if(o.RecordTypeId == poRTId && !delimitedInvoiceableStatuses.contains(o.Status)){
                        if(o.UNITY_Vendor__c == woVendorMap.get(id)){
                            pass = false;
                            showMsg1 = true;
                            msg += 'Order ' + o.OrderNumber;
                            oNum =  o.OrderNumber;
                            System.debug('//CLAY: We have found a PO that will prevent completion. Rolling back.');
                        }
                    }else if(o.RecordTypeId == partSourceRTId && !delimitedInvoiceableStatuses.contains(o.Status)){
                        pass = false;
                        showMsg1 = true;
                        msg += 'Order ' + o.OrderNumber;
                        oNum =  o.OrderNumber;
                        System.debug('//CLAY: We have found a part sourcing PO that will prevent completion. Rolling back.');
                    }else if( o.RecordTypeId == urRectype ){
                        pass = false;
                        showMsg2 = true;
                        //Clay: TODO - Could we insert HTML here for the javascript to render as a link for the user? Would need to target primary/sub tab
                        msg2 += 'Order ' + o.OrderNumber;
                        oNum =  o.OrderNumber;
                        System.debug('//CLAY: We have found a usage request that will prevent completion. Rolling back.');
                    }
                }
                if(!pass){
                    
                    msg += ' Please fix before completing this work order.';
                    msg2 += ' Please fix before completing this work order.';

                    /* Comment out building notification due to null exception & notification not used
                    List<UNITY_Push_Notification__c> notifs = new List<UNITY_Push_Notification__c>();
                    UNITY_Push_Notification__c notif = new UNITY_Push_Notification__c();
                    notif.Message__c = (( showMsg1 ) ? msg : '' ) + (( showMsg2 ) ? msg2 : '' ) ;
                    notif.Record_Name__c = wosMap.get(id).WorkOrderNumber;
                    notif.Record_Id__c = id;
                    notif.Subject__c = 'Error Completing Work Order';
                    notif.Subscriber__c = UserInfo.getUserId();
                    notif.Type__c = 'Process Error';
                    notifs.add(notif);
                    insertPushNotification(JSON.serialize(notifs)); 
                    */
                    
                    
                    wosMap.get(id).Status = 'IVR Check Out - Agent Review Needed';
                    wosMap.get(id).SFPS_FS_AllTasks_Completed__c = null;                    
                    wosMap.get(id).UNITY_Next_Step__c = null;
                    //Clay: Izay had been using notification panel because we were behind the process builders. Now this is before. 
                    //Proof of concept - using standard addError method on work order to prevent any changes. Can pass in order number as well for user.
                    //TODO: Can then remove the notification and rollback attempt
                    wosMap.get(id).addError('The following Order is still open: '+oNum+' Please cancel or complete it before trying to complete this Work Order');



                }
            }
        }
    }
    /**This method reassigns a case to the appropriate team queue after its first work order has been dispatched (accepted by a vendor)
    *@param cids - Set<Id>: The case ids to reassign to team
    */
    @future
    public static void reassignCaseToCustTeam(Set<Id> cids){
        UNITY_Constants.isExecutingContext('reassignCaseToCustTeam');
        if(cids != null){
            //First Need to do some setup... 
            //Get the values from trhe Custom Setting for the field to look at from the account
            Map<String,UNITY_BU_Team_Field_Map__c> fieldsMap = UNITY_BU_Team_Field_Map__c.getAll();
            //Now buil a query using those fields to get the needed values
            String mergeFields = '';
            String myCids = ApexHelper.joinIds(cids);
            for(UNITY_BU_Team_Field_Map__c fMap :fieldsMap.values()){
                mergeFields += 'Account.'+fMap.UNITY_Field_API_Name__c + ',';
            }
            String query = 'SELECT Id,OwnerId,AccountId,UNITY_Business_Unit__c,Account.UNITY_Agent_Work_Hour_End_Time__c,Account.UNITY_Agent_Work_Day__c,'+
                mergeFields+
                '(SELECT Id,UNITY_Vendor_Status__c FROM WorkOrders)';
            query += ' FROM Case WHERE ID IN ' + myCids;
            //Get the cases with the related Work Orders
            List<Case> cases = Database.query(query);
            if(cases.size() > 0){
                //Need to add the case to a Map by its Id
                Map<Id,Case> cMap = new Map<Id,Case>();
                //Also need to create the String for the Queue name to assign the case to
                Map<Id,String> cQueueNameMap = new Map<Id,String>();
                //Add queue names to this set to run a clean query for queues by names
                Set<String> qNames = new Set<String>();
                for(Case c :cases){
                    if(!(c.WorkOrders.size() > 1)){
                        cMap.put(c.Id,c);
                        String qName = 'UNITY_';
                        if(fieldsMap.containsKey(c.UNITY_Business_Unit__c)){
                            String fname = fieldsMap.get(c.UNITY_Business_Unit__c).UNITY_Field_API_Name__c;
                            String team = (String)c.getSObject('Account').get(fname);
                            if(String.isNotBlank(team)){
                                qName += c.UNITY_Business_Unit__c;
                                qName += '_';
                                team = team.replaceAll(' ', '_');
                                qName += team;
                            }else{
                                qName = '';
                            }
                        }else{
                            //Need Queue name for unknown BU value
                            qName = '';
                        }
                        System.debug('##### qName: ' +  qName);
                        if(String.isNotBlank(qName)){
                            cQueueNameMap.put(c.Id,qName);
                            qNames.add(qName);
                        }
                    }//End of WO.size()
                }//End for Cases
                if(qNames.size() > 0){
                    //Now that I have the queue names and know which case goes to each queue
                    //Need to queury the queues
                    List<Group> queues = [SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN :qNames and Type = 'Queue'];
                    //Add the queues to a map by queu dev name
                    Map<String,Id> qIdsMap = new Map<String,Id>();
                    for(Group q :queues){
                        qIdsMap.put(q.DeveloperName,q.Id);
                    }
                    //Now we are ready to assign the queue id as the owner to the cases
                    for(Id cid :cMap.keySet()){
                        if(cQueueNameMap.containsKey(cid)){
                            String qName = cQueueNameMap.get(cid);
                            if(qIdsMap.containsKey(qName)){
                                System.debug('##### qid: ' + qIdsMap.get(qName));
                                cMap.get(cid).OwnerId = qIdsMap.get(qName);
                            }
                        }
                    }//End for case Id
                    //Now try to update the cases
                    try{
                        update cMap.values();
                    }catch(Exception e){
                        //Need exception handling here
                        System.debug('##### Error: ' + e.getMessage());
                    }
                }//End if qNames
            }//End if cases.size()
        }
    }
    /**This method updates the Attachment Compliance flag on the Case when all Work Orders under the case are Attachment Compliant
    *@param cids - Set<Id>: The case ids to check for attachment compliance
    */
    @future
    public static void processAttachmentCompliant(Set<Id> cids){
        UNITY_Constants.isExecutingContext('processAttachmentCompliant');
        if(cids != null && !cids.isEmpty()){
            List<Case> cases = [SELECT Id,UNITY_Attachment_Compliant__c, 
                                (
                                    SELECT Id,UNITY_Attachment_Compliant__c,Status
                                    FROM WorkOrders WHERE Status != 'Canceled'
                                )
                                FROM Case WHERE Id IN :cids AND RecordTypeId = :UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE];
            System.debug('#####Izay: cases = ' + cases);
            if(!cases.isEmpty()){
                for(Case c :cases){
                    Boolean isAllComp = true;
                    if(!c.WorkOrders.isEmpty()){
                        for(WorkOrder wo :c.WorkOrders){
                            if(!wo.UNITY_Attachment_Compliant__c)
                                isAllComp = false;
                        }
                    }else{
                        isAllComp = false;
                    }
                    System.debug('#####Izay: isAllComp = ' + isAllComp);
                    c.UNITY_Attachment_Compliant__c = isAllComp;
                }
                update cases;
            }
        }
    }
    /**This method inserts push notifications.
    *@param notifications - String: List<UNITY_Push_Notification__c> serialized in JSON format
    */
    @future
    public static void insertPushNotification(String notifications){
        if(String.isNotBlank(notifications)){
            List<UNITY_Push_Notification__c> notifs = 
                (List<UNITY_Push_Notification__c>)JSON.deserialize(notifications, List<UNITY_Push_Notification__c>.class);

            insert notifs;
        }
            
    }
    
    public static void revertOwnerChange(List<workOrder> workOrders){
        if(!workOrders.isEmpty()){
            Set<Id> buids = new Set<Id>();
            for(WorkOrder wo :workOrders){
                buids.add(wo.UNITY_Business_Unit_Account__c);
            }
            Map<Id,Account> busMap = new Map<Id,Account>([SELECT Id,MSPFS_Is_MSP_BU__c FROM Account WHERE Id IN :buids AND MSPFS_Is_MSP_BU__c = FALSE]);
            for(WorkOrder wo :workOrders){
                if(busMap.containsKey(wo.UNITY_Business_Unit_Account__c)){
                    wo.OwnerId = wo.UNITY_Agent__c;
                }
            }
        }
    }
    
  
    
    //Returns a map of WO ID and the Group ID of the Vendor Account's Role (Community Role)
    public static Map<Id, Id> getGroupIdAndWOrderIdMap (List<WorkOrder> workOrders){
		Map<Id, Id> result = new Map<Id, Id>();

    	Map<Id, Id> acctWOrderMap = new Map<Id,Id>();
    	for(WorkOrder wo: workOrders)
    		acctWOrderMap.put(wo.UNITY_Assigned_Vendor__c, wo.Id);
    	
    	system.debug('@@@getGroupIdAndWOrderIdMap acctWOrderMap:'+acctWOrderMap);
    	
    	// Select Account 
		Map<Id, Account> vendorList = new Map<Id, Account>([SELECT Id, IsCustomerPortal
										FROM Account
	                                 	WHERE Id In :acctWOrderMap.keySet()
	                                 	AND IsCustomerPortal = true]);

		if (vendorList.size() <= 0)
       		return null;

        //Query the UserRoles associated to the accounts
        List<UserRole> userRoleList = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId in :vendorList.keySet()];
		
		Map<Id, Id> roleAndWOrderMap =  new Map<Id, Id>();
		for (UserRole role: userRoleList){
            roleAndWOrderMap.put(role.Id, acctWOrderMap.get(role.PortalAccountId));
        }

        system.debug('@@@getGroupIdAndWOrderIdMap roleAndWOrderMap:'+roleAndWOrderMap);
        
        if (roleAndWOrderMap.size() <= 0)
       		return null;
        
        //Query Group ID 
        List<Group> groupList = [SELECT Id, RelatedID FROM Group WHERE RelatedID in :roleAndWOrderMap.keySet() AND Type = 'RoleAndSubordinates'];
        
        system.debug('@@@getGroupIdAndWOrderIdMap groupList:'+groupList);
        
        if (groupList.size() <= 0)
        	return null;
        
        for (Group g: groupList){
            result.put(g.Id, roleAndWOrderMap.get(g.RelatedID));
        }    	
    	return result;
    }    

    //Reset UNITYPM_Expecting_Case_from_Integration__c flag
    private static void evaluateAndSetExpectingCaseFlag(Map<id, WorkOrder> woList){
        system.debug('@@@evaluateAndSetExpectingCaseFlag woList'+woList);

        Map<id, Id> woCaseMap = new Map<id, id>();
        for (WorkOrder wo : woList.values()){
            woCaseMap.put(wo.Id, wo.CaseId);
        }

        Map<id, Case> caseList = new Map<Id, Case>([SELECT Id, RecordTypeId FROM Case where Id in :woCaseMap.values()]);

        for(Id woId : woCaseMap.keySet()){
            WorkOrder wo = woList.get(woId);
            Case c = caseList.get(woCaseMap.get(woId));

            if (c.RecordTypeId == UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE){
              system.debug('@@@evaluateAndSetExpectingCaseFlag Service Request? Yes');
              wo.UNITYPM_Expecting_Case_from_Integration__c = false;
            }
        }
    }
    //Clay
    //This method will make the last two WOLIs of work orders not completed
    //WHY: This was needed to finish the validation

    /**
    *** This variable and method are used to prevent triggers recursion on before insert/update
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
    /**
    *** This variable and method are used to prevent triggers recursion on after insert/update
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
}