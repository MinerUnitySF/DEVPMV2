public class UNITYPM_AddRemoveWOAssetsCntrlExt {
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
       public String customeAccount { get; set; }
       public String siteStoreNumber { get; set; }
       
       public Boolean WorkOrderNoPM {get;set;}
       public Boolean WorkOrderCanceled {get;set;}
       public Boolean WorkOrderCompleted {get;set;}
        
       public String WarningWONoPM {get;set;}
       public String WarningWOCanceled {get;set;}
       public String WarningWOCompleted {get;set;}
       
       public UNITYPM_AddRemoveWOAssetsCntrlExt (ApexPages.StandardController controller){
       
         VendorAssignedStatus = false;
         WorkOrderNoPM = false;
         WorkOrderCanceled = false;
         WorkOrderCompleted = false;
         
          workorder = (Workorder)controller.getRecord();
          worOrderID = (ID) controller.getRecord().get('id');
          
          WarningMessage = 'This Work Order has not been assigned. Please return to the Work Order and assign the Vendor.';
          
           WorkOrder wo= [SELECT ID,Account.ID, WorkOrderNumber, UNITY_Vendor_Status__c, 
                            UNITY_Assigned_Vendor__c,RecordTypeId, Status, UNITY_Customer__r.Name, UNITY_Site_Store_Number__c
                               FROM WorkOrder
                                    WHERE id =: worOrderID];
                                    
             if (wo.RecordTypeId != UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE) {
                  WarningWONoPM ='Work order is not Preventative Maintenance'; 
                  WorkOrderNoPM = true;
                }
            else  if (wo.Status == 'Canceled') {
                  WarningWOCanceled ='Work order is Canceled'; 
                  WorkOrderCanceled = true;
                }
            else  if (wo.Status == 'Completed') {
                  WarningWOCompleted ='Work order is Completed'; 
                  WorkOrderCompleted = true;
                }
                
            else if ( wo.UNITY_Assigned_Vendor__c == null){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, WarningMessage));
                  VendorAssignedStatus = false;
            }
            else{
                 VendorAssignedStatus = true;
                 accountID = wo.Account.ID;
                 workOrderNumber = wo.WorkOrderNumber ;
                 customeAccount = wo.UNITY_Customer__r.Name;
                 siteStoreNumber = wo.UNITY_Site_Store_Number__c;
            }
       }
      
 
       public List<UNITYPM_WorkPlanAssetsWrapper> getExistingwOLIs(){
         Integer counter = 1; 
         system.debug('>>>>  neli getExistingwOLIs >>>' + worOrderID );
         wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper> ();
         Map <ID, List<ID>> wpIDAssetsListMap = new Map <ID, List<ID>>();
        
        Set<ID> aIDs = new Set <ID>();
      
         List<UNITYPM_Work_Order_Assets_junction__c> woAssetsWP = [SELECT Asset__c, Work_Order__c, Work_Plan__c
                                           FROM  UNITYPM_Work_Order_Assets_junction__c WHERE Work_Order__c =:worOrderID  ];
                                           
         for (UNITYPM_Work_Order_Assets_junction__c woli : woAssetsWP) {
                 List<Id> assetIDs = new List<ID>();
                if(!wpIDAssetsListMap.containsKey(woli.Work_Plan__c)){
                    assetIDs.add(woli.Asset__c);
                    wpIDAssetsListMap.put(woli.Work_Plan__c, assetIDs);
                }
                else{
                  assetIDs= wpIDAssetsListMap.get(woli.Work_Plan__c);
                  assetIDs.add(woli.Asset__c);
                  wpIDAssetsListMap.put(woli.Work_Plan__c, assetIDs);
                } 
                
              aIDs.add(woli.Asset__c);
          }                                 
                                           
           //system.debug('>>>>   neli wpIDAssetsListMap.size() >>>' + wpIDAssetsListMap.size() );
           
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
           system.debug('>>>>  neli call getRecordsToDisplay >>>');
            // getexistingwOLIs(); 
             Integer counter = 1; 
             Map<id, FSO__WorkPlan__c> workPlanMap = new Map<id, FSO__WorkPlan__c>();
            
            if ( wplAssetWrapper == null){
                 wplAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper>(); 
                 //get assets for account
                 List<Asset> assets = [SELECT Id, AccountId,  Name,  Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset WHERE AccountId =:accountID AND UNITY_Asset_Type__c != NULL
                                     ORDER BY Name];    
                                     
                  //get available work plans
                  for (FSO__WorkPlan__c wpi :  [SELECT ID, Name, UNITY_Asset_Type__c  FROM FSO__WorkPlan__c]){
                      workPlanMap.put(wpi.id, wpi);
                  }
                 
                //get assets/workplan for work order for this account
                Map <ID, List<ID>> wpIDAssetsListMap = new Map <ID, List<ID>>();
                List<UNITYPM_Work_Order_Assets_junction__c> woAssetsWP = [SELECT Asset__c, Work_Order__c, Work_Plan__c,Work_Plan__r.Name
                                               FROM  UNITYPM_Work_Order_Assets_junction__c WHERE Work_Order__c =:worOrderID  ];
                                                 
                 for (UNITYPM_Work_Order_Assets_junction__c woli : woAssetsWP) {
                    List<Id> assetIDs = new List<ID>();
                     system.debug('>>>>   neli woli.Asset__c >>>>' +woli.Asset__c);
                    system.debug('>>>>   neli woli.Work_Plan__c >>>>' +woli.Work_Plan__c);
                          
                    if(!wpIDAssetsListMap.containsKey(woli.Work_Plan__c)){
                        assetIDs.add(woli.Asset__c);
                        wpIDAssetsListMap.put(woli.Work_Plan__c, assetIDs);
                    }
                    else{
                      assetIDs= wpIDAssetsListMap.get(woli.Work_Plan__c);
                      assetIDs.add(woli.Asset__c);
                      wpIDAssetsListMap.put(woli.Work_Plan__c, assetIDs);
                    }
                  }             
                    
                   
                  if ( assets.size() != 0 && workPlanMap.size() > 0){
                      wplAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
                      
                      for (Asset a: assets){
                          
                             Boolean assetSelected = false;
                             List<SelectOption> wplist = new List<SelectOption>();
                             for(FSO__WorkPlan__c temp : workPlanMap.values())
                              {
                                 if (temp.UNITY_Asset_Type__c == a.UNITY_Asset_Type__c)
                                    wplist.add(new SelectOption(temp.Id, temp.Name));
                                      system.debug('>>>>   neli assetSelected >>>>' +assetSelected);
                                      system.debug('>>>>   neli  wpIDAssetsListMap.get(temp.ID) >>>>'  + wpIDAssetsListMap.get(temp.ID));
                                      system.debug('>>>>   neli a.ID >>>>' +a.ID);
                                    if ( wpIDAssetsListMap.get(temp.ID) != null && !assetSelected){
                                        List<ID> aID =  wpIDAssetsListMap.get(temp.ID);
                                        system.debug('>>>>   neli exist >>>>' + listContains(aID, a.ID));
                                        assetSelected = aID.contains(a.ID); //listContains(aID, a.ID);
                                    }
                              }
                              
                         if ( wplist.size()> 0){
                            wplAssetWrapper.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, assetSelected));
                            counter++;
                         }
                      }
                  }
                
             }
        
             if ( wplAssetWrapperRePopulated == null){
                 wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper>();
           }
          
          /*
            if (wplAssetWrapperRePopulated.size() > 0){
                
                for ( Integer i = wplAssetWrapper.size() - 1; i >= 0; --i ){
                    UNITYPM_WorkPlanAssetsWrapper oppWrapObj=wplAssetWrapper[i];
                    
                    // system.debug('>>>>  neli oppWrapObj >>>' + oppWrapObj);
                     for (UNITYPM_WorkPlanAssetsWrapper wpselected : wplAssetWrapperRePopulated){
                         if (oppWrapObj.asset.ID == wpselected.asset.ID){
                             wplAssetWrapper.remove(i);
                             //system.debug('>>>>  neli remove  >>>' + i);
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
             
               wplAssetWrapperRePopulated = null;
           }
           */
           return wplAssetWrapper; 
        }
        
        Boolean listContains(Object[] source, Object target) {
            return (new Set<Object>(source)).contains(target);
        }

        public Boolean hasError { get { return ApexPages.hasMessages(); } }
      
        @RemoteAction
        public static Boolean handleAssetsSubmit(List<String> selectedAssets, String  workOrderID)
        {    
            Boolean isDone = false;
            
            Set<ID> aIDs = new Set<ID>();
            Set<ID> wpIDs = new Set<ID>();
            Set<ID> aDeleteIDs = new Set<ID>();
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
                   
                   String aselected = sSplit[2].substringAfter('=');
                   system.debug('>>>>   neli aselected >>>>' + aselected);
                  
                  if ( aselected == '1') {
                   String awpIDs = sSplit[0].substringAfter('=') + ',' + sSplit[1].substringAfter('='); 
                   assetIDWPid.add(awpIDs);
                  }
                  else if (aselected == '0'){
                      aDeleteIDs.add(Id.valueOf(aID));
                  }
                }
            }
           
           // system.debug('>>>>   neli added assetIDWPid.size().Asset__c  >>>'  +assetIDWPid.size());
          //  system.debug('>>>>   neli added  wpIDs.size() >>>'  +  wpIDs.size());
           // system.debug('>>>>   neli added aIDs.size()  >>>'  + aIDs.size());
           // system.debug ('>>>>> neli workOrderID>>>> ' + workOrderID)  ;
            
           if (assetIDWPid.size() > 0 && wpIDs.size() > 0 && aIDs.size() > 0 && workOrderID != ''){
              //add WOlis
             isDone = UNITYPM_AddRemoveWOLIsOnWrokOrder.createWorkOrderLineItems(workOrderID, assetIDWPid, wpIDs, aIDs);
           } 
           else if (workOrderID != '')
            {
              UNITYPM_AddRemoveWOLIsOnWrokOrder.deleteWorkOrderLineItems(workOrderID, aDeleteIDs); 
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