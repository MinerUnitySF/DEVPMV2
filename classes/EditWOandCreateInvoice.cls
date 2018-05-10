/**This class serves as controller for the EditWOandCreateInvoice vfPage
** @programer: Izay Ramos-Irizarry
** @version: 2.0
** @date: 4/23/2015
*/
public class EditWOandCreateInvoice {
    public SVMXC__Service_Order__c workOrder {get; private set;}                    //The work order
    public Decimal orderTotal {get; private set;}                                   //The work order total
    public Decimal taxTotal {get; private set;}                                     //The tax total
    public Decimal revenue {get; private set;}                                      //The revenue
    public Decimal marginCurr {get; private set;}                                   //The margin in currency
    public Decimal marginPercent {get; private set;}                                //The margin in percent
    public Decimal invRevenue {get; private set;}                                   //The invoiced revenue
    public Decimal invTaxTotal {get; private set;}                                  //The invoiced tax total
    public Decimal invTotal {get; private set;}                                     //The invoiced order total
    public Decimal invMarginCurr {get; private set;}                                //The invoiced margin in currency
    public Decimal invMarginPercent {get; private set;}                             //The invoiced margin in percent
    public List<WorkOrderLineWrapper> workOrderLines {get; set;}                    //The work order lines
    public Boolean hasError {get; private set;}                                     //Denotes if the page has error
    public Boolean denyAccess {get; set;}                                           //Denotes if the user should be redirected to the work order page
    public String message{ get; private set;}                                       //The message to display on the page
    public Boolean isAdmin {get; private set;}                                      //Denotes if layout is Admin Layout
    public Boolean isService {get; private set;}                                    //Denotes if layout is Service Layout
    public Boolean isEquip {get; private set;}                                      //Denotes if layout is Equipment Layout
    public Boolean isQuote {get; private set;}                                      //Denotes if the wo is a quoted wo
    public Boolean isQuoted {get; private set;}                                     //Denotes if the wo is a quoted wo without requiring anything
    public Boolean isWarranty {get; set;}                                           //Denotes if the Work Order is a warranty WO
    public Boolean editQuote {get; private set;}                                    //Denotes that the quote fieldscan be editted
    public SVMXC__Service_Order_Line__c tempLine {get; private set;}                //Line to show work order link on page
    public Boolean previewButtonVisible {get; private set;}                         //Denotes if preview Invoice is visible
    public String workPerformed  {get; private set;}                                //Work performed job notes
	public String friendlyMsgEQUIP {get; set;}										//Set error message
 	public Boolean isOpen {get; private set;}										//Identify if lines are still open on the WO
    
    /**Class constructor
    **@param controller - ApexPages.StandardController(new SVMXC__Service_Order__c()): The standard controller for the work order
    */
    public EditWOandCreateInvoice(ApexPages.StandardController controller) {
        /* ***********************************
        *** Instantiate all page variables ***
        *********************************** */
        this.hasError = false;
        this.denyAccess = false;
        this.message = '';
        this.isAdmin = false;
        this.isService = false;
        this.isEquip = false;
        this.isQuote = false;
        this.isQuoted = false;
        this.isWarranty = false;
        this.editQuote = false;
        this.revenue = 0;
        this.taxTotal = 0;
        this.orderTotal = 0;
        this.marginCurr = 0;
        this.marginPercent = 0;
        this.invRevenue = 0;
        this.invTaxTotal = 0;
        this.invTotal = 0;
        this.invMarginCurr = 0;
        this.invMarginPercent = 0;
        this.workOrder = new SVMXC__Service_Order__c();
        this.workOrderLines = new List<WorkOrderLineWrapper>();
        this.tempLine = new SVMXC__Service_Order_Line__c();
        this.previewButtonVisible = false;
        this.workPerformed = '';
        this.friendlyMsgEQUIP = '';
        this.isOpen = false;
        
        /* *****************************************
        *** End Instantiating all page variables ***
        ***************************************** */
        String profName = [SELECT Id,Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;    //Get the current user profile name
        /*
        Map<String, ProfileToLayout__c> layoutMap = ProfileToLayout__c.getAll();                             //Get the layout/access data from custom setting
        if(layoutMap.containsKey(profName)){                                                                 //If the user profile has access to the page...
            if(layoutMap.get(profName).Layout__c == 'Admin Layout')                                          //If the layout is 'Admin Layout'
                this.isAdmin = true;                                                                         //Set isAdmin to true
        }else{                                                                                               //Otherwise, the user doesn't have access to the page...
            this.hasError = true;                                                                            //Set hasError to true
            this.denyAccess = true;                                                                          //Set denyAccess to true
            this.message = 'You do not have access to manage this work order. Please contact your system administrator to request access.'; //Set page message
        }
        */
        //Fetch the work order record
        this.workOrder = [SELECT Id,Name,Work_Order_Total__c,Sales_Tax_Total__c,NTEThreshold__c,Contract_Total_c__c,Contract_Amount__c,Super_Center__c,
                          SVMXC__Group_Member__r.SVMXC__Inventory_Location__c,Labor_Standard_DDM__c,SVMXC__Group_Member__r.SVMXC__Fixed_Cost__c,Location__c,
                          SVMXC__Company__c,SVMXC__Group_Member__r.SVMXC__Service_Group__r.Super_Center__c,SVMXC__Group_Member__r.SVMXC__Service_Group__r.Segment__c,
                          SVMXC__Contact__c,SVMXC__Problem_Description__c,SVMXC__Order_Type__c,Work_Order_Type__c,SVMXC__Order_Status__c, Non_Billable_Line_Items__c,
                          Non_Billable_Item_Approval_Status__c,Not_Billable_from_iPad__c,Edit_Quoted_Values__c,Quoted_Total__c, Service_Notes__c, Customer_P_O__c, Invoice_Total__c, Invoiced_WD_FALSE__c
                          FROM SVMXC__Service_Order__c WHERE Id = :controller.getId() LIMIT 1];
        tempLine.SVMXC__Service_Order__c = this.workOrder.Id;


        List<Work_Performed__c> workPerformedNotes = [SELECT History_Notes__c, Note_Type__c  FROM Work_Performed__c
                                                WHERE Note_Type__c = 'Work Performed'
                                                AND Work_Order_c__c = :this.workOrder.Id];

        for(Work_Performed__c note : workPerformedNotes){
            this.workPerformed += note.History_Notes__c + '\r\n';
        }
        //Set the isEquip and isService flags
        if(this.workOrder.SVMXC__Order_Type__c == 'Sales-EQUIP'){
            this.isEquip = true;
        }else{
            this.isService = true;
        }
        if(this.workOrder.Work_Order_Type__c == 'Quoted'){
            this.isQuoted = true; //Removed requirements for 'Quoted' work orders -- Josh Phillips 10-23-2017
        }else if(this.workOrder.Work_Order_Type__c == 'Warranty'){
            this.isWarranty = true;
        }
        system.debug('JOSH - OPEN'+ this.workOrder.Invoiced_WD_FALSE__c);
        if(this.workOrder.Invoiced_WD_FALSE__c != 0){
            this.isOpen = true;
        }else{
            this.isOpen = false;
        }
        /*if(this.workOrder.Edit_Quoted_Values__c){
            this.editQuote = true;
        }*/ //Removed requirements for 'Quoted' work orders -- Josh Phillips 10-23-2017
        if(profName == 'System Administrator'){
            this.isAdmin = true;
        }
        if(this.workOrder.SVMXC__Order_Status__c != 'Invoice Completed' &&
            (profName == 'MH Service Coordinator' || profName == 'Miner Equipment' || profName == 'Miner Hybrid User' || profName == 'System Administrator')){
            this.previewButtonVisible = true;
        }
        setWorkOrderLines();                                                                       //Call the setWorkOrderLines() method to set the work order lines
        calculateTotals();                                                                         //Call the calculateTotals() method
        populateInventory();                                                                       //Call the populateInventory() method
    }//End page constructor
    /**setWorkOrderLines method. This method fetched work detail lines for the work order and sets them as WorOrderLineWrapper */
    public void setWorkOrderLines(){
        this.workOrderLines = new List<WorkOrderLineWrapper>();                                        //Instantiate the workOrderLines
        //Fetch the work detail lines record type id
        String lineRecType = [SELECT Id FROM RecordType  WHERE SobjectType = 'SVMXC__Service_Order_Line__c' AND DeveloperName = 'UsageConsumption'].id;
        //Fetch the work detail lines
        List<SVMXC__Service_Order_Line__c> myLines = [SELECT SVMXC__Line_Type__c,SVMXC__Product__c, SVMXC__Product__r.ProductCode,SVMXC__Line_Status__c,SVMXC__Consumed_From_Location__c,Vendor_Cost_Per_Unit__c,
                                                      SVMXC__Actual_Price2__c,Deliver_Date__c,SVMXC__Use_Price_From_Pricebook__c,SVMXC__Is_Billable__c,Sales_Tax__c, SVMXC__Product__r.Name,Invoiced__c,
                                                      SVMXC__Activity_Type__c,Vendor__c,Vendor_Status__c,SVMXC__Actual_Quantity2__c,Hide_Line__c,Invoice_Detail__c, Sort_Order__c,WD_Created_Date__c,CreatedDate,
                                                      SVMXC__Work_Description__c,SVMXC__Service_Order__c, Total_Line_Price_w_Tax__c,SVMXC__Service_Order__r.Labor_Standard_DDM__c,Total_Line_PriceMH__c,
                                                      Quoted_Quantity__c,Quoted_Unit_Cost__c,Quoted_Unit_Price__c,Total_Quoted_Price__c,Total_Cost__c,Line_from_iPad__c,Quoted__c,Parts_Order_Line__c,Invoice_Qty__c,Invoice_Unit_Price__c,Unit_of_Measure__c
                                                      FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c = :this.workOrder.Id AND RecordTypeId = :lineRecType ORDER BY Sort_Order__c ASC NULLS LAST];
        if(myLines.size() > 0){                                                                        //If the work order has work detail lines...
            Integer index = 0;                                                                         //Integer index to set the sort order for lines without a sort order
            for(SVMXC__Service_Order_Line__c line :myLines){                                           //For each detail line...
                Date d = line.CreatedDate.date();
                line.WD_Created_Date__c = d;
                index++;                                                                               //Add 1 to index
                WorkOrderLineWrapper lineW = new WorkOrderLineWrapper(line, this.workOrder);           //Create new WorkOrderLineWrapper for the line
                if(lineW.line.Sort_Order__c == null)                                                   //If the line doesn't have a sort order...
                    lineW.line.Sort_Order__c = index;                                                  //Add the index as the sort order
                workOrderLines.add(lineW);                                                             //Add the line wrapper to the workOrderLines list
            }
        }else{                                                                                         //Otherwise, If no work detail lines are found...
            this.hasError = true;                                                                      //Set hasError to true
            this.message = '0 Work Detail Lines found.';                                               //Set page message
        }
    }//End setWOrkOrderLines method
    /**populateInventory method. This methodchecks for the selected product inventory availability on part lines */
    public void populateInventory() {
        Set<Id> prodIds = new Set<Id>();                                                                                    //Set to hole product ids
        for(WorkOrderLineWrapper lineWrap :this.WorkOrderLines) {                                                           //For each work detail line...
            if (lineWrap.line.SVMXC__Line_Type__c == 'Parts' && String.isNotBlank(lineWrap.line.SVMXC__Product__c)){        //If the line type is 'Parts' && has a part...
                prodIds.add(lineWrap.line.SVMXC__Product__c);                                                               //Add the product id to the prodIds set
            }
        }
        //Fetch the inventory for the product ids in the prodIds set
        List<SVMXC__Product_Stock__c> invs = [SELECT SVMXC__Location__c, SVMXC__Product__c, SVMXC__Available_Qty__c FROM SVMXC__Product_Stock__c WHERE SVMXC__Product__c IN :prodIds AND SVMXC__Status__c = 'Available'];
        for(WorkOrderLineWrapper lineWrap :this.WorkOrderLines) {                                                           //For each work detail line...
            lineWrap.inv1 = 0;                                                                                              //Set the inv1 to 0 (total in my inventory location)
            lineWrap.inv2 = 0;                                                                                              //Set the inv2 to 0 (total in all locations)
            for(SVMXC__Product_Stock__c inv : invs) {                                                                       //For each inventory product
                //If this is the product on the line and has available qty...
                if(inv.SVMXC__Product__c == lineWrap.line.SVMXC__Product__c && inv.SVMXC__Available_Qty__c != null) {
                    //If the inventory location is the same as the inventory location for the tech assigned to the work order
                    if (inv.SVMXC__Location__c == this.workOrder.SVMXC__Group_Member__r.SVMXC__Inventory_Location__c) {
                        lineWrap.inv1 += (integer)inv.SVMXC__Available_Qty__c;                                               //Add the available qty to the line inv1
                    }
                    lineWrap.inv2 += (integer)inv.SVMXC__Available_Qty__c;                                                   //Add the available qty to the line inv2
                }
            }
        }
    }//End populateInventory method
    /**calculateTotals method. This method iterates through all work detail lines to calculate the work order totals */
    public void calculateTotals(){
        //Reset variables
        this.revenue = 0;
        this.invRevenue = 0;
        this.taxTotal = 0;
        this.invTaxTotal = 0;
        this.orderTotal = 0;
        this.marginCurr = 0;
        this.marginPercent = 0;
        this.invMarginCurr = 0;
        this.invMarginPercent = 0;
        Decimal totalp = 0, totalc = 0;
        Decimal invTotalp = 0, invTotalc =0;
        for(WorkOrderLineWrapper lineWrap :this.WorkOrderLines){                                                                //For each work detail line...
            if(lineWrap.line.SVMXC__Line_Status__c != 'Canceled'){
                if(this.workOrder.Work_Order_Type__c != 'Warranty'){
                    if((lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){         //If the line has a price and qty...
                        this.revenue += lineWrap.line.SVMXC__Actual_Price2__c * lineWrap.line.SVMXC__Actual_Quantity2__c;               //Add the price * qty to the revenue
                    }
                    if(lineWrap.line.Sales_Tax__c != null){                                                                             //if the line has sales tax...
                        this.taxTotal += lineWrap.line.Sales_Tax__c;                                                                    //Add the sales tax to the taxTotal
                        this.invTaxTotal += lineWrap.line.Sales_Tax__c;
                    }
                    //If the line has price, unit cost, and qty...
                    if((lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.Vendor_Cost_Per_Unit__c != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){
                        //Add (price - cost) * qty to marginCurr
                        this.marginCurr += (lineWrap.line.SVMXC__Actual_Price2__c - lineWrap.line.Vendor_Cost_Per_Unit__c) * lineWrap.line.SVMXC__Actual_Quantity2__c;
                        totalp += lineWrap.line.SVMXC__Actual_Price2__c * lineWrap.line.SVMXC__Actual_Quantity2__c;                     //Add price * qty to totalp
                        totalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;                     //Add cost * qty to totalc
                    }
                    if((lineWrap.line.Invoice_Unit_Price__c != null) && (lineWrap.line.Invoice_Qty__c != null) && (lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.Vendor_Cost_Per_Unit__c != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){
                        this.invRevenue += (lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c);
                        this.invMarginCurr += (lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c) - (lineWrap.line.SVMXC__Actual_Quantity2__c * lineWrap.line.Vendor_Cost_Per_Unit__c);
                        invTotalp += lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c;
                        invTotalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;
                    }
                    /*if(lineWrap.canInvoice){
                        invTotalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;
                    }*/
                    if(lineWrap.line.Invoice_Unit_Price__c == lineWrap.line.Vendor_Cost_Per_Unit__c)
                    	lineWrap.friendlyMsg = 'Invoice Unit Price matches Unit Cost. Please Review.'; 
                    else 
                    	lineWrap.friendlyMsg = '';
                    
                    
                }else{
                   if((lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){         //If the line has a price and qty...
                        this.revenue += 0;               //Add the price * qty to the revenue
                    }
                    if(lineWrap.line.Sales_Tax__c != null){                                                                             //if the line has sales tax...
                        this.taxTotal += lineWrap.line.Sales_Tax__c;                                                                    //Add the sales tax to the taxTotal
                        this.invTaxTotal += lineWrap.line.Sales_Tax__c;
                    }
                    //If the line has price, unit cost, and qty...
                    if((lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.Vendor_Cost_Per_Unit__c != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){
                        //Add (price - cost) * qty to marginCurr
                        this.marginCurr += (0 - lineWrap.line.Vendor_Cost_Per_Unit__c) * lineWrap.line.SVMXC__Actual_Quantity2__c;
                        totalp += 0 * lineWrap.line.SVMXC__Actual_Quantity2__c;                     //Add price * qty to totalp
                        totalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;                     //Add cost * qty to totalc
                    }
                    if((lineWrap.line.Invoice_Unit_Price__c != null) && (lineWrap.line.Invoice_Qty__c != null) && (lineWrap.line.SVMXC__Actual_Price2__c  != null) && (lineWrap.line.Vendor_Cost_Per_Unit__c != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){
                        this.invRevenue += (lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c);
                        this.invMarginCurr += (lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c) - (lineWrap.line.SVMXC__Actual_Quantity2__c * lineWrap.line.Vendor_Cost_Per_Unit__c);
                        invTotalp += lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c;
                        invTotalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;
                    } 
                }
                /*else{
                    if((lineWrap.line.Quoted_Unit_Price__c  != null) && (lineWrap.line.Quoted_Quantity__c != null)){                         //If the line has a price and qty...
                        this.revenue += lineWrap.line.Quoted_Unit_Price__c * lineWrap.line.Quoted_Quantity__c;                               //Add the price * qty to the revenue
                    }
                    if(lineWrap.line.Sales_Tax__c != null){                                                                             //if the line has sales tax...
                        this.taxTotal += lineWrap.line.Sales_Tax__c;                                                                    //Add the sales tax to the taxTotal
                        this.invTaxTotal += lineWrap.line.Sales_Tax__c;
                    }
                    //If the line has price, unit cost, and qty...
                    if((lineWrap.line.Quoted_Unit_Price__c  != null) && (lineWrap.line.Vendor_Cost_Per_Unit__c != null) && (lineWrap.line.Quoted_Quantity__c != null) && (lineWrap.line.SVMXC__Actual_Quantity2__c != null)){
                        //Add (price - cost) * qty to marginCurr
                        this.marginCurr += ((lineWrap.line.Quoted_Unit_Price__c * lineWrap.line.Quoted_Quantity__c) - (lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c));
                        totalp += lineWrap.line.Quoted_Unit_Price__c * lineWrap.line.Quoted_Quantity__c;                                     //Add price * qty to totalp
                        totalc += lineWrap.line.Vendor_Cost_Per_Unit__c * lineWrap.line.SVMXC__Actual_Quantity2__c;                     //Add cost * qty to totalc
                    }
                    if((lineWrap.line.Invoice_Unit_Price__c != null) && (lineWrap.line.Invoice_Qty__c != null)){
                        this.invRevenue += lineWrap.line.Invoice_Unit_Price__c * lineWrap.line.Invoice_Qty__c;
                    }
                }*/ //Removed requirements for 'Quoted' work orders -- Josh Phillips 10-23-2017

            }

        }
        if(totalp > 0){                                                                                                         //if totalp is greater than 0...
            this.marginPercent = ((totalp - totalc) / totalp) * 100;                                                            //Set marginPercent to ((totalp - totalc)/totalp) * 100
        }
        if(invTotalp > 0){
            this.invMarginPercent = ((invTotalp - invTotalc) / invTotalp) * 100;
        }
        
        
        this.revenue = this.revenue.setScale(2, System.RoundingMode.HALF_DOWN);                                                 //Perform rounding on revenue
        this.marginCurr = this.marginCurr.setScale(3, System.RoundingMode.HALF_DOWN);                                           //Perform rounding on marginCurr
        this.marginPercent = this.marginPercent.setScale(0, System.RoundingMode.HALF_UP);                                       //Perform rounding on marginPercent
        this.orderTotal = revenue + taxTotal;                                                                                   //Set orderTotal to (revenue + taxTotal)
        this.orderTotal = this.orderTotal.setScale(2,System.RoundingMode.Half_Down);
        this.invRevenue = this.invRevenue.setScale(2, System.RoundingMode.HALF_DOWN);                                           //Perform rounding on invoiced revenue
        this.invTotal = invRevenue + invTaxTotal;                                                                               //Set invTotal to (invRevenue + invTaxTotal)
        this.invMarginCurr = this.invMarginCurr.setScale(3, System.RoundingMode.HALF_DOWN);
        this.invMarginPercent = this.invMarginPercent.setScale(0, System.RoundingMode.HALF_UP);
        if(this.isEquip && this.orderTotal != this.workOrder.Contract_Total_c__c)
                    	this.friendlyMsgEQUIP = 'Work Order Total does not match Contract Total for this job. Please adjust Estimated Unit Price or quantities.'; 
                    else 
                        this.friendlyMsgEQUIP = '';
    }//End calculateTotals method
    /**add10MoreLines method. This method adds 10 lines ot the workOrderLines list */
    public void add10MoreLines(){
        resetMessage();//Reset page message
        if(this.workOrder.SVMXC__Order_Status__c == 'Invoice Completed'){
            this.hasError = true;
            this.message = 'This work order is invoiced';
        }else{
            //Fetch the work detail lines record type
            String lineRecType = [SELECT Id FROM RecordType  WHERE SobjectType = 'SVMXC__Service_Order_Line__c' AND DeveloperName = 'UsageConsumption'].id;
            Integer max = workOrderLines.size();                                                                                    //Integer with number of total lines
            for(Integer i = 0; i < 10; i++){                                                                                        //Iterate 10 times
                SVMXC__Service_Order_Line__c line = new SVMXC__Service_Order_Line__c();                                             //Create new work detail line
                line.RecordTypeId = lineRecType;                                                                                    //Set line record type id
                line.SVMXC__Is_Billable__c = true; 																					//Set as billable
                line.SVMXC__Service_Order__c = this.workOrder.Id;                                                                   //Set the related to work order
                line.SVMXC__Use_Price_From_Pricebook__c = true;  //Set price from pricebook to true
                line.Quoted__c = this.isQuote;
                line.Invoice_Qty__c = 0;
                line.Invoice_Unit_Price__c = 0;
                max ++;                                                                                                             //Add 1 to max
                line.Sort_Order__c = max;                                                                                           //Set max as sort order
                WorkOrderLineWrapper lineWrap = new WorkOrderLineWrapper(line, this.workOrder);                                     //Create new line wrapper
                lineWrap.edit = true;                                                                                               //Set as editable
                workOrderLines.add(lineWrap);                                                                                       //Add line wrapper to workOrderLines
            }
        }
    }//End add10MoreLines

    public void completeLines() {
        resetMessage();
        for(WorkOrderLineWrapper lineWrap :workOrderLines) {
            if (lineWrap.line.SVMXC__Line_Status__c == 'Open'){
                lineWrap.line.SVMXC__Line_Status__c = 'Completed';
                lineWrap.canInvoice = (lineWrap.line.SVMXC__Line_Status__c == 'Completed' && !lineWrap.line.Invoiced__c) ? true : false;
                lineWrap.line.Completed_Date__c = DateTime.Now();
                lineWrap.line.Completed_By__c = UserInfo.getUserId();
            }
        }
        calculateTotals();
        quickSave();
    }

    public void quickSave(){
        resetMessage();
        List<Labor_Rate_Mapping__c> rateMapping = [SELECT Name, Labor_Rate_Type__c FROM Labor_Rate_Mapping__c];
        Map<String, String> rateMappingMap = new Map<String, String>();
        for(Labor_Rate_Mapping__c rate : rateMapping){
            rateMappingMap.put(rate.Name, rate.Labor_Rate_Type__c);
        }

        //if (String.isEmpty(workOrder.Id)) workOrder.SVMXC__Order_Type__c = 'Drop Ship';
        List<SVMXC__RMA_Shipment_Order__c> pos = queryForPartOrdersRelatedToWO();
        Map<Id,SVMXC__RMA_Shipment_Line__c> poLineByWOLine = new Map<Id,SVMXC__RMA_Shipment_Line__c>();
        if(!pos.isEmpty()){
            for(SVMXC__RMA_Shipment_Order__c po :pos){
                for(SVMXC__RMA_Shipment_Line__c poli :po.SVMXC__RMA_Shipment_Line__r){
                    poLineByWOLine.put(poli.Id,poli);
                }
            }
        }

        List<SVMXC__Service_Order_Line__c> toUpsertLines = new List<SVMXC__Service_Order_Line__c>();
        Boolean valid = true;
        for(WorkOrderLineWrapper lineWrap :workOrderLines){
            if((lineWrap.line.SVMXC__Line_Type__c!=null || lineWrap.line.SVMXC__Product__c!=null ||
            lineWrap.line.SVMXC__Activity_Type__c!=null || lineWrap.line.Vendor__c!=null ||
            lineWrap.line.Vendor_Status__c!=null || lineWrap.line.SVMXC__Actual_Quantity2__c!=null ||
            lineWrap.line.SVMXC__Work_Description__c!=null || lineWrap.line.Vendor_Cost_Per_Unit__c!=null ||
            lineWrap.line.SVMXC__Actual_Price2__c!=null || lineWrap.line.Deliver_Date__c!=null)  && lineWrap.line.SVMXC__Line_Status__c != 'Canceled'){
                Boolean isValid = true;
                /*
                if(String.isBlank(lineWrap.line.SVMXC__Line_Type__c)){
                    isValid = false;
                    lineWrap.line.SVMXC__Line_Type__c.addError('Required');
                }else{
                    if((lineWrap.line.SVMXC__Line_Type__c == 'Parts' || lineWrap.line.SVMXC__Line_Type__c == 'Vendor Services')){
                        if(String.isBlank(lineWrap.line.SVMXC__Product__c)){
                            isValid = false;
                            lineWrap.line.SVMXC__Product__c.addError('Required');
                        }
                        if(lineWrap.line.SVMXC__Line_Type__c == 'Vendor Services' && String.isBlank(lineWrap.line.Vendor__c)){
                            //isValid = false;
                            //lineWrap.line.Vendor__c.addError('Required');
                        }
                    }
                    if ( lineWrap.line.SVMXC__Line_Type__c == 'Parts' && String.isBlank(lineWrap.line.SVMXC__Consumed_From_Location__c) && !Test.isRunningTest() ) {
                        isValid = false;
                        lineWrap.line.SVMXC__Consumed_From_Location__c.addError('Required');
                    }
                }
                if(String.isBlank(lineWrap.line.SVMXC__Activity_Type__c)){
                    isValid = false;
                    lineWrap.line.SVMXC__Activity_Type__c.addError('Required');
                }
                */
                if (this.isService && !this.isQuote && lineWrap.canInvoice) {
                    if(lineWrap.line.SVMXC__Actual_Quantity2__c == null || (lineWrap.line.SVMXC__Actual_Quantity2__c == 0)){
                        isValid = false;
                        lineWrap.line.SVMXC__Actual_Quantity2__c.addError('Required and must not be 0');
                    }
                    if(lineWrap.line.Invoice_Unit_Price__c == lineWrap.line.Vendor_Cost_Per_Unit__c){
                        //isValid = false;
                        //lineWrap.line.Invoice_Unit_Price__c.addError('Invoice Unit Price matches Unit Cost. Please Review.');
                    }
                    /*if(lineWrap.line.Vendor_Cost_Per_Unit__c == null || (lineWrap.line.Vendor_Cost_Per_Unit__c == 0)) {
                        isValid = false;
                        lineWrap.line.Vendor_Cost_Per_Unit__c.addError('Required and must not be 0');
                    }
                    if(lineWrap.line.SVMXC__Actual_Price2__c == null || (lineWrap.line.SVMXC__Actual_Price2__c == 0  && lineWrap.line.SVMXC__Is_Billable__c && !this.isWarranty)){
                        isValid = false;
                        lineWrap.line.SVMXC__Actual_Price2__c.addError('Required and must not be 0');
                    }*/
                /*}else if(this.isService && this.isQuote && !lineWrap.line.Line_from_iPad__c && lineWrap.line.Quoted__c && lineWrap.canInvoice){
                    if(lineWrap.line.Quoted_Quantity__c == null || (lineWrap.line.Quoted_Quantity__c == 0)){
                        isValid = false;
                        lineWrap.line.Quoted_Quantity__c.addError('Required and must not be 0');
                    }
                    if(lineWrap.line.Quoted_Unit_Cost__c == null || (lineWrap.line.Quoted_Unit_Cost__c == 0)){
                        isValid = false;
                        lineWrap.line.Quoted_Unit_Cost__c.addError('Required and must not be 0');
                    }
                    if(lineWrap.line.Quoted_Unit_Price__c == null || (lineWrap.line.Quoted_Unit_Price__c == 0  && lineWrap.line.SVMXC__Is_Billable__c)){
                        isValid = false;
                        lineWrap.line.Quoted_Unit_Price__c.addError('Required and must not be 0');
                    }*/ //Removed requirements related to 'Quoted' work orders -- Josh Phillips 10-23-2017
                    /*else if(String.isNotBlank(lineWrap.line.Id)){
                        if(lineWrap.line.SVMXC__Actual_Quantity2__c == null || (lineWrap.line.SVMXC__Actual_Quantity2__c == 0  && lineWrap.line.SVMXC__Is_Billable__c)){
                            isValid = false;
                            lineWrap.line.SVMXC__Actual_Quantity2__c.addError('Required and must not be 0');
                        }
                        if(lineWrap.line.Vendor_Cost_Per_Unit__c == null || (lineWrap.line.Vendor_Cost_Per_Unit__c == 0)){
                            isValid = false;
                            lineWrap.line.Vendor_Cost_Per_Unit__c.addError('Required and must not be 0');
                        }
                    }*/
                }
                System.debug('Izay: this.isService: ' + this.isService);
                System.debug('Izay: lineWrap.line.SVMXC__Line_Type__c: ' + lineWrap.line.SVMXC__Line_Type__c);
                System.debug('Izay: lineWrap.line.SVMXC__Activity_Type__c: ' + lineWrap.line.SVMXC__Activity_Type__c);
                System.debug('Izay: lineWrap.line.SVMXC__Consumed_From_Location__c: ' + lineWrap.line.SVMXC__Consumed_From_Location__c);
                if (this.isService && lineWrap.line.SVMXC__Line_Type__c == 'Parts' && (String.isNotBlank(lineWrap.line.SVMXC__Activity_Type__c) && lineWrap.line.SVMXC__Activity_Type__c.indexOf('Parts') != -1) && String.isBlank(lineWrap.line.SVMXC__Consumed_From_Location__c) ) {
                    isValid = false;
                    lineWrap.line.SVMXC__Consumed_From_Location__c.addError('Required');
                }
                //if(this.isService){
                    if(String.isNotBlank(lineWrap.line.Parts_Order_Line__c)){
                        if(poLineByWOLine.containsKey(lineWrap.line.Parts_Order_Line__c)){
                            if(poLineByWOLine.get(lineWrap.line.Parts_Order_Line__c).SVMXC__Line_Status__c != 'Completed' &&
                               lineWrap.line.SVMXC__Line_Status__c == 'Completed'){
                                    valid = false;
                                    lineWrap.line.SVMXC__Line_Status__c.addError('Open Part Order Line');
                                    this.hasError = true;
                                    this.message = String.isBlank(this.message)?'Line ' + lineWrap.line.Sort_Order__c + ' has Parts Order that need receipt.&nbsp;':this.message+'Line ' + lineWrap.line.Sort_Order__c + ' has Parts Order(s) that need receipt.&nbsp;';
                            }
                        }
                    }
                //}
                if(isValid){
                    lineWrap.line.SVMXC__Use_Price_From_Pricebook__c = false;
                    if(lineWrap.line.SVMXC__Line_Type__c == 'Labor' && rateMappingMap.containsKey(lineWrap.line.SVMXC__Activity_Type__c)) {
                        lineWrap.line.Labor_Type__c = rateMappingMap.get(lineWrap.line.SVMXC__Activity_Type__c);
                    }
                    if(lineWrap.line.SVMXC__Line_Status__c == 'Completed' && lineWrap.originalStatus != 'Completed'){
                        lineWrap.line.Completed_Date__c = DateTime.Now();
                        lineWrap.line.Completed_By__c = UserInfo.getUserId();
                    }
                    if(lineWrap.line.SVMXC__Line_Status__c != 'Completed'){
                        lineWrap.line.Completed_Date__c = null;
                        lineWrap.line.Completed_By__c = null;
                    }
                    toUpsertLines.add(lineWrap.line);
                }else{
                    valid = false;
                }
            }else if(lineWrap.line.SVMXC__Line_Status__c == 'Canceled'){
                lineWrap.line.Completed_Date__c = null;
                lineWrap.line.Completed_By__c = null;
                toUpsertLines.add(lineWrap.line);
            }
        }
        if(valid){
            if(toUpsertLines.size() > 0){
                try{
                    upsert toUpsertLines;
                    //Hold the line id for lines set as invoice
                    Set<Id> toInvoiceLines = new Set<Id>();
                    for(WorkOrderLineWrapper lineWrap :workOrderLines){
                        if(lineWrap.invoice){
                            toInvoiceLines.add(lineWrap.line.Id);
                        }
                    }
                    setWorkOrderLines();
                    for(WorkOrderLineWrapper lineWrap :workOrderLines){
                        if(toInvoiceLines.contains(lineWrap.line.Id)){
                            lineWrap.invoice = true;
                        }
                    }
                }catch(Exception e){
                    this.hasError = true;
                    String messageText = e.getMessage();
                    String validationErrorString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, ';
                    Integer validationStringLength = validationErrorString.length();
                    Integer index = messageText.indexOf( validationErrorString );
                    if ( index >= 0 ) messageText = messageText.substring( index+validationStringLength );
                    this.message = 'An error occurred while updating the work order details. Error: ' + messageText;
                }
            }
        }else{
            this.hasError = true;
            this.message = String.isBlank(this.message)?'Missing required field(s).':this.message;
        }
        this.workOrder.Edit_Quoted_Values__c = false;
        try{
            update this.workOrder;
        }catch(Exception e){
            this.hasError = true;
            this.message = e.getMessage();
        }
        this.editQuote = false;
        calculateTotals();
    }

    public PageReference saveAndClose(){
        quickSave();
        if(!this.hasError){
            PageReference page = new PageReference('/' + this.workOrder.Id);
            page.setRedirect(true);
            return page;
        }
        return null;
    }

    public PageReference callAvatax() {
        resetMessage();
        String retUrl = EncodingUtil.urlEncode('/apex/EditWOandCreateInvoice?id=' + this.workOrder.Id, 'UTF-8');
        PageReference page = new PageReference('/apex/callavatax?id='+ this.workOrder.Id + '&retUrl=' + retUrl);
        page.setRedirect(true);
        return page;
    }

    private Boolean hasOpenLineItems() {
        Boolean openLineItem = false;
        for ( WorkOrderLineWrapper lineWrap :this.WorkOrderLines ) {
             
            if ( lineWrap.line.SVMXC__Line_Status__c != 'Completed' && lineWrap.line.SVMXC__Line_Status__c != 'Canceled' ) {              
                openLineItem = true;
                break;
            }
        }
        return openLineItem;
    }

    private List<SVMXC__RMA_Shipment_Order__c> queryForPartOrdersRelatedToWO() {
        return [SELECT Id, SVMXC__Order_Status__c, (SELECT Id,SVMXC__Line_Status__c,SVMXC__Actual_Quantity2__c,SVMXC__Service_Order_Line__c FROM SVMXC__RMA_Shipment_Line__r)
                FROM SVMXC__RMA_Shipment_Order__c
                WHERE SVMXC__Service_Order__c =: workOrder.Id
                AND SVMXC__Order_Status__c != 'Canceled' AND SVMXC__Order_Status__c != 'Closed'];
    }

    private Boolean hasOpenShipmentOrders() {
        Boolean openShipmentOrder = false;
        for ( SVMXC__RMA_Shipment_Order__c shipmentOrder : queryForPartOrdersRelatedToWO() ) {
             system.debug('>>>>>   shipmentOrder.SVMXC__Order_Status__c  >> ' + shipmentOrder.SVMXC__Order_Status__c);
            if ( shipmentOrder.SVMXC__Order_Status__c != 'Closed' && shipmentOrder.SVMXC__Order_Status__c != 'Canceled') {
                openShipmentOrder = true;
            } else if (shipmentOrder.SVMXC__Order_Status__c != 'Canceled'){
                for ( SVMXC__RMA_Shipment_Line__c partLine : shipmentOrder.SVMXC__RMA_Shipment_Line__r ) {
                    if ( (partLine.SVMXC__Line_Status__c != 'Canceled' && partLine.SVMXC__Line_Status__c != 'Completed')
                        || ( partLine.SVMXC__Line_Status__c == 'Completed' && partLine.SVMXC__Actual_Quantity2__c == null ) )  {
                        openShipmentOrder = true;
                        break;
                    }
                }
            }
            if ( openShipmentOrder ) break;
        }
        return openShipmentOrder;
    }
/*
    public pageReference requestEditQuote(){
        // Create an approval request
        Approval.ProcessSubmitRequest approvalRequest =new Approval.ProcessSubmitRequest();
        approvalRequest.setComments(' Please allow me to re-enter the quoted values for this work order.');
        approvalRequest.setObjectId(workOrder.id);
        // Submit the record to specific process and skip the criteria evaluation
        approvalRequest.setProcessDefinitionNameOrId('Edit_Quoted_Values');
        approvalRequest.setSkipEntryCriteria(true);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(approvalRequest);
        this.hasError = true;
        this.message = ' The work order has been sent for approval to edit the quote values. The work order will be locked until the approval request has been answered';
        return null;
    }

    public pageReference requestUpdateQuotedTotal(){
        // Create an approval request
        Approval.ProcessSubmitRequest approvalRequest =new Approval.ProcessSubmitRequest();
        approvalRequest.setComments(' Need to quoted total increased to the work order total.');
        approvalRequest.setObjectId(workOrder.id);
        // Submit the record to specific process and skip the criteria evaluation
        approvalRequest.setProcessDefinitionNameOrId('Update_Quoted_Total');
        approvalRequest.setSkipEntryCriteria(true);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(approvalRequest);
        this.hasError = true;
        this.message = ' The work order has been sent for approval to update the quoted total. The work order will be locked until the approval request has been answered';
        return null;
    }
*/ //Removed requirements related to 'Quoted' work orders -- Josh Phillips 10-23-2017
    public pageReference updateAndCreateInvoice(){
        Boolean createInvoice = false;
        quickSave();
        //Create a save point
        Savepoint sp = Database.setSavepoint();
        if (this.isService && hasOpenLineItems() ) {
            this.hasError = true;
            this.message = LABEL.ErrorMessage_PartialInvoicingNotPermitted;
        }
        if (this.isService && hasOpenShipmentOrders() ) {
            this.hasError = true;
            this.message = LABEL.ErrorMessage_OpenPartsOrders;
        }
        if(this.isService && this.workOrder.SVMXC__Order_Status__c == 'Invoice Completed'){
            this.hasError = true;
            this.message = 'This work order is invoiced';
        }
        if(String.isEmpty(this.workOrder.Service_Notes__c)){
            this.hasError = true;
            this.message = 'Please enter the service notes.';
        }
      
        if(this.isService && (this.invRevenue > this.workOrder.NTEThreshold__c)){
            this.hasError = true;
            this.message = 'Invoiced Total is greater than the NTE Threshold. Please review your lines or confirm with the customer that the work order can be billed at this amount.';
        }       
        if(this.isEquip && (this.invRevenue > this.workOrder.Contract_Total_c__c)){
            this.hasError = true;
            this.message = 'Invoiced Total is greater than the Contract Total. Please review your lines.';
        }
        if(this.isEquip && this.isOpen && (this.orderTotal != this.workOrder.Contract_Total_c__c) ){
            this.hasError = true;
            this.message = 'Work Order Total does not match the Contract Total for this job.  Please adjust Estimated Unit Price or Quantities';
        }
        if(this.isEquip && this.isOpen && (this.invRevenue > this.workOrder.Contract_Total_c__c)){
            this.hasError = true;
            this.message = 'Invoice Revenue is greater than the Contract Total for this job. Please adjust Invoice Unit Price or Invoice Qty.';
        }
        /*if(this.isEquip && !hasOpenLineItems() && (this.revenue > this.workOrder.Contract_Total_c__c)){
            this.hasError = true;
            this.message = 'Estimated Revenue does not match Contract Total for this job. Please adjust Estimated Unit Price or quantities.';
        }*/
       
        /*if(this.isEquip && ((this.invRevenue + this.workOrder.Invoice_Total__c) < this.workorder.Contract_Total_c__c)){
            this.hasError = true;
            this.message = 'The total being invoiced for this work order will be less than the Contract Amount. Please review your lines and invoiced amounts.';
        }*/
    
        if(this.isQuoted && (this.invRevenue > this.workOrder.Quoted_Total__c)){
            this.hasError = true;
            this.message = 'Invoiced Total is greater than the Quoted Total. Please review your lines.';
        }
        if(this.isQuoted && (this.invRevenue < this.workOrder.Quoted_Total__c)){
            this.hasError = true;
            this.message = 'Invoiced Total is less than the Quoted Total. Please review the Invoice Qty and Invoice Unit Price fields on your lines.';
        }
        /*if(this.isService && (this.revenue > this.invRevenue)){
            this.hasError = true;
            this.message = 'You are attempting to invoice less revenue than exists on the work order. Please adjust invoice qty or price.';
        }*/
        
        calculateTotals();
        
        if(this.revenue == 0 && this.isWarranty){
            List<SVMXC__Service_Order_Line__c> linesToUpdate = new List<SVMXC__Service_Order_Line__c>();
            for (WorkOrderLineWrapper lineWrap :workOrderLines){
                linewrap.line.Invoiced__c = true;
                linesToUpdate.add(linewrap.line);
                continue;
            }
            if(!linesToUpdate.isEmpty()){
                try{
                    update linesToUpdate;
                    this.workOrder.SVMXC__Order_Status__c = 'Invoice Completed';
                    update this.workOrder;
                    PageReference pr = new Pagereference('/'+this.WorkOrder.Id);
                    pr.setRedirect(true);
                    return pr;
                }catch(Exception e){
                    this.hasError = true;
                    this.message = 'An error occurred while updating the detail lines. Error: ' + e.getMessage();
                    Database.rollback(sp);
                    return null;
                }
            }
        }else if(this.invRevenue == 0){
            this.hasError = true;
            this.message = 'This work order has no revenue to invoice and it is not a "Warranty" work order.';
        }
        /*
        if (this.isService && this.workOrder.Non_Billable_Line_Items__c > 0 && (!this.isQuote || this.isQuote && (this.workOrder.Non_Billable_Line_Items__c > this.workOrder.Not_Billable_from_iPad__c)) && this.workOrder.Non_Billable_Item_Approval_Status__c != 'Pending' && this.workOrder.Non_Billable_Item_Approval_Status__c != 'Approved') {
            this.hasError = true;
            // Create an approval request for the account
            Approval.ProcessSubmitRequest approvalRequest =new Approval.ProcessSubmitRequest();
            approvalRequest.setComments( 'This invoice has non-billable line items.' );
            approvalRequest.setObjectId( workOrder.id );
            // Submit the record to specific process and skip the criteria evaluation
            approvalRequest.setProcessDefinitionNameOrId('Non_Billable_Line_Items');
            approvalRequest.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process( approvalRequest );
            // Message to display on the page
            this.message = 'The work order needs approval for Not Billable lines.';
        }else if(this.isService && (this.workOrder.Non_Billable_Item_Approval_Status__c == 'Pending' || this.workOrder.Non_Billable_Item_Approval_Status__c == 'Denied')){
            this.hasError = true;
            this.message = 'The work order needs approval for Not Billable lines.';
        }
        */
       
        if(!this.hasError ){
            //Make sure that the account SL Customer ID
            List<Account> a = [SELECT Id,MH_SL_CustID__c FROM Account WHERE Id = :this.workOrder.SVMXC__Company__c LIMIT 1];
            if(a.size() > 0){
                if(String.isBlank(a[0].MH_SL_CustID__c)){
                    this.hasError = true;
                    this.message = 'This account does not have an SL Customer ID. Please make sure that this is an Active Customer and try again.';
                    return null;
                }
            }

            ApexPages.CurrentPage().getParameters().put('id', this.workOrder.Id);

            (new CallAvatax()).Call();

            for(WorkOrderLineWrapper lineWrap :workOrderLines){
                if(lineWrap.canInvoice && lineWrap.invoice){
                    createInvoice = true;
                    break;
                }
            }

            if(createInvoice){

                //Create the invoice
                MH_Invoice__c invoice = new MH_Invoice__c();
                invoice.Account__c = this.workOrder.SVMXC__Company__c;
                invoice.Work_Order__c = this.workOrder.id;
                invoice.Supercenter__c = this.workOrder.SVMXC__Group_Member__r.SVMXC__Service_Group__r.Super_Center__c;
                invoice.Segment__c = this.workOrder.SVMXC__Group_Member__r.SVMXC__Service_Group__r.Segment__c;
                invoice.Location__c = this.workOrder.Location__c;
                invoice.Contact__c = this.workOrder.SVMXC__Contact__c;
                invoice.Work_Description__c = this.workOrder.SVMXC__Problem_Description__c;
                invoice.Service_Notes_c__c = this.workOrder.Service_Notes__c;
                //invoice.Date_Invoiced__c = Date.today();
                try{
                    //Insert the invoice
                    insert invoice;
                    //Create invoice lines
                    List<MH_Invoice_Details__c> invLines = new List<MH_Invoice_Details__c>();
                    List<SVMXC__Service_Order_Line__c> linesToUpdate = new List<SVMXC__Service_Order_Line__c>();

                    for (WorkOrderLineWrapper lineWrap :workOrderLines){
                        if (!lineWrap.canInvoice || !lineWrap.invoice || lineWrap.line.SVMXC__Line_Status__c == 'Canceled' ||
                            (this.isQuote && lineWrap.line.Line_from_Ipad__c && lineWrap.line.SVMXC__Line_Type__c == 'Labor')){
                                //linewrap.line.Invoiced__c = true;
                                //linesToUpdate.add(linewrap.line);
                                continue;
                            }
                        system.debug('JOSH: ' + this.isQuote);
                        MH_Invoice_Details__c invLine = new MH_Invoice_Details__c();
                        /*if (this.isQuote) {
                            invLine.Line_Qty__c = lineWrap.line.Quoted_Quantity__c;
                            invLine.Line_Price_Per_Unit__c = lineWrap.line.Quoted_Unit_Price__c;
                            invLine.Total_Line_Price__c = lineWrap.line.Total_Quoted_Price__c;
                        }else{
                            invLine.Line_Qty__c = lineWrap.line.Invoice_Qty__c;
                            system.debug('JOSH: ' + invLine.Line_Qty__c);
                            invLine.Line_Price_Per_Unit__c = lineWrap.line.Invoice_Unit_Price__c;
                            system.debug('JOSH: ' + invLine.Line_Price_Per_Unit__c);
                            invLine.Total_Line_Price__c = lineWrap.line.Total_Line_PriceMH__c;
                            system.debug('JOSH: ' + invLine.Total_Line_Price__c);
                        }*/
                        if (this.isWarranty) {
                            invLine.Line_Price_Per_Unit__c = 0;
                        }else{
                            invLine.Line_Price_per_Unit__c = lineWrap.line.Invoice_Unit_Price__c;
                        }
                        if(lineWrap.line.Hide_Line__c == true){
                            invLine.Line_Qty__c = lineWrap.line.SVMXC__Actual_Quantity2__c;
                        }else{
                            invLine.Line_Qty__c = lineWrap.line.Invoice_Qty__c;
                        }
                        //invLine.Line_Price_per_Unit__c = lineWrap.line.Invoice_Unit_Price__c;
                        invLine.Costing_Qty__c = lineWrap.line.SVMXC__Actual_Quantity2__c;
                        invLine.Total_Line_Price__c = lineWrap.line.Total_Line_PriceMH__c;
                        invLine.Detail_Line_Cost__c = lineWrap.line.SVMXC__Actual_Quantity2__c * lineWrap.line.Vendor_Cost_Per_Unit__c;
                        invLine.Work_Detail__c = lineWrap.line.id;
                        invLine.Work_Order__c = lineWrap.line.SVMXC__Service_Order__c;
                        invLine.Line_Type__c = lineWrap.line.SVMXC__Line_Type__c;
                        invLine.Activity_Type__c = lineWrap.line.SVMXC__Activity_Type__c;
                        invLine.Part__c = lineWrap.line.SVMXC__Product__c;
                        invLine.Unit_of_Measure_idc__c = lineWrap.line.Unit_of_Measure__c;
                        invLine.Work_Description_idc__c = lineWrap.line.SVMXC__Work_Description__c;
                        //invLine.Line_Qty__c = lineWrap.line.Invoice_Qty__c;
                        //invLine.Line_Price_Per_Unit__c = lineWrap.line.Invoice_Unit_Price__c;
                        //invLine.Total_Line_Price__c = lineWrap.line.Total_Line_PriceMH__c;
                        invLine.Hide_Line_c__c = (lineWrap.line.Hide_Line__c||!lineWrap.line.SVMXC__Is_Billable__c)?true:false;
                        invLine.Invoice__c = invoice.id;
                        invLine.Sort_Order__c = lineWrap.line.Sort_Order__c;
                        invLine.Date_Invoiced__c = Date.today();
                        //Add the invoice line to the list of invoice lines
                        invLines.add(invLine);
                    }
                    if(invLines.size() > 0){
                        try{
                            //Insert the invoice lines
                            insert invLines;
                            //Redirect to CallAvataxInvoice page
                            PageReference pr = Page.CallAvataxInvoice;
                            pr.getParameters().put('id', invoice.Id);
                            pr.setRedirect(true);
                            return pr;
                        }catch(Exception e){
                            this.hasError = true;
                            this.message = 'An error occurred while creating the invoice lines. Error: ' + e.getMessage();
                            Database.rollback(sp);
                        }
                    }
                    if(!linesToUpdate.isEmpty()){
                        try{
                            update linesToUpdate;
                        }catch(Exception e){
                            this.hasError = true;
                            this.message = 'An error occurred while updating the detail lines. Error: ' + e.getMessage();
                            Database.rollback(sp);
                        }
                    }
                }catch(Exception e){
                    this.hasError = true;
                    this.message = 'An error occurred while creating the invoice. Error: ' + e.getMessage();
                    Database.rollback(sp);
                }
            }
        }
        return null;
    }

    public void resetMessage(){
        this.hasError = false;
        this.denyAccess = false;
        this.message = '';
    }

    /**Wrapper class for work order lines */
    public class WorkOrderLineWrapper {

        public SVMXC__Service_Order_Line__c line {get; set;}
        public String originalStatus {get;set;} //saved status
        public Boolean canInvoice {get; set;} //based on line status
        public Boolean invoice {get; set;} //Based on checkbox. Should default to true since 12/19/2016 release
        public Boolean hide {get; set;} //Based on linw field
        public Boolean edit {get; set;} //If it has been invoiced or not. It is has been invoiced it can't be eddited
        public Boolean isPart {get; set;} //If the line type is Parts or Vendor Services
        public Boolean labFromIpad {get; set;} //If it is a labor line comming from the iPad
        public Integer inv1 {get; set;} //The inventory amount in the assigned inventory location
        public Integer inv2 {get; set;} //The inventory amount in all inventory locations
        public String prodCode {get; set;}
        private SVMXC__Service_Order__c wo;
        public String friendlyMsg {get; set;}
        public WorkOrderLineWrapper(SVMXC__Service_Order_Line__c l, SVMXC__Service_Order__c wo) {
            this.line = l;
            this.originalStatus = l.SVMXC__Line_Status__c;
            this.wo = wo;
            this.canInvoice = (l.SVMXC__Line_Status__c == 'Completed' && !l.Invoiced__c) ? true : false;
            this.edit = (l.Invoiced__c) ? false : true;
            this.isPart = (l.SVMXC__Line_Type__c == 'Parts' || line.SVMXC__Line_Type__c == 'Vendor Services') ? true : false;
            this.labFromIpad = l.Line_from_iPad__c && l.SVMXC__Line_Type__c == 'Labor';
            if((this.labFromIpad && this.line.Quoted__c)||(this.line.SVMXC__Line_Status__c == 'Canceled' && wo.SVMXC__Order_Status__c == 'Invoice Completed')){
                this.edit = false;
            }
            if(this.isPart){
                this.prodCode = l.SVMXC__Product__r.ProductCode;
            }else{
                this.prodCode = '';
            }
            this.invoice = true;
            this.hide = false;
            this.inv1 = 0;
            this.inv2 = 0;
        }

        public Decimal subTotal {
            get {
                if (line.SVMXC__Actual_Quantity2__c == null || line.SVMXC__Actual_Price2__c == null)
                    return 0;
                else if(line.Quoted_Quantity__c != null && line.Quoted_Unit_Price__c != null){
                    return line.Quoted_Quantity__c * line.Quoted_Unit_Price__c;
                }else{
                    return line.SVMXC__Actual_Quantity2__c * line.SVMXC__Actual_Price2__c;
                }
            }
        }

        public Decimal invTotal {
            get {
                if (line.Invoice_Qty__c == null || line.Invoice_Unit_Price__c == null)
                    return 0;
                else if(line.Quoted_Quantity__c != null && line.Quoted_Unit_Price__c != null){
                    return line.Quoted_Quantity__c * line.Quoted_Unit_Price__c;
                }else{
                    return line.Invoice_Qty__c * line.Invoice_Unit_Price__c;
                }
            }
        }

        public void changePart(){
            String sCenter = ApexHelper.getParam('sc');
            String customPbId = '';
            this.line.Vendor_Cost_Per_Unit__c = 0;
            this.line.SVMXC__Actual_Price2__c = 0;
            this.prodCode = '';
            String standardPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
            System.debug('================= sCenter: ' + sCenter);
            if(String.isNotBlank(sCenter)){
                try{
                    customPbId = [SELECT Id FROM Pricebook2 WHERE Name = :sCenter].Id;
                    System.debug('================= customPbId: ' + customPbId);
                }catch(Exception e){
                    //Expected to fial when there are no pricebook with the super center name
                }
            }
            String prodId = this.line.SVMXC__Product__c;
            Product2 product = new Product2();
            if(String.isNotBlank(prodId)){
                product = [SELECT id, SVMXC__Product_Cost__c, Description, ProductCode FROM Product2 WHERE id = :prodId LIMIT 1];
                this.prodCode = product.ProductCode;
                List<PricebookEntry> pEntry = new List<PricebookEntry>();
                if(String.isNotBlank(customPbId)){
                    try{
                        pEntry = [SELECT Id, Pricebook2Id, UnitPrice, Cost__c FROM PricebookEntry WHERE Pricebook2Id = :customPbId AND Product2Id = :prodId LIMIT 1];
                        System.debug('================= [438] pEntry.size(): ' + pEntry.size());
                    }catch(Exception e){}
                }
                if(pEntry.size() <= 0 && String.isNotBlank(standardPbId)){
                    try{
                        pEntry = [SELECT Id, Pricebook2Id, UnitPrice, Cost__c FROM PricebookEntry WHERE Pricebook2Id = :standardPbId AND Product2Id = :prodId LIMIT 1];
                        System.debug('================= [446] pEntry.size(): ' + pEntry.size());
                    }catch(Exception e){}
                }
                if(pEntry.size() > 0){
                    System.debug('================= pEntry[0].Cost__c: ' + pEntry[0].Cost__c);
                    System.debug('================= pEntry[0].UnitPrice: ' + pEntry[0].UnitPrice);
                    this.line.Vendor_Cost_Per_Unit__c = (pEntry[0].Cost__c != null) ? pEntry[0].Cost__c.setScale(2, System.RoundingMode.HALF_UP) : product.SVMXC__Product_Cost__c.setScale(2, System.RoundingMode.HALF_UP);
                    this.line.SVMXC__Actual_Price2__c = (pEntry[0].UnitPrice != null) ? pEntry[0].UnitPrice.setScale(2, System.RoundingMode.HALF_UP) : 0;
                }else{
                    this.line.Vendor_Cost_Per_Unit__c = (product.SVMXC__Product_Cost__c != null) ? product.SVMXC__Product_Cost__c.setScale(2, System.RoundingMode.HALF_UP) : 0;
                    this.line.SVMXC__Actual_Price2__c = 0;
                }
            }else{
                this.line.Vendor_Cost_Per_Unit__c = 0;
                this.line.SVMXC__Actual_Price2__c = 0;
            }
            if(this.line.SVMXC__Activity_Type__c == 'Warranty'){
                this.line.SVMXC__Actual_Price2__c = 0;
                this.line.SVMXC__Is_Billable__c = false;
            }
            populateInventory();
        }
        /**populateInventory method. This methodchecks for the selected product inventory availability on part lines */
        public void populateInventory() {
            String prodId = this.line.SVMXC__Product__c;
            if(String.isNotBlank(prodId)){
                //Fetch the inventory for the product ids in the prodIds set
                List<SVMXC__Product_Stock__c> invs = [SELECT SVMXC__Location__c, SVMXC__Product__c, SVMXC__Available_Qty__c FROM SVMXC__Product_Stock__c WHERE SVMXC__Product__c = :prodId AND SVMXC__Status__c = 'Available'];
                //For each work detail line...
                this.inv1 = 0;                                                                                              //Set the inv1 to 0 (total in my inventory location)
                this.inv2 = 0;                                                                                              //Set the inv2 to 0 (total in all locations)
                for(SVMXC__Product_Stock__c inv : invs){                                                                    //For each inventory product
                    //If this is the product on the line and has available qty...
                    if(inv.SVMXC__Product__c == this.line.SVMXC__Product__c && inv.SVMXC__Available_Qty__c != null) {
                        //If the inventory location is the same as the inventory location for the tech assigned to the work order
                        if (inv.SVMXC__Location__c == this.wo.SVMXC__Group_Member__r.SVMXC__Inventory_Location__c) {
                            this.inv1 += (integer)inv.SVMXC__Available_Qty__c;                                               //Add the available qty to the line inv1
                        }else if(String.isNotBlank(this.line.SVMXC__Consumed_From_Location__c)){
                            if(inv.SVMXC__Location__c == this.line.SVMXC__Consumed_From_Location__c){
                                this.inv1 += (integer)inv.SVMXC__Available_Qty__c;
                            }
                        }
                        this.inv2 += (integer)inv.SVMXC__Available_Qty__c;                                                   //Add the available qty to the line inv2
                    }
                }
            }
        }//End populateInventory method

        public void enableCheckbox(){
            if(this.line.SVMXC__Line_Status__c == 'Completed')
                this.canInvoice = true;
            else{
                this.canInvoice = false;
                if(this.line.SVMXC__Line_Status__c == 'Canceled'){
                    this.line.SVMXC__Is_Billable__c = false;
                    billableChanged();
                }

            }
        }

        public void billableChanged(){
            if(!this.line.SVMXC__Is_Billable__c){
                this.line.SVMXC__Actual_Price2__c = 0;
                if(this.line.Quoted_Unit_Price__c != null){
                    this.line.Quoted_Unit_Price__c = 0;
                }
                if(this.line.SVMXC__Line_Status__c == 'Canceled'){
                    this.line.Vendor_Cost_Per_Unit__c = 0;
                    this.line.SVMXC__Actual_Quantity2__c = 0;
                    if(this.line.Quoted_Unit_Cost__c != null)
                        this.line.Quoted_Unit_Cost__c = 0;
                    if(this.line.Quoted_Quantity__c != null)
                        this.line.Quoted_Quantity__c = 0;
                }
            }else{
                //this.line.SVMXC__Actual_Price2__c = 0;
                //this.line.Quoted_Unit_Price__c = 0;
            }
        }

        public void quotedChanged(){
            if(this.line.Quoted__c){
                this.line.Line_from_iPad__c = false;
            }else{
                this.line.Line_from_iPad__c = true;
            }
        }

        public void togglePart(){
            resetLine();
            if(String.isNotBlank(this.Line.SVMXC__Line_Type__c)){
                this.line.SVMXC__Line_Status__c = 'Open';
            }
            if (this.line.SVMXC__Line_Type__c == 'Parts' || this.line.SVMXC__Line_Type__c =='Vendor Services'){
                this.isPart = true;
            }else{
                this.isPart = false;
            }
            if ((this.line.SVMXC__Service_Order__c != null) && (this.line.SVMXC__Line_Type__c == 'Travel')){
                this.line.SVMXC__Actual_Price2__c = this.wo.Labor_Standard_DDM__c;
            }
            if ((this.wo.SVMXC__Group_Member__c != null) && (this.line.SVMXC__Line_Type__c == 'Travel')){
                this.line.Vendor_Cost_Per_Unit__c = this.wo.SVMXC__Group_Member__r.SVMXC__Fixed_Cost__c;
            }
            enableCheckbox();
        }

        public void resetLine(){
            this.line.Vendor_Cost_Per_Unit__c = null;
            this.line.SVMXC__Actual_Price2__c = null;
            this.line.SVMXC__Actual_Quantity2__c = null;
            this.line.Quoted_Unit_Cost__c = null;
            this.line.Quoted_Unit_Price__c = null;
            this.line.Quoted_Quantity__c = null;
            this.line.SVMXC__Product__c = null;
            this.line.Deliver_Date__c = null;
            this.line.SVMXC__Line_Status__c = null;
            this.line.Vendor__c = null;
            this.line.SVMXC__Activity_Type__c = null;
            this.inv1 = 0;
            this.inv2 = 0;
            this.prodCode = '';
            this.line.SVMXC__Work_Description__c = null;
            this.friendlyMsg = '';
        }
    }
}