public class UNITYPM_AddRemoveWOLIsOnWrokOrder {
   
    public static void deleteWorkOrderLineItems (String workOrderID){
        //delete WoLI's
        Boolean deletedWOLISCompleted = deleteWOLIs( workOrderID);
    } 
    
    public static void deleteWorkOrderLineItems (String workOrderID, Set <ID> assetID){
        //delete WoLI's
        Boolean deletedWOLISCompleted = deleteWorkOrderAssetsWP( workOrderID, assetID);
    } 
    
     public static  Boolean createWorkOrderLineItems(String workOrderID, List<String> assetIDWPid, Set <ID> workPlanID, Set <ID> assetID){
         system.debug('@@@@ neli createWorkOrderLineItems workOrderID @@@@' + workOrderID);
         system.debug('@@@@ neli createWorkOrderLineItems assetIDWPid.size() @@@@' + assetIDWPid.size());
         system.debug('@@@@ neli createWorkOrderLineItems workPlanID.size() @@@@' + workPlanID.size());
         system.debug('@@@@ neli createWorkOrderLineItems assetID.size() @@@@' + assetID.size());
      
       Boolean isDone = false;
       
       Map <ID, List<FSO__WorkPlanItem__c>> mapWorkPlanLineItems = new Map <ID, List<FSO__WorkPlanItem__c>>(); 
           for (FSO__WorkPlan__c wp : [SELECT ID FROM FSO__WorkPlan__c WHERE ID =:workPlanID]){
               List<FSO__WorkPlanItem__c> wpItems = new List<FSO__WorkPlanItem__c>();
                 
               for (FSO__WorkPlanItem__c wpli : [SELECT ID, Name, FSO__Description__c, UNITY_Render_Type__c  
                                              FROM FSO__WorkPlanItem__c 
                                                 WHERE FSO__WorkPlan__r.ID = :wp.ID]){
                   wpItems.add(wpli);
                     
               }
               mapWorkPlanLineItems.put(wp.ID, wpItems);
           }
       
       try{        
        //deleteWOLIs( workOrderID);
        //createdWOLIs(workOrderID, assetIDWPid, mapWorkPlanLineItems);
        deleteWorkOrderAssetsWP(workOrderID, assetID);
        createdAssetsWPcombineWOLIs(workOrderID, assetIDWPid, mapWorkPlanLineItems);
        
        isDone = true;
       } 
      catch(exception ex){
          system.debug('@@@@    ERROR @@@@ ' + ex);
      }
       return isDone;
    }
    
     private  static Boolean deleteWOLIs ( String workOrderID){
        Boolean hasError = false;
        Boolean returnResult = false;
        String message = '';
        system.debug('@@@@ neli deleteWOLIs workOrderID @@@@' + workOrderID);
        
        List<WorkOrderLineItem> woliListDelete =new List<WorkOrderLineItem>();
        
         woliListDelete = [SELECT ID, UNITY_Work_Plan__c, AssetId, workOrderID, UNITY_PM_WOLI__c
                                                 FROM WorkOrderLineItem 
                                                 WHERE workOrderID=:workOrderID 
                                                 AND UNITY_PM_WOLI__c = true]; 
    
          try{ 
           if (woliListDelete.size()>0)
                delete woliListDelete;
                
             system.debug('@@@@ neli deleteWOLIs for workOrderID completed @@@@' + workOrderID);
         }
         catch (DMLexception ex){
             system.debug('>>>> neli ERROR delete WOLIs >>>' + ex);
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
             hasError= true;
         }
         
         if (!hasError)
           returnResult= true;
           
         return returnResult;
     }
     
     private static Boolean deleteWorkOrderAssetsWP(String workOrderID, Set <ID> assetID){
        Boolean hasError = false;
        Boolean returnResult = false;
        String message = '';
        system.debug('@@@@ neli deleteWOLIs workOrderID @@@@' + workOrderID);
      
        
        List<UNITYPM_Work_Order_Assets_junction__c> woAssetsWPToDelete = [SELECT Asset__c, Work_Order__c, Work_Plan__c
                                           FROM  UNITYPM_Work_Order_Assets_junction__c WHERE Work_Order__c =:workOrderID  AND Asset__c in :assetID];
      
          try{ 
           if (woAssetsWPToDelete.size()>0)
                delete woAssetsWPToDelete;
                
             system.debug('@@@@ neli deleteWOLIs for workOrderID completed @@@@' + workOrderID);
         }
         catch (DMLexception ex){
             system.debug('>>>> neli ERROR delete WOLIs >>>' + ex);
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
             hasError= true;
         }
         
         if (!hasError)
           returnResult= true;
           
         return returnResult;
     }
   
     private static  Boolean createdWOLIs (String workOrderID,  List<String> assetIDWPid, Map <ID, List<FSO__WorkPlanItem__c>> mapWorkPlanLineItems){
      String saveResult = '';
      Boolean saveComplete = false;
      Boolean hasError = false;
       String message = '';
      
      system.debug('@@@@ neli createdWOLIs workOrderID @@@@' + workOrderID);
      
      List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem> ();
      
      system.debug('@@@@ neli createdWOLIs assetIDWPid @@@@' + assetIDWPid);
      
      for (String s : assetIDWPid){
          String[] sSplit = s.split(',');
          String assetID = sSplit[0];
          String wpID = sSplit[1];
          
           system.debug('@@@@ neli createdWOLIs assetID @@@@' + assetID);
            system.debug('@@@@ neli createdWOLIs wpID @@@@' + wpID);
            
          if ( wpID != null && assetID != null){
             List<FSO__WorkPlanItem__c> wpliList = mapWorkPlanLineItems.get(wpID);
               for ( FSO__WorkPlanItem__c wpli :wpliList){
                  WorkOrderLineItem woli = new WorkOrderLineItem();
                      woli.WorkOrderId = workOrderID;
                      woli.AssetId = assetID;
                     
                      woli.Description = wpli.FSO__Description__c;
                      woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                      woli.FSO__IsRequired__c = true;
                      woli.UNITY_Work_Plan__c = wpID;
                      woli.UNITY_Render_Type__c = wpli.UNITY_Render_Type__c;
                      woli.UNITY_PM_WOLI__c = true;
                  
                  system.debug('@@@@ neli createdWOLIs woli @@@@' + woli);
                   woliInsertList.add(woli);
               }
          }
       }
         try{
          if ( woliInsertList.size() > 0){
              system.debug('>>>>  neli woliInsertList.size()  >>>> ' + woliInsertList.size());
              
              // insert woliInsertList; //createdCompleted =  upsertWoLIs(woliInsertList);
            
              Database.SaveResult[] uResults = Database.insert(woliInsertList, false);

              for(Database.SaveResult result:uResults) {
                 if (result.isSuccess() ) {
                     saveComplete = true;
                 }
                 else{
                     for(Database.Error err : result.getErrors()) {
                         message += err.getMessage();
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
                         hasError= true;
                     }
                 }
              }
          }
        }
        catch ( exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
              system.debug('&&&&&&&&& neli ERROR  before insert &&&&&&&' + ex);
            hasError= true;
        }
         
         return saveComplete;
     }
     
     
     
      private static  Boolean createdAssetsWPcombineWOLIs (String workOrderID,  List<String> assetIDWPid, Map <ID, List<FSO__WorkPlanItem__c>> mapWorkPlanLineItems){
      String saveResult = '';
      Boolean saveComplete = false;
      Boolean hasError = false;
       String message = '';
      
      system.debug('@@@@ neli createdWOLIs workOrderID @@@@' + workOrderID);
      
      List<UNITYPM_Work_Order_Assets_junction__c> woliInsertList = new List<UNITYPM_Work_Order_Assets_junction__c> ();
      
      system.debug('@@@@ neli createdWOLIs assetIDWPid @@@@' + assetIDWPid);
      
      for (String s : assetIDWPid){
          String[] sSplit = s.split(',');
          String assetID = sSplit[0];
          String wpID = sSplit[1];
          
           system.debug('@@@@ neli createdWOLIs assetID @@@@' + assetID);
            system.debug('@@@@ neli createdWOLIs wpID @@@@' + wpID);
            
          if ( wpID != null && assetID != null){
             UNITYPM_Work_Order_Assets_junction__c woAWP = new UNITYPM_Work_Order_Assets_junction__c();
             
               woAWP.Work_Order__c = workOrderID;
               woAWP.Asset__c = assetID;
               woAWP.Work_Plan__c = wpID;
             
                woliInsertList.add(woAWP);
           
                  system.debug('@@@@ neli createdWOLIs woAWP @@@@' + woAWP);
                  
               }
       }
         try{
          if ( woliInsertList.size() > 0){
              system.debug('>>>>  neli woliInsertList.size()  >>>> ' + woliInsertList.size());
              
              // insert woliInsertList; //createdCompleted =  upsertWoLIs(woliInsertList);
            
              Database.SaveResult[] uResults = Database.insert(woliInsertList, false);

              for(Database.SaveResult result:uResults) {
                 if (result.isSuccess() ) {
                     saveComplete = true;
                 }
                 else{
                     for(Database.Error err : result.getErrors()) {
                         message += err.getMessage();
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
                         hasError= true;
                     }
                 }
              }
          }
        }
        catch ( exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
              system.debug('&&&&&&&&& neli ERROR  before insert &&&&&&&' + ex);
            hasError= true;
        }
         
         return saveComplete;
     }
     
      public static void createDefaultSetOfAssets(String accounID, String workOrderNumber, String asset, Integer count){
       List<asset> assetsToInsert = new List<Asset>();
       String dt = Datetime.now().format('yyyy-MM-dd');
       String assetName = workOrderNumber + '_' + dt;
       Boolean noAssetsExist = false;
       
       system.debug('@@@@ neli asset @@@@' + asset);
       system.debug('@@@@ neli accounID @@@@' + accounID);
       
       try
        {
            Asset assetCopy = [SELECT  ContactId, AccountId,  Product2Id, 
                       IsCompetitorProduct, Name, SerialNumber, InstallDate, PurchaseDate, 
                       UsageEndDate, Status, Price, Quantity, Description, RecordTypeId, 
                       FSO__Location__Latitude__s, FSO__Location__Longitude__s, FSO__Location__c,
                       FSO__ScanCode__c, SSVY_Asset_Condition__c, SSVY_Open_Work_Orders__c, 
                       SSVY_ScanCode__c, SSVY_Total_of_Work_Orders__c, UNITY_Asset_External_Id__c,
                       UNITY_Asset_Location_On_Site__c, UNITY_Is_Under_Warranty__c, UNITY_Make__c,
                       UNITY_Model__c, UNITY_Ownership_Type__c, UNITY_Photo__c, 
                       UNITY_Service_Channel_Asset_ID__c, UNITY_Warranty_End_Date__c, 
                       UNITY_Warranty_Start_Date__c, UNITY_Work_Order__c, UNITY_Template_Config_Ext_ID__c,
                       UNITY_Template_Configuration__c, UNITY_Active_Date__c, UNITY_Active_Reason__c,
                       UNITY_Active__c, UNITY_Current_Fiscal_Year_End_Date__c, UNITY_Current_Fiscal_Year_Start_Date__c,
                       UNITY_Current_Fiscal_Year__c, UNITY_Inactive_Date__c, UNITY_Initial_Active_Date__c, 
                       UNITY_Is_Retired__c, UNITY_LY_Total_Cost_Ownership__c, UNITY_Last_Year_Down_Time__c, 
                       UNITY_Last_Year_Service_Time__c, UNITY_Retired_Date__c, UNITY_YTD_Availability__c,
                       UNITY_YTD_Down_Time__c, UNITY_YTD_Service_Time__c, UNITY_YTD_Total_Cost_Ownership__c, 
                       UNITY_Additional_Trades__c, UNITY_Age_Months_of_Asset__c, UNITY_Asset_Type__c,
                       UNITY_Backrest_Height__c, UNITY_Brand__c, UNITY_Bumper_Projection__c, 
                       UNITY_Bumper_to_Building_Measurement__c, UNITY_Customer_Dock_Position_Name__c,
                       UNITY_Dimension_A1__c, UNITY_Dimension_A2__c, UNITY_Dimension_B1__c,
                       UNITY_Dimension_B2__c, UNITY_Dimension_C1__c, UNITY_Dimension_C2__c, UNITY_Dimension_D1__c, 
                       UNITY_Dock_Height_at_50__c, UNITY_Dock_Height_at_Face__c, UNITY_Door_Jamb_Type__c,
                       UNITY_Door_Opening_Size_Height__c, UNITY_Door_Opening_Size_Width__c, UNITY_Driveway_Dock_Approach__c, 
                       UNITY_Finished_Floor__c, UNITY_Hour_Meter_Reading__c, UNITY_Left_Clearance__c, 
                       UNITY_Lift_Height__c, UNITY_Load_Capacity__c, UNITY_Mast_Height_Collapsed__c, UNITY_Mast_Height_Extended__c, 
                       UNITY_Model_No__c, UNITY_Orientation_of_Position__c, UNITY_Overall_Condition__c, 
                       UNITY_Phase__c, UNITY_Pit_Height__c, UNITY_Pit_Length__c, UNITY_Pit_Width__c, 
                       UNITY_Power_Source__c, UNITY_Primary_Trade__c, UNITY_Right_Clearance__c, UNITY_Serial_No__c,
                       UNITY_Set_Back_to_Building__c, UNITY_Slope_of_Drive__c, UNITY_Store__c, UNITY_Tag_ID__c, 
                       UNITY_Tire_Condition__c, UNITY_Top_Clearance__c, UNITY_Type_of_Position__c, UNITY_Type_of_Wall__c,
                       UNITY_Voltage__c, UNITY_Warranty_Expires__c, UNITY_Warranty_Period__c, UNITY_Warranty_Provider__c, 
                       UNITY_Warranty_Starts_from_Install_Date__c, UNITY_Warranty__c, UNITY_Zone_B_Type_of_Obstruction__c, 
                       Unity_Zone_A_Type_of_Obstruction__c, Unity_Zone_C_Type_of_Obstruction__c,
                       Unity_Zone_D_Type_of_Obstruction__c, Unity_Zone_Type_of_Obstruction__c FROM Asset WHERE UNITY_Asset_Type__c =:asset];
      
           system.debug('@@@@ neli assetCopy @@@@' + assetCopy);
      
           for (Integer i=0 ; i < count; i++ ){
              Asset clonedAsset = assetCopy.clone(false, true);
              clonedAsset.Name = assetCopy.Name + '_' + assetName;
          
              assetsToInsert.add(clonedAsset);
           }
       }
       catch (Exception ex){
           system.debug('>>>    ERROR >>>> ' + ex);
           //if ( ex == 'List has no rows for assignment to SObject'){
               noAssetsExist = true;
          // }
       }
       
       if ( noAssetsExist){
           for (Integer i=0; i <count; i++){
               Asset a = new Asset();
                   a.UNITY_Asset_Type__c = asset;
                   a.AccountId = accounID;
                   a.Name = asset + '_' + assetName;
                   
                     system.debug('@@@@ neli added a @@@@' + a);
                     
               assetsToInsert.add(a);
           }
       }
       
        system.debug('@@@@ neli assetsToInsert.size()@@@@' + assetsToInsert.size());  
        try {
           if ( assetsToInsert.size() > 0)
              insert assetsToInsert;
        }
        catch (Exception ex){
            system.debug('>>>    ERROR to create assets>>>> ' + ex);
        }
     } 
     
      
    /* private  Boolean upsertWoLIs(List<WorkOrderLineItem> wolis)  {
      Boolean upsertCompleted = true;   
      List<Database.upsertResult> uResults = Database.upsert(wolis,false);
      
      for(Database.upsertResult result:uResults) {
         if (!result.isSuccess() && !result.isCreated()) {
             system.debug('>>>  ERROR to upsert >>>> ' + result.getErrors());
             upsertCompleted = false;
         }
      }
      
      return upsertCompleted;
   }
   */
   
    /* 
     private static Boolean deleteWOLIs ( String workOrderID, Set <ID> assetID){
         Boolean hasError = false;
         String message = '';
         Boolean returnResult = false;
        List<WorkOrderLineItem> woliListDelete = new List<WorkOrderLineItem>();
       
       for ( WorkOrderLineItem woliDelete : [SELECT ID, UNITY_Work_Plan__c, AssetId, workOrderID, UNITY_PM_WOLI__c
                                                 FROM WorkOrderLineItem 
                                                  WHERE workOrderID=:workOrderID 
                                                      AND AssetId NOT IN :assetID
                                                        AND UNITY_PM_WOLI__c = true]){
        
          woliListDelete.add(woliDelete);
       }
            try{ 
           if (woliListDelete.size()>0)
                delete woliListDelete;
         }
         catch (DMLexception ex){
             system.debug('>>>> ERROR delete WOLIs >>>' + ex);
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
             hasError= true;
         }
         if (!hasError)
           returnResult= true;
           
         return returnResult;
     }
     
     private static Boolean updateWOLIs(String workOrderID,  List<String> assetIDWPid, Set <ID> assetID){
         Boolean foundWOLIs = false;
         Boolean hasError = false;
         Boolean returnResult = false;
         List <String> aIdWpIdInsert = new List<string>();
         List <WorkOrderLineItem> woliUpdate = new List<WorkOrderLineItem>();
                                       
          for (WorkOrderLineItem wl : [SELECT Id, AssetId, UNITY_Work_Plan__c, UNITY_Work_Plan__r.Name, UNITY_Render_Type__c, UNITY_PM_WOLI__c 
                                                                     FROM  WorkOrderLineItem 
                                                                     WHERE workOrderID =:workOrderID  
                                                                     AND AssetId IN :assetID
                                                                     AND UNITY_PM_WOLI__c = true])
             {
                     
                 foundWOLIs = false;
                 for (String s : assetIDWPid){
                    String[] sSplit = s.split(',');
                    String aID = sSplit[0];
                    String wpID = sSplit[1];
                   
                    if (wl.AssetId == aID) 
                    {  
                        if (wl.UNITY_Work_Plan__c == wpID){
                            foundWOLIs = true;
                        }
                         else if (wl.UNITY_Work_Plan__c != wpID){
                             wl.UNITY_Work_Plan__c = wpID;
                             woliUpdate.add(wl);
                             foundWOLIs = true;
                         }
                         if (foundWOLIs)
                            break;
                     }
                     else{
                         aIdWpIdInsert.add(aID + ',' + wpID);
                         foundWOLIs = false; 
                     }
                 }
             }
            
            try{ 
             if ( woliUpdate.size() > 0)
                     update woliUpdate;
            }
            catch(exception ex){
               Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
               hasError= true;   
            }
            
            if (!hasError)
                returnResult= true;
           
         return returnResult;
     }
     
      private  static Boolean addWOLIs (String workOrderID, List<String> assetIDWPid, Map <ID, List<FSO__WorkPlanItem__c>> mapWorkPlanLineItems){
      system.debug('&&&&&&   addWOLIs  assetIDWPid &&&&' + assetIDWPid);
      String saveResult = '';
      Boolean saveComplete = false;
      Boolean hasError = false;
      String message = '';
     
      List <String> aIdWpIdInsert = new List<string>();
       
      for (WorkOrderLineItem wl : [SELECT Id, AssetId, UNITY_Work_Plan__c, UNITY_Work_Plan__r.Name, UNITY_Render_Type__c, UNITY_PM_WOLI__c 
                                                                     FROM  WorkOrderLineItem
                                                                     WHERE workOrderID =:workOrderID 
                                                                     AND UNITY_PM_WOLI__c = true])
                                                                     
        {
            
             for (String s : assetIDWPid){
                  String[] sSplit = s.split(',');
                  String aID = sSplit[0];
                  String wpID = sSplit[1];
                  
                if (wl.AssetId != aID){
                    aIdWpIdInsert.add(aID + ',' + wpID);
                }
            }
        }
                                                                     
      List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem> ();
    
       
      if ( aIdWpIdInsert.size() > 0) {  
              for (String s : aIdWpIdInsert){
              String[] sSplit = s.split(',');
              String assetID = sSplit[0];
              String wpID = sSplit[1];
                
              if ( wpID != null && assetID != null){
                 List<FSO__WorkPlanItem__c> wpliList = mapWorkPlanLineItems.get(wpID);
                   for ( FSO__WorkPlanItem__c wpli :wpliList){
                      WorkOrderLineItem woli = new WorkOrderLineItem();
                          woli.WorkOrderId = workOrderID;
                          woli.AssetId = assetID;
                         
                          woli.Description = wpli.FSO__Description__c;
                          woli.RecordTypeId =UNITY_Constants.WOLI_WORK_ORDER_LINE_ITEM_RECORDTYPE; 
                          woli.FSO__IsRequired__c = true;
                          woli.UNITY_Work_Plan__c = wpID;
                          woli.UNITY_Render_Type__c = wpli.UNITY_Render_Type__c;
                          woli.UNITY_PM_WOLI__c = true;
                       
                       woliInsertList.add(woli);
                   }
              }
           }
         
            try{
              if ( woliInsertList.size() > 0){
                  //insert woliInsertList;
                  Database.SaveResult[] uResults = Database.insert(woliInsertList, false);
    
                  for(Database.SaveResult result:uResults) {
                     if (result.isSuccess() ) {
                         saveComplete = true;
                     }
                     else{
                         for(Database.Error err : result.getErrors()) {
                             message += err.getMessage();
                             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
                             hasError= true;
                         }
                     }
                  }
                  
              }
            }
            catch ( exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex));
                hasError= true;
            }
        }  
      else{
         saveComplete =  createdWOLIs ( workOrderID,  assetIDWPid,  mapWorkPlanLineItems);
      }
         
         return saveComplete;
     }
     
    */
}