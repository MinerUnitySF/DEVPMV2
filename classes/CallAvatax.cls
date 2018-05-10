global with sharing class CallAvatax {
    public List<SVMXC__Service_Order_Line__c> wilist;
    public String oname {get;set;}
    public String otype {get;set;}
    public String tcode {get;set;}
    public Integer x {get;set;}
    public Integer y {get;set;}
    public String wid;
    public String retUrl;
    public String SampleResult {get;set;}
    public Boolean error1 {get;set;}
    
    public CallAvatax(){
        
    }
    
    public CallAvatax(ApexPages.StandardController controller){
        
    }
    
    public PageReference Call(){
        
        wid = ApexPages.CurrentPage().getParameters().get('id');
        
        List<Key_Value_Store__c> kvslist = new List<Key_Value_Store__c>();
        kvslist = [SELECT Id, Name, Value__c FROM Key_Value_Store__c];
        
        String user = null;
        String pass = null;
        for (Key_Value_Store__c kvsindex : kvslist){
            if (kvsindex.Name.toLowerCase() == 'avatax account id')
                user = kvsindex.Value__c;
            if (kvsindex.Name.toLowerCase() == 'avatax license key')
                pass = kvsindex.Value__c;
        }
                
        SVMXC__Service_Order__c w = [SELECT Id, SVMXC__Company__r.MH_SL_CustID__c, Location__r.SVMXC__Street__c, Location__r.SVMXC__City__c, Certificate__c,SVMXC__Order_Type__c,
                                          Location__r.SVMXC__State__c, Location__r.SVMXC__Zip__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c,
                                          SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__City__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__State__c,
                                          SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Zip__c, SVMXC__Service_Group__r.SVMXC__Street__c,
                                          SVMXC__Service_Group__r.SVMXC__City__c, SVMXC__Service_Group__r.SVMXC__State__c, SVMXC__Service_Group__r.SVMXC__Zip__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.Company_Code__c,
                                          SVMXC__Service_Group__r.Company_Code__c, SVMXC__Service_Group__c, SVMXC__Company__c, Location__c, Super_Center2__c, Super_Center2__r.Name, Segment__c, Segment__r.Segment_Name__c FROM SVMXC__Service_Order__c WHERE Id =: wid LIMIT 1];
        wilist = new List<SVMXC__Service_Order_Line__c>();
        wilist = [SELECT Id, Name, SVMXC__Actual_Price2__c, SVMXC__Actual_Quantity2__c, SVMXC__Line_Type__c, SVMXC__Activity_Type__c, Total_Line_PriceMH__c, Tax_Code__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c =: w.Id AND SVMXC__Line_Status__c != 'Canceled'];
		
        avataxAvalaraComServicesAlt.TaxSvcAltSecSoap taxSvc = new avataxAvalaraComServicesAlt.TaxSvcAltSecSoap();
        taxSvc.Security = new avataxAvalaraComServicesAlt.Security();
        taxSvc.Security.UsernameToken = new avataxAvalaraComServicesAlt.UsernameToken_element();
        taxSvc.Security.UsernameToken.Username = user;
        taxSvc.Security.UsernameToken.Password = pass;
        taxSvc.Profile = new avataxAvalaraComServicesAlt.Profile();
        taxSvc.Profile.Name = '1.0.0';
        taxSvc.Profile.Client = 'My Application Name,1.0';
        taxSvc.Profile.Machine = 'My Machine Name';

        avataxAvalaraComServicesAlt.GetTaxRequest gtreq = new avataxAvalaraComServicesAlt.GetTaxRequest();
        error1 = false;
        if(String.isNotBlank(w.SVMXC__Group_Member__c)){
            if(String.isNotBlank(w.SVMXC__Group_Member__r.SVMXC__Service_Group__c))
                gtreq.CompanyCode = w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.Company_Code__c;
        }else{
            if(String.isNotBlank(w.SVMXC__Service_Group__c))
                gtreq.CompanyCode = w.SVMXC__Service_Group__r.Company_Code__c;
        }
        if(String.isBlank(gtreq.CompanyCode))
            error1 = true;
        gtreq.DocType = 'SalesOrder';
        if(String.isNotBlank(w.SVMXC__Company__c))
            gtreq.CustomerCode = w.SVMXC__Company__r.MH_SL_CustID__c;//'Customer One';//
        gtreq.Discount = 0; 
        gtreq.DetailLevel = 'Tax';
        gtreq.HashCode = 0;
        gtreq.ServiceMode = 'Automatic';
        gtreq.ExchangeRate = 0;
        gtreq.ExchangeRateEffDate = date.today();
        gtreq.PaymentDate = date.today(); 
        gtreq.ExemptionNo = w.Certificate__c;
        
        avataxAvalaraComServicesAlt.BaseAddress orgAddr = new avataxAvalaraComServicesAlt.BaseAddress();
        orgAddr.AddressCode = 'Origin';
        if(String.isNotBlank(w.SVMXC__Group_Member__c)){
            if (String.isNotBlank(w.SVMXC__Group_Member__r.SVMXC__Service_Group__c)){
                orgAddr.Line1 = w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c;//'11827 Tech Com Dr #115';//w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c;
                orgAddr.City = w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__City__c;//'San Antonio'; //
                orgAddr.Region = w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__State__c;//'TX'; //
                orgAddr.PostalCode = w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Zip__c;//'78233'; //
            }
        }else{
            if(String.isNotBlank(w.SVMXC__Service_Group__c)){
                orgAddr.Line1 = w.SVMXC__Service_Group__r.SVMXC__Street__c;
                orgAddr.City = w.SVMXC__Service_Group__r.SVMXC__City__c;
                orgAddr.Region = w.SVMXC__Service_Group__r.SVMXC__State__c;
                orgAddr.PostalCode = w.SVMXC__Service_Group__r.SVMXC__Zip__c;
            }
        }
        orgAddr.TaxRegionId = 0;
        avataxAvalaraComServicesAlt.BaseAddress dstAddr = new avataxAvalaraComServicesAlt.BaseAddress();
        dstAddr.AddressCode = 'Destination';
        if(String.isNotBlank(w.Location__c)){
            dstAddr.Line1 = w.Location__r.SVMXC__Street__c;//'11827 Tech Com Dr #116'; 
            dstAddr.City = w.Location__r.SVMXC__City__c;//'San Antonio'; 
            dstAddr.Region = w.Location__r.SVMXC__State__c;//'TX'; 
            dstAddr.PostalCode = w.Location__r.SVMXC__Zip__c;//'78233'; 
        }
        dstAddr.TaxRegionId = 0;
        gtreq.Addresses = new avataxAvalaraComServicesAlt.ArrayOfBaseAddress();
        gtreq.Addresses.BaseAddress = new avataxAvalaraComServicesAlt.BaseAddress[2];
        gtreq.Addresses.BaseAddress[0] = orgAddr;
        gtreq.Addresses.BaseAddress[1] = dstAddr;
        gtreq.OriginCode = orgAddr.AddressCode;
        gtreq.DestinationCode = dstAddr.AddressCode;
        gtreq.Lines = new avataxAvalaraComServicesAlt.ArrayOfLine();
        gtreq.Lines.Line = new avataxAvalaraComServicesAlt.Line[wilist.size()];
        Integer i = 0;
        x = 0;
        y = 0;
        Map<String, SVMXC__Service_Order_Line__c> detailmap = new Map<String, SVMXC__Service_Order_Line__c>();
        if (!error1){
            wilist = getTaxCode(w.Id);
            for(SVMXC__Service_Order_Line__c windex : wilist){
                detailmap.put(windex.Name, windex);
                gtreq.Lines.Line[i] = new avataxAvalaraComServicesAlt.Line();
                gtreq.Lines.Line[i].No = windex.Name;
                gtreq.Lines.Line[i].Amount = (windex.Total_Line_PriceMH__c != null) ? windex.Total_Line_PriceMH__c : 0;
                gtreq.Lines.Line[i].Qty = (windex.SVMXC__Actual_Quantity2__c != null) ? windex.SVMXC__Actual_Quantity2__c : 0;
                gtreq.Lines.Line[i].Discounted = false;
                gtreq.Lines.Line[i].OriginCode = 'Origin';
                gtreq.Lines.Line[i].DestinationCode = 'Destination';
                if(String.isBlank(windex.SVMXC__Activity_Type__c)){
                    y = 1;
                    oname = windex.Name;
                    break;
                }
                //Get the tax code for the line
                String taxCode = windex.Tax_Code__c;//getTaxCode(w.Segment__r.Segment_Name__c,w.SVMXC__Order_Type__c,windex.SVMXC__Line_Type__c,windex.SVMXC__Activity_Type__c);
                //If after checking all the tax code association... a matching tax code wasn't found...
                if(String.isNotBlank(taxCode)){
                    gtreq.Lines.Line[i].TaxCode = taxCode;
                }else{
                    x = 1;
                    oname = windex.Name;
                    otype = windex.SVMXC__Activity_Type__c;
                    break;
                }
                i++;
            }
        }
        
        gtreq.DocDate = Date.Today();
        gtreq.Commit_x=true;
        
        avataxAvalaraComServicesAlt.GetTaxResult gtres = null;
        SampleResult = '';
        
        if ((x == 0) && (y == 0) && (!error1)){
            try{
                 gtres = taxSvc.GetTax(gtreq);
            
                 if(gtres.ResultCode == 'Success'){
			         SampleResult = '<span class="success-result">'+gtres.ResultCode + '</span>' +
                         '<table class="message-table"><tr><th>Total Tax</th><td> $' + gtres.TotalTax + '</td></tr></table>';
			         //showconf = false;
			     }else{
			         SampleResult = '<span class="error-result">'+gtres.ResultCode + '</span><table class="message-table"><tr><th>Summary</th><td>' + ((gtres.Messages != null) ? gtres.Messages.Message[0].Summary : 'Not available') + '</td></tr>';
                     SampleResult += '<tr><th>Details</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].Details: 'Not available') +'</td></tr>';
                     SampleResult += '<tr><th>Refers To</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].RefersTo: 'Not available') +'</td></tr>';
                     SampleResult += '<tr><th>Source</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].Source: 'Not available') +'</td></tr>';
                     SampleResult += '</table>';
			     }
            }catch(Exception ex){
                SampleResult = 'GetTax Threw an Exception: ' + ex.getmessage();
                System.debug('================== ' + SampleResult);
            }
        }
        
        if(gtres != null){
            //system.debug('sampleresult:' + gtres.TotalTax);
            if(gtres.TaxLines != null){
                if(gtres.TaxLines.TaxLine != null){
                    List<SVMXC__Service_Order_Line__c> detaillist = new List<SVMXC__Service_Order_Line__c>();
                    for(avataxavalaraComServicesAlt.TaxLine tl : gtres.TaxLines.TaxLine){
                        if(detailmap.containsKey(tl.No)){
                            detailmap.get(tl.No).Sales_Tax__c = tl.Tax;
                            detaillist.add(detailmap.get(tl.No));
                        }
                    }
                    update detaillist;
                }
            }
        }
        retUrl = ApexPages.CurrentPage().getParameters().get('retUrl');
        if (String.IsNotBlank(retUrl))
        	 return new pageReference(retUrl);
        return null;
    }
    
    public pageReference Save(){
        if(String.IsNotBlank(tcode)){
            Tax_Code_Associations__c t = new Tax_Code_Associations__c (Activity_Type__c = otype, Tax_Code__c = tcode);
            insert t;
        }else{
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a tax code.'));
             return null;
        }
        retUrl = ApexPages.CurrentPage().getParameters().get('retUrl');
        pageReference pr;
        if(String.isBlank(retUrl))
       		 pr = new pageReference('/' + wid);
       	else	
        	 pr = new pageReference(retUrl);
        
        return pr;
        
    }
    
    public pageReference Cancel(){
        retUrl = ApexPages.CurrentPage().getParameters().get('retUrl');
        pageReference pr;
        if (retUrl == null)
       		 pr = new pageReference('/' + wid);
       	else	
        	 pr = new pageReference(retUrl);
        return pr;
    }
    
    public static List<SVMXC__Service_Order_Line__c> getTaxCode(String woid){
        SVMXC__Service_Order__c wo = [SELECT Id, SVMXC__Company__r.MH_SL_CustID__c, Location__r.SVMXC__Street__c, Location__r.SVMXC__City__c, Certificate__c,SVMXC__Order_Type__c,
                                          Location__r.SVMXC__State__c, Location__r.SVMXC__Zip__c, SVMXC__Group_Member__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c,
                                          SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__City__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__State__c,
                                          SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Zip__c, SVMXC__Service_Group__r.SVMXC__Street__c,
                                          SVMXC__Service_Group__r.SVMXC__City__c, SVMXC__Service_Group__r.SVMXC__State__c, SVMXC__Service_Group__r.SVMXC__Zip__c, SVMXC__Group_Member__r.SVMXC__Service_Group__r.Company_Code__c,
                                          SVMXC__Service_Group__r.Company_Code__c, SVMXC__Service_Group__c, SVMXC__Company__c, Location__c, Super_Center2__c, Super_Center2__r.Name, Segment__c, Segment__r.Segment_Name__c FROM SVMXC__Service_Order__c WHERE Id =: woid LIMIT 1];
        List<SVMXC__Service_Order_Line__c> lines = [SELECT Id, Name, SVMXC__Actual_Price2__c, SVMXC__Actual_Quantity2__c, SVMXC__Line_Type__c, SVMXC__Activity_Type__c, Total_Line_PriceMH__c, Tax_Code__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Service_Order__c =: wo.Id AND SVMXC__Line_Status__c != 'Canceled'];
        //First, lets clear all tax codes
        for(SVMXC__Service_Order_Line__c line :lines){
            line.Tax_Code__c = null;
        }
        //Get the record type ids for the tax code association object
        String sRTId = [SELECT ID FROM RecordType WHERE SObjectType = 'Tax_Code_Associations__c' AND Name = 'Standard'].Id;
        String exRTId = [SELECT ID FROM RecordType WHERE SObjectType = 'Tax_Code_Associations__c' AND Name = 'Exception'].Id;
        //Set the segment (state) from the service team on the work order
        String segment = wo.SVMXC__Service_Group__r.SVMXC__State__c;
        //System.debug('========== segment: ' + segment);
        //Set the order type
        String orderType = wo.SVMXC__Order_Type__c;
        //System.debug('========== orderType: ' + orderType);
        //Need to get any exception tax code for the segment (state) on the work order
        List<Tax_Code_Associations__c> exList = [SELECT Id,Name,Segment__c,Order_Type__c,Included_Activity_Types__c,Excluded_Activity_Types__c,
                                                 Included_Line_Types__c,Excluded_Line_Types__c,(SELECT Id,Name,Activity_Type__c,Tax_Code__c 
                                                 FROM Tax_Code_Exceptions__r)
                                                 FROM Tax_Code_Associations__c WHERE Segment__c = :segment AND RecordTypeId = :exRTId];
        //If there are exeptions for the segment (state) on the work order...
        if(exList.size() > 0){
            //Now we need to find if the work order matches the rule. 
            //If it does, the associated tax code exceptions are applied based on line activity type
            //For each exception...
            for(Tax_Code_Associations__c ex :exList){
                Boolean isOType = false;//Denotes if the work order types matches the exception type
                Boolean ltInc = false;//Denotes if the lines include any of the Included Line Types 
                Boolean ltExc = true;//Denotes if the lines don't include any of the Excluded Line Types
                Boolean atInc = false;//Denotes if the lines include any of the Included Activity Types
                Boolean atExc = true;//Denotes if the lines include any of the Excluded Activity Types
                //Boolean match = true;
                //First, check if this rule applies to a specific order type.... 
                if(String.isNotBlank(ex.Order_Type__c)){
                    //If it does and it matches the order type on the work order...
                    if(ex.Order_Type__c.contains(wo.SVMXC__Order_Type__c))
                        isOType = true;//Set isOType to true
                //Otherwise, if the order type is not specified...
                }else{
                    isOType = true;//Set isOType to true
                }
                //If the isOType is set to true (a match or not specified)
                if(isOType){
                    //Now, need to iterate through each line to see if the work order matches the exception
                    for(SVMXC__Service_Order_Line__c line :lines){
                        //Check for included line types.
                        //If there are included line types specified....
                        if(String.isNotBlank(ex.Included_Line_Types__c)){
                            //If the line type matches one of the Included Line Types...
                            if(ex.Included_Line_Types__c.contains(line.SVMXC__Line_Type__c))
                                ltInc = true;//Set ltinc to true
                        //Otherwise, if Included Line Types is not specified...
                        }else{
                            ltInc = true;//Set ltinc to true
                        }
                        //Check for excluded line types
                        //If there are excluded line types specified....
                        if(String.isNotBlank(ex.Excluded_Line_Types__c)){
                            //If the line type matches one of the Excluded Line Types...
                            if(ex.Excluded_Line_Types__c.contains(line.SVMXC__Line_Type__c))
                                ltExc = false;//Set ltExc to false
                        //Otherwise, if Excluded Line Types is not specified...
                        }else{
                            ltExc = true;//Set ltExc to true
                        }
                        //Check for included activity types
                        //If there are included activity types specified...
                        if(String.isNotBlank(ex.Included_Activity_Types__c)){
                            //If the activity type matches one of the Included Activity Types...
                            if(ex.Included_Activity_Types__c.contains(line.SVMXC__Activity_Type__c))
                                atInc = true;//Set atInc to true
                        //Otherwise, if Included Activity Types is not specified...
                        }else{
                            atInc = true;//Set atInc to true
                        }
                        //Check for excluded activity types
                        //If there are excluded activity types specified...
                        if(String.isNotBlank(ex.Excluded_Activity_Types__c)){
                            //If the activity type matches one of the Excluded Activity Types...
                            if(ex.Excluded_Activity_Types__c.contains(line.SVMXC__Activity_Type__c))
                                atExc = false;//Set atExc to false
                        //Otherwise, if Excluded Activity Types is not specified...
                        }else{
                            atExc = true;//Set atExc to true
                        }
                    }
                    //System.debug('========== ltInc: ' + ltInc);
                    //System.debug('========== ltExc: ' + ltExc);
                    //System.debug('========== atInc: ' + atInc);
                    //System.debug('========== atExc: ' + atExc);
                    //If the work order is a match...
                    if(ltInc && ltExc && atInc && atExc){
                        //Create a map to hold the tax code by activity type. 
                        //This will save me a few iterations trough the lines
                        Map<String,String> taxCodeMap = new Map<String,String>();
                        for(Tax_Code_Exception__c exLine :ex.Tax_Code_Exceptions__r){
                        	taxCodeMap.put(exLine.Activity_Type__c, exLine.Tax_Code__c);
                        }
                        //Need to apply the exception tax code to the lines
                        for(SVMXC__Service_Order_Line__c line :lines){
                            if(taxCodeMap.containsKey(line.SVMXC__Activity_Type__c)){
                                //Need to set the line tax code here...
                                line.Tax_Code__c = taxCodeMap.get(line.SVMXC__Activity_Type__c);
                            }//End if tax code map
                        }//End for line
                    }//End if match
                }//End if isOType
            }//End for each tax exception
        }//End if tax exceptions
        //Maps to group the STANDARD tax association By Segment(state), Order Type, Line Type, and Activity Type
        //All rules are by acticvity type but they can be Segment, Order Type, and/or Line type specific
        Map<String, List<Tax_Code_Associations__c>> segmentMap = new Map<String, List<Tax_Code_Associations__c>>();
        Map<String, List<Tax_Code_Associations__c>> ordTypeMap = new Map<String, List<Tax_Code_Associations__c>>();
        Map<String, List<Tax_Code_Associations__c>> lineTypeMap = new Map<String, List<Tax_Code_Associations__c>>();
        Map<String, List<Tax_Code_Associations__c>> actTypeMap = new Map<String, List<Tax_Code_Associations__c>>();
		//Fetch all standard tax code associations
        List<Tax_Code_Associations__c> codeList = new List<Tax_Code_Associations__c>();
        codeList = [SELECT Id, Segment__c,Order_Type__c,Line_Type__c,Activity_Type__c,Tax_Code__c FROM Tax_Code_Associations__c WHERE RecordTypeId = :sRTId];
        //Put the tax code associations in their respective maps
        for(Tax_Code_Associations__c tca : codeList){
            //If the line has a segment... Put it in the segmentMap
            if(String.isNotBlank(tca.Segment__c) && tca.Segment__c != '<Any>'){
                if(!segmentMap.containsKey(tca.Segment__c)){
                    List<Tax_Code_Associations__c> temp = new List<Tax_Code_Associations__c>();
                    temp.add(tca);
                    segmentMap.put(tca.Segment__c,temp);
                }else{
                    segmentMap.get(tca.Segment__c).add(tca);
                }
            //Otherwise... If the line has an Order Type... put it in the ordTypeMap
            }else if(String.isNotBlank(tca.Order_Type__c)  && tca.Order_Type__c != '<Any>'){
                List<String> oTypes = tca.Order_Type__c.split(';');
                for(String ot :oTypes){
                    if(!ordTypeMap.containsKey(ot)){
                        List<Tax_Code_Associations__c> temp = new List<Tax_Code_Associations__c>();
                        temp.add(tca);
                        ordTypeMap.put(ot,temp);
                    }else{
                        ordTypeMap.get(ot).add(tca);
                    }
                }
            //Otherwise... If the line has an Order Type... put it in the ordTypeMap
            }else if(String.isNotBlank(tca.Line_Type__c) && tca.Line_Type__c != '<Any>'){
                if(!lineTypeMap.containsKey(tca.Line_Type__c)){
                    List<Tax_Code_Associations__c> temp = new List<Tax_Code_Associations__c>();
                    temp.add(tca);
                    lineTypeMap.put(tca.Line_Type__c,temp);
                }else{
                    lineTypeMap.get(tca.Line_Type__c).add(tca);
                }
			//Otherwise... If the line has an Order Type... put it in the ordTypeMap
            }else if(String.isNotBlank(tca.Activity_Type__c)){
            	if(!actTypeMap.containsKey(tca.Activity_Type__c)){
                    List<Tax_Code_Associations__c> temp = new List<Tax_Code_Associations__c>();
                    temp.add(tca);
                    actTypeMap.put(tca.Activity_Type__c,temp);
                }else{
                    actTypeMap.get(tca.Activity_Type__c).add(tca);
                }
            }
        }
        //Denmotes if the tax code was found
		for(SVMXC__Service_Order_Line__c line :lines){
            if(String.isBlank(line.Tax_Code__c)){
                Boolean tcFound = false;
                String lineType = line.SVMXC__Line_Type__c;
                String activityType = line.SVMXC__Activity_Type__c;
                
                if(String.isNotBlank(segment)){
                    if(segmentMap.containsKey(segment)){
                        for(Tax_Code_Associations__c tc :segmentMap.get(segment)){
                            Boolean match = true;
                            if(String.isNotBlank(tc.Order_Type__c)){
                                List<String> oTypes = tc.Order_Type__c.split(';');
                                Boolean isOT = false;
                                for(String ot :oTypes){
                                    if(ot == orderType){
                                        isOT = true;
                                        break;
                                    }
                                }
                                if(!isOT)
                                    match = false;
                            }
                            if(String.isNotBlank(tc.Line_Type__c)){
                                if(lineType != tc.Line_Type__c)
                                    match = false;
                            }
                            if(String.isNotBlank(tc.Activity_Type__c)){
                                if(activityType != tc.Activity_Type__c)
                                    match = false;
                            }
                            if(match){
                                line.Tax_Code__c = tc.Tax_Code__c;
                                tcFound = true;
                                break;
                                //System.debug('================= matched tax code: ' + tc);
                            }
                        }
                    }
                }
                //If the tax code wasn't found at Segment level... check rules at the Line Type level
                if(!tcFound){
                    if(String.isNotBlank(orderType)){
                        if(ordTypeMap.containsKey(orderType)){
                            for(Tax_Code_Associations__c tc :ordTypeMap.get(orderType)){
                                Boolean match = true;
                                if(String.isNotBlank(tc.Line_Type__c)){
                                    if(lineType != tc.Line_Type__c)
                                        match = false;
                                }
                                if(String.isNotBlank(tc.Activity_Type__c)){
                                    if(activityType != tc.Activity_Type__c)
                                        match = false;
                                }
                                if(match){
                                    line.Tax_Code__c = tc.Tax_Code__c;
                                    tcFound = true;
                                    break;
                                    System.debug('================= matched tax code: ' + tc);
                                }
                            }
                        }
                    }
                }
                //If the tax code wasn't found at Order Type level... check rules at the Line Type level
                if(!tcFound){
                    if(String.isNotBlank(lineType)){
                        if(lineTypeMap.containsKey(lineType)){
                            for(Tax_Code_Associations__c tc :lineTypeMap.get(lineType)){
                                Boolean match = true;
                                if(String.isNotBlank(tc.Activity_Type__c)){
                                    if(activityType != tc.Activity_Type__c)
                                        match = false;
                                }
                                if(match){
                                    line.Tax_Code__c = tc.Tax_Code__c;
                                    tcFound = true;
                                    break;
                                    System.debug('================= matched tax code: ' + tc);
                                }
                            }
                        }
                    }
                }
                //If the tax code wasn't found at Line Type level... check rules at the Activity Type level
                if(!tcFound){
                    if(String.isNotBlank(activityType)){
                        if(actTypeMap.containsKey(activityType)){
                            for(Tax_Code_Associations__c tc :actTypeMap.get(activityType)){
                                line.Tax_Code__c = tc.Tax_Code__c;
                                tcFound = true;
                                break;
                                System.debug('================= matched tax code: ' + tc);
                            }
                        }
                    }
                }
            }
        }
        
        return lines;
    }

}