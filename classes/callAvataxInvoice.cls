public with sharing class callAvataxInvoice {

	public List<MH_Invoice_Details__c> invlist;
	public String oname {get;set;}
	public String otype {get;set;}
	public String tcode {get;set;}
	public Integer x {get;set;}
	public Integer y {get;set;}
	public String invid;
	public String SampleResult {get;set;}
	public Boolean error1 {get;set;}
	public Boolean showconf {get;set;}
	
	public callAvataxInvoice(){
		
	}
    
	public callAvataxInvoice(ApexPages.StandardController controller){
		
	}
    
	public pageReference call(){
		
		invid = ApexPages.CurrentPage().getParameters().get('id');
		showconf = true;
		
		List<Key_Value_Store__c> kvslist = new List<Key_Value_Store__c>();
		kvslist = [SELECT Id, Name, Value__c FROM Key_Value_Store__c];
		
		List<Default_Invoice_Status__c> statuslist = new List<Default_Invoice_Status__c>();
		statuslist = [SELECT Id, Name, Status__c FROM Default_Invoice_Status__c];
		Map<String, String> statusmap = new Map<String, String>();
		for (Default_Invoice_Status__c index : statuslist)
			statusmap.put(index.Name.toLowerCase(), index.Status__c);
		
		String user = null;
		String pass = null;
		for(Key_Value_Store__c kvsindex : kvslist){
			if (kvsindex.Name.toLowerCase() == 'avatax account id')
				user = kvsindex.Value__c;
			if (kvsindex.Name.toLowerCase() == 'avatax license key')
				pass = kvsindex.Value__c;
		}
		
		MH_Invoice__c inv = [SELECT Id, Name, Work_Order__r.SVMXC__Group_Member__c, Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.Company_Code__c, Certificate__c, Date_Invoiced__c,
		          			 Work_Order__r.SVMXC__Service_Group__c, Work_Order__r.SVMXC__Service_Group__r.Company_Code__c, Work_Order__c, Work_Order__r.SVMXC__Company__c, Work_Order__r.SVMXC__Company__r.MH_SL_CustID__c,
		          			 Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__c, Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c, Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__City__c,
		          			 Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__State__c, Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Zip__c, Work_Order__r.SVMXC__Service_Group__r.SVMXC__Street__c,
		          			 Work_Order__r.SVMXC__Service_Group__r.SVMXC__City__c, Work_Order__r.SVMXC__Service_Group__r.SVMXC__State__c, Work_Order__r.SVMXC__Service_Group__r.SVMXC__Zip__c, Work_Order__r.Location__c,
		          			 Work_Order__r.Location__r.SVMXC__Street__c, Work_Order__r.Location__r.SVMXC__City__c, Work_Order__r.Location__r.SVMXC__State__c, Work_Order__r.Location__r.SVMXC__Zip__c, Work_Order__r.Business_Unit__c,
                             Work_Order__r.Segment__r.Segment_Name__c, Work_Order__r.SVMXC__Order_Type__c FROM MH_Invoice__c WHERE Id =: invid];
		
		invlist = new List<MH_Invoice_Details__c>();
		invlist = [SELECT Id, Name, Total_Line_Price__c, Line_Qty__c, Sales_Tax__c, Activity_Type__c, Line_Type__c,Work_Detail__c,Work_Detail__r.Tax_Code__c  FROM MH_Invoice_Details__c WHERE Invoice__c =: inv.Id];
		
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
		if(String.isNotBlank(inv.Work_Order__c)){
			if(String.IsNotBlank(inv.Work_Order__r.SVMXC__Group_Member__c)){
				if(inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__c != null)
					gtreq.CompanyCode = inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.Company_Code__c;
			}else{
				if(inv.Work_Order__r.SVMXC__Service_Group__c != null)
					gtreq.CompanyCode = inv.Work_Order__r.SVMXC__Service_Group__r.Company_Code__c;
			}
		}
        if(String.isBlank(gtreq.CompanyCode ))
            error1 = true;
		
		gtreq.DocType = 'SalesInvoice';
		gtreq.DocCode = inv.Name;
        gtreq.ReferenceCode = inv.Id;
		if(inv.Work_Order__c != null){
			if(inv.Work_Order__r.SVMXC__Company__c != null)
				gtreq.CustomerCode = inv.Work_Order__r.SVMXC__Company__r.MH_SL_CustID__c;
		}
		gtreq.Discount = 0; 
		gtreq.DetailLevel = 'Tax';
		gtreq.HashCode = 0;
		gtreq.ServiceMode = 'Automatic';
		gtreq.ExchangeRate = 0;
		gtreq.ExchangeRateEffDate = date.today();
		gtreq.PaymentDate = date.today();
        gtreq.DocDate = inv.Date_Invoiced__c;
        gtreq.ExemptionNo = inv.Certificate__c;
		
		avataxAvalaraComServicesAlt.BaseAddress orgAddr = new avataxAvalaraComServicesAlt.BaseAddress();
		orgAddr.AddressCode = 'Origin';
		if(inv.Work_Order__c != null){
			if(inv.Work_Order__r.SVMXC__Group_Member__c != null){
				if(inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__c != null){
					orgAddr.Line1 = inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c;//'11827 Tech Com Dr #115';//w.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Street__c;
					orgAddr.City = inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__City__c;//'San Antonio'; //
					orgAddr.Region = inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__State__c;//'TX'; //
					orgAddr.PostalCode = inv.Work_Order__r.SVMXC__Group_Member__r.SVMXC__Service_Group__r.SVMXC__Zip__c;//'78233'; //
				}
			}else{
				if (inv.Work_Order__r.SVMXC__Service_Group__c != null){
					orgAddr.Line1 = inv.Work_Order__r.SVMXC__Service_Group__r.SVMXC__Street__c;
					orgAddr.City = inv.Work_Order__r.SVMXC__Service_Group__r.SVMXC__City__c;
					orgAddr.Region = inv.Work_Order__r.SVMXC__Service_Group__r.SVMXC__State__c;
					orgAddr.PostalCode = inv.Work_Order__r.SVMXC__Service_Group__r.SVMXC__Zip__c;
				}
			}
		}
		
		orgAddr.TaxRegionId = 0;
		avataxAvalaraComServicesAlt.BaseAddress dstAddr = new avataxAvalaraComServicesAlt.BaseAddress();
		dstAddr.AddressCode = 'Destination';
		if(String.isNotBlank(inv.Work_Order__c)){
			if(String.isNotBlank(inv.Work_Order__r.Location__c)){
				dstAddr.Line1 = inv.Work_Order__r.Location__r.SVMXC__Street__c;//'11827 Tech Com Dr #116'; 
				dstAddr.City = inv.Work_Order__r.Location__r.SVMXC__City__c;//'San Antonio'; 
				dstAddr.Region = inv.Work_Order__r.Location__r.SVMXC__State__c;//'TX'; 
				dstAddr.PostalCode = inv.Work_Order__r.Location__r.SVMXC__Zip__c;//'78233'; 
			}
		}
		dstAddr.TaxRegionId = 0;
		
		gtreq.Addresses = new avataxAvalaraComServicesAlt.ArrayOfBaseAddress();
		gtreq.Addresses.BaseAddress = new avataxAvalaraComServicesAlt.BaseAddress[2];
		
		gtreq.Addresses.BaseAddress[0] = orgAddr;
		gtreq.Addresses.BaseAddress[1] = dstAddr;
		
		gtreq.OriginCode = orgAddr.AddressCode;
		gtreq.DestinationCode = dstAddr.AddressCode;
		
		gtreq.Lines = new avataxAvalaraComServicesAlt.ArrayOfLine();
		gtreq.Lines.Line = new avataxAvalaraComServicesAlt.Line[invlist.size()];
		Integer i = 0;
		
        //Tax Code Association Rule
		x = 0;
		y = 0;
		Map<String, MH_Invoice_Details__c> detailmap = new Map<String, MH_Invoice_Details__c>();
        Map<Id,SVMXC__Service_Order_Line__c> workDetMap = new Map<Id,SVMXC__Service_Order_Line__c>();
        //Need to check if the all work detail lines have tax code associated with them
        Boolean needCode = false;
        for(MH_Invoice_Details__c line : invlist){
            if(String.isBlank(line.Work_Detail__r.Tax_Code__c)){
                needCode = true;
                break;
            }
        }
        if(needCode){
            List<SVMXC__Service_Order_Line__c> tempList = CallAvatax.getTaxCode(inv.Work_Order__c);
            for(SVMXC__Service_Order_Line__c line :tempList){
                workDetMap.put(line.Id,line);
            }
            tempList.clear();
        }
		if(!error1){
			for(MH_Invoice_Details__c invindex : invlist){
				detailmap.put(invindex.Name, invindex);
				gtreq.Lines.Line[i] = new avataxAvalaraComServicesAlt.Line();
				gtreq.Lines.Line[i].No = invindex.Name;
				gtreq.Lines.Line[i].Amount = (invindex.Total_Line_Price__c != null) ? invindex.Total_Line_Price__c : 0;
				gtreq.Lines.Line[i].Qty = (invindex.Line_Qty__c != null) ? invindex.Line_Qty__c : 0;
				gtreq.Lines.Line[i].Discounted = false;
				gtreq.Lines.Line[i].OriginCode = 'Origin';
				gtreq.Lines.Line[i].DestinationCode = 'Destination';
                gtreq.Lines.Line[i].ItemCode = invindex.Activity_Type__c;
				if(String.isBlank(invindex.Activity_Type__c)){
					y = 1;
					oname = invindex.Name;
					break;
				}
                String taxCode = '';
                if(needCode)
                    taxCode = workDetMap.get(invindex.Work_Detail__c).Tax_Code__c;
                else
                	taxCode = invindex.Work_Detail__r.Tax_Code__c;//CallAvatax.getTaxCode(inv.Work_Order__r.Segment__r.Segment_Name__c, inv.Work_Order__r.SVMXC__Order_Type__c,invindex.Activity_Type__c,invindex.Line_Type__c);
				if(String.isNotBlank(taxCode))
					gtreq.Lines.Line[i].TaxCode = taxCode;
				else{
					x = 1;
					oname = invindex.Name;
					otype = invindex.Activity_Type__c;
					break;
				}
				i++;
			}
		}
		//gtreq.DocDate = Date.Today();
		gtreq.Commit_x= true;
		
		avataxAvalaraComServicesAlt.GetTaxResult gtres = null;
		SampleResult = '';
		
		if((x == 0) && (y == 0) && (!error1)){
			try{
			     gtres = taxSvc.GetTax(gtreq);
			
			     if(gtres.ResultCode == 'Success'){
			         SampleResult = '<span class="success-result">'+gtres.ResultCode + '</span>' +
                         '<table class="message-table"><tr><th>Total Tax</th><td>' + gtres.TotalTax + '</td></tr></table>';
			         showconf = false;
			     }else{
			         SampleResult = '<span class="error-result">'+gtres.ResultCode + '</span><table class="message-table"><tr><th>Summary</th><td>' + ((gtres.Messages != null) ? gtres.Messages.Message[0].Summary : 'Not available') + '</td></tr>';
                     SampleResult += '<tr><th>Details</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].Details: 'Not available') +'</td></tr>';
                     SampleResult += '<tr><th>Refers To</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].RefersTo: 'Not available') +'</td></tr>';
                     SampleResult += '<tr><th>Source</th><td>'+ ((gtres.Messages != null) ? gtres.Messages.Message[0].Source: 'Not available') +'</td></tr>';
                     SampleResult += '</table>';
                     showconf = true;
			     }
			}catch(Exception ex){
			     SampleResult = 'GetTax Threw an Exception: ' + ex.getmessage();
			}
		}
		
		if((gtres != null)){
			//gtres.TaxLines = new avataxavalaraComServicesAlt.ArrayOfTaxLine();
			//gtres.TaxLines.TaxLine = new avataxavalaraComServicesAlt.TaxLine();
			if((gtres.TaxLines != null)){
				if((gtres.TaxLines.TaxLine != null)){
					if(String.isNotBlank(inv.Work_Order__c)){
						if(!showconf){
							if((String.isBlank(inv.Work_Order__r.Business_Unit__c)) || (!statusmap.containsKey(inv.Work_Order__r.Business_Unit__c.toLowerCase()))){
								SampleResult = 'There is no invoice status set for the business unit, please select the appropriate invoice status';
								showconf = true;
							}else
								inv.Status__c = statusmap.get(inv.Work_Order__r.Business_Unit__c.toLowerCase());
						}else{
							if((String.isBlank(inv.Work_Order__r.Business_Unit__c)) || ((!statusmap.containsKey((inv.Work_Order__r.Business_Unit__c + '-Error').toLowerCase())) && (!statusmap.containsKey((inv.Work_Order__r.Business_Unit__c + ' - Error').toLowerCase()))))
								inv.Status__c = 'Error';
							else{
								if(statusmap.containsKey((inv.Work_Order__r.Business_Unit__c + '-Error').toLowerCase()))
									inv.Status__c = statusmap.get((inv.Work_Order__r.Business_Unit__c + '-Error').toLowerCase());
								if(statusmap.containsKey((inv.Work_Order__r.Business_Unit__c + ' - Error').toLowerCase()))
									inv.Status__c = statusmap.get((inv.Work_Order__r.Business_Unit__c + ' - Error').toLowerCase());
							}
						}
					}
					List<MH_Invoice_Details__c> detaillist = new List<MH_Invoice_Details__c>();
                    for(avataxavalaraComServicesAlt.TaxLine tl : gtres.TaxLines.TaxLine){
                        if(detailmap.containsKey(tl.No)){
                            detailmap.get(tl.No).Sales_Tax__c = tl.Tax;
                            detaillist.add(detailmap.get(tl.No));
                        }
                    }
					update detaillist;
                    update inv;
                    if(needCode)
                        update workDetMap.values();
				}
			}
		}
		if(!showconf){
			PageReference page = new PageReference('/' + invid);
	        page.setRedirect(true);
	        return page;
		}
		return null;
	}
	
	public pageReference Save(){
		
		if ((tcode != null) && (tcode != '')){
			Tax_Code_Associations__c t = new Tax_Code_Associations__c (Activity_Type__c = otype, Tax_Code__c = tcode);
			insert t;
		}
		else{
			 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a tax code.'));
             return null;
		}
		pageReference pr = new pageReference('/' + invid);
		return pr;
		
	}
	
	public pageReference Cancel(){
		
		pageReference pr = new pageReference('/' + invid);
		return pr;
		
	}
	
}