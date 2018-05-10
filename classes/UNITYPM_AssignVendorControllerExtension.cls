public class UNITYPM_AssignVendorControllerExtension {
    public ID id {get;  set;}
    public WorkOrder workorder {get; set;}
    public WorkOrder wo {get; set;}
    public id accountID {get;set;}
    public String assignedVendor {get; set;}
    public List<Account> vendorAccountList {get;set;}
 
     public UNITYPM_AssignVendorControllerExtension (ApexPages.StandardController controller){
         workorder = (Workorder)controller.getRecord();
         id = (ID) controller.getRecord().get('id'); 
         //id = '0WO3B000000DeAPWA0';
       
         wo = [SELECT Id, AccountID, UNITY_Assigned_Vendor__c, UNITY_Current_PO__c,Status
                                  FROM WorkOrder WHERE ID =:id];
                                  
         accountID = wo.AccountID;
         assignedVendor ='';
         
          if (wo.UNITY_Assigned_Vendor__c != null){
             assignedVendor = wo.UNITY_Assigned_Vendor__c;
         }
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
       wo = [SELECT Id, AccountID, UNITY_Assigned_Vendor__c, UNITY_Current_PO__c,Status
                            FROM WorkOrder WHERE ID =:id  FOR UPDATE];
          if ( wo != null && wo.Status != 'Completed' && wo.Status != 'Canceled' && wo.Status != 'IVR Check Out - Agent Review Needed' && wo.Status != 'In Progress')   {
                 //wo.UNITY_Assigned_Vendor__c = assignedVendor;
                 system.debug('@@@assignVendor:'+workOrder.UNITY_Assigned_Vendor__c);
                 wo.UNITY_Assigned_Vendor__c = workOrder.UNITY_Assigned_Vendor__c;
                 wo.Status = 'Pending Tech Dispatch';
                 wo.UNITY_Current_PO__c= null;
             
             try{ 
                update wo;
                system.debug('@@@@assignedVendor' + wo.ID);
             }
             catch (Exception ex){
                 system.debug('@@@ ex:'+ex);
             }
          }
          else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Vendor cannot be reassigned at this stage.');
            	ApexPages.addMessage(myMsg);
            	return null;
          }
          return null;
      }
      
      public Boolean hasError { get { return ApexPages.hasMessages(); } }

}