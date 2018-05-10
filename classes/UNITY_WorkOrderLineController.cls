/*
 * @programer: Rodrigo Birriel
 * @date:      12/20/2016
 */
public class UNITY_WorkOrderLineController {
    public Id workOrderId {get; 
                           set {
                               workOrderId = value;
                               items = [SELECT Id,FSO__Order__c,LineItemNumber,Description, CreatedDate FROM WorkOrderLineItem
                                        WHERE WorkOrderId=:workOrderId  AND UNITY_PM_WOLI__c = false
                                        ORDER BY Createddate ASC, FSO__Order__c ASC NULLS FIRST];
                           }}
    
    public List<WorkOrderLineItem> items {get; set;}
    
}