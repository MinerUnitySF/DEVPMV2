public class UNITYPM_OrderLineItemsController {
    public Id orderId {get; 
                           set {
                               orderId = value;
                                    
                                List <OrderItem> olList = [SELECT UNITY_Product_Code__c,UNITY_Product_Description__c,
                                                  UNITY_Cost__c,Quantity,UNITY_Asset__c,UNITY_Asset__r.UNITY_Asset_Type__c,
                                                  UNITY_Unknown_Part_Description__c,UNITY_Vendor_Adjusted_Quantity__c,
                                                  UNITY_Total_Cost__c,Order.UNITY_Total_Cost__c 
                                            FROM OrderItem
                                                WHERE OrderId=:value 
                                                  AND UNITYPM_Is_Preventative_Maintenance__c = true];
                                        
                                 Map<String, List<OrderItem>> olMap = new Map  <String, List<OrderItem>>();      
                                 
                                 for( OrderItem ol: olList){
                                    String  aId =ol.UNITY_Asset__r.UNITY_Asset_Type__c;
                                  
                                     if(olMap.containsKey(aId)) {
                                         List<OrderItem> ols = olMap.get(aId);
                                         ols.add(ol);
                                         olMap.put(aId, ols);
                                     }
                                     else{
                                         olMap.put(aId, new List<OrderItem> {ol});
                                     }
                                }
                                
                                olWrapper = new List<orderLineWrapper>();
                                
                                for(String key : olMap.keySet()){
                                     String  productName ='';
                                     String  description ='';
                                     Decimal cost = null;
                                     Decimal  quianity = null;
                                     Decimal   vendorAdjustedQuantity = null;
                                     Decimal totalCost = null;
                                      
                                     for(OrderItem ol : olMap.get(key) ){
                                         if ( productName == '') 
                                             productName = ol.UNITY_Product_Code__c;
                                             
                                         if ( description == ''){
                                             if (ol.UNITY_Unknown_Part_Description__c !=null)
                                               description = ol.UNITY_Product_Description__c;
                                             else
                                               description = ol.UNITY_Product_Description__c + ' ' + ol.UNITY_Unknown_Part_Description__c;
                                         }
                                            
                                         if ( cost == null)
                                             cost = ol.UNITY_Cost__c;
                                         else
                                            cost= cost +ol.UNITY_Cost__c;
                                            
                                         if (quianity == null)
                                              quianity = ol.Quantity;
                                         else
                                             quianity=quianity + ol.Quantity;
                                            
                                         if (vendorAdjustedQuantity == null)
                                              vendorAdjustedQuantity = ol.UNITY_Vendor_Adjusted_Quantity__c;
                                         else
                                             vendorAdjustedQuantity= vendorAdjustedQuantity +  ol.UNITY_Vendor_Adjusted_Quantity__c;
                                        
                                         if (totalCost == null)
                                             totalCost = ol.UNITY_Total_Cost__c;
                                         else
                                             totalCost = totalCost + ol.UNITY_Total_Cost__c;
                                     }
                                   
                                     olWrapper.add(new orderLineWrapper(productName, description, cost, quianity, vendorAdjustedQuantity, totalCost)) ;
                                }
                 
                           }}
 
    public List<orderLineWrapper> olWrapper {get;set;}
    
    class orderLineWrapper{
        public String productName {get;set;}
        public String description {get;set;}
        public Decimal cost {get;set;}
        public Decimal quianity  {get;set;}
        public Decimal vendorAdjustedQuantity {get;set;}
        public Decimal totalCost {get;set;}
        
        public orderLineWrapper(String productName,String description, Decimal cost, Decimal quianity, Decimal vendorAdjustedQuantity, Decimal totalCost){
            this.productName = productName;
            this.description = description;
            this.cost = cost;
            this.quianity = quianity;
            this.vendorAdjustedQuantity = vendorAdjustedQuantity;
            this.totalCost = totalCost;
        }
        
    }
}