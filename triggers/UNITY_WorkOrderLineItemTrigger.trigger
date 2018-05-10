trigger UNITY_WorkOrderLineItemTrigger on WorkOrderLineItem (after insert, after update, after delete, before delete) {
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_WorkOrderLineItemTriggerHandler.class);
}