public class UNITY_WorkOrderPlanPDFCntrlExtension {
    public workOrder workorder {get; private set;}
    public ID id {get; private set;}
    public User contactUser { set; private get;}
    public String CreatedDate{get;private set;}
    public String AssignedDate{get;private set;}
    public String Window_Begin{get;private set;}
    public String Window_End {get; private set;}
    public String MinerFooterDocument {get;private set;}
    public String JobSite {get;private set;}
    public Boolean VendorAcceptedStatus {get;private set;}
    public Decimal POtotalCost {get;private set;}
    public String CustomerStoreLocation {get;private set;}
    public  String WarningMessage {get;private set;}
    public string  MinerImage {get;private set;} 
    public string  WorkOrderShippingCity {get; private set;} 
    public string  WorkOrderShippingStreet {get;private set;}
    public string  WorkOrderShippingState {get;private set;}
    public string  WorkOrderShippingPostalCode {get;private set;}
    public string  WorkOrderCustomerPO {get;private set;}
    public string WorkOrderContact {get;private set;} 
    public String aType {get; private set;}
    public List<Asset> assets {get; private set;}
    public List<OrderItem> products {get; private set;}
    public List<OrderItem> additionalProducts {get; private set;}
    public List<WorkOrderLineItem> woli {get; private set;}
    public Boolean AssetsDataAvailable {get; private set;}
    
    public UNITY_WorkOrderPlanPDFCntrlExtension(ApexPages.StandardController controller) {
       WarningMessage = 'This Work Order has not been accepted. Please return to the Home tab to accept.';
       workorder= (Workorder)controller.getRecord();
       id = (ID) controller.getRecord().get('id');
         
         system.debug('@@@@   neli >>> work order id  >>> ' + id);
         
          try{
              WorkOrder wo= [SELECT Account.UNITY_TimeZoneSidKey__c, Case.CreatedDate, UNITY_Vendor_Last_Assigned__c,UNITY_Job_Site__c,
                            UNITY_Work_Window_Begin__c,UNITY_Work_Window_End__c, UNITY_Email_Document_Footer__c,UNITY_Vendor_Status__c,
                               Account.UNITY_LOC__c, UNITY_Email_Logo_URL__c,Contact.Name,UNITY_Skill_Broad__c, //UNITY_Current_PO__r.UNITY_Total_Cost__c,
                              Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, case.UNITY_Customer_PO__c
                                                   FROM WorkOrder
                                                                   WHERE id =: id];
          //MinerFooterDocument = wo.UNITY_Email_Document_Footer__c;
          //MinerFooterDocument = MinerFooterDocument.replace('<br>', '<br/>');
          
          JobSite = wo.UNITY_Job_Site__c;
          JobSite = JobSite.replace('BR()', '<br/>');
          MinerImage = wo.UNITY_Email_Logo_URL__c;
          WorkOrderShippingCity = wo.Account.ShippingCity;
          WorkOrderShippingStreet = wo.Account.ShippingStreet;
          WorkOrderShippingState = wo.Account.ShippingState;
          WorkOrderShippingPostalCode = wo.Account.ShippingPostalCode;
          WorkOrderCustomerPO = '12345'; //wo.case.UNITY_Customer_PO__c;
          WorkOrderContact = wo.Contact.Name;
          this.aType = String.isNotBlank(wo.UNITY_Skill_Broad__c)?wo.UNITY_Skill_Broad__c:'';
          
          UNITY_Utils.DateTimeZone dtzCreatedDate = UNITY_Utils.getDateTime(wo.Case.CreatedDate, null, wo.Account.UNITY_TimeZoneSidKey__c);
          UNITY_Utils.DateTimeZone dtzAssignedDate;
    
          if (wo.UNITY_Vendor_Last_Assigned__c != null)
              dtzAssignedDate = UNITY_Utils.getDateTime(wo.UNITY_Vendor_Last_Assigned__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
          else
              dtzAssignedDate = dtzCreatedDate;
    
         // UNITY_Utils.DateTimeZone dtzWindow_Begin = UNITY_Utils.getDateTime(wo.UNITY_Work_Window_Begin__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
          //UNITY_Utils.DateTimeZone dtzWindow_End = UNITY_Utils.getDateTime(wo.UNITY_Work_Window_End__c, null, wo.Account.UNITY_TimeZoneSidKey__c);
       
          CreatedDate = dtzCreatedDate.format; 
          AssignedDate = dtzAssignedDate.format; 
            
          Window_Begin = '2/05/2018';//dtzWindow_Begin.format + ' ' + dtzWindow_Begin.displayname;
          Window_End = '2/05/2018'; //dtzWindow_End.format + ' ' + dtzWindow_End.displayname;
          POtotalCost = 100;  // wo.UNITY_Current_PO__r.UNITY_Total_Cost__c;
          CustomerStoreLocation = wo.Account.UNITY_LOC__c;
          VendorAcceptedStatus = false;
        
            
           if ( wo.UNITY_Vendor_Status__c != 'Accepted'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This Work Order has not been accepted. Please return to the Home tab to accept.'));
          }
           else {
               VendorAcceptedStatus = true;
           }
        
           //WOLI's
            List<WorkOrderLineItem> wolis = [SELECT Id, AssetId FROM WorkOrderLineItem WHERE WorkOrderId = :id];
            Set<Id> assetids = new Set<Id>();
            for(WorkOrderLineItem woli :wolis){
                    assetids.add(woli.AssetId);
            }
             
             system.debug('@@@@   neli >>> work order id  >>> ' + id);
             system.debug('@@@@   neli >>> assetids >>> ' + assetids);
             
             this.assets = [ Select  Id,Name,Product2Id,Product2.Name,Product2.Make1__c,Product2.Model__c,Product2.UNITY_Asset_Type__c,UNITY_Asset_Location_On_Site__c,SerialNumber,
                   (SELECT Id, FSO__Order__c,LineItemNumber, Description, CreatedDate, UNITY_Render_Type__c, UNITY_Vendor_Pin__c, Asset.ID
                                    FROM WorkOrderLineItems  
                                        WHERE WorkOrderId=:id ) From Asset WHERE Id IN :assetids];    
                                        
            if(this.assets.isEmpty()){
                this.assets.add(new Asset());
                AssetsDataAvailable = false;
            }
            else{
                AssetsDataAvailable = true;
            }
            
            system.debug('@@@@ neli   AssetsDataAvailable  >>>>> ' + AssetsDataAvailable );
            
            this.woli =  [SELECT Id, FSO__Order__c,LineItemNumber, Description, CreatedDate, UNITY_Render_Type__c, UNITY_Vendor_Pin__c, Asset.ID
                                    FROM WorkOrderLineItem
                                       WHERE WorkOrderId=:id  AND Asset.ID = NULL
                                       ORDER BY Createddate ASC, FSO__Order__c ASC NULLS FIRST];
              
               system.debug('@@@@   neli >>> WOLIs  >>> ' + this.woli);
               
             for (Integer i = (woli.size()-1) ; i>= 0 ; i--){
                String s = woli[i].Description;
                if(s.contains('Check-In') || s.contains('Check-Out')){
                    woli.remove(i);
                }
            }
          }
          catch (Exception ex){
              system.debug('>>>>>  ERROR >>>>>>> ' + ex);
          }
        }
    }