public class UNITYPM_WorkOrderTriggerHandler_Miner extends UNITY_BaseHandler{
     
    private static Set<Id> includeRTSet = new Set<Id>{UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE};
    public static List<SObject> newList_WO = UNITY_Utils.includeRecordType(trigger.new, includeRTSet);
    public static Boolean woliCheckInCheckOutCreated = false;

     public override void bulkBefore(List<SObject> newList_WorkOrder, List<SObject> oldList_WorkOrder, Map<Id,SObject> oldMap_WorkOrder, Map<Id,SObject> newMap_WorkOrder){
        if (isFirstTriggerRun_Before){
            if(trigger.isInsert){
                UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_WorkOrder,null,'WorkOrder',true);
            }
                 
            Map<Id,WorkOrder> vendorChangedMap = new Map<Id,WorkOrder>();
            Map<Id,WorkOrder> woDebriefMap = new Map<Id,WorkOrder>();

            if(trigger.isUpdate){
              
              UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_WorkOrder,oldMap_WorkOrder,'WorkOrder',true);      

              for(SObject sObj :  newList_WorkOrder){
                  WorkOrder wo = (WorkOrder)sObj;
                  WorkOrder oldWo = (WorkOrder)oldMap_WorkOrder.get(wo.Id);
              
                  //Check if vendor changed or got populated
                  if (wo.UNITY_Assigned_Vendor__c != oldWO.UNITY_Assigned_Vendor__c){
                    if (wo.UNITY_Assigned_Vendor__c == null){
                      wo.UNITY_Vendor_Contract__c = null;
                      wo.UNITY_Vendor_Email__c = null;
                    }
                    else {
                      vendorChangedMap.put(wo.Id, wo);
                    }
                  }

                  //if attachment reason has been populated, check attachment compliant
                  if (wo.UNITY_Override_Attach_Compliance_Reason__c != oldWO.UNITY_Override_Attach_Compliance_Reason__c){
                      if (wo.UNITY_Override_Attach_Compliance_Reason__c != null)
                        wo.UNITY_Attachment_Compliant__c = true;
                      else
                        wo.UNITY_Attachment_Compliant__c = false;
                  }
                  
                  if (wo.SFPS_FS_AllTasks_Completed__c != null && wo.UNITY_Next_Step__c != null){
                    if (wo.SFPS_FS_AllTasks_Completed__c != oldWO.SFPS_FS_AllTasks_Completed__c && wo.UNITY_Next_Step__c != oldWO.UNITY_Next_Step__c){
                           
                       if ( wo.SFPS_FS_AllTasks_Completed__c == 'Partially Complete'  && wo.UNITY_Next_Step__c == 'Requires another trip'){
                            woDebriefMap.put(wo.Id, wo);
                       }
                       else  if ( wo.SFPS_FS_AllTasks_Completed__c == 'Complete'  && wo.UNITY_Next_Step__c == 'Completion Confirmed'){
                               wo.Status = 'Completed';
                               wo.SFPS_FS_OverallStatus__c = 'Completed';
                       }
                        else  if ( wo.SFPS_FS_AllTasks_Completed__c == 'PM Complete'  && wo.UNITY_Next_Step__c == 'Waiting for checklists'){
                               wo.Status = 'Waiting for Checklist/Paperwork';
                               wo.SFPS_FS_OverallStatus__c = 'In Progress';
                       }
                     }
                  }

                }
            }

            if (vendorChangedMap.size() > 0)
              setVendorDetails(vendorChangedMap);
              
            if (woDebriefMap.size() > 0)
               setDebriefdetails(woDebriefMap);
            
        }
    }

    public override void bulkAfter(List<SObject> newList_WorkOrder, List<SObject> oldList_WorkOrder, Map<Id,SObject> oldMap_WorkOrder, Map<Id,SObject> newMap_WorkOrder){
        List<WorkOrder> vendorSCChangedList = new List<WorkOrder>();
        Map<Id, WorkOrder> woDebriefCompletedMap = new Map<Id, WorkOrder>();
        List<WorkOrder> woForCheckInCheckOut = new List<WorkOrder>();
        Set <ID> caseIDs = new Set <ID>();
        List<WorkOrder> shareToVendorList = new List<WorkOrder>(); //WOs that has an assigned vendor
		List<WorkOrder> unshareToVendorList = new List<WorkOrder>(); //WOs that's no longer assigned to a certain vendor        
			
        if (trigger.isInsert){

            for(SObject sObj :  newList_WorkOrder){
              WorkOrder wo = (WorkOrder)sObj;

              //Check if vendor contract is not null
              if (wo.UNITY_Assigned_Vendor__c != null)  
                vendorSCChangedList.add(wo);
                
               	shareToVendorList.add(wo);
            }
            
             createDefaultwOLIsSet(newList_WorkOrder);
        }

        if(trigger.isUpdate){

          for(SObject sObj :  newList_WorkOrder){
            WorkOrder wo = (WorkOrder)sObj;
            WorkOrder oldWo = (WorkOrder)oldMap_WorkOrder.get(wo.Id);            

            //Check if vendor SC changed 
            if (wo.UNITY_Assigned_Vendor__c != oldWO.UNITY_Assigned_Vendor__c)
              vendorSCChangedList.add(wo);
                 
            if ( wo.SFPS_FS_AllTasks_Completed__c == 'Complete' &&  wo.UNITY_Next_Step__c == 'Completion Confirmed' )
                   woDebriefCompletedMap.put(wo.Id, wo);
             
             
              //if ( wo.RecordTypeId == UNITY_Constants.WO_NON_WORK_RECORDTYPE || wo.RecordTypeId == UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
            	if (oldWO.UNITY_Assigned_Vendor__c != wo.UNITY_Assigned_Vendor__c){	
                    system.debug('@@@ UNITYPM WorkOrderTrigger share assignedVendorChanged');
                	if (wo.UNITY_Assigned_Vendor__c != null)
                		shareToVendorList.add(wo);
                	if (oldWO.UNITY_Assigned_Vendor__c != wo.UNITY_Assigned_Vendor__c)
                		unshareToVendorList.add(oldWO);
            	}
                if (oldWO.OwnerID != wo.OwnerId){
                    system.debug('@@@ UNITYPM WorkOrderTrigger share owner changed');
            		shareToVendorList.add(wo);
                }
                if (oldWO.Status != wo.Status && wo.Status == 'Canceled'){
                    system.debug('@@@ UNITYPM WorkOrderTrigger share status changed');
                    unshareToVendorList.add(oldWO);
                }
           // }
             
                   
             //system.debug('#### createCheckInCheckOutWOLIsSet wo.FSO__Check_In_Date__c ###' + wo.FSO__Check_In_Date__c);
             //system.debug('#### createCheckInCheckOutWOLIsSet oldWO.FSO__Check_In_Date__c ###' + oldWO.FSO__Check_In_Date__c);
             //system.debug('#### createCheckInCheckOutWOLIsSet FSO__Completed_Date__c ###' + wo.FSO__Completed_Date__c);
             
             /*if ( wo.FSO__Check_In_Date__c != null && wo.FSO__Completed_Date__c  != null ){
                 if (( oldWO.FSO__Check_In_Date__c != wo.FSO__Check_In_Date__c) ||  ( oldWO.FSO__Completed_Date__c  != wo.FSO__Completed_Date__c)){
                      system.debug('#### createCheckInCheckOutWOLIsSet woForCheckInCheckOut ###' + wo);
                     woForCheckInCheckOut.add(wo);
                 }
             }
                
             if ( wo.FSO__Check_In_Date__c != null){
                 if ( oldWO.FSO__Check_In_Date__c != wo.FSO__Check_In_Date__c){
                     woForCheckInCheckOut.add(wo);
                 }
             }
                    
             if ( wo.FSO__Completed_Date__c  != null){
                 if ( oldWO.FSO__Completed_Date__c  != wo.FSO__Completed_Date__c){
                     woForCheckInCheckOut.add(wo);
                 }
             }
              */   
           }
        }

    
        if (vendorSCChangedList.size() > 0)
          UNITY_OrderUtilities.updatePMPO(vendorSCChangedList);
                    
        if ( woDebriefCompletedMap.size() > 0)
              setCaseStatusOnComplete(woDebriefCompletedMap);
              
        //if ( woForCheckInCheckOut.size() > 0)
         //     createCheckInCheckOutWOLIsSet(woForCheckInCheckOut);
              
        if (unshareToVendorList.size() > 0)
            	UNITY_WorkOrderTriggerHandler_NoSharing.unshareToVendor(unshareToVendorList);
            if (shareToVendorList.size() > 0)
            	UNITY_WorkOrderTriggerHandler_NoSharing.shareToVendor(shareToVendorList);
          
    }

/*
    private static void createCheckInCheckOutWOLIsSet ( List<SObject> newList_WorkOrder){
        if ( woliCheckInCheckOutCreated)
              return;
        
        system.debug('#### createCheckInCheckOutWOLIsSet ###' );
        List<workOrder> woToCreatewoLIs = new List<WorkOrder>();
        List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem> ();
        WorkOrderLineItem woli = new WorkOrderLineItem();
        
        for (SObject sObj :  newList_WorkOrder){
            WorkOrder wo = (WorkOrder)sObj;
           
            if ( wo.FSO__Check_In_Date__c !=null &&  wo.FSO__Completed_Date__c  !=null){
                
                system.debug('#### createCheckInCheckOutWOLIsSet added work order ID  ###' + wo.ID );
                
                 //check-in  
                  woli.WorkOrderId = wo.ID;
                      DateTime dtIn = wo.FSO__Check_In_Date__c;
                      Date dIn = date.newinstance(dtIn.year(), dtIn.month(), dtIn.day());
                      String tempIn = String.valueOf(dIn) + ' : Tech Check-In';
                  woli.Description = tempIn;
                  woli.RecordTypeId = UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                  woli.FSO__IsRequired__c = false;
                  woli.UNITY_PM_WOLI__c = false;
                  woli.SFPS_FS_Task_Type__c = 'Check-In';
                  woli.SFPS_FS_TaskDate__c = dIn;
                  woli.FSO__IsCompleted__c = true;
                  woli.StartDate = wo.FSO__Check_In_Date__c ;
                  woli.EndDate = wo.FSO__Check_In_Date__c ;
                      woliInsertList.add(woli);
                      
                  system.debug('#### createCheckInCheckOutWOLIsSet added woli In ###' + woli );
                  
                  woli = new WorkOrderLineItem();
                  
                  //check-out  
                  woli.WorkOrderId = wo.ID;
                      DateTime dtOut = wo.FSO__Completed_Date__c;
                      Date dOut = date.newinstance(dtOut.year(), dtOut.month(), dtOut.day());
                      String tempOut = String.valueOf(dOut) + ' : Tech Check-Out';
                  woli.Description = tempOut;
                  woli.RecordTypeId = UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                  woli.FSO__IsRequired__c = false;
                  woli.UNITY_PM_WOLI__c = false;
                  woli.SFPS_FS_Task_Type__c = 'Check-Out';
                  woli.SFPS_FS_TaskDate__c = dOut;
                  woli.FSO__IsCompleted__c = true;
                  woli.StartDate = wo.FSO__Completed_Date__c ;
                  woli.EndDate = wo.FSO__Completed_Date__c ;
                      woliInsertList.add(woli);
                      
                  woli = new WorkOrderLineItem();
              
                system.debug('#### createCheckInCheckOutWOLIsSet added woli OUT ###' + woli );
            }
        }
        
      
          if (woliInsertList.size() > 0){
              try{
                  system.debug('####  before insert woli ###' + woliInsertList);
                 insert woliInsertList; 
                 woliCheckInCheckOutCreated = true;
              }
              catch (Exception ex){
                 system.debug('#####   ERROR to insert wolis #### ' + ex) ;
              }
            }
      
    }
    */
    public override void andFinally(){
      
    }

   //update Case status to Completed base on complete status on debrief of work order
   private static void setCaseStatusOnComplete(Map<Id,WorkOrder> woMap){
       Set <String> caseNums = new Set <String>();
       Set <ID> programCaseIDs = new Set <ID>();
       
       for (WorkOrder wo : woMap.values()){
         caseNums.add(wo.UNITY_Case_Number__c);  
       }
     
       system.debug('#### neli caseNums ### ' + caseNums); 
       
       if ( caseNums.size() > 0){
           List<Case> casesToUpdate = new List<Case>();
           for (Case c : [SELECT ID, Status FROM Case WHERE CaseNumber IN :caseNums]){
               c.Status = 'Service Completed';
               casesToUpdate.add(c);
               
           }
           try{
               if (casesToUpdate.size() >0){
                   update casesToUpdate;
               }
           }
           catch(Exception ex){
              system.debug('#####   ERROR to update case status #### ' + ex) ;  
           }
       }
   }
   
    //Set the vendor email and service contract to the WO's vendor email and vendor contract
    private static void setVendorDetails(Map<Id,WorkOrder> woMap){
      Map<Id, Id> woVendorMap = new Map<Id, Id>();

      //Filer map with records that has vendor assignment
      for (WorkOrder wo : woMap.values()){
          if (wo.UNITY_Assigned_Vendor__c != null){
              woVendorMap.put(wo.Id, wo.UNITY_Assigned_Vendor__c);
          }
      }
           
     if (woVendorMap.size()>0){

         //Assign vendor email
         Map<Id, Account> vendorMap = new Map<Id, Account>([SELECT ID, UNITY_Service_Contract__c,Account_Email__c,UNITYPM_PIN__C FROM Account 
                                                            WHERE ID IN :woVendorMap.values() AND UNITY_Vendor_Type_PM__c = true]);

         for (Id woId : woVendorMap.keySet()){
            WorkOrder wo = woMap.get(woId);
            Account vendor = vendorMap.get(wo.UNITY_Assigned_Vendor__c); 
            if (vendor == null){           
              wo.addError('Vendor should be of type Preventative Maintenance.');
            }
            else
              wo.UNITY_Vendor_Email__c = vendor.Account_Email__c;
              if (vendor.UNITYPM_PIN__c != null)
                wo.UNITY_Vendor_PIN__c = vendor.UNITYPM_PIN__c;
         }

     
          Map<Id, UNITY_Service_Contract__c> scMap = new Map<Id, UNITY_Service_Contract__c>([SELECT ID, UNITY_IS_Active__c, UNITY_Account__c
                                                                                                  FROM UNITY_Service_Contract__c 
                                                                                                  WHERE UNITY_Account__c IN :woVendorMap.values() AND UNITY_IS_Active__c = true 
                                                                                                  AND RecordTypeId = :UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE]);

          Map<Id, UNITY_Service_Contract__c> vendorSCMap = new Map<Id, UNITY_Service_Contract__c> ();
          for (UNITY_Service_Contract__c sc: scMap.values()){
              vendorSCMap.put(sc.UNITY_Account__c, sc);
          }


          for (Id woId : woVendorMap.keySet()){
              WorkOrder wo = woMap.get(woId);
              Account vendor = vendorMap.get(wo.UNITY_Assigned_Vendor__c);
              if (vendor != null){
                UNITY_Service_Contract__c sc = vendorSCMap.get(vendor.Id);
                if (sc != null)
                  wo.UNITY_Vendor_Contract__c = sc.Id;
                else {
                  wo.addError('Vendor should have an active Preventative Maintenance service contract.');
                }                
              }
          }
      }

    }
    
    //set debrief details
    private static void setDebriefdetails( Map<ID, workOrder> woDebriefMap){
      system.debug('#### neli setDebriefdetails  ### ' + woDebriefMap);
      for (WorkOrder wo : woDebriefMap.values()){
          if (wo.SFPS_FS_FirstCheckIn__c == null){
              if ( wo.UNITY_Check_In_Date_Cust__c != null)
              {
                  DateTime dtTemp =  DateTime.parse(wo.UNITY_Check_In_Date_Cust__c);
                  wo.SFPS_FS_FirstCheckIn__c = dtTemp;
              }
            }
        
          if ( wo.UNITY_Check_Out_Date_Cust__c != null ){
              DateTime dtTemp =  DateTime.parse(wo.UNITY_Check_Out_Date_Cust__c);
              wo.SFPS_FS_LastCheckOut__c = dtTemp;
          }
          wo.UNITY_MultiTrip_Actual__c = true;
          
          wo.UNITY_Check_In_Date_Cust__c = null;   
          wo.FSO__Check_In_Date__c = null;
          wo.UNITY_Check_Out_Date_Cust__c = null;
          wo.FSO__Completed_Date__c = null;
          
          wo.Status = 'Pending Assignment';
          wo.SFPS_FS_OverallStatus__c = 'In Progress';
      }
    }
    
    //create IVR wolis
     private static void createDefaultwOLIsSet( List<SObject> newList_WorkOrder){
        List<workOrder> woToCreatewoLIs = new List<WorkOrder>();
      
        for (SObject sObj :  newList_WorkOrder){
            WorkOrder wo = (WorkOrder)sObj;
            if ( wo.UNITY_Customer_IVR_Pin__c !=null && wo.UNITY_Miner_IVR_Phone_Number__c != null){
              woToCreatewoLIs.add(wo); 
              
            }
        }
        
        if ( woToCreatewoLIs.size() > 0){
            List<String> wolis  = new List<string> (); 
         
            for (WorkOrder wo : woToCreatewoLIs){
                system.debug('####  work order id ###' +  wo.ID);
                string woli = '';
                if ( wo.Case.UNITY_Customer_WO__c == null)
                    woli = 'Technician is required to check in and out with Customer IVR - ' + wo.UNITY_Customer_IVR_Pin__c + '; Tracking # '+ 'N/A';
                else
                    woli = 'Technician is required to check in and out with Customer IVR - ' + wo.UNITY_Customer_IVR_Pin__c + '; Tracking # '+ wo.Case.UNITY_Customer_WO__c;
                
                  wolis.add(woli); 

                if ( wo.UNITY_Vendor_PIN__c != null)
                   woli = 'Technician is required to check in and out with ' + wo.UNITY_Business_Unit_Formula__c + ' IVR - ' + wo.UNITY_Miner_IVR_Phone_Number__c + ' ' + wo.WorkOrderNumber + ' Pin: ' + wo.UNITY_Vendor_PIN__c;
                else
                    woli = 'Technician is required to check in and out with ' + wo.UNITY_Business_Unit_Formula__c + ' IVR - ' + wo.UNITY_Miner_IVR_Phone_Number__c + ' ' + wo.WorkOrderNumber;
                wolis.add(woli);  
                
                woli = 'Technician must capture a ' + wo.UNITY_Business_Unit_Formula__c + ' Service Report with authorizing Manager on Duty printed name and signature.';
                
                wolis.add(woli); 
            }
            
          //add wolis
         List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem> ();
           for (WorkOrder wo : woToCreatewoLIs){
               for ( String wl : wolis){
                      WorkOrderLineItem woli = new WorkOrderLineItem();
                   
                      woli.WorkOrderId = wo.ID;
                      woli.Description = wl;
                      woli.RecordTypeId = UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                      woli.FSO__IsRequired__c = true;
                      woli.UNITY_PM_WOLI__c = false;
                      woli.UNITY_Vendor_Pin__c = true;
                   
                   
                    woliInsertList.add(woli);
               }
           }
           
          if (woliInsertList.size() > 0){
              try{
                  system.debug('#### before insert woli ###' + woliInsertList);
                 insert woliInsertList; 
              }
              catch (Exception ex){
                 system.debug('#####   ERROR to insert wolis #### ' + ex) ;
              }
            }
        }
    }

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