/**
 * Izay: Added the UNITY_Invoice_Description to the invoice query to display on invoice PDF
 * 
 * */
public class UNITY_InvoicePDFController{

    public UNITY_Invoice__c invoice {get;set;}
    
    public List<InvoicePageWrapper> pageWrappers {get;set;}
    public List<InvoiceLineItemWrapper> wrapperPMList {get;set;}
    
    public String[] emailAddress {get;set;}
    public String[] shippingAddress {get;set;}
    public String[] billingAddress {get;set;}
    public Date dateValue {get;set;}
    
    public String net {get;set;}
    public String discount {get;set;}
    public String tax {get;set;}
    public String total {get;set;}
    
    public Decimal discountDecimal {get;set;}
    public Decimal taxDecimal {get;set;}
    public Decimal totalDecimal {get;set;}
    public Decimal finalDecimal {get;set;}
    
    public Integer totalPages {get;set;}
    public Boolean invoiceForPM {get;set;}
    
    public final static Integer MAX_LINEITEM_LINES_PER_PAGE = 15; //23

    public Id invoiceId {get;
    set{
        if(value == null) return;
        invoiceId = value;
        pageWrappers = new List<InvoicePageWrapper>();
        invoiceForPM = false;
        
        system.debug('>>>> neli >>>>');
        
        invoice = [SELECT Id, 
                    Name, 
                    CreatedDate, 

                    UNITY_Bill_To_Address__c, 
                    UNITY_Job_Site__c, 
                    UNITY_Final_Price__c, 
                    UNITY_Total_Price__c, 
                    UNITY_Total_Tax__c, 
                    UNITY_Total_Cost__c, 
                    UNITY_Discount_Amount__c, 
                    UNITY_Email_Logo_URL__c, 
                    UNITY_Email_Billing_Address__c,
                    UNITY_Invoice_Description__c,
                    UNITY_Invoice_Status__c,
                    UNITY_Invoice_Date__c,
                    UNITY_Total_Adjustments__c, 

                    UNITY_Case__r.UNITY_Customer_PO__c, 
                    UNITY_Case__r.UNITY_Email_Invoice_Guarantee_Text__c, 
                
                    UNITY_Customer__r.UNITY_TimeZoneSidKey__c, 
                    UNITY_Customer__r.UNITY_Account_ID__c, 
                    UNITY_Customer__r.BillingStreet, 
                    UNITY_Customer__r.BillingPostalCode, 
                    UNITY_Customer__r.BillingCity,
                    UNITY_Customer__r.BillingState, 
                    UNITY_Customer__r.ShippingStreet, 
                    UNITY_Customer__r.ShippingPostalCode, 
                    UNITY_Customer__r.ShippingCity, 
                    UNITY_Customer__r.ShippingState, 

                    UNITY_Customer_Service_Contract__r.UNITY_Net_Payment_Terms__c, 

                    UNITY_Business_Unit_Account__c,
                    UNITY_Business_Unit_Account__r.MSPFS_BU_Billing_Address__c

                   FROM UNITY_Invoice__c WHERE Id =: invoiceId];
                  
                  
                  system.debug('>>>> neli  invoiceId >>>>' + invoiceId);
                  
        List<UNITY_Invoice_Line_Item__c> invoiceLineItems = [SELECT Id,Product__r.Description,UNITY_Sales_Tax__c,Product__r.Name,UNITY_Quantity__c,UNITY_Unit_Price__c,
                                                            UNITY_Total_Price__c,UNITY_Adjusted_Quantity__c,UNITY_Description__c, UNITYPM_Is_Preventative_Maintenance__c 
                                                        FROM UNITY_Invoice_Line_Item__c 
                                                        WHERE UNITY_Invoice__c =: invoiceId 
                                                          AND UNITY_Line_Status__c != 'Cancelled'
                                                          ORDER BY Product__r.Name];
        
        
        system.debug('>>>> neli  invoiceLineItems >>>>' + invoiceLineItems.size());
        
        List<List<UNITY_Invoice_Line_Item__c>> invoiceLineItemList = new List<List<UNITY_Invoice_Line_Item__c>>();
        List<UNITY_Invoice_Line_Item__c> iliPageList = new List<UNITY_Invoice_Line_Item__c>();
        wrapperPMList = new List<InvoiceLineItemWrapper>();
         
         for(UNITY_Invoice_Line_Item__c ili : invoiceLineItems){
            if (!invoiceForPM)
                invoiceForPM = ili.UNITYPM_Is_Preventative_Maintenance__c;
            
            if (invoiceForPM)   
                 break;
         }
        Integer counter = 0;
        for(UNITY_Invoice_Line_Item__c ili : invoiceLineItems){
           // if (!invoiceForPM)
            //    invoiceForPM = ili.UNITYPM_Is_Preventative_Maintenance__c;
            
            system.debug('>>>> neli  invoiceForPM >>>>' + invoiceForPM);
            
            if(invoiceForPM){
                 iliPageList.add(ili);  
                 
                 system.debug('>>>> neli  ili >>>>' + ili);
                 
            }
            else {
                if(counter >= 22){
                    invoiceLineItemList.add(iliPageList);
                    iliPageList = new List<UNITY_Invoice_Line_Item__c>();
                    counter = 0;   
                }
                iliPageList.add(ili);
                   if(ili.Product__r.Description.length() > 256 || ili.Product__r.Name.length() > 80){
                        counter = counter + 2;
                   } else if(ili.Product__r.Description.length() > 128 || ili.Product__r.Name.length() > 40){
                        counter = counter + 1;
                }
            }
            counter++;
        }
        
        invoiceLineItemList.add(iliPageList);
        
         system.debug('>>>> neli  invoiceLineItemList.size() >>>>' + invoiceLineItemList.size());
         
        totalPages = 1;
        for(List<UNITY_Invoice_Line_Item__c> iliList : invoiceLineItemList){
            system.debug('####  iliList.size   ###' + iliList.size());
            List<InvoiceLineItemWrapper> wrapperList = new List<InvoiceLineItemWrapper>();
            for(UNITY_Invoice_Line_Item__c ili : iliList){
                wrapperList.add(new InvoiceLineItemWrapper(ili));
            }
            
            //start adding ==============================================
          if ( invoiceForPM) {
             Map<String, List<InvoiceLineItemWrapper>> maptemp = new Map <String, List<InvoiceLineItemWrapper>>();
            
            system.debug('####  wrapperList.size   ###' + wrapperList.size());
            
                 for(InvoiceLineItemWrapper wrapper : wrapperList){
                     String  aId = wrapper.productName;
                      
                     if(maptemp.containsKey(aId)) {
                         List<InvoiceLineItemWrapper> ols = maptemp.get(aId);
                         ols.add(wrapper);
                         maptemp.put(aId, ols);
                     }
                     else{
                         maptemp.put(aId, new List<InvoiceLineItemWrapper> {wrapper});
                     }
                   }
                                
                 for(String key : maptemp.keySet()){
                     String productName ='';
                     String description ='';
                    
                     Integer intquantity =0;
                     Integer inttax=0;
                     Integer intprice =0; 
                     Integer inttotal =0;
                     
                     Decimal dectax=0.00;
                     Decimal decprice =0.00; 
                     Decimal dectotal =0.00;
                      
                     String strquantity ='';
                     String strtax='';
                     String strprice =''; 
                     String strtotal ='';
                      
                     for(InvoiceLineItemWrapper il : maptemp.get(key) ){
                         if ( productName == '') 
                              productName = il.productName;
                          
                         if ( description == '') 
                              description = il.description;
                         
                         if (strquantity == ''){  
                             strquantity = il.quantity;
                             intquantity = Integer.valueof(strquantity);
                         }
                         else{
                             strquantity = il.quantity;
                             intquantity = intquantity + Integer.valueof(strquantity);
                         }
                         /*
                           if (strtax == ''){  
                             strtax = il.tax;
                             inttax = Integer.valueof(strtax);
                         }
                         else{
                             strtax = il.tax;
                             inttax = inttax + Integer.valueof(strtax);
                         }
                         */
                          if (strtax == ''){  
                             strtax = il.tax;
                             dectax = decimal.valueof(strtax);
                         }
                         else{
                             strtax = il.tax;
                             dectax = dectax + decimal.valueof(strtax);
                         }
                         /*
                          if (strprice == ''){  
                             strprice = il.price;
                             intprice = Integer.valueof(strprice);
                         }
                         else{
                             Integer temp =Integer.valueof(il.price);
                             if (temp > intprice)                             
                                  intprice = temp;
                          }
                          */
                           if (strprice == ''){  
                             strprice = il.price;
                             decprice = decimal.valueof(strprice);
                         }
                         else{
                             Decimal temp =Decimal.valueof(il.price);
                             if (temp > decprice)                             
                                  decprice = temp;
                          }
                         /* 
                           if (strtotal == ''){  
                             strtotal = il.total;
                             inttotal = Integer.valueof(strtotal);
                             }
                            else{
                                 strtotal = il.total;
                                 inttotal = inttotal + Integer.valueof(strtotal);
                             }
                             
                           */   
                           if (strtotal == ''){  
                             strtotal = il.total;
                             dectotal = Decimal.valueof(strtotal);
                             }
                            else{
                                 strtotal = il.total;
                                 dectotal = dectotal + Decimal.valueof(strtotal);
                             }
                     }
                         
                    strquantity =  String.valueOf(intquantity);
                    //strtax =  String.valueOf(inttax);
                    strtax =  String.valueOf(dectax);
                    //strprice =  String.valueOf(intprice);
                    strprice =  String.valueOf(decprice);
                    //strtotal =  String.valueOf(inttotal);
                    strtotal =  String.valueOf(dectotal);
                   
                 wrapperPMList.add(new InvoiceLineItemWrapper(productName, description, strquantity, strtax,  strprice, strtotal)) ;
                }
            }    
            
             system.debug('####  wrapperPMList.size   ###' + wrapperPMList.size());
             
            Integer pageSize = 0;
            if ( invoiceForPM == true && wrapperPMList.size() > 0){
                   for(InvoiceLineItemWrapper wrapper : wrapperPMList){
                    pageSize  = pageSize + wrapper.textLines;
                }
                if(pageSize < MAX_LINEITEM_LINES_PER_PAGE){
                    for(Integer i = 0; i < MAX_LINEITEM_LINES_PER_PAGE - pageSize; i++){
                        wrapperPMList.add(new InvoiceLineItemWrapper(null));
                    }
                }
                pageWrappers.add(new InvoicePageWrapper(wrapperPMList, totalPages));
                totalPages++; 
               
          }  //finish adding ========================================================== 
             else
             {
                for(InvoiceLineItemWrapper wrapper : wrapperList){
                    pageSize  = pageSize + wrapper.textLines;
                }
                if(pageSize < MAX_LINEITEM_LINES_PER_PAGE){
                    for(Integer i = 0; i < MAX_LINEITEM_LINES_PER_PAGE - pageSize; i++){
                        wrapperList.add(new InvoiceLineItemWrapper(null));
                    }
                }
                pageWrappers.add(new InvoicePageWrapper(wrapperList, totalPages));
                totalPages++;
            }
           system.debug('####  pageSize   ###' + pageSize); 
           system.debug('####  start totalPages   ###' + totalPages);
        }
         
          system.debug('#### end  totalPages   ###' + totalPages);
          
        totalPages--;
        pageWrappers.get(pageWrappers.size() - 1).lastPage = true;
        
        emailAddress = (invoice.UNITY_Email_Billing_Address__c.replace('&amp;','&')).split('<br>');
        
        billingAddress = new String[2];
        shippingAddress = new String[2];
        shippingAddress[0] = invoice.UNITY_Job_Site__c;//invoice.UNITY_Customer__r.ShippingStreet == null ? ' ' : invoice.UNITY_Customer__r.ShippingStreet;
        shippingAddress[1] = '';//invoice.UNITY_Customer__r.ShippingCity == null ? ' ' : invoice.UNITY_Customer__r.ShippingCity + ', ' + invoice.UNITY_Customer__r.ShippingState == null ? ' ' : invoice.UNITY_Customer__r.ShippingState + ' ' + invoice.UNITY_Customer__r.ShippingPostalCode == null ? ' ' : invoice.UNITY_Customer__r.ShippingPostalCode;
        billingAddress[0] = invoice.UNITY_Bill_To_Address__c;
        billingAddress[1] = '';
        /*
            billingAddress[0] = invoice.UNITY_Customer__r.BillingStreet == null ? ' ' : invoice.UNITY_Customer__r.BillingStreet;
            billingAddress[1] = invoice.UNITY_Customer__r.BillingCity == null ? ' ' : invoice.UNITY_Customer__r.BillingCity + ', ' + invoice.UNITY_Customer__r.BillingState == null ? ' ' : invoice.UNITY_Customer__r.BillingState + ' ' + invoice.UNITY_Customer__r.BillingPostalCode == null ? ' ' : invoice.UNITY_Customer__r.BillingPostalCode;
        */
        
        discountDecimal = invoice.UNITY_Discount_Amount__c == null ? 0: invoice.UNITY_Discount_Amount__c;
        taxDecimal = invoice.UNITY_Total_Tax__c == null ? 0: invoice.UNITY_Total_Tax__c;
        totalDecimal = invoice.UNITY_Total_Price__c == null ? 0: invoice.UNITY_Total_Price__c;
        finalDecimal = invoice.UNITY_Final_Price__c == null ? 0: invoice.UNITY_Final_Price__c;
        
        dateValue = invoice.UNITY_Invoice_Date__c;
        total = String.valueOf(finalDecimal- discountDecimal);
        discount = String.valueOf(discountDecimal);
        tax = String.valueOf(taxDecimal);
        net = String.valueOf(finalDecimal - taxDecimal);
        
        }
    }
    //Izay - Added to support UNITY_CustomerInvoice vfPage
    public UNITY_InvoicePDFController(){
        this.invoiceId = ApexHelper.getParam('id');
    }

    //Izay - Added to support UNITY_CustomerInvoice vfPage
    public UNITY_InvoicePDFController(ApexPages.StandardController controller){
        this.invoiceId = ApexHelper.getParam('id');
    }
    
    private String convertDate(DateTime value, String timeZoneId){
        system.debug('>>> '+value+'/'+timeZoneId);
        String strConvertedDate = value.format('MM/dd/yyyy HH:mm:ss', timeZoneId);
        
        String d = strConvertedDate.substring(0,2);
        if(d.length() == 1){
            d = '0' + d;
        }
        String m = strConvertedDate.substring(3,5);
        String y = strConvertedDate.substring(6,10);
        return d + '/' + m + '/' + y;
    }
    
    public class InvoicePageWrapper{
        public List<InvoiceLineItemWrapper> invoiceLineItemWrappers {get;set;}
        public Integer pageNumber {get;set;}
        public Boolean lastPage {get;set;}
        
        InvoicePageWrapper(List<InvoiceLineItemWrapper> wrappers, Integer pageNumber){
            this.invoiceLineItemWrappers = wrappers;
            this.pageNumber = pageNumber;
        }
    }
    
  
    public class InvoiceLineItemWrapper{
        public String productName{get;set;}
        public String description {get;set;}
        public String quantity {get;set;}
        public String tax {get;set;}
        public String price {get;set;}
        public String total {get;set;}
        public Decimal taxDecimal {get;set;}
        public Integer textLines {get;set;}
        
        public InvoiceLineItemWrapper (String productName, String description,  String quantity,  String tax,   String price,  String total){
            this.productName = productName;
            this.description = description;
            this.quantity = quantity;
            this.tax = tax;
            this.price = price;
            this.total = total;
            
            if(description.length() > 256){
                description = description.substring(0, 256) + ' ...';
            }
            textLines = 1;
            if(description.length() > 256 || productName.length() > 80){
                textLines = 3;
            } else if(description.length() > 128 || productName.length() > 40){
                textLines = 2;
            }
        }
        
     
        public InvoiceLineItemWrapper(UNITY_Invoice_Line_Item__c ili){
            if(ili != null){
                productName = String.valueOf(ili.Product__r.Name);
                description = String.valueOf(ili.Product__r.Description);
                if(String.isNotBlank(ili.UNITY_Description__c))
                    description += ili.UNITY_Description__c;
                    
                quantity = ili.UNITY_Adjusted_Quantity__c == null ? '0.00': String.valueOf(ili.UNITY_Adjusted_Quantity__c);
                price = ili.UNITY_Unit_Price__c == null ? '0.00': String.valueOf(ili.UNITY_Unit_Price__c);
                total= ili.UNITY_Total_Price__c == null ? '0.00': String.valueOf(ili.UNITY_Total_Price__c);
                tax = ili.UNITY_Sales_Tax__c == null ? '0.00':  String.valueOf(ili.UNITY_Sales_Tax__c);
            } else {
                productName = '';
                description = '';
                quantity = '';
                price = '';
                total= '';
                tax = '';
            }
            if(description.length() > 256){
                description = description.substring(0, 256) + ' ...';
            }
            textLines = 1;
            if(description.length() > 256 || productName.length() > 80){
                textLines = 3;
            } else if(description.length() > 128 || productName.length() > 40){
                textLines = 2;
            }
        }
    }
}