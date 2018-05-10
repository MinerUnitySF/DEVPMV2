public class UNITY_UpdateWODateTimeDebriefCompleted  implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator([
              SELECT Id, WorkOrderId, CreatedDate, Field, OldValue, NewValue 
                                   FROM WorkOrderHistory WHERE Field= 'SFPS_FS_AllTasks_Completed__c' 
                                   AND  CreatedDate =LAST_N_DAYS:31
             ]);
    }
    
    public void execute(Database.BatchableContext context, List<WorkOrderHistory> scope) {
         Map<ID, DateTime> woUpdate = new Map<ID, DateTime>();
	       for (WorkOrderHistory woh: scope)
		   {
		      if (woh.NewValue == 'All Tasks Completed/Verified'){
			     woUpdate.put(woh.WorkOrderId, woh.CreatedDate);
				//system.debug('>>>> woh.WorkOrderId >>>>>' + woh.WorkOrderId + '>>>> woh.CreatedDate >>>>>' + woh.CreatedDate);
			  }	   
		   }
		   
		   system.debug('###### map size #####' + woUpdate.size());	
		   List<WorkOrder> woSendToUpdate = new List<WorkOrder>();
			
           for (WorkOrder wo : [SELECT ID, UNITY_Date_Time_Debrief_Completed__c 
                                           FROM WorkOrder 
                                                 WHERE id IN : woUpdate.keySet() 
                                                        AND UNITY_Date_Time_Debrief_Completed__c = null]){
		       DateTime dt = woUpdate.get(wo.ID);
		       //system.debug('@@@@@ wo.ID @@@@@@' + wo.ID + '@@@@@@  dt @@@@@' + dt);
			   wo.UNITY_Date_Time_Debrief_Completed__c = dt;
			   woSendToUpdate.add(wo);
			}		   

			 if (woSendToUpdate.size() > 0){
			    update woSendToUpdate;
			 }	  
			 
    }
    
     public void finish(Database.BatchableContext context) {
    }
    
}