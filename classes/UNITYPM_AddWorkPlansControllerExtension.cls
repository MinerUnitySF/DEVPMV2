public class UNITYPM_AddWorkPlansControllerExtension  {

    public workOrder workorder {get; private set;}
      
    public List<FSO__WorkPlan__c> woliWorkPlan = new List <FSO__WorkPlan__c>();
   
    public List<UNITYPM_WorkPlanAssetsWrapper> wplAssetSelectedWrapper {get;set;}
  
    public List<UNITYPM_WorkPlanAssetsWrapper> wplAssetWrapperRePopulated {get;set;}
    
    public  Set<ID> aIDs {get;set;}
    public  Set<ID> wpIDs {get;set;}
    public List<String> combineSelectedAssetIDandWPid {get;set;}
    
    public Boolean recsCommit {get; set;}         
    public UNITYPM_WorkPlanAssetsWrapper selectedAsset {get;  set;}
    public String selectedWorkPalnName{get; private set;}
    public String selectedWorkPalnNameID {get;  set;}
   
    private Integer counter = 0;

    public String worOrderID { get; set; }
    public String accountID { get; set; }
    public String workOrderNumber { get; set; }
    
    public String selectedAssetVal{get;set;}
    public string selectedNumVal {get;set;}
    public string selectedSearchAsset{get;set;}
    
    public UNITYPM_CustomWorkPlanAssetsIterable obj;
    public List<UNITYPM_WorkPlanAssetsWrapper> wplAssetWrapper {get;set;}
    public List<UNITYPM_WorkPlanAssetsWrapper> wplSetAssetWrapper {get;set;}
    public List<UNITYPM_WorkPlanAssetsWrapper> wplSearchAssetWrapper {get;set;}
    
    public static String compareField {get; set;}
    public static String sortOrder {get; set;}
     
    public String searchAsset {get;  set;}
    public Boolean readyForAssetSearch {get;  set;}
    public Integer RecPerPage {get;  set;}
    public Boolean doSearch {get; set;} 
    public Integer totalRecCount {get;set;}
    public Boolean VendorAssignedStatus {get;set;}
    public String WarningMessage {get;set;}
    public Boolean recPerPageChanged {get;set;}
  
     public UNITYPM_AddWorkPlansControllerExtension (ApexPages.StandardController controller){
          workorder = (Workorder)controller.getRecord();
          this.worOrderID = (ID) controller.getRecord().get('id');
          WarningMessage = 'This Work Order has not been assigned. Please return to the Work Order and assign the Vendor.';
           
          WorkOrder wo= [SELECT Account.ID, WorkOrderNumber, UNITY_Vendor_Status__c, UNITY_Assigned_Vendor__c
                               FROM WorkOrder
                                    WHERE id =: worOrderID];
           
            if ( wo.UNITY_Assigned_Vendor__c == null){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, WarningMessage));
                  VendorAssignedStatus = false;
            }
            else{
                 VendorAssignedStatus = true;
            }
          
          if ( VendorAssignedStatus)  {
               this.accountID = wo.Account.ID;
               this.workOrderNumber = wo.WorkOrderNumber ;
               this.RecPerPage = 10;
               retriveAllAssetsAndWorkPlan();
               readyForAssetSearch = false;
               //doSearch = false;
               recPerPageChanged= false;
             
          }
      }
     
     public  void retriveAllAssetsAndWorkPlan(){
         system.debug('@@@@@  neli retriveAllAssetsAndWorkPlan doSearch @@@@' + doSearch);
         if (doSearch == null)
              doSearch = false;
         if ( recPerPageChanged == null)    
              recPerPageChanged = false;
         
          
         if (doSearch){
            wplSearchAssetWrapper = getSearchRecordsToDisplay(searchAsset);
            
            system.debug('@@@@@  neli retriveAllAssetsAndWorkPlan wplSearchAssetWrapper  @@@@' + wplSearchAssetWrapper.size());
            
            obj = new UNITYPM_CustomWorkPlanAssetsIterable(wplSearchAssetWrapper);
           
            // doSearch = false;
             
             if(wplSearchAssetWrapper.size() > this.RecPerPage) {
                obj.setPageSize = this.RecPerPage;
            } else {
                obj.setPageSize = wplSearchAssetWrapper.size() ;
            }
            
            next();
            
         }
         else{
         
            //doSearch = false;
            wplSetAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper>();
            if (!recPerPageChanged)
                 getexistingwOLIs();  //get existing woli's
                 
            wplAssetWrapper = getRecordsToDisplay();
           
            system.debug('@@@@@  neli retriveAllAssetsAndWorkPlan wplAssetWrapper @@@@' + wplAssetWrapper.size());
            
            obj = new UNITYPM_CustomWorkPlanAssetsIterable(wplAssetWrapper);
            //Initializing the iterator
            if(wplAssetWrapper.size() > this.RecPerPage) {
                obj.setPageSize = this.RecPerPage;
            } else {
                obj.setPageSize = wplAssetWrapper.size() ;
            }
            
            totalRecCount =  wplAssetWrapper.size();
             
            next();
         }
      }
       
     public List<SelectOption> getSearchAssetList () {
         List<SelectOption> optns = new List<Selectoption>();
         List<string> SearchAssetList = new List<string>{'Asset Type','Asset Name'}; 
         for (String s: SearchAssetList) {
             optns.add(new selectOption(s, s));
         }                  
                             
         return optns;
     }  
    
     public void enableSearchButton(){
          this.readyForAssetSearch = true;
      }
    
     
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
     
     public List<SelectOption> getPageSize () {
         List<SelectOption> optns = new List<Selectoption>();
         List<string> pageSizeList = new List<string>{'5', '10', '15','20','25','30','35','40','50', '70','80','90','100'}; 
         for (string num: pageSizeList) {
            optns.add(new selectOption(num, num));
         }                  
                             
         return optns;
     }  
     
     public   List<UNITYPM_WorkPlanAssetsWrapper> getExistingwOLIs(){
         Integer counter = 1; 
     
         wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper> ();
         Map <ID, List<ID>> wpIDAssetsListMap = new Map <ID, List<ID>>();
        
        Set<ID> aIDs = new Set <ID>();
        
         List<WorkOrderLineItem> wolis = [SELECT Id, LineItemNumber, UNITY_Work_Plan__r.ID, Asset.ID
                                    FROM WorkOrderLineItem
                                       WHERE WorkOrderId=:this.worOrderID ];
         for (WorkOrderLineItem woli : wolis){
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
                                     FROM Asset WHERE  ID IN :aIDs AND UNITY_Asset_Type__c != null]; 
                                     
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
     
    /*  OLD
     public  List<UNITYPM_WorkPlanAssetsWrapper> getExistingwOLIsOld(){
       Integer counter = 1; 
       Map <String, String> assetWPMapIDs = new Map <String, String>();
       List<WorkOrderLineItem> wolis = [SELECT Id, LineItemNumber, UNITY_Work_Plan__r.ID, Asset.ID
                                    FROM WorkOrderLineItem
                                       WHERE WorkOrderId=:this.worOrderID ];
                                       
        for (WorkOrderLineItem woli : wolis){
           assetWPMapIDs.put(woli.Asset.ID, woli.UNITY_Work_Plan__r.ID ) ;
        }
       
       if ( assetWPMapIDs.size() > 0){ 
         List<Asset> assets = [select Id, AccountId,  Name,  Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset WHERE  ID IN: assetWPMapIDs.keySet()];   
                                     
         woliWorkPlan = [SELECT ID, Name, UNITY_Asset_Type__c, FSO__Number_of_Work_Plan_Items__c  FROM FSO__WorkPlan__c WHERE ID in :assetWPMapIDs.values()];
         
         if ( assets.size() != 0){
              wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper> ();
                 for (Asset a: assets){
                             
                    String wpID = assetWPMapIDs.get(a.ID);
                    system.debug('@@@  getExistingwOLIs >> wpID   @@@@' + wpID);
                     String assettype =  a.UNITY_Asset_Type__c;
                     system.debug('@@@  getExistingwOLIs >> assettype   @@@@' + assettype);
                     
                     List<SelectOption> wplist = new List<SelectOption>();
                     for(FSO__WorkPlan__c temp : tempWP)
                      {
                          system.debug('@@@  getExistingwOLIs >> temp.UNITY_Asset_Type__c  @@@@' + assettype);
                          
                         if (temp.UNITY_Asset_Type__c == assettype)
                            wplist.add(new SelectOption(temp.Id, temp.Name));
                          
                           system.debug('@@@  getExistingwOLIs >> temp.Id   @@@@' + temp.Id);
                           system.debug('@@@  getExistingwOLIs >> temp.Name   @@@@' + temp.Name);
                           system.debug('@@@  getExistingwOLIs >> assettype  @@@@' + assettype);
                      }
                      
                      wplAssetWrapperRePopulated.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, true));
                      counter++;
                }
             }
         } 
         
          return wplAssetWrapperRePopulated; 
    }
    */
    
       
     public List<UNITYPM_WorkPlanAssetsWrapper> getSearchRecordsToDisplay(String searchAsset) {
         system.debug('@@@@@ neli getSearchRecordsToDisplay doSearch  @@@@' + doSearch);
            this.recsCommit  = false;
            Integer counter = 1; 
            Map<id, FSO__WorkPlan__c> workPlanMap = new Map<id, FSO__WorkPlan__c>();
                wplSearchAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
                
                 List<Asset> assetsList = [SELECT Id, AccountId,  Name, Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset 
                                        WHERE AccountId =:this.accountID AND UNITY_Asset_Type__c != null 
                                           ORDER BY Name]; 
                  
                       
                  List<Asset> assets = new List<Asset>();                   
                  for (Asset a : assetsList){
                      if ( this.selectedSearchAsset == 'Asset Name' ){
                        if ( a.Name.containsIgnoreCase(searchAsset)){
                          assets.add(a);
                        }
                      }
                      else if  ( this.selectedSearchAsset == 'Asset Type' ){
                        if ( a.UNITY_Asset_Type__c.containsIgnoreCase(searchAsset)){
                          assets.add(a);
                        }
                      }
                 }
                   
                  for (FSO__WorkPlan__c wpi :  [SELECT ID, Name, UNITY_Asset_Type__c  FROM FSO__WorkPlan__c]){
                      workPlanMap.put(wpi.id, wpi);
                  }
                 
                  if ( assets.size() != 0 && workPlanMap.size() > 0){
                       
                      for (Asset a: assets){
                          String asstype =  a.UNITY_Asset_Type__c;
                          List<SelectOption> wplist = new List<SelectOption>();
                             for(FSO__WorkPlan__c temp : workPlanMap.values())
                              {
                                 if (temp.UNITY_Asset_Type__c == asstype)
                                    wplist.add(new SelectOption(temp.Id, temp.Name));
                              }
                         if ( wplist.size()> 0){
                            wplSearchAssetWrapper.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, false));
                            counter++;
                         }
                      }
                      
                      totalRecCount = counter;
                  }
          
           if ( wplAssetWrapperRePopulated == null){
                 wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper>();
                   getexistingwOLIs();
           }
        
           if (wplAssetWrapperRePopulated.size() > 0){
             
               for (UNITYPM_WorkPlanAssetsWrapper wp : wplSearchAssetWrapper){
                   String assetID = wp.asset.ID;
                  
                   for (UNITYPM_WorkPlanAssetsWrapper wpselected : wplAssetWrapperRePopulated){
                       String aID = wpselected.asset.ID;
                       
                       if ( assetID == aID){
                          wp.selected = true;
                          List<SelectOption> newwplist = new List<SelectOption>();
                          String selectedItem = '';
                          for (SelectOption slSelected : wpselected.wplist){
                                   newwplist.add(slSelected);
                                   selectedItem = slSelected.getValue();
                            }
                            
                           wp.SelectedOption = selectedItem;
                           
                           for(SelectOption sl : wp.wplist){ 
                                FSO__WorkPlan__c wpitem = workPlanMap.get(sl.getValue());
                                if ( wpitem != null){
                                    if ( newwplist[0].getValue() != wpitem.Id){
                                       newwplist.add(new SelectOption(wpitem.Id, wpitem.Name));
                                    }
                                }
                           } 
                           
                            wp.wplist =newwplist;
                           
                       }
                   }
               }
               
               handleAssetCheckboxChange();
               wplAssetWrapperRePopulated = null;
           }
        
           return wplSearchAssetWrapper; 
        }
     public List<UNITYPM_WorkPlanAssetsWrapper> getRecordsToDisplay() {
          system.debug('@@@@@ neli  getRecordsToDisplay  @@@@' );
            Integer counter = 1; 
             Map<id, FSO__WorkPlan__c> workPlanMap = new Map<id, FSO__WorkPlan__c>();
            
            if ( wplAssetWrapper == null){
                 wplAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper>(); 
                 List<Asset> assets = [SELECT Id, AccountId,  Name,  Description, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset 
                                     WHERE AccountId =:this.accountID AND UNITY_Asset_Type__c != null 
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
                            wplAssetWrapper.add(new UNITYPM_WorkPlanAssetsWrapper(a, wplist, counter, false));
                            counter++;
                         }
                      }
                      totalRecCount = counter;
                  }
             }
           if ( wplAssetWrapperRePopulated == null){
                 wplAssetWrapperRePopulated = new List<UNITYPM_WorkPlanAssetsWrapper>();
           }
        
           if (wplAssetWrapperRePopulated.size() > 0){
             
               for (UNITYPM_WorkPlanAssetsWrapper wp : wplAssetWrapper){
                   String assetID = wp.asset.ID;
                  
                   for (UNITYPM_WorkPlanAssetsWrapper wpselected : wplAssetWrapperRePopulated){
                       String aID = wpselected.asset.ID;
                       if ( assetID == aID){
                          wp.selected = true;
                          List<SelectOption> newwplist = new List<SelectOption>();
                          String selectedItem = '';
                          for (SelectOption slSelected : wpselected.wplist){
                             newwplist.add(slSelected);
                                selectedItem = slSelected.getValue();
                            }
                          
                           wp.SelectedOption = selectedItem;
                           
                           for(SelectOption sl : wp.wplist){ 
                                FSO__WorkPlan__c wpitem = workPlanMap.get(sl.getValue());
                                if ( wpitem != null){
                                    if ( newwplist[0].getValue() != wpitem.Id){
                                       newwplist.add(new SelectOption(wpitem.Id, wpitem.Name));
                                    }
                                }
                           } 
                           
                            wp.wplist =newwplist;
                       }
                   }
               }
               
               handleAssetCheckboxChange();
               wplAssetWrapperRePopulated = null;
           }
        
           return wplAssetWrapper; 
        }
        
     public void handleAssetCheckboxChange(){
         system.debug('@@@@@   neli  handleAssetCheckboxChange doSearch  @@@@ ' + doSearch);
       
        List<UNITYPM_WorkPlanAssetsWrapper> wplAssetSelected = new List<UNITYPM_WorkPlanAssetsWrapper> (); 
        aIDs = new Set <ID>();
        wpIDs = new Set <ID>();
        combineSelectedAssetIDandWPid = new List<String>();
           
         if ( doSearch){
             for ( UNITYPM_WorkPlanAssetsWrapper w : wplSetAssetWrapper){
                  if ( w.selected == true){
                      for ( UNITYPM_WorkPlanAssetsWrapper ws : wplAssetWrapper){
                          if (w.asset.ID == ws.asset.ID){
                              ws.selected = true;
                              ws.SelectedOption = w.SelectedOption;
                          }
                      }
                  }
                   if ( w.selected == false){
                      for ( UNITYPM_WorkPlanAssetsWrapper ws : wplAssetWrapper){
                          if (w.asset.ID == ws.asset.ID){
                              ws.selected = false;
                              ws.SelectedOption = w.SelectedOption;
                          }
                      }
                  }
                }
         }
        // else{
          //   wplSetAssetWrapper = new  List<UNITYPM_WorkPlanAssetsWrapper> (); 
         //}
         
         Integer noSelected = 0;
         for ( UNITYPM_WorkPlanAssetsWrapper w : wplAssetWrapper){ 
             if ( w.selected == true){
                   this.aIDs.add(w.asset.ID);
                   this.wpIDs.add(w.SelectedOption);
                   combineSelectedAssetIDandWPid.add(w.asset.ID + ',' +  w.SelectedOption);
                     
                  this.recsCommit = true;
             }
             else{
                 
                 noSelected++;
                            
                 if ( aIDs != null && wpIDs != null && combineSelectedAssetIDandWPid != null){
                     string assetToRemove='';
                      for (string s : combineSelectedAssetIDandWPid){
                           String[] sSplit = s.split(',');
                           String assetID = sSplit[0];
                           String wpID = sSplit[1];
                         if ( w.asset.ID == assetID){
                             assetToRemove = s;
                             break;
                         }
                      }
                      if (assetToRemove != ''){
                         for (Integer i = (combineSelectedAssetIDandWPid.size()-1) ; i>= 0 ; i--){
                            String s = combineSelectedAssetIDandWPid[i];
                            if(s.contains(assetToRemove)){
                                combineSelectedAssetIDandWPid.remove(i);
                            }
                        } 
                      }
                  }
             }
         }
         
       
         if ( noSelected == wplAssetWrapper.size()){
             system.debug('@@@@@   neli  handleAssetCheckboxChange noSelected == wplAssetWrapper.size() doSearch  @@@@ ' + doSearch);
               
             combineSelectedAssetIDandWPid = new List<String>();
             aIDs = new Set<ID>();
             wpIDs = new Set<ID>();
             recsCommit = false;
             //doSearch = false;
             if ( wplSearchAssetWrapper != null)
                  wplSearchAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();  
                  
             if (wplAssetSelectedWrapper != null)
                 wplAssetSelectedWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
         }
      }
      
     public void actionAssetsAddToCommit(){
         handleAssetCheckboxChange();
     }
    
      public List<UNITYPM_WorkPlanAssetsWrapper> getRecordsToCommit (){
            
        if ( aIDs != null && wpIDs != null ){
              Map <String, String> itemsSelected = new Map<String, String>();
              
                             
              for (string s : combineSelectedAssetIDandWPid){
                   String[] sSplit = s.split(',');
                   String assetID = sSplit[0];
                   String wpID = sSplit[1];
                         
                   recsCommit = true;
                   itemsSelected.put(assetID, wpID);
              }
                   
             if (itemsSelected.size() > 0 && aIDs.size() > 0 && wpIDs.size() > 0){
              
                 List<Asset> assets = [select Id, AccountId, Description, Name, 
                                     UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c 
                                     FROM Asset WHERE ID IN: itemsSelected.keySet()];     // itemsSelected.keySet() aIDs
                 
                
                 Map<id, FSO__WorkPlan__c> workPlanMap = new Map<id, FSO__WorkPlan__c>([SELECT ID, Name, UNITY_Asset_Type__c 
                                               FROM FSO__WorkPlan__c WHERE ID in :itemsSelected.values()]);  // wpIDs]); itemsSelected.values()
                 
                  if ( assets.size() != 0){
                      
                      wplAssetSelectedWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
                      
                      for (Asset a: assets){
                            String wpID = itemsSelected.get(a.ID);
                           
                            if( workPlanMap.ContainsKey(wpID) ){
                                   FSO__WorkPlan__c wp = workPlanMap.get(wpID);
                                        
                                   selectedWorkPalnName = wp.Name;
                                   selectedWorkPalnNameID = wpID;
                            }
                            if ( selectedWorkPalnName != '' && selectedWorkPalnNameID != ''){
                                wplAssetSelectedWrapper.add(new UNITYPM_WorkPlanAssetsWrapper(a, selectedWorkPalnName, selectedWorkPalnNameID, counter, true));
                                selectedWorkPalnName= '';
                                selectedWorkPalnNameID ='';
                                 
                                recsCommit = true;
                                counter++;
                            }
                      }
                  }
           }
             else{
                 
                 if (wplAssetSelectedWrapper != null){
                        wplAssetSelectedWrapper = null;
                    combineSelectedAssetIDandWPid = new List<String>();
                 }
             }
          }
        else{
             wplAssetSelectedWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();
              wplSearchAssetWrapper = new List<UNITYPM_WorkPlanAssetsWrapper> ();  //added
             combineSelectedAssetIDandWPid = new List<String>();
             aIDs = new Set<ID>();
             wpIDs = new Set<ID>();
             recsCommit = false;
        }    
       return wplAssetSelectedWrapper;
       
     }
     
       public PageReference actionAllAssetsAddToCommit(){
           handleAssetCheckboxChange();
           getRecordsToCommit();
           return null;
       }
    
    
     public PageReference BuildAssetsWorkPlanPageSet (){
         recPerPageChanged = true;
         retriveAllAssetsAndWorkPlan();
         recPerPageChanged = false;
         return null;
     }
     
     public PageReference addDefaultAssets (){
         system.debug('>>>> neli selectedAssetVal  >>>  ' + selectedAssetVal);
         UNITYPM_AddRemoveWOLIsOnWrokOrder.createDefaultSetOfAssets (accountID, workOrderNumber, selectedAssetVal, integer.valueof(selectedNumVal));
         selectedNumVal = '1';
         return null;
     }
     
       public PageReference searchAssetType(){
           wplSearchAssetWrapper = getSearchRecordsToDisplay(searchAsset);
           obj = new UNITYPM_CustomWorkPlanAssetsIterable(wplSearchAssetWrapper);
         
           doSearch = true;
            
            if(wplSearchAssetWrapper.size() > 10) {
                obj.setPageSize = 10;
            } else {
                obj.setPageSize = wplSearchAssetWrapper.size() ;
            }
            this.RecPerPage = obj.setPageSize;
            
            next();
            
          return null;
      } 
     
     public PageReference ResetAssetsTable (){
         doSearch= false;
         retriveAllAssetsAndWorkPlan();  
       return null;  
     }
     public PageReference  addPlan (){
         system.debug('>>>> neli addPlan >>>');
        PageReference pg;
        Boolean isDone = false;
        List<String> assetnameWPid = new List<String>();
        wpIDs = new set<ID>();
          
         
          system.debug('>>>> neli addPlan >>>' + wplAssetSelectedWrapper);
          system.debug('>>>> neli recsCommit >>>' + recsCommit);
          
          if (wplAssetSelectedWrapper != null && recsCommit == true){
            for ( UNITYPM_WorkPlanAssetsWrapper w : wplAssetSelectedWrapper ){
                 if ( w.selected == true){
                   aIDs.add(w.asset.ID);
                   wpIDs.add(w.wpID);
                  
                   assetnameWPid.add(w.asset.ID + ',' + w.wpID);
                 }
             }
             
             system.debug('>>>> neli assetnameWPid.size() >>>' + assetnameWPid.size());
             system.debug('>>>> neli wpIDs.size() >>>' + wpIDs.size());
             system.debug('>>>> neli aIDs.size() >>>' + aIDs.size());
             
              if (assetnameWPid.size() > 0 && wpIDs.size() > 0 && aIDs.size() > 0){
                  //add WOlis
                  UNITYPM_AddRemoveWOLIsOnWrokOrder.createWorkOrderLineItems(worOrderID, assetnameWPid, wpIDs, aIDs);
              } 
              else
              {
                 UNITYPM_AddRemoveWOLIsOnWrokOrder.deleteWorkOrderLineItems(worOrderID); 
                
              }
              //add/remove PO and POLIs
              UNITY_OrderUtilities.updatePMPO(new List<WorkOrder>{new Workorder(Id = worOrderID)});
               isDone = true;
          }
          else{
             
               UNITYPM_AddRemoveWOLIsOnWrokOrder.deleteWorkOrderLineItems(worOrderID); 
            isDone = true;
          }
             //if (isDone){
               //  pg = new pageReference('/apex/unitypm_addworkplans'); 
               //   pg.setRedirect(false);
               //   return pg;
             // }
              //else
            return null;
       }
  
    
   //Navigation methods
      public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
        }
    
      public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
      }
    
      public void next() {
        wplSetAssetWrapper = obj.next();
      }

     public void previous() {
        wplSetAssetWrapper = obj.previous();
     }
    
      public void sortWrpLst() {
        UNITYPM_WorkPlanAssetsWrapper.compareField = compareField;
        UNITYPM_WorkPlanAssetsWrapper.sortOrder = sortOrder;
        wplAssetWrapper.sort();
       
        obj = new UNITYPM_CustomWorkPlanAssetsIterable(wplAssetWrapper);
        obj.setPageSize = this.RecPerPage;
        next();
    }
    
    /*
       public void First() {
          while(hasPrevious()) 
            if(iterator != null && hasPrevious()) 
               wplSetAssetWrapper = iterator.previous();
            else 
            break; 
            
        } 
        
        public void Last() { 
            while(hasNext()) 
            if(iterator != null && hasNext()) 
               wplSetAssetWrapper = iterator.next();
               else 
               break; 
            
        }
     */   
}