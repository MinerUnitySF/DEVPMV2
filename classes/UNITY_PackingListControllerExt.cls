public class UNITY_PackingListControllerExt {

	private final Order order;
	public WorkOrder wo {get;set;}
	public String relatedServiceWONo {get;set;}
	public String relatedServiceWOPO {get;set;}

	public UNITY_PackingListControllerExt(ApexPages.StandardController stdController){
		List<String> fields = new List<String>(); 
		this.order = (Order)stdController.getRecord();
        
		system.debug('@@@ UNITY_PackingListControllerExt this.order'+this.order);
        system.debug('@@@ UNITY_PackingListControllerExt this.order.UNITY_Originating_Usage_Request__c'+this.order.UNITY_Originating_Usage_Request__c);
		if (this.order != null 
			&& this.order.UNITY_Originating_Usage_Request__c != null  			
           ){
               system.debug('@@@ UNITY_PackingListControllerExt this.order.id'+this.order.id);
               
               wo = [SELECT WorkOrderNumber, UNITY_Customer_PO__c,
                     (SELECT Id,OrderNumber, UNITY_Originating_Usage_Request__c FROM FSO__Orders__r
                      WHERE RecordTypeId = :UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE 
                      AND UNITY_Originating_Usage_Request__c = :this.order.UNITY_Originating_Usage_Request__c  
                      AND Status in (:UNITY_Constants.ORDER_STATUS_ACCEPTED, :UNITY_Constants.ORDER_STATUS_FINAL_FINAL, :UNITY_CONSTANTS.ORDER_STATUS_DRAFT)
                      Order By CreatedDate desc)
                     FROM WorkOrder
                     WHERE Id in (SELECT FSO__WorkOrder__c FROM Order WHERE Id = :this.order.UNITY_Originating_Usage_Request__c)];
               system.debug('@@@ UNITY_PackingListControllerExt wo:'+wo);
               
               if (wo != null)
                   relatedServiceWONo = wo.WorkOrderNumber;
               if (wo.FSO__Orders__r != null && wo.FSO__Orders__r.size() > 0){
                   system.debug('@@@ UNITY_PackingListControllerExt wo.FSO__Orders__r:'+wo.FSO__Orders__r);
                   relatedServiceWOPO = wo.FSO__Orders__r[0].OrderNumber;
               }
           }
			
			
	}
	
}