/*------------------------------------------------------------
Name:           UNITYPM_NewOrderItemController 
Author:         Izay/Mary
Company:        Miner
Description:    This is the class controller for the Preventative Maintenance Add Product page
=====================================================
*/
public without sharing class UNITYPM_NewOrderItemController {
    
    public List<OLineWrapper> oLines {get; set;}
    public List<OrderItem> orderItemLines{get; set;}
    public Order o {get; private set;}              //The order lines are being added to
    public Boolean finalize {get; set;}             //Denotes if to finalize the order on the next save
    public Boolean saveComplete {get; private set;} //Denotes that the save button was used and should go back to detail page
    public Boolean canEdit {get; private set;}      //Denotes that the PO can be editted
    public Boolean hasError {get; private set;}     //Denotes that the page has errors
    public String saveResult {get; private set;}    //Holds save results to return to page
    public String message {get; private set;}       //Holds any messages to return to the page
    private String bu = '';                         //The BU name on the PO. Ex. 'NSBS','MNS','MSP Nashville',...
    private String oType = '';                      //The order type. 'Service','Project','PM'
    private String vendId = '';                       //The vendor id. Used to query the BU Account on intercompany transfer
    public UNITY_Service_Contract__c customerSC {get; private set;}
    public UNITY_Service_Contract__c vendorSC {get; private set;}
    public String assetType = '';
    public Decimal unitCostReplacement {get;set;}
    public Decimal unitPriceReplacement {get;set;}


    public UNITYPM_NewOrderItemController(ApexPages.StandardController controller){
        //Assign variables
        setOrder();
        this.bu = this.o.UNITY_Business_Unit__c;
        this.vendId = this.o.UNITY_Vendor__c;
        this.oType = this.o.UNITY_Work_Order_Type__c;
        this.finalize = false;
        this.saveComplete = false;
        this.canEdit = true;
        this.hasError = false;
        this.saveResult = '';
        this.message = '';

        //Determine if can edit PO
        if(this.o.Status == 'Final' || this.o.Status == 'Cancelled'){
            this.hasError = true;
            this.message = 'This PO cannot be modified.';
            this.canEdit = false;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
        }

        //Create the line wrapper for existing POLIs
        setPOLines();
    }

    public List<SelectOption> getAssetTypes() {
        List<Schema.PicklistEntry> assetTypesPL = Asset.getSObjectType().getDescribe().fields.getMap().get('UNITY_Asset_Type__c').getDescribe().getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry at : assetTypesPL){
            options.add(new SelectOption(at.getLabel(),at.getValue()));    
        }
        system.debug('@@@getAssetTypes options'+options);
        return options;

    }

    public String getAssetType() {
        return assetType;
    }

    public void setAssetType(String at) {
        this.assetType = at;
    }

    private void setOrder(){
        this.o = [SELECT Id,OrderNumber,AccountId,Status,UNITY_Total_Cost__c,UNITY_Business_Unit__c,
        			UNITY_Final_Price__c,UNITY_NTE__c,UNITY_Work_Order_Type__c,
                  	FSO__WorkOrder__c,FSO__WorkOrder__r.RecordTypeId,
                  	UNITY_Vendor__c, FSO__WorkOrder__r.UNITY_Vendor_Contract__c, FSO__WorkOrder__r.UNITY_Customer_Service_Contract__c, 
                  	UNITY_Estimated_Tax__c, RecordTypeId, UNITYPM_Is_WO_Preventative_Maintenance__c 
                  FROM Order WHERE Id = :ApexHelper.getParam('id') LIMIT 1];
        Map<Id,UNITY_Service_Contract__c> serviceContractMap = new Map<Id,UNITY_Service_Contract__c>([SELECT Id,UNITY_Default_Labor_Rate__c, (SELECT Id, Asset_Type__c, UNITY_Product__r.Id, RecordTypeId, UNITY_Labor_Cost__c  
                                                                    FROM UNITY_Service_Contract_Line_Items__r 
                                                                    WHERE RecordTypeId = :UNITY_Constants.SCLI_ASSET_TYPE_RATE_RECORDTYPE OR RecordTypeId = :UNITY_Constants.SCLI_PM_PRODUCT_RECORDTYPE)
                                                               FROM UNITY_Service_Contract__c WHERE (Id = :this.o.FSO__WorkOrder__r.UNITY_Vendor_Contract__c OR Id = :this.o.FSO__WorkOrder__r.UNITY_Customer_Service_Contract__c)
                                                               AND RecordTypeId = :UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE
                                                               AND UNITY_IS_Active__c = true]);
        if (serviceContractMap.size()> 0){
        	
        	this.vendorSC = serviceContractMap.get(this.o.FSO__WorkOrder__r.UNITY_Vendor_Contract__c);
        	this.customerSC = serviceContractMap.get(this.o.FSO__WorkOrder__r.UNITY_Customer_Service_Contract__c);
        }
    }
    private void setPOLines(){
        //Create the line wrapper for existing POLIs
        this.oLines = new List<OLineWrapper>();
        this.orderItemLines = [SELECT Id,OrderId,OrderItemNumber,Quantity,UNITY_Activity_Type__c,UNITY_Cost__c,
        							UNITY_Product_Code__c, UNITY_Is_Vendor_Supply__c,UNITY_Type__c,
        							PricebookEntryId,UnitPrice,UNITY_Total_Cost__c,UNITY_Asset__c, UNITY_Asset__r.Name,
        							UNITY_Vendor_Holiday_Multiplier__c,UNITY_Vendor_OT_Multiplier__c,
                                    UNITY_Price__c,UNITY_Total_Price__c,UNITY_Price_Calculation_Details__c,
                                    UNITY_Vendor_Adjusted_Quantity__c,UNITY_Customer_Adjusted_Quantity__c,
                                    UNITY_Cost_Calculation_Details__c,UNITY_Customer_Holiday_Multiplier__c,
                                    UNITY_Customer_OT_Multiplier__c, UNITYPM_Is_Preventative_Maintenance__c,
                                    UNITY_Asset_Type__c, UNITY_Not_Billable__c
                                    FROM OrderItem WHERE OrderId = :o.Id ORDER BY OrderItemNumber ASC];

        Set<Id> priceBookEntryIds = new Set<Id>();
        for (OrderItem oi : this.orderItemLines){
            priceBookEntryIds.add(oi.PricebookEntryId);
        }

        Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>([SELECT Id,Pricebook2Id,Product2Id,Product2.UNITY_Product_Type__c, Product2.ProductCode,Product2.Name FROM PriceBookEntry WHERE Id = :priceBookEntryIds]);
        //this.pbe = [SELECT Id,Pricebook2Id,Product2Id,Product2.UNITY_Product_Type__c, Product2.ProductCode,Product2.Name FROM PriceBookEntry WHERE Id = :this.item.PricebookEntryId LIMIT 1];

        if(!orderItemLines.isEmpty()){
            for(OrderItem line :orderItemLines){
                Integer index = oLines.size();
                OLineWrapper wrapper = new OLineWrapper(line,this.bu,this.oType,index, customerSC, vendorSC, this.orderItemLines, priceBookEntryMap.get(line.PricebookEntryId));
                oLines.add(wrapper);
            }
        }
    }
    
    public void addItem(){
        OrderItem oLine = new OrderItem(
            OrderId = this.o.Id,
            Quantity = 1,
            UnitPrice = 0,
            UNITY_Vendor_Adjusted_Quantity__c = 1,
            UNITY_Customer_Adjusted_Quantity__c = 1,
            UNITYPM_Is_Preventative_Maintenance__c = false,
            UNITY_Is_Vendor_Supply__c = true
        );
        Integer index = oLines.size();
        OLineWrapper wrapper = new OLineWrapper(oLine,this.bu,this.oType,index, customerSC, vendorSC, this.orderItemLines, null);
        this.oLines.add(wrapper);
    }
    
    public void deleteSel(){
        this.hasError = false;
        this.message = '';
        SavePoint sp = Database.setSavepoint();
        List<OrderItem> toDelete = new List<OrderItem>();
        List<OLineWrapper> newLines = new List<OLineWrapper>();
        for(OLineWrapper line :oLines){
            if(line.sel){
                if(line.item != null){
                    if(String.isNotBlank(line.item.Id))
                    	if (line.item.UNITYPM_Is_Preventative_Maintenance__c){
                    		this.message = 'PM Order Lines cannot be deleted';
                        	this.hasError = true;
                    	}                    		
                    	else
                    		toDelete.add(line.item);
                }
            }else{
                newLines.add(line);
            }
        }
        try{
        	if (this.hasError){
        		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            	Database.rollback(sp);	
        	}
        	else{
	            if(!toDelete.isEmpty()){
	                delete toDelete;
	                setOrder();
	            }
	            this.oLines = newLines;
	            Integer i = 0;
	            for(OLineWrapper line :oLines){
	                line.index = i;
	                i++;
	            }        		
        	}
        }catch(Exception e){
            this.hasError = true;
            this.message = e.getMessage();
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            Database.rollback(sp);
        }
    }
    
    public PageReference doQuickSave(){
        PageReference pr;
        this.saveResult = '';
        this.saveComplete = false;
        this.hasError = false;
        this.message = '';
        SavePoint sp = Database.setSavepoint();
        if(!this.canEdit){
            pr = new PageReference('/'+this.o.Id);
            pr.setRedirect(true);
            return pr;
        }
        try{
            validateLines();
            if(!this.hasError){
                Set<Id> itemIds = new Set<Id>();
                List<OrderItem> toInsert = new List<OrderItem>();
                List<OrderItem> toUpdate = new List<OrderItem>();
                for(OLineWrapper line :oLines){
                    line.onPriceChange();
                    line.onCostQtyChange();       
                    if(String.isBlank(line.item.Id)){
                        toInsert.add(line.item);
                    }else{
                        toUpdate.add(line.item);
                        itemIds.add(line.item.Id);
                    }
                }
                if(!toInsert.isEmpty()){
                    insert toInsert;
                    for(OrderItem item :toInsert){
                        itemIds.add(item.Id);
                    }
                }
                if(!toUpdate.isEmpty())
                    update toUpdate;
                setOrder();
                setPOLines();
            }else{
                //this.message = 'Missing required fields.';
            	//Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
                return null;
            }
        }catch(Exception e){
            this.hasError = true;
            this.message = e.getMessage();
            if(e.getTypeName() == 'System.DmlException'){
                this.message = e.getDMLMessage(0);
                if(!ApexPages.hasMessages())
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            }else{
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            }
            Database.rollback(sp);
        }
        return null;
    }
    public PageReference doSave(){
        PageReference pr;
        this.saveResult = '';
        this.saveComplete = false;
        this.hasError = false;
        this.message = '';
        SavePoint sp = Database.setSavepoint();
        if(!this.canEdit){
            pr = new PageReference('/'+this.o.Id);
            pr.setRedirect(true);
            return pr;
        }
        try{
            validateLines();
            if(!this.hasError){
                List<OrderItem> toInsert = new List<OrderItem>();
                List<OrderItem> toUpdate = new List<OrderItem>();
                for(OLineWrapper line :oLines){
                    line.onPriceChange();
                    line.onCostQtyChange();
                    if(String.isBlank(line.item.Id)){
                        line.item.PricebookEntryId = line.pbe.Id;
                        toInsert.add(line.item);
                    }else{
                        toUpdate.add(line.item);
                    }
                }
                if(!toInsert.isEmpty())
                    insert toInsert;
                if(!toUpdate.isEmpty())
                    update toUpdate;
                if(this.finalize){
                    this.o.Status = 'Final';
                    update this.o;
                }
                this.saveComplete = true;
                setOrder();
                setPOLines();
            }else{
                return null;
            }
        }catch(Exception e){
            this.hasError = true;
            this.message = e.getMessage();
            Database.rollback(sp);
            if(e.getTypeName() == 'System.DmlException'){
                this.message = e.getDMLMessage(0);
                if(!ApexPages.hasMessages())
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            }else{
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + message));
            }
        }
        return null;
    }
    
    public void validateLines(){
        if(!this.oLines.isEmpty()){
            List<OLineWrapper> newLines = new List<OLineWrapper>();
            for(OLineWrapper line :oLines){
                if(String.isNotBlank(line.pbe.Product2Id)){
                    if(String.isBlank(line.item.UNITY_Type__c)){
                        line.item.UNITY_Type__c.addError('This field is required');
                        this.hasError = true;
                    }
                    if(String.isBlank(line.item.UNITY_Activity_Type__c)){
                        line.item.UNITY_Activity_Type__c.addError('This field is required');
                        this.hasError = true;
                    }
                    if(line.item.Quantity == null || line.item.Quantity == 0){
                        line.item.Quantity.addError('This field is required');
                        this.hasError = true;
                    }
                    if(line.item.UNITY_Is_Vendor_Supply__c && 
                      (line.item.UNITY_Activity_Type__c.indexOf('Labor') == -1 && line.item.UNITY_Activity_Type__c.indexOf('Travel') == -1) &&
                      (line.item.UNITY_Cost__c == null)){
                          line.item.UNITY_Cost__c.addError('This field is required');
                          this.hasError = true;
                    }
                    if(!this.hasError)
                        newLines.add(line);
                }
            }
            if(!hasError)
                this.oLines = newLines;
        }
    }
    
    public void onProductChange(){
        Integer i = Integer.valueOf(ApexHelper.getParam('index'));
        String value = ApexHelper.getParam('myValue');
        System.debug('#####Izay: i = ' + i);
        System.debug('#####Izay: value = ' + value);
        for(OLineWrapper line :oLines){
            if(line.index == i){
                line.pbe = new PriceBookEntry();
                line.pbe.Product2Id = (value != null && value != '')?value:null;
                line.onProductChange();
                //system.debug('@@@onProductChange line.item.pbe.Product2Id'+line.item.pbe.Product2Id);
                break;
            }
        }
    }

    public void onAssetChange(){
        Integer i = Integer.valueOf(ApexHelper.getParam('index'));
        String value = ApexHelper.getParam('myValue');
    	System.debug('@@@onAssetChange value:'+value);
        for(OLineWrapper line :oLines){
            if(line.index == i && line.item != null && value != null && value != ''){
            	line.item.UNITY_Asset__c = value;
                line.onAssetChange();
                break;
            }
        }
    }
    public class OLineWrapper{
        public OrderItem item {get; set;}
        public List<OrderItem> orderItemLines{get; set;}
        public PriceBookEntry pbe {get; set;}
        public Boolean sel {get; set;}
        public Boolean hasError {get; set;}
        private String bu {get; set;}
        private String oType {get; set;}
        public Integer index {get; set;}
        private UNITY_Service_Contract__c customerSC {get;set;}
        private UNITY_Service_Contract__c vendorSC {get;set;}
		public String assetName {get; set;}
		public String assetType {get; set;}

        public oLineWrapper(OrderItem oLine,String bu,String otype,Integer i, UNITY_Service_Contract__c customerSC, UNITY_Service_Contract__c vendorSC, List<OrderItem> oiLines, PricebookEntry pbe){
            this.item = oLine;
            this.sel = false;
            this.hasError = false;
            this.bu = bu;
            this.oType = otype;
            this.index = i;
            this.customerSC = customerSC;
            this.vendorSC = vendorSC;
            this.orderItemLines = oiLines;
            this.pbe = pbe;

            if(String.isBlank(this.item.PriceBookEntryId)){
                this.pbe = new PriceBookEntry();
            }else{
                if (this.pbe == null){
                    this.pbe = [SELECT Id,Pricebook2Id,Product2Id,Product2.UNITY_Product_Type__c,
                    Product2.ProductCode,Product2.Name FROM PriceBookEntry WHERE Id = :this.item.PricebookEntryId LIMIT 1];
                }
            }

            if(String.isBlank(this.item.UNITY_Asset__c)){
            	this.assetName = '';
            	this.assetType = '';
            }
            else{ 
            	this.assetName = this.item.UNITY_Asset__r.Name;
            	this.assetType = this.item.UNITY_Asset_Type__c;
            }
        }
        /**This method associates pricebook entry ans set default on POLI when product change
        */
        public void onProductChange(){
            if(String.isNotBlank(this.pbe.Product2Id)){
                //Associate the pricebookentry to the POLI from the selected Product
                Id standardPBId = UNITY_Constants.getStandardPriceBookId();
                PriceBookEntry[] temp = [SELECT Id,Pricebook2Id,Product2Id,Product2.UNITY_Product_Type__c,Product2.ProductCode,Product2.Name FROM PriceBookEntry WHERE Product2Id = :this.pbe.Product2Id AND Pricebook2Id = :standardPBId LIMIT 1];
                if(!temp.isEmpty()){
                    this.pbe = temp[0];
                }else{
                    PriceBookEntry tempPBE = new PriceBookEntry(
                        Product2Id = this.pbe.Product2Id,
                        Pricebook2Id = standardPBId,
                        IsActive = true,
                        UnitPrice = 0,
                        UseStandardPrice = false
                    );
                    insert tempPBE;
                    temp = [SELECT Id,Pricebook2Id,Product2Id,Product2.UNITY_Product_Type__c,Product2.ProductCode,Product2.Name FROM PriceBookEntry WHERE Product2Id = :this.pbe.Product2Id LIMIT 1];
                    this.pbe = temp[0];
                }
                this.item.PriceBookEntryId = this.pbe.Id;
                //Clear the line inventory values
                this.item.UNITY_Part_Source__c = null;
                this.item.UNITY_Part_Location__c = null;
                //Default Line Type and Activity Type based on the selected propduct's product type
                UNITY_OrderItemHandlerHelper.setPMFieldValuesBasedOnType(this.item, pbe);
                UNITY_Service_Contract_Line_Item__c customerSCLI = UNITY_OrderUtilities.getSCLIForPriceBookEntry(this.pbe, customerSC);
                UNITY_Service_Contract_Line_Item__c vendorSCLI = UNITY_OrderUtilities.getSCLIForPriceBookEntry(this.pbe, vendorSC);
                UNITY_OrderUtilities.calculatePMPricing(this.item, this.orderItemLines, customerSCLI, vendorSCLI);
                onCostQtyChange();
                onPriceChange();
            }else{
                //Clear line if no product is selected
                this.pbe = new PriceBookEntry();
                this.item.UNITY_Type__c = null;
                this.item.UNITY_Activity_Type__c = null;
                this.item.UNITY_Is_Vendor_Supply__c = false;
                this.item.UNITY_Number_of_Techs__c = null;
            }
        }//End onProductChange()
        /**This method associates pricebook entry ans set default on POLI when product change
        */
        public void onAssetChange(){
            if(String.isNotBlank(this.item.UNITY_Asset__c)){
                Asset selAsset = [SELECT Id, Name, UNITY_Asset_Type__c FROM Asset WHERE Id = :this.item.UNITY_Asset__c limit 1];
                if (selAsset != null){
                	system.debug('@@@selAsset.UNITY_Asset_Type__c'+selAsset.UNITY_Asset_Type__c);
                	this.assetType = selAsset.UNITY_Asset_Type__c;
                	this.assetName = selAsset.Name;
                }
            }else{
                //this.item.UNITYPM_Asset_Type__c = null;
            }
            system.debug('@@@oLineWrapper.onAssetChange this.item.UNITY_Asset__c:'+this.item.UNITY_Asset__c);
        }//End onProductChange()        
        /**This method runs when the line cost is changed.
        */
        public void onCostQtyChange(){
            //Calculate the total cost
            if(this.item.UNITY_Cost__c != null){
            	this.item.UNITY_Total_Cost__c = this.item.UNITY_Cost__c * (this.item.UNITYPM_Is_Preventative_Maintenance__c ? this.item.Quantity : this.item.UNITY_Vendor_Adjusted_Quantity__c);
            }
        }//End onCostQtyChange
        /**This method runs when the line price is changed.
        */
        public void onPriceChange(){
            //Calculate the total price
            if(this.item.UNITY_Price__c != null){
            	this.item.UNITY_Total_Price__c = this.item.UNITY_Price__c * (this.item.UNITYPM_Is_Preventative_Maintenance__c ? this.item.Quantity : this.item.UNITY_Customer_Adjusted_Quantity__c);
            }
        }//End onPriceChange
        /**This method runs when the Is Vendor Supply flag changes. 
        *Updates the default Line Type and Activity Type
        */ 
        /**This method runs when the qty is changed.
        */
        public void onQtyChange(){
        	if (this.item.Quantity != null && this.item.Quantity > 0){
        		if (!this.item.UNITYPM_Is_Preventative_Maintenance__c){
        			this.item.UNITY_Vendor_Adjusted_Quantity__c = this.item.Quantity;
        			this.item.UNITY_Customer_Adjusted_Quantity__c = this.item.Quantity;
        			onPriceChange();
        			onCostQtyChange();
        		}
        	}

            if(this.item.UNITY_Cost__c != null)
            	this.item.UNITY_Total_Cost__c = this.item.UNITY_Cost__c * (this.item.UNITYPM_Is_Preventative_Maintenance__c ? this.item.Quantity : this.item.UNITY_Vendor_Adjusted_Quantity__c);
        }//End onCostQtyChange
        public void onVendorSupplyChange(){
            if(String.isNotBlank(this.pbe.Product2.UNITY_Product_Type__c)){
                if(this.item.UNITY_Is_Vendor_Supply__c
                	&& (this.pbe.Product2.UNITY_Product_Type__c.contains('Part')
                		|| this.pbe.Product2.UNITY_Product_Type__c.contains('Freight')
                		|| this.pbe.Product2.UNITY_Product_Type__c.contains('Labor')
                		|| this.pbe.Product2.UNITY_Product_Type__c.contains('Travel'))){
                    this.item.UNITY_Type__c = 'Vendor Services';
                    this.item.UNITY_Part_Source__c = null;
                }
        	}//ENd onVenbdorSupplyChange

    	}
    }
    
    @RemoteAction
    public static Map<String,String> getStockInfo(String[] args){
        Map<String,String> valsMap = new Map<String,String>();
        if(!args.isEmpty()){
            String locId = args[0];
            String prodId = args[1];
            List<FSO__LocationStock__c> lockStock = new List<FSO__LocationStock__c>();
            lockStock = [SELECT Id,Name,FSO__Quantity__c,FSO__Location__c,FSO__Product__c,LastModifiedDate,UNITY_Min__c FROM FSO__LocationStock__c WHERE FSO__Location__c = :locId AND FSO__Product__c = :prodId LIMIT 1];
            if(lockStock.size() > 0){
                valsMap.put('qty',String.valueOf(lockStock[0].FSO__Quantity__c));
                valsMap.put('lastDate',String.valueOf(lockStock[0].LastModifiedDate));
                valsMap.put('instock',String.valueOf((lockStock[0].FSO__Quantity__c > 0)));
            }else{
                valsMap.put('err','The part was not found in the selected inventory location');
            }
        }
        return valsMap;
    }
    
}