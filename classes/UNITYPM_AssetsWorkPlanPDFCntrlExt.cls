public class UNITYPM_AssetsWorkPlanPDFCntrlExt {
     public workOrder workorder {get; set;}
     public workOrder wo {get;  set;}
     public ID id {get;  set;}
     public String info {get;  set;}
     public string workPlanName {get;  set;}
     public String storeNo {get;  set;}
     public String siteAddress {get;  set;}
     public String siteCity {get;  set;}
     public String siteState {get;  set;}
     public DateTime woCreatedDate {get;  set;}
     public Boolean VendorAcceptedStatus {get; set;}
     public String WarningMessage {get;set;}
     public String siteContactPhone {get;set;}
     public String workOrderNumber {get;set;}
     
     public  List<string> wlYesNoList  {get;  set;}
     public  List<string> wlPassFailList  {get;  set;}
     public List<Asset> assets {get;set;}
     
     public  List<string> all  {get;  set;}
     public  List<FSO__WorkPlanItem__c> allWpLIs  {get;  set;}
     
     private static Integer FIRST_BREAK = 5;
     private static Integer SUBSEQ_BREAKS = 10;
     
     public  Map<String, List<String>> renderTypeWPLIs {get;set;}
     public List<assetsRowsWPLIsWrapper> pageWrapper {get;set;}
     public final static Integer MAX_LINEITEM_LINES_PER_PAGE = 25; 
     public Integer renderGroupItem {get;set;} 
     
   public UNITYPM_AssetsWorkPlanPDFCntrlExt(ApexPages.StandardController controller) {
       WarningMessage = 'This Work Order has not been accepted. Please return to the Home tab to accept.';
        workorder= (Workorder)controller.getRecord();
        id = (ID) controller.getRecord().get('id');
        
       
       try{
           WorkOrder wo= [SELECT CreatedDate, ID, AccountID,Account.ShippingStreet,UNITY_Vendor_Status__c,UNITY_Site_Contact_Phone__c,
                          WorkOrderNumber, UNITY_Work_Site_Address__c, UNITY_WO_Site_Location_City__c,UNITY_WO_Site_Location_State__c,UNITY_Site_Store_Number__c
                              FROM WorkOrder  WHERE id =:id];
                              //ID (SELECT Work_Order__c  FROM  UNITYPM_Work_Order_Assets_junction__c WHERE Work_Order__c ='0WOW0000000CqC6OAK'];
                                                   
             //select id from WorkOrder where id in (select Work_Order__c from UNITYPM_Work_Order_Assets_junction__c where Work_Order__c = '0WOW0000000CqC6OAK')
           
             system.debug('@@@@   workorder  @@@@ ' + workorder); 
             storeNo = wo.UNITY_Site_Store_Number__c;
             siteAddress = wo.Account.ShippingStreet;
             siteCity = wo.UNITY_WO_Site_Location_City__c;
             siteState = wo.UNITY_WO_Site_Location_State__c;
             woCreatedDate = wo.CreatedDate;
             siteContactPhone = wo.UNITY_Site_Contact_Phone__c;
             workOrderNumber = wo.WorkOrderNumber;
             
             //cerate map of work plan ID and List of assets associated with work plan
            Set<Id> aIds = new Set<Id>();
            Map<ID, List<ID>> wpIdAssetIDMap = new Map<ID, List<ID>>();
            
             List<UNITYPM_Work_Order_Assets_junction__c> woAssetsWP = [SELECT Asset__c, Work_Order__c, Work_Plan__c
                                           FROM  UNITYPM_Work_Order_Assets_junction__c WHERE Work_Order__c =:id  ];
                                           
             for (UNITYPM_Work_Order_Assets_junction__c woli : woAssetsWP) {
                     List<Id> assetIDs = new List<ID>();
                    if(!wpIdAssetIDMap.containsKey(woli.Work_Plan__c)){
                        assetIDs.add(woli.Asset__c);
                        wpIdAssetIDMap.put(woli.Work_Plan__c, assetIDs);
                    }
                    else{
                      assetIDs= wpIdAssetIDMap.get(woli.Work_Plan__c);
                      assetIDs.add(woli.Asset__c);
                      wpIdAssetIDMap.put(woli.Work_Plan__c, assetIDs);
                    } 
                    
                  aIDs.add(woli.Asset__c);
              }                                 
          
           wlYesNoList = new List<string>();
           wlPassFailList = new List<string>();
           all = new List<string>();
           allWPLIs = new List<FSO__WorkPlanItem__c>();
        
            assets =  [SELECT Id,Name,Product2Id,Product2.Name,Product2.Make1__c,Product2.Model__c,
                                     Product2.UNITY_Asset_Type__c,UNITY_Asset_Location_On_Site__c,SerialNumber,
                                      Description, UNITY_Model__c, UNITY_Asset_Type__c, UNITY_Model_No__c, UNITY_Serial_No__c
                                      FROM Asset WHERE Id IN :aIds];
          
            renderTypeWPLIs = new Map<String, List<String>>();
            pageWrapper = new  List<assetsRowsWPLIsWrapper>();
          
           
            for (FSO__WorkPlan__c wp : [SELECT Name, Id, UNITY_Group_Assets__c, 
                                  (SELECT FSO__Description__c, UNITY_Render_Type__c 
                                               FROM FSO__Items__r ORDER  BY UNITY_Render_Type__c)
                                                 FROM FSO__WorkPlan__c  WHERE ID IN :wpIdAssetIDMap.keyset() ORDER BY Name])
            {
               
                for  ( FSO__WorkPlanItem__c wpli : wp.FSO__Items__r)
                {
                    if(!renderTypeWPLIs.containsKey(wpli.UNITY_Render_Type__c)){
                         renderTypeWPLIs.put(wpli.UNITY_Render_Type__c, new List<String>{wpli.FSO__Description__c});
                
                    }else{
                         renderTypeWPLIs.get(wpli.UNITY_Render_Type__c).add(wpli.FSO__Description__c);
                    }
                }
                
               List< Asset> assetList = new List<asset>();
               List<ID> asdIDs = wpIdAssetIDMap.get(wp.ID);
               List<RowWrapper> rwrapper;
               Boolean groupAssets = false;
               
                if ( wp.UNITY_Group_Assets__c == false){   //UNITY_Group_Assets__c == false --> group by 1 asset column  
                    groupAssets = false; // wp.UNITY_Group_Assets__c;
                    
                    for (ID id : asdIDs){
                       for (Asset a : assets){
                            if (id == a.Id){
                                assetList.add(a);
                                rwrapper = getRowWrappersForOneAsset(assetList);
                                system.debug('#####     wp.name        ####' + wp.name);
                                system.debug('#####     renderTypeWPLIs        ####' + renderTypeWPLIs);
                                system.debug('#####     rwrapper        ####' + rwrapper);
                                system.debug('#####     groupAssets        ####' + groupAssets);
                                
                                pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets));
                                rwrapper = new List<RowWrapper>();
                                assetList = new List<asset>();
                               // renderTypeWPLIs = new Map<String, List<String>>();
                            }
                        }
                    }
                    renderTypeWPLIs = new Map<String, List<String>>();
                }
                else  {                              // UNITY_Group_Assets__c ==true --> group by 5 assets column
                    groupAssets = wp.UNITY_Group_Assets__c;  //groupAssets == true
                   
                    if ( asdIDs.size() > 5){
                        for (Integer i = (asdIDs.size()-1) ; i>= 0 ; i--)
                        {
                            for (Asset a : assets){
                                if (asdIDs[i] == a.Id){
                                      assetList.add(a);
                                      if (assetList.size() == 5){
                                        rwrapper = getAllRowWrappers(assetList);
                                         system.debug('##### more 5   wp.name        ####' + wp.name);
                                         system.debug('##### more  5  renderTypeWPLIs        ####' + renderTypeWPLIs);
                                         system.debug('##### more 5   rwrapper        ####' + rwrapper);
                                         system.debug('#####  more 5  groupAssets        ####' + groupAssets);
                                        assetList = new List<asset>();
                                        pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, 5));
                                        rwrapper = new List<RowWrapper>();
                                        
                                     }
                                     asdIDs.remove( i );
                            
                                     break;
                                  }
                            }
                          if ( asdIDs.size() < 5 && assetList.size() == 0){
                             break;
                          }
                        }
                    }
                    
                    if ( asdIDs.size() == 5){
                         for (Asset a : assets){
                             if (asdIDs.contains(a.Id)){
                                  assetList.add(a);
                                  if (assetList.size() == 5){
                                    rwrapper = getAllRowWrappers(assetList);
                                    assetList = new List<asset>();
                                 }
                             }
                          } 
                             renderGroupItem = 5;
                             system.debug('#####  5   wp.name        ####' + wp.name);
                             system.debug('#####   5  renderTypeWPLIs        ####' + renderTypeWPLIs);
                             system.debug('#####  5   rwrapper        ####' + rwrapper);
                             system.debug('#####   5  groupAssets        ####' + groupAssets);
                                         
                         pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, renderGroupItem));
                         rwrapper = new List<RowWrapper>();
                    }
                    else  if ( asdIDs.size() == 1){
                         for (Asset a : assets){
                             if (asdIDs.contains(a.Id)){
                                assetList.add(a);
                                rwrapper = getAllRowWrappersForOne(assetList);
                                assetList = new List<asset>();
                             }
                          }
                             renderGroupItem = 1;
                             system.debug('#####  1   wp.name        ####' + wp.name);
                             system.debug('#####   1  renderTypeWPLIs        ####' + renderTypeWPLIs);
                             system.debug('#####  1   rwrapper        ####' + rwrapper);
                             system.debug('#####   1  groupAssets        ####' + groupAssets);
                         pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, renderGroupItem));
                         rwrapper = new List<RowWrapper>();
                    }
                    else  if ( asdIDs.size() == 2){
                         for (Asset a : assets){
                             if (asdIDs.contains(a.Id)){
                                assetList.add(a);
                                if (assetList.size() == asdIDs.size()){
                                  rwrapper = getAllRowWrappersForTwo(assetList);
                                  assetList = new List<asset>();
                                }
                             }
                          }
                             renderGroupItem =2;
                             system.debug('#####  2   wp.name        ####' + wp.name);
                             system.debug('#####   2  renderTypeWPLIs        ####' + renderTypeWPLIs);
                             system.debug('#####  2   rwrapper        ####' + rwrapper);
                             system.debug('#####   2  groupAssets        ####' + groupAssets);
                             
                         pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, renderGroupItem));
                         rwrapper = new List<RowWrapper>();
                    }
                    else  if ( asdIDs.size() == 3){
                         for (Asset a : assets){
                             if (asdIDs.contains(a.Id)){
                                assetList.add(a);
                                if (assetList.size() == asdIDs.size()){
                                  rwrapper = getAllRowWrappersForThree(assetList);
                                  assetList = new List<asset>();
                                }
                             }
                          } 
                          
                            renderGroupItem =3;
                             system.debug('#####  3   wp.name        ####' + wp.name);
                             system.debug('#####   3  renderTypeWPLIs        ####' + renderTypeWPLIs);
                             system.debug('#####  3   rwrapper        ####' + rwrapper);
                             system.debug('#####   3  groupAssets        ####' + groupAssets);
                             
                         pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, renderGroupItem));
                         rwrapper = new List<RowWrapper>();
                    }
                    else  if ( asdIDs.size() == 4){
                        for (Asset a : assets){
                             if (asdIDs.contains(a.Id)){
                                assetList.add(a);
                                if (assetList.size() == asdIDs.size()){
                                  rwrapper = getAllRowWrappersForFour(assetList);
                                  assetList = new List<asset>();
                                }
                             }
                          }
                          
                             renderGroupItem = 4;
                             system.debug('#####  4   wp.name        ####' + wp.name);
                             system.debug('#####   4  renderTypeWPLIs        ####' + renderTypeWPLIs);
                             system.debug('#####  4   rwrapper        ####' + rwrapper);
                             system.debug('#####   4  groupAssets        ####' + groupAssets);
                             
                        pageWrapper.add( new assetsRowsWPLIsWrapper(wp.name, renderTypeWPLIs, rwrapper, groupAssets, renderGroupItem));
                        rwrapper = new List<RowWrapper>();
                    }
                
                    renderTypeWPLIs = new Map<String, List<String>>();
                }
         }
       }
       catch (Exception ex){
           system.debug('****   error *** ' + ex);
       }
   }
   
    public List<RowWrapper> getAllRowWrappers(List<Asset> assetsList)
    {
         String emptyCell = '<td width="14%">&nbsp;</td>';
        List<RowWrapper> rows = new List<RowWrapper>();
        rows=new List<RowWrapper>();
            
            for (Integer idx=0; idx<5; idx++)
                rows.add(new RowWrapper());
            
            rows[0].addValue('<td width="30%">Position</td>');
            rows[1].addValue('<td width="30%">Make/Brand </td>');
            rows[2].addValue('<td width="30%">Model</td>');
            rows[3].addValue('<td width="30%">Serial</td>');
            rows[4].addValue('<td width="30%">Condition </td>');
            
            system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
           
                for (Integer idx=0; idx < assetsList.size(); idx++)
                {
                    String productName ='';
                    if ( assetsList[idx].Product2.Name != null)
                         productName = assetsList[idx].Product2.Name;
                         
                     String modelNo ='';
                    if ( assetsList[idx].UNITY_Model_No__c != null)
                         modelNo = assetsList[idx].UNITY_Model_No__c;
                         
                     String serialNo ='';
                    if ( assetsList[idx].UNITY_Serial_No__c != null)
                         serialNo = assetsList[idx].UNITY_Serial_No__c;
                       
                    rows[0].addValue('<td width="14%"> </td>');
                    rows[1].addValue('<td width="14%">' + productName + '</td>');
                    rows[2].addValue('<td width="14%">' + modelNo + '</td>');
                    rows[3].addValue('<td width="14%">' + serialNo + '</td>');
                    rows[4].addValue('<td width="14%"> Green / Yellow / Red </td>');
                }
    
        return rows;
    }
    public List<RowWrapper> getAllRowWrappersForOne(List<Asset> assetsList)
    {
         String emptyCell = '<td width="14%">&nbsp;</td>';
        List<RowWrapper> rows = new List<RowWrapper>();
        rows=new List<RowWrapper>();
            
            for (Integer idx=0; idx<5; idx++)
                rows.add(new RowWrapper());
                
            rows[0].addValue('<td width="30%">Position</td>');
            rows[1].addValue('<td width="30%">Make/Brand </td>');
            rows[2].addValue('<td width="30%">Model </td>');
            rows[3].addValue('<td width="30%">Serial </td>');
            rows[4].addValue('<td width="30%">Condition </td>');
            
            system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
           
                for (Integer idx=0; idx < assetsList.size(); idx++)
                {
                     String productName ='';
                    if ( assetsList[idx].Product2.Name != null)
                         productName = assetsList[idx].Product2.Name;
                         
                     String modelNo ='';
                    if ( assetsList[idx].UNITY_Model_No__c != null)
                         modelNo = assetsList[idx].UNITY_Model_No__c;
                         
                     String serialNo ='';
                    if ( assetsList[idx].UNITY_Serial_No__c != null)
                         serialNo = assetsList[idx].UNITY_Serial_No__c;
                         
                    rows[0].addValue('<td width="14%"> </td>');
                    rows[1].addValue('<td width="14%">' + productName + '</td>');
                    rows[2].addValue('<td width="14%">' + modelNo + '</td>');
                    rows[3].addValue('<td width="14%">' + serialNo + '</td>');
                    rows[4].addValue('<td width="14%"> Green / Yellow / Red </td>');
                }
            
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
    
        return rows;
    }
     public List<RowWrapper> getAllRowWrappersForTwo(List<Asset> assetsList)
    {
         String emptyCell = '<td width="14%">&nbsp;</td>';
        List<RowWrapper> rows = new List<RowWrapper>();
        rows=new List<RowWrapper>();
            
            for (Integer idx=0; idx<5; idx++)
                rows.add(new RowWrapper());
          
            rows[0].addValue('<td width="30%">Position</td>');
            rows[1].addValue('<td width="30%">Make/Brand </td>');
            rows[2].addValue('<td width="30%">Model</td>');
            rows[3].addValue('<td width="30%">Serial</td>');
            rows[4].addValue('<td width="30%">Condition </td>');
             
            system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
           
                for (Integer idx=0; idx < assetsList.size(); idx++)
                {
                     String productName ='';
                    if ( assetsList[idx].Product2.Name != null)
                         productName = assetsList[idx].Product2.Name;
                         
                     String modelNo ='';
                    if ( assetsList[idx].UNITY_Model_No__c != null)
                         modelNo = assetsList[idx].UNITY_Model_No__c;
                         
                     String serialNo ='';
                    if ( assetsList[idx].UNITY_Serial_No__c != null)
                         serialNo = assetsList[idx].UNITY_Serial_No__c;
                         
                    rows[0].addValue('<td width="14%"> </td>');
                    rows[1].addValue('<td width="14%">' + productName + '</td>');
                    rows[2].addValue('<td width="14%">' + modelNo + '</td>');
                    rows[3].addValue('<td width="14%">' + serialNo + '</td>');
                    rows[4].addValue('<td width="14%"> Green / Yellow / Red </td>');
                }
            
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
    
        return rows;
    }
    public List<RowWrapper> getAllRowWrappersForThree(List<Asset> assetsList)
    {
         String emptyCell = '<td width="14%">&nbsp;</td>';
        List<RowWrapper> rows = new List<RowWrapper>();
        rows=new List<RowWrapper>();
            
            for (Integer idx=0; idx<5; idx++)
                rows.add(new RowWrapper());
          
            rows[0].addValue('<td width="30%">Position</td>');
            rows[1].addValue('<td width="30%">Make/Brand</td>');
            rows[2].addValue('<td width="30%">Model</td>');
            rows[3].addValue('<td width="30%">Serial</td>');
            rows[4].addValue('<td width="30%">Condition </td>');
            
            system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
           
                for (Integer idx=0; idx < assetsList.size(); idx++)
                {
                     String productName ='';
                    if ( assetsList[idx].Product2.Name != null)
                         productName = assetsList[idx].Product2.Name;
                         
                     String modelNo ='';
                    if ( assetsList[idx].UNITY_Model_No__c != null)
                         modelNo = assetsList[idx].UNITY_Model_No__c;
                         
                     String serialNo ='';
                    if ( assetsList[idx].UNITY_Serial_No__c != null)
                         serialNo = assetsList[idx].UNITY_Serial_No__c;
                         
                    rows[0].addValue('<td width="14%"> </td>');
                    rows[1].addValue('<td width="14%">' + productName + '</td>');
                    rows[2].addValue('<td width="14%">' + modelNo + '</td>');
                    rows[3].addValue('<td width="14%">' + serialNo + '</td>');
                    rows[4].addValue('<td width="14%"> Green / Yellow / Red </td>');
                }
            
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
                    
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
    
        return rows;
    }
    public List<RowWrapper> getAllRowWrappersForFour(List<Asset> assetsList)
    {
         String emptyCell = '<td width="14%">&nbsp;</td>';
        List<RowWrapper> rows = new List<RowWrapper>();
        rows=new List<RowWrapper>();
            
            for (Integer idx=0; idx<5; idx++)
                rows.add(new RowWrapper());
          
            rows[0].addValue('<td width="30%">Position</td>');
            rows[1].addValue('<td width="30%">Make/Brand </td>');
            rows[2].addValue('<td width="30%">Model</td>');
            rows[3].addValue('<td width="30%">Serial</td>');
            rows[4].addValue('<td width="30%">Condition </td>');
            
            system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
           
                for (Integer idx=0; idx < assetsList.size(); idx++)
                {
                    String productName ='';
                    if ( assetsList[idx].Product2.Name != null)
                         productName = assetsList[idx].Product2.Name;
                         
                     String modelNo ='';
                    if ( assetsList[idx].UNITY_Model_No__c != null)
                         modelNo = assetsList[idx].UNITY_Model_No__c;
                         
                     String serialNo ='';
                    if ( assetsList[idx].UNITY_Serial_No__c != null)
                         serialNo = assetsList[idx].UNITY_Serial_No__c;
                         
                    rows[0].addValue('<td width="14%"> </td>');
                    rows[1].addValue('<td width="14%">' + productName + '</td>');
                    rows[2].addValue('<td width="14%">' + modelNo + '</td>');
                    rows[3].addValue('<td width="14%">' + serialNo + '</td>');
                    rows[4].addValue('<td width="14%"> Green / Yellow / Red </td>');
                }
            
                    rows[0].addValue(emptyCell);
                    rows[1].addValue(emptyCell);
                    rows[2].addValue(emptyCell);
                    rows[3].addValue(emptyCell);
                    rows[4].addValue(emptyCell);
    
        return rows;
    }
    
  
     public List<RowWrapper> getRowWrappersForOneAsset(List<Asset> assetsList)
    {
             String emptyCell = '<td width="14%">&nbsp;</td>';
            List<RowWrapper> rows = new List<RowWrapper>();
            rows=new List<RowWrapper>();
                
                for (Integer idx=0; idx<4; idx++)
                    rows.add(new RowWrapper());
              
                rows[0].addValue('<td width="30%">Make/Brand </td>');
                rows[1].addValue('<td width="30%">Model</td>');
                rows[2].addValue('<td width="30%">Serial</td>');
                rows[3].addValue('<td width="30%">Condition </td>');
                
                system.debug('@@@@   this.assets.size() @@@' + assetsList.size());
               
                    for (Integer idx=0; idx < assetsList.size(); idx++)
                    {
                          String productName ='';
                            if ( assetsList[idx].Product2.Name != null)
                                 productName = assetsList[idx].Product2.Name;
                                 
                             String modelNo ='';
                            if ( assetsList[idx].UNITY_Model_No__c != null)
                                 modelNo = assetsList[idx].UNITY_Model_No__c;
                                 
                             String serialNo ='';
                            if ( assetsList[idx].UNITY_Serial_No__c != null)
                                 serialNo = assetsList[idx].UNITY_Serial_No__c;
                         
                        rows[0].addValue('<td width="70%">' + productName + '</td>');
                        rows[1].addValue('<td width="70%">' + modelNo + '</td>');
                        rows[2].addValue('<td width="70%">' + serialNo + '</td>');
                        rows[3].addValue('<td width="70%"> Green / Yellow / Red </td>');
                    }
        
            return rows;
    }
    public class RowWrapper
    {
      public List<String> values {get; set;}
    
         public RowWrapper()
         {
            values=new List<String>();
         }
         public void addValue(String value)
         {
           values.add(value);
         }
    }
    
    public class assetsRowsWPLIsWrapper{
        public String renderType {get;set;}
        public List<String> wpliDescription {get;set;}
        public List<RowWrapper> assetsRow {get;set;}
        public List<List<RowWrapper>> rowWrapperList {get;set;}
        public Map<String, List<String>> renderTypeWPLIs {get;set;}
        public List<RowWrapper> rowWrapper {get;set;}
        public  Map<String, Map<String, List<String>>> mapOfWPLiMap {get;set;}
        public String wpName {get;set;}
        public Boolean groupAssets { get; set;}
        public Integer renderGroupItem {get;set;}
     
        
        public assetsRowsWPLIsWrapper (String wpName, Map<String, List<String>> renderTypeWPLIs, List<RowWrapper>  rowWrapper,  Boolean groupAssets){
             this.wpName = wpName;
            this.renderTypeWPLIs = renderTypeWPLIs;
            this.rowWrapper = rowWrapper;
            this.groupAssets = groupAssets;
        }
        
         public assetsRowsWPLIsWrapper (String wpName, Map<String, List<String>> renderTypeWPLIs, List<RowWrapper>  rowWrapper,  Boolean groupAssets, Integer renderGroupItem){
             this.wpName = wpName;
            this.renderTypeWPLIs = renderTypeWPLIs;
            this.rowWrapper = rowWrapper;
            this.groupAssets = groupAssets;
            this.renderGroupItem = renderGroupItem;
        }
    }
}