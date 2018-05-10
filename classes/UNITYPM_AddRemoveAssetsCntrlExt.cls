public class UNITYPM_AddRemoveAssetsCntrlExt {
       public List<UNITYPM_WorkPlanAssetsWrapper> wplAssetWrapper {get;set;}
       public List<UNITYPM_WorkPlanAssetsWrapper> wplAssetWrapperRePopulated {get;set;}
       public List<FSO__WorkPlan__c> woliWorkPlan = new List <FSO__WorkPlan__c>();
        
       public String accountID { get; set; }
       public String worOrderID { get; set; }
       public workOrder workorder {get; private set;}
       public String selectedAssetVal{get;set;}
       public string selectedNumVal {get;set;}
       public String WarningMessage {get;set;}
       public Boolean VendorAssignedStatus {get;set;}
        public String workOrderNumber { get; set; }
        
       public UNITYPM_AddRemoveAssetsCntrlExt (ApexPages.StandardController controller){
       
          workorder = (Workorder)controller.getRecord();
          worOrderID = (ID) controller.getRecord().get('id');
          
          WarningMessage = 'This Work Order has not been assigned. Please return to the Work Order and assign the Vendor.';
          
           WorkOrder wo= [SELECT ID,Account.ID, WorkOrderNumber, UNITY_Vendor_Status__c, UNITY_Assigned_Vendor__c
                               FROM WorkOrder
                                    WHERE id =: worOrderID];
           if ( wo.UNITY_Assigned_Vendor__c == null){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, WarningMessage));
                  VendorAssignedStatus = false;
            }
            else{
                 VendorAssignedStatus = true;
            }
        
            accountID = wo.Account.ID;
            workOrderNumber = wo.WorkOrderNumber ;
            
            system.debug('>>>> VendorAssignedStatus >>> ' + VendorAssignedStatus);
       }
      
 
     public   List<UNITYPM_WorkPlanAssetsWrapper> getExistingwOLIs(){
         Integer counter = 1; 
         //system.debug('>>>>   getExistingwOLIs >>>' );
         wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper> ();
         Map <ID, List<ID>> wpIDAssetsListMap = new Map <ID, List<ID>>();
        
        Set<ID> aIDs = new Set <ID>();
        
         List<WorkOrderLineItem> wolis = [SELECT Id, LineItemNumber, UNITY_Work_Plan__r.ID, Asset.ID
                                    FROM WorkOrderLineItem
                                       WHERE WorkOrderId=:this.worOrderID ];
         for (WorkOrderLineItem woli : wolis){
             //system.debug('>>>>   getExistingwOLIs woli >>>'  + woli);
               
             List<Id> assetIDs = new List<ID>();
                if(!wpIDAssetsListMap.containsKey(woli.UNITY_Work_Plan__c)){
                    assetIDs.add(woli.AssetId);
                    wpIDAssetsListMap.put(woli.UNITY_Work_Plan__c, assetIDs);
                }
                else{
                  assetIDs= wpIDAssetsListMap.get(woli.UNITY_Work_Plan__c);
                  assetIDs.add(woli.AssetID);
                  wpIDAssetsListMap.put(woli.UNITY_Work_Plan__c, assetIDs);
                }
            aIDs.add(woli.AssetId);
         }
         
          if ( wpIDAssetsListMap.size() > 0){ 
               List<Asset> woliAssets = [select Id, AccountId,  Name,  Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset WHERE  ID IN :aIDs]; 
                                     
               woliWorkPlan = [SELECT ID, Name, UNITY_Asset_Type__c, FSO__Number_of_Work_Plan_Items__c  
                        FROM FSO__WorkPlan__c WHERE ID in :wpIDAssetsListMap.keySet()];
          
               for (FSO__WorkPlan__c wp: woliWorkPlan){
                  List<ID> astiDs =  wpIDAssetsListMap.get(wp.ID);
                   for (Asset a : woliAssets){
                       for (ID i : astiDs) {
                           if ( i == a.ID){
                             String assettype =  a.UNITY_Asset_Type__c;
                             String wpID = wp.ID;
                             List<SelectOption> wplist = new List<SelectOption>();
                              wplist.add(new SelectOption(wp.Id, wp.Name));                       
                              wplAssetWrapperRePopulated.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, true));
                              counter++;
                              break;
                           } 
                       }
                    }
               }
          }
         
        return wplAssetWrapperRePopulated;
     }
     
      public List<UNITYPM_WorkPlanAssetsWrapper> getRecordsToDisplay() {
              getexistingwOLIs(); 
             Integer counter = 1; 
             Map<id, FSO__WorkPlan__c> workPlanMap = new Map<id, FSO__WorkPlan__c>();
            
            if ( wplAssetWrapper == null){
                 wplAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper>(); 
                 List<Asset> assets = [SELECT Id, AccountId,  Name,  Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset WHERE AccountId =:accountID AND UNITY_Asset_Type__c != NULL
                                     ORDER BY Name];    
                                     
                  
                  for (FSO__WorkPlan__c wpi :  [SELECT ID, Name, UNITY_Asset_Type__c  FROM FSO__WorkPlan__c]){
                      workPlanMap.put(wpi.id, wpi);
                  }
                 
                  
                  if ( assets.size() != 0 && workPlanMap.size() > 0){
                      wplAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
                      
                      for (Asset a: assets){
                          String asstype =  a.UNITY_Asset_Type__c;
                          List<SelectOption> wplist = new List<SelectOption>();
                             for(FSO__WorkPlan__c temp : workPlanMap.values())
                              {
                                 if (temp.UNITY_Asset_Type__c == asstype)
                                    wplist.add(new SelectOption(temp.Id, temp.Name));
                              }
                         if ( wplist.size()> 0){
                            //system.debug('>>>>  neli counter >>>' + counter);
                            wplAssetWrapper.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, false));
                            counter++;
                         }
                      }
                  }
             }
        
             if ( wplAssetWrapperRePopulated == null){
                 wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper>();
           }
          
            if (wplAssetWrapperRePopulated.size() > 0){
                
                for ( Integer i = wplAssetWrapper.size() - 1; i >= 0; --i ){
                    UNITYPM_WorkPlanAssetsWrapper oppWrapObj=wplAssetWrapper[i];
                    
                    // system.debug('>>>>  neli oppWrapObj >>>' + oppWrapObj);
                     for (UNITYPM_WorkPlanAssetsWrapper wpselected : wplAssetWrapperRePopulated){
                         if (oppWrapObj.asset.ID == wpselected.asset.ID){
                             wplAssetWrapper.remove(i);
                              system.debug('>>>>  neli remove  >>>' + i);
                         }
                     }
                }
                
                
                //system.debug('>>>>  neli wplAssetWrapperRePopulated.size()  >>>' + wplAssetWrapperRePopulated.size());
                for ( Integer i = wplAssetWrapperRePopulated.size() - 1; i >= 0; --i ){
                    //system.debug('>>>>  neli wplAssetWrapperRePopulated[i]  >>>' + wplAssetWrapperRePopulated[i]);
                    UNITYPM_WorkPlanAssetsWrapper oppWrapObj=wplAssetWrapperRePopulated[i];
                    oppWrapObj.selected = true;
                    //system.debug('>>>>  neli add  >>>' + oppWrapObj);
                    wplAssetWrapper.add(oppWrapObj);
                }
                
                
                
           /*
               for (UNITYPM_WorkPlanAssetsWrapper wp : wplAssetWrapper){
                   String assetID = wp.asset.ID;
                  
                   for (UNITYPM_WorkPlanAssetsWrapper wpselected : wplAssetWrapperRePopulated){
                       String aID = wpselected.asset.ID;
                       if ( assetID == aID){
                        
                       }
                   }
               }
               */
               wplAssetWrapperRePopulated = null;
           }
         
           
           system.debug('>>>>   wplAssetWrapper >>>' );
           return wplAssetWrapper; 
        }
        
        public Boolean hasError { get { return ApexPages.hasMessages(); } }
      
        @RemoteAction
        public static Boolean handleAssetsSubmit(List<String> selectedAssets, String  workOrderID)
        {    
            Boolean isDone = false;
            
            Set<ID> aIDs = new Set<ID>();
            Set<ID> wpIDs = new Set<ID>();
            List<String> assetIDWPid = new List<String>();
             
            if ( selectedAssets.size() > 0){
                for (String s : selectedAssets ){
                   
                   s = s.replace('}','');
                   s = s.replace('{','');
                   String[] sSplit = s.split(',');
                        
                   ID aID = sSplit[0].substringAfter('=');
                   aIDs.add(Id.valueOf(aID));
                   
                   ID wpID = sSplit[1].substringAfter('=');
                   wpIDs.add(Id.valueOf(wpID));
                   
                   String awpIDs = sSplit[0].substringAfter('=') + ',' + sSplit[1].substringAfter('='); 
                   assetIDWPid.add(awpIDs);
                  
                }
            }
            
           if (assetIDWPid.size() > 0 && wpIDs.size() > 0 && aIDs.size() > 0 && workOrderID != ''){
              //add WOlis
             isDone = UNITYPM_AddRemoveWOLIsOnWrokOrder.createWorkOrderLineItems(workOrderID, assetIDWPid, wpIDs, aIDs);
           } 
           else if (workOrderID != '')
            {
              UNITYPM_AddRemoveWOLIsOnWrokOrder.deleteWorkOrderLineItems(workOrderID); 
            }
          
            UNITY_OrderUtilities.updatePMPO(new List<WorkOrder>{new Workorder(Id = workOrderID)});
    
           return isDone; 
        }
        
         //================================================================================================
        
          public list<SelectOption> getDefaultAssetsList(){
            list<SelectOption> options = new list<SelectOption>();
            List<Schema.PicklistEntry> assetTypesPL = Asset.getSObjectType().getDescribe().fields.getMap().get('UNITY_Asset_Type__c').getDescribe().getPickListValues();
            
            for ( Schema.PicklistEntry lst: assetTypesPL){
                options.add(new selectOption(lst.getLabel(), lst.getValue()));
            }
            
            return options;
         }
     
         public List<SelectOption> getNumbersList () {
             List<SelectOption> optns = new List<Selectoption>();
             List<string> numbersList = new List<string>{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50'}; 
             for (string num: numbersList) {
                optns.add(new selectOption(num, num));
             }                   
                                 
             return optns;
         }
         public PageReference addDefaultAssets (){
             system.debug('>>>>> neli  accountID >>>>' + accountID );
             system.debug('>>>>> neli workOrderNumber  >>>>' + workOrderNumber);
             system.debug('>>>>> neli selectedAssetVal  >>>>' + selectedAssetVal);
             system.debug('>>>>> neli selectedNumVal  >>>>' + selectedNumVal);
             
             
          UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets (accountID, workOrderNumber, selectedAssetVal, integer.valueof(selectedNumVal));
          selectedNumVal = '1';
          return null;
         }

}