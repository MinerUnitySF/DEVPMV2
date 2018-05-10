public class UNITYPM_AssignVendorBulkControllerExt {
    public List<WorkOrder> workorderList {get; set;}
    private Set<Id> woIds = new Set<Id>();
    public id accountID {get;set;}
    public List<Account> vendorAccountList {get;set;}
    private ApexPages.StandardSetController cont;
 
     public UNITYPM_AssignVendorBulkControllerExt (ApexPages.StandardSetController controller){
         cont = controller;
      }
     
      public List<SelectOption> getVendorAccounts () {
         List<SelectOption> vendorsList = new List<Selectoption>();
          vendorAccountList = [SELECT ID, Name, UNITY_Vendor_Status__c, RecordType.Name  
                                    FROM Account  
                                    WHERE UNITY_Vendor_Status__c = 'Active' 
                                    AND RecordType.Name ='Vendor'];
              
          for (Account a :vendorAccountList){
              vendorsList.add(new SelectOption(a.Id, a.Name));
         }
                             
         return vendorsList;
     } 
     
      public PageReference assignVendor(){
          workorderList = (List<Workorder>)cont.getSelected();
          for (WorkOrder wo: workorderList){
              woIds.add(wo.Id);
          }

          List<WorkOrder> woToUpdate = [SELECT Id, AccountID, UNITY_Assigned_Vendor__c, UNITY_Current_PO__c,Status, RecordTypeId, 
                                        UNITY_Accepted_Vendor__c, UNITY_Vendor_Accept_Date__c, UNITY_Vendor_Status__c
                            FROM WorkOrder WHERE ID =:woIds  FOR UPDATE];
          
          for (WorkOrder wo: woToUpdate){
              if (wo.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE 
                  && wo.Status != 'Completed' && wo.Status != 'Canceled' && wo.Status != 'IVR Check Out - Agent Review Needed' && wo.Status != 'In Progress' ){
                        system.debug('@@@assignVendor accountID:'+accountID);
                      	wo.UNITY_Assigned_Vendor__c = accountID;
             			wo.Status = 'Pending Tech Dispatch';
             			wo.UNITY_Current_PO__c= null;
                      //if vendor changed, clear out these fields
                      if (accountID != wo.UNITY_Assigned_Vendor__c){
                          	wo.UNITY_Accepted_Vendor__c = null;
                        	wo.UNITY_Vendor_Accept_Date__c = null;
                        	wo.UNITY_Vendor_Status__c = '';
                      }
                  }
          }
          
          system.debug('@@@assignVendor woToUpdate:'+woToUpdate);
          Database.SaveResult[] saveResults = Database.update(woToUpdate, false);
          system.debug('@@@assignVendor saveResults:'+saveResults);
          return null;
      }

      public Boolean hasError { get { return ApexPages.hasMessages(); } }


}