public class UNITY_FixWorkOrderManualSharing  implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator([
              SELECT Id FROM Account where UNITY_Has_Community_Member__c = true ]);
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope) {
        Set <ID> accID = new Set<ID>();
        for (Account acc : scope){
            accID.add(acc.ID);
        }
        List< WorkOrder> woList = new List< WorkOrder> ([SELECT Id,UNITY_Assigned_Vendor__c 
                         FROM WorkOrder 
                         WHERE UNITY_Assigned_Vendor__c != null
						 AND Status != 'Canceled'
                         AND UNITY_Assigned_Vendor__r.IsCustomerPortal = true
                         AND UNITY_Assigned_Vendor__c in :accID
                         AND RecordTypeId in (Select Id From RecordType where sobjecttype = 'WorkOrder' and name in ('Service Request', 'Non-work'))
                        ]);

        List<UserRole> userRoles = [SELECT Id FROM UserRole WHERE PortalAccountId IN :accID];
        List<Group> vendorGroup = [SELECT Id FROM Group WHERE RelatedID IN  :userRoles AND Type = 'RoleAndSubordinates'];
        
        List<WorkOrderShare> woShare = [SELECT ID, ParentId, AccessLevel, RowCause, UserOrGroupId   
        		FROM WorkOrderShare  
        		WHERE  ParentId IN:woList AND RowCause  = 'Manual' AND  UserOrGroupId IN:vendorGroup ]; 
        			
        	
        Map<ID, WorkOrderShare> woShareIDs = new Map<ID, WorkOrderShare>();
        
        for (WorkOrderShare ws : woShare ){
            woShareIDs.put(ws.ParentId, ws);
        }
        
        Map <ID, List<WorkOrder>> woToShare = new Map<ID, List<WorkOrder>>();
        
        for (WorkOrder wo : woList){
           List<WorkOrder> temp = new List<WorkOrder>();
           
           if (!woShareIDs.containsKey(wo.ID)){
              
               if(!woToShare.containsKey(wo.UNITY_Assigned_Vendor__c)){
                   temp.add(wo);
                   woToShare.put(wo.UNITY_Assigned_Vendor__c, temp);
                   system.debug('>>> vendor >>' + wo.UNITY_Assigned_Vendor__c);
                   system.debug('>>> work order >>>' + temp);
               }
               else{
                   temp = woToShare.get(wo.UNITY_Assigned_Vendor__c);
                   temp.add(wo);
                   woToShare.put(wo.UNITY_Assigned_Vendor__c, temp); 
                   system.debug('**** vendor ****' + wo.UNITY_Assigned_Vendor__c);
                   system.debug('**** work order ****' + temp);
               }
           }
        }
       //===========================================================================================
       for (Id vID : woToShare.keySet()){
          List<WorkOrder> wol = new List<WorkOrder>();
           wol = woToShare.get(vID);
           system.debug('**** wo list ***' + wol.size()); 
           AddWorkOrderManualShare (vID, wol);
       }
			 
    }
    
     private  static void AddWorkOrderManualShare(ID vendorAccID, List<WorkOrder> WOrderList){
           
            UserRole userRole = [SELECT Id, PortalAccountId FROM UserRole WHERE PortalAccountId = :vendorAccID];
           
            Group vGroup = [SELECT Id, RelatedID FROM Group WHERE RelatedID = :userRole.Id AND Type = 'RoleAndSubordinates'];
            
            List<WorkOrderShare> shareToInsert = new List<WorkOrderShare>();
            for (WorkOrder wo:WOrderList){
                WorkOrderShare os = new WorkOrderShare();
                os.ParentId = wo.Id;
                os.AccessLevel = 'Read';
                os.RowCause = Schema.OrderShare.RowCause.Manual;
                os.UserOrGroupId = vGroup.ID;
                shareToInsert.add(os);
                system.debug('&&&&& share &&& ' + os);
                
            }
            
            system.debug('$$$$ sieze to update $$$ ' + shareToInsert.size());
            
            if (shareToInsert.size() > 0)
               insert shareToInsert;
     }
    
     public void finish(Database.BatchableContext context) {
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}