public class SVMX_VF_Invoice_Preview_Extension{

	public SVMXC__Service_Order__c workOrder {get; private set;}
	public List<SVMXC__Service_Order_Line__c> workOrderLines {get; private set;}
	public List<Work_Performed__c> jobNotes  {get; private set;}
    public Decimal orderTotal {get; private set;}                                   //The work order total
    public Decimal taxTotal {get; private set;}                                     //The tax total
    public Decimal revenue {get; private set;}                                      //The revenue
    public Decimal marginCurr {get; private set;}                                   //The margin in currency
    public Decimal marginPercent {get; private set;}                                //The margin in percent
    public Decimal invRevenue {get; private set;}									//The invoiced revenue
    public Decimal invTaxTotal {get; private set;}                                  //The invoiced tax total
    public Decimal invTotal {get; private set;}                                     //The invoiced order total
    public Decimal invMarginCurr {get; private set;}								//The invoiced margin in currency
    public Decimal invMarginPercent {get; private set;}								//The invoiced margin in percent
    public Boolean isQuoted {get; private set;}                                     //Denotes if the wo is a quoted wo without requiring anything
   	public List<Work_Performed__c> recommendedServices  {get; private set;}
   	public Account minerAccount  {get; private set;}

	public SVMX_VF_Invoice_Preview_Extension(ApexPages.StandardController controller) {
		recommendedServices = new List<Work_Performed__c>();
		//Fetch the work order record
        this.workOrder = [SELECT Id,Name, TFS_Invoice_Date__c, SVMXC__Invoice_Number__c,
        				SVMXC__Company__r.Name, SVMXC__Company__r.BillingStreet, SVMXC__Company__r.BillingCity, SVMXC__Company__r.BillingState,
        				SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.MH_SL_CustID__c, SVMXC__Company__r.Pay_Terms__c,
        				Location__r.Name, Location__r.SVMXC__Street__c, Location__r.SVMXC__City__c, Location__r.SVMXC__State__c,
        				Location__r.SVMXC__Zip__c,
        				SVMXC__Service_Group__r.Company_Legal_Name__c, SVMXC__Service_Group__r.SVMXC__Street__c, SVMXC__Service_Group__r.SVMXC__City__c,
        				SVMXC__Service_Group__r.SVMXC__State__c, SVMXC__Service_Group__r.SVMXC__Zip__c, SVMXC__Service_Group__r.SVMXC__Phone__c,
        				SVMXC__Service_Group__r.Fax_c__c, Customer_P_O__c, SVMXC__SLA_Terms__c, Work_Order_Type__c, Service_Notes__c
                        FROM SVMXC__Service_Order__c WHERE Id = :controller.getId() LIMIT 1];

		workOrderLines = [SELECT SVMXC__Work_Description__c, SVMXC__Actual_Quantity2__c, Unit_of_Measure__c, Estimate_or_Actual_Price__c, SVMXC__Line_Status__c,
							 SVMXC__Total_Line_Price__c, SVMXC__Actual_Price2__c, Sales_Tax__c, Vendor_Cost_Per_Unit__c, Invoice_Qty__c, Invoice_Unit_Price__c, Total_Line_PriceMH__c
							 FROM SVMXC__Service_Order_Line__c
							 WHERE SVMXC__Service_Order__c = :controller.getId()
							 AND SVMXC__Line_Status__c = 'Completed'
							 AND Hide_Line__c = false
							 AND SVMXC__Is_Billable__c = true
							 ORDER BY Sort_Order__c ASC];
		jobNotes = [SELECT History_Notes__c, Note_Type__c  FROM Work_Performed__c
							WHERE (Note_Type__c='Recommended Service' OR Note_Type__c='	Work Performed')
							AND Work_Order_c__c = :controller.getId()];

		minerAccount = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE id = :Label.Preview_Invoice_Billing_Account_Source];

		for (Work_Performed__c notes : jobNotes){
			if (notes.Note_Type__c =='Recommended Service')
				recommendedServices.add(notes);
		}

		calculateTotals();
	}
    public void calculateTotals(){
        //Reset variables
        this.revenue = 0;
        this.taxTotal = 0;
        this.orderTotal = 0;
        this.marginCurr = 0;
        this.marginPercent = 0;
        this.invRevenue = 0;
        this.invTaxTotal = 0;
        this.invMarginCurr = 0;
        this.invMarginPercent =0;
        Decimal totalp = 0, totalc = 0;
        Decimal invTotalp = 0, invTotalc =0;
        for(SVMXC__Service_Order_Line__c line :this.WorkOrderLines){                                                                //For each work detail line...
            if(line.SVMXC__Line_Status__c != 'Canceled'){
                if(this.workOrder.Work_Order_Type__c != 'Warranty'){
                    if((line.SVMXC__Actual_Price2__c  != null) && (line.SVMXC__Actual_Quantity2__c != null)){         //If the line has a price and qty...
                        this.revenue += line.SVMXC__Actual_Price2__c * line.SVMXC__Actual_Quantity2__c;               //Add the price * qty to the revenue
                    }
                    if(line.Sales_Tax__c != null){                                                                             //if the line has sales tax...
                        this.taxTotal += line.Sales_Tax__c;                                                                    //Add the sales tax to the taxTotal
                        this.invTaxTotal += line.Sales_Tax__c;															//Add the sales tax to the invTaxTotal
                    }
                    //If the line has price, unit cost, and qty...
                    if((line.SVMXC__Actual_Price2__c  != null) && (line.Vendor_Cost_Per_Unit__c != null) && (line.SVMXC__Actual_Quantity2__c != null)){
                        //Add (price - cost) * qty to marginCurr
                        this.marginCurr += (line.SVMXC__Actual_Price2__c - line.Vendor_Cost_Per_Unit__c) * line.SVMXC__Actual_Quantity2__c;
                        totalp += line.SVMXC__Actual_Price2__c * line.SVMXC__Actual_Quantity2__c;                     //Add price * qty to totalp
                        totalc += line.Vendor_Cost_Per_Unit__c * line.SVMXC__Actual_Quantity2__c;                     //Add cost * qty to totalc
                    }
                    if((line.Invoice_Unit_Price__c != null) && (line.Invoice_Qty__c != null)){
                        this.invRevenue += (line.Invoice_Unit_Price__c * line.Invoice_Qty__c);
                        this.invMarginCurr += (line.Invoice_Unit_Price__c - line.Vendor_Cost_Per_Unit__c) * line.Invoice_Qty__c;
                        invTotalp += line.Invoice_Unit_Price__c * line.Invoice_Qty__c;
                        invTotalc += line.Vendor_Cost_Per_Unit__c * line.Invoice_Qty__c;
                    }
                }/*else{
                    if((line.Quoted_Unit_Price__c  != null) && (line.Quoted_Quantity__c != null)){                         //If the line has a price and qty...
                        this.revenue += line.Quoted_Unit_Price__c * line.Quoted_Quantity__c;                               //Add the price * qty to the revenue
                    }
                    if(line.Sales_Tax__c != null){                                                                             //if the line has sales tax...
                        this.taxTotal += line.Sales_Tax__c;                                                                    //Add the sales tax to the taxTotal
                    }
                    //If the line has price, unit cost, and qty...
                    if((line.Quoted_Unit_Price__c  != null) && (line.Vendor_Cost_Per_Unit__c != null) && (line.Quoted_Quantity__c != null) && (line.SVMXC__Actual_Quantity2__c != null)){
                        //Add (price - cost) * qty to marginCurr
                        this.marginCurr += ((line.Quoted_Unit_Price__c * line.Quoted_Quantity__c) - (line.Vendor_Cost_Per_Unit__c * line.SVMXC__Actual_Quantity2__c));
                        totalp += line.Quoted_Unit_Price__c * line.Quoted_Quantity__c;                                     //Add price * qty to totalp
                        totalc += line.Vendor_Cost_Per_Unit__c * line.SVMXC__Actual_Quantity2__c;                     //Add cost * qty to totalc
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
        this.revenue = this.revenue.setScale(3, System.RoundingMode.HALF_DOWN);                                                 //Perform rounding on revenue
        this.marginCurr = this.marginCurr.setScale(3, System.RoundingMode.HALF_DOWN);                                           //Perform rounding on marginCurr
        this.marginPercent = this.marginPercent.setScale(0, System.RoundingMode.HALF_UP);                                       //Perform rounding on marginPercent
        this.orderTotal = revenue + taxTotal;                                                                                   //Set orderTotal to (revenue + taxTotal)
        this.invRevenue = this.invRevenue.setScale(3, System.RoundingMode.HALF_DOWN);                                           //Perform rounding on invoiced revenue
        this.invTotal = invRevenue + invTaxTotal;                                                                               //Set invTotal to (invRevenue + invTaxTotal)
        this.invMarginCurr = this.invMarginCurr.setScale(3, System.RoundingMode.HALF_DOWN);
        this.invMarginPercent = this.invMarginPercent.setScale(0, System.RoundingMode.HALF_UP);
    }

}