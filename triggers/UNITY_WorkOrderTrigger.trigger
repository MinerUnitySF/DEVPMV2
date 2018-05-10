/*------------------------------------------------------------
Name:           UNITY_WorkOrderTrigger 
Author:         Dan nakonieczny
Company:        Miner
Description:    This trigger updates parent(Case) status by calling updateStatus() method updates status field by assign least status of its workorders
History:
03/21/2016      Krishna Kamineni Added if statement.
=====================================================
Changelog
=====================================================
Developer:      Izay Ramos
Description:    Added call to intercompany transfer sharing process
Date:           1/20/2016
=====================================================
------------------------------------------------------------*/
trigger UNITY_WorkOrderTrigger on WorkOrder (after insert, after update, after delete, before insert, before update) {
    system.debug(LoggingLevel.INFO, '****** UNITY_WorkOrderTrigger');
    
    Private Set<Id> PMWorkOrderSet = new Set<Id>{UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE}; 
    Public List<SObject> new_SR_WorkOrders = UNITY_Utils.excludeRecordType(trigger.new, PMWorkOrderSet);
    Public Map<Id, SObject> newMap_SR_WorkOrders = UNITY_Utils.excludeRecordType(Trigger.newMap, PMWorkOrderSet);    
    Public Map<Id, SObject> oldMap_SR_WorkOrders = UNITY_Utils.excludeRecordType(Trigger.oldMap, PMWorkOrderSet);    
    
    //Retrieve all record types except PMs        
    Map<Id, Schema.RecordTypeInfo> defaultRecordTypeMap = Schema.SObjectType.WorkOrder.getRecordTypeInfosById().clone();
    defaultRecordTypeMap.remove(UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE);

    //Trigger Handler for PM Work Orders 
    UNITY_TriggerFactory.createAndExecuteHandler(UNITYPM_WorkOrderTriggerHandler_Miner.class, PMWorkOrderSet);  
    //Trigger Handler for non-PM Work Orders   
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_WorkOrderTriggerHandler.class, defaultRecordTypeMap.keySet());
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_WorkOrderTriggerHandler_Miner.class, defaultRecordTypeMap.keySet());

    //Izay: Added to call the intercompany transfer process sharing after all UNITY code runs.  ????
    if(Trigger.isBefore && Trigger.isUpdate && MSPFS_WorkOrderHandler.handleIntercompanyTransferOnce()){
         MSPFS_WorkOrderHandler.handleIntercompanyTransferSharing(new_SR_WorkOrders, oldMap_SR_WorkOrders);
    }else if(Trigger.isAfter && Trigger.isInsert && MSPFS_WorkOrderHandler.handleIntercompanyTransferOnce()){
        MSPFS_WorkOrderHandler.handleIntercompanyTransferSharing(new_SR_WorkOrders,null);
    }
    
}