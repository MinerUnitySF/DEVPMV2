public class UNITY_ServiceReportCntrlExtension  {
     
    public UNITY_ServiceReportCntrlExtension(ApexPages.StandardController controller) {
       relatedTo= (Workorder)controller.getRecord();
    }
    public WorkOrder relatedTo {get;
            set{
                relatedTo = value;
                        system.debug('@@@@@@   relatedTo  @@@ ' + relatedTo);
                       
                       try{
                            if(String.isNotBlank(relatedTo.UNITY_Tech_ETA_Date_Cust__c)){
                                this.d = relatedTo.UNITY_Tech_ETA_Date_Cust__c;
                                this.d = d.substring(0,d.indexOf(' '));
                            }else{
                                d = '';
                            }
                            
                            List<WorkOrderLineItem> wolis = [SELECT Id,AssetId FROM WorkOrderLineItem WHERE WorkOrderId = :relatedTo.Id];
                            Set<Id> assetids = new Set<Id>();
                            for(WorkOrderLineItem woli :wolis){
                                if(String.isNotBlank(woli.AssetId))
                                    assetids.add(woli.AssetId);
                            }
                            //Get the case related rto the Work Order
                            this.cse = [SELECT Id,CaseNumber,AssetId FROM Case WHERE Id = :relatedTo.CaseId LIMIT 1];
                            if(String.isNotBlank(this.cse.AssetId))
                                assetids.add(this.cse.AssetId);
                            //Get the asset related to the Work Order (via the Case or WOLIs)
                            this.assets = [SELECT Id,Name,Product2Id,Product2.Name,Product2.Make1__c,Product2.Model__c,Product2.UNITY_Asset_Type__c,UNITY_Asset_Location_On_Site__c,SerialNumber FROM Asset WHERE Id IN :assetids];
                            if(this.assets.isEmpty()){
                                this.assets.add(new Asset());
                            }
                            this.aType = String.isNotBlank(relatedTo.UNITY_Skill_Broad__c)?relatedTo.UNITY_Skill_Broad__c:'';
                            Set<String> delimitedInvoiceableStatuses = new Set<String>();
                            //Get all PO Lines for this work order
                            Map<string,UNITY_General_Settings__c> generalSettings = UNITY_General_Settings__c.getAll();
                            UNITY_General_Settings__c generalSetting = generalSettings.get(UNITY_Constants.PO_INVOICEABLE_STATUSES);
                            String POInvoiceableStatuses;
                            if(generalSetting!=null){
                                POInvoiceableStatuses = generalSetting.UNITY_Value__c;
                            }
                            if(POInvoiceableStatuses!=null){
                                delimitedInvoiceableStatuses = new Set<String>(POInvoiceableStatuses.split(UNITY_Constants.PO_INVOICEABLE_STATUSES_DELIMITER));
                                delimitedInvoiceableStatuses.add('Final');
                            }
                            List<Order> allPOs = [SELECT Id,OrderNumber,AccountId,EffectiveDate,
                                                  (SELECT Id,OrderId,Order.OrderNumber,OrderItemNumber,Quantity,UNITY_Is_Vendor_Supply__c,
                                                   UNITY_Product_Description__c,UNITY_Product_Name__c
                                                   FROM OrderItems 
                                                   WHERE PriceBookEntry.Product2.Name != 'Vendor Service Fee'
                                                   AND PriceBookEntry.Product2.UNITY_Product_Type__c = 'Part'
                                                  ) 
                                                  FROM Order WHERE FSO__WorkOrder__c = :relatedTo.Id
                                                  AND RecordTypeId = :UNITY_Constants.ORDER_PURCHASE_ORDER_RECORDTYPE
                                                  AND UNITY_Vendor__c = :relatedTo.UNITY_Assigned_Vendor__c
                                                  AND Status NOT IN ('Cancelled','Rejected')];
                            this.products = new List<OrderItem>();
                            this.additionalProducts = new List<OrderItem>();
                            for(Order o :allPOs){
                                Integer count = 0;
                                for(OrderItem oi :o.OrderItems){
                                    count++;
                                    if(count > 10)
                                        this.additionalProducts.add(oi);
                                    else
                                        this.products.add(oi);
                                }
                            }
                            if(products.size() >= 10){
                                for(Integer i = 0; i < 10; i++){
                                    additionalProducts.add(new OrderItem());
                                }
                            }else{
                                for(Integer i = products.size(); i < 10; i++){
                                    products.add(new OrderItem());
                                }
                            }
                       }
                         catch(exception ex){
                             system.debug('*** ERROR from UNITY_ServiceReportCntrlExtension **** ' + ex);
                      }
                }
        }
                            
    public Case cse {get; private set;}
    public List<Asset> assets {get; private set;}
    public List<OrderItem> products {get; private set;}
    public List<OrderItem> additionalProducts {get; private set;}
    public String d {get; private set;}
    public String aType {get; private set;}
     public  String WarningMessage {get;set;}
}