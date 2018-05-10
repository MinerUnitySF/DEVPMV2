public class UNITYPM_CaseTriggerHandler_Miner extends UNITY_BaseHandler{

    private static Set<Id> PMCaseSet = new Set<Id>{UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
                                    UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE};
    public static List<SObject> new_PM_Cases1 = UNITY_Utils.includeRecordType(trigger.new, PMCaseSet );
    public static Map<Id, SObject> oldMap_PM_Cases1 = UNITY_Utils.includeRecordType(Trigger.oldMap, PMCaseSet );
    public static Map<Id, SObject> newMap_PM_Cases1 = UNITY_Utils.includeRecordType(Trigger.newMap, PMCaseSet );
	public Set<Id> caseIdsToFireAR = new Set<Id>();
    
    private List<Case> casesToSetSC = new List<Case>(); 
    public static Map<String, Id> businessUnitAccountMap = new Map<String, Id>();

    public override void bulkBefore(List<SObject> new_PM_Cases, List<SObject> old_PM_Cases, Map<Id,SObject> oldMap_PM_Cases, Map<Id,SObject> newMap_PM_Cases){
        System.debug('//Clay this is the standard UNITYPM bulkBefore');
        setBusinessUnitAccountMap();

        if(trigger.isInsert){
            system.debug('@@@UNITYPM_CaseTriggerHandler_Miner bulkbefore Insert:'+new_PM_Cases);
            for (SObject obj : new_PM_Cases){
                Case c = (Case)obj;
                if (c.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
	               	c.UNITY_Customer__c = c.AccountId;     
           			casesToSetSC.add(c);
                }
                if (c.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
                    c.AccountId = c.UNITY_Customer__c;
                }
            }
        }
        if (trigger.isUpdate){
            //Check if account is being updated
            for (SObject obj : new_PM_Cases){
                Case newCase = (Case)obj;
                Case oldCase = (Case)oldMap_PM_Cases.get(newCase.Id);

                if (newCase.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE && newCase.AccountId != oldCase.AccountId){
                    casesToSetSC.add(newCase);
                }                   
        	}
        }
    }

    public override void beforeInsert(SObject so){
    	Case currentCase = (Case)so;
        
        if (currentCase.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE){

        }
        else if (currentCase.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
            setBusinessUnitAccount(currentCase);
        }
    }
    
    public override void afterInsert(SObject so){
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterInsert:'+so);        
    	Case currentCase = (Case)so;

        if (currentCase.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
            
            //Update the Program Case count of child PM cases
            if (currentCase.ParentId != null)
                updateParentTotalPMCases(currentCase);
            if (currentCase.UNITY_Fire_Assignment_Rule__c == true)
            	caseIdsToFireAR.add(currentCase.id);
        }
        
    }
    
    
    public override void beforeUpdate(SObject oldSo, SObject so){
        //UNITYPM check for record type
        Case currentCase = (Case)so;
        Case oldCase = (Case)oldSo;
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner beforeUpdate currentCase:'+currentCase);      
        system.debug('@@@UNITYPM_CaseTriggerHandler_Miner beforeUpdate oldCase:'+oldCase);      
        system.debug('@@@UNITYPM_CaseTriggerHandler_Miner beforeUpdate currentCase.UNITY_Customer__c:'+currentCase.UNITY_Customer__c);      
        system.debug('@@@UNITYPM_CaseTriggerHandler_Miner beforeUpdate oldCase.UNITY_Customer__c:'+oldCase.UNITY_Customer__c);      
        
        
        if (currentCase.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
		    if (currentCase.UNITY_Customer_Service_Contract__c == null || (currentCase.UNITY_Customer__c != oldCase.UNITY_Customer__c)){
	            casesToSetSC.add(currentCase);
    	    }
            
            if (currentCase.AccountId != oldCase.AccountId)
                currentCase.UNITY_Customer__c = currentCase.AccountId;
        }
        else if (currentCase.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
        }
        
    }
    
    public override void afterUpdate(SObject oldSo, SObject so){
        //UNITYPM check for record type
        Case currentCase = (Case)so;
        Case oldCase = (Case)oldSo;
        
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate currentCase:'+currentCase);      
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate oldCase:'+oldCase);              
        system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate currentCase.UNITY_Customer__c:'+currentCase.UNITY_Customer__c);      
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate oldCase.UNITY_Customer__c:'+oldCase.UNITY_Customer__c);              
        
        if (currentCase.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE){
            system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate - this is a PM Case'); 
            if (oldCase.RecordTypeId != UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE)
                casesToSetSC.add(currentCase);

            //Update Program Case total of children PM cases:
            if (currentCase.ParentId != null){
                if (currentCase.Status == 'Cancelled' && currentCase.Status != oldCase.Status ){
                    system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate - this is a PM Case - Status set to Cancelled'); 
                    updateParentTotalPMCases(currentCase);
                }
                Case parentCase = [SELECT RecordTypeId FROM Case WHERE Id = :currentCase.ParentId];
            ///////////////////////////////////////////////////////////
            //If Case has parent case and status is Verified - Create the WO.
                if (currentCase.Status == 'Verified' && currentCase.Status != oldCase.Status && currentCase.ParentId != null 
                    && parentCase.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
                    //Check if there is an existing WO
                    system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate - this is a PM Case - Status set to Verified'); 
                    	List<WorkOrder> wos = [SELECT Id FROM WorkOrder WHERE CaseId = :currentCase.Id AND Status != 'Canceled'];
    					if (wos == null || wos.size() == 0){
                    		createWo(currentCase);
    					}
                    }

            }

			  //if important fields change on case - change them on work order as well
            if (oldCase.AccountId != currentCase.AccountId 
                || oldCase.UNITY_Customer__c != currentCase.UNITY_Customer__c
            	|| oldCase.UNITY_Customer_Service_Contract__c != currentCase.UNITY_Customer_Service_Contract__c
            	|| oldCase.UNITY_Skill_Broad__c != currentCase.UNITY_Skill_Broad__c
            	|| oldCase.UNITY_Skill_Group__c != currentCase.UNITY_Skill_Group__c
            	|| oldCase.UNITY_Skill_Type__c != currentCase.UNITY_Skill_Type__c
            	|| oldCase.UNITY_Trade__c != currentCase.UNITY_Trade__c
            	|| oldCase.UNITY_Work_Window_Begin__c != currentCase.UNITY_Work_Window_Begin__c
            	|| oldCase.UNITY_Work_Window_End__c != currentCase.UNITY_Work_Window_End__c
                || oldCase.ParentId != currentCase.ParentId
            	|| oldCase.UNITY_Business_Unit__c != currentCase.UNITY_Business_Unit__c
            	|| oldCase.UNITY_Business_Unit_Account__c != currentCase.UNITY_Business_Unit_Account__c){
                system.debug('@@@UNITYPM_CaseTriggerHandler_Miner afterUpdate - this is a PM Case - Other field modified, need to updat WO'); 
                List<WorkOrder> wos = [SELECT Id FROM WorkOrder WHERE CaseId = :currentCase.Id AND Status != 'Canceled'];
                if (wos != null && wos.size() > 0)
                	updateWo(currentCase, oldCase, wos[0]);                		
            }
        }
        /////////  
        //Clay: Make sure to fire assignment rules for PM cases
        if (currentCase.UNITY_Fire_Assignment_Rule__c == true && oldCase.UNITY_Fire_Assignment_Rule__c == false){
			caseIdsToFireAR.add(currentCase.id);
        }
        if (currentCase.UNITY_Fire_Assignment_Rule__c == true && currentCase.UNITY_Portal_Source__c == 'Service Channel')
            caseIdsToFireAR.add(currentCase.id);
    }
    
    public override void andFinally(){
        if (!casesToSetSC.isEmpty()){
            UNITYPM_CaseTriggerHandler_Miner.popoulateServiceContract(casesToSetSC);
        }
        if (!caseIdsToFireAR.isEmpty()){
            System.debug('//Clay - Calling the fireAssighmentRule method:');
            UNITY_CaseUtilities.fireAssignmentRule(caseIdsToFireAR);
        }
    }
    
    public static void createWO(Case currentCase){
        WorkOrder wo = new WorkOrder(
        	CaseId = currentCase.id,
            RecordTypeId = UNITY_Constants.WO_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
            AccountId = currentCase.AccountId,
            UNITY_Customer__c = currentCase.UNITY_Customer__c,
            UNITY_Customer_Service_Contract__c = currentCase.UNITY_Customer_Service_Contract__c,
            UNITY_Skill_Broad__c = currentCase.UNITY_Skill_Broad__c,
            UNITY_Skill_Group__c = currentCase.UNITY_Skill_Group__c,
            UNITY_Skill_Type__c = currentCase.UNITY_Skill_Type__c,
            UNITY_Trade__c = currentCase.UNITY_Trade__c,
            UNITY_Work_Window_Begin__c = currentCase.UNITY_Work_Window_Begin__c,
            UNITY_Work_Window_End__c = currentCase.UNITY_Work_Window_End__c,
            UNITY_Program_Case__c = currentCase.ParentId,
            Subject = currentCase.Subject,
            Description = currentCase.Description,
            UNITY_Business_Unit__c = currentCase.UNITY_Business_Unit__c,
            UNITY_Business_Unit_Account__c = currentCase.UNITY_Business_Unit_Account__c,
            Priority = currentCase.Priority,
            UNITY_Site_Contact_Phone__c = currentCase.UNITY_Site_Location_Contact_Phone__c
        	);
        insert WO;
    }
    
    public static void updateWO(Case currentCase, Case oldCase, WorkOrder wo){
        
        if (oldCase.AccountId != currentCase.AccountId)    
        	wo.AccountId = currentCase.AccountId;
        if (oldCase.UNITY_Customer__c != currentCase.UNITY_Customer__c)
        	wo.UNITY_Customer__c = currentCase.UNITY_Customer__c;
        if (oldCase.UNITY_Customer_Service_Contract__c != currentCase.UNITY_Customer_Service_Contract__c)
        	wo.UNITY_Customer_Service_Contract__c = currentCase.UNITY_Customer_Service_Contract__c;
		if (oldCase.UNITY_Skill_Broad__c != currentCase.UNITY_Skill_Broad__c)
        	wo.UNITY_Skill_Broad__c = currentCase.UNITY_Skill_Broad__c;
        if (oldCase.UNITY_Skill_Group__c != currentCase.UNITY_Skill_Group__c)
			wo.UNITY_Skill_Group__c = currentCase.UNITY_Skill_Group__c;
        if (oldCase.UNITY_Skill_Type__c != currentCase.UNITY_Skill_Type__c)    
        	wo.UNITY_Skill_Type__c = currentCase.UNITY_Skill_Type__c;
		if (oldCase.UNITY_Trade__c != currentCase.UNITY_Trade__c)
            wo.UNITY_Trade__c = currentCase.UNITY_Trade__c;
        if (oldCase.UNITY_Work_Window_Begin__c != currentCase.UNITY_Work_Window_Begin__c)
			wo.UNITY_Work_Window_Begin__c = currentCase.UNITY_Work_Window_Begin__c;
        if (oldCase.UNITY_Work_Window_End__c != currentCase.UNITY_Work_Window_End__c)
			wo.UNITY_Work_Window_End__c = currentCase.UNITY_Work_Window_End__c;
        if (oldCase.ParentId != currentCase.ParentId)
            wo.UNITY_Program_Case__c = currentCase.ParentId;
		if (oldCase.UNITY_Business_Unit__c != currentCase.UNITY_Business_Unit__c)		
			wo.UNITY_Business_Unit__c = currentCase.UNITY_Business_Unit__c;
        if (oldCase.UNITY_Business_Unit_Account__c != currentCase.UNITY_Business_Unit_Account__c)
			wo.UNITY_Business_Unit_Account__c = currentCase.UNITY_Business_Unit_Account__c;
        update wo;
    }
    
    public static void updateParentTotalPMCases(Case currentCase){
        
        List<Case> childCases = [SELECT Id FROM Case WHERE ParentId = :currentCase.ParentId AND Status != 'Cancelled'];
        Case parentCase = new Case(Id = currentCase.ParentId);
        parentCase.UNITYPM_Total_PM_Cases__c = childCases.size();
        update parentCase;
        
    }
    
    public static void popoulateServiceContract(List<Case> caseList){
        
        Set<Id> relatedCustomerIdSet = new Set<Id>();
        Set<Id> relatedAccountIdSet = new Set<Id>();
        Set<Id> relatedbusUnitAccountIdSet = new Set<Id>();
        
        //collect customer account
        for(Case iter: caseList){
            relatedCustomerIdSet.add(iter.UNITY_Customer__c);
            relatedAccountIdSet.add(iter.AccountId);
            relatedbusUnitAccountIdSet.add(iter.UNITY_Business_Unit_Account__c);
        }
        
        // get related customer accounts
        List<Account> relatedCustomerList = [SELECT Id, ParentId, UNITY_Bill_To_Account__c, Residential__c,
                                            
                                            (SELECT Id, UNITY_Account__c, UNITY_Business_Unit__c, UNITY_End_Customer__c, Default_Customer_Service_Contract__c, Residential__c
                                            FROM Service_Contracts__r 
                                            WHERE RecordTypeId =:UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE and UNITY_IS_Active__c = true)
                                            
                                            FROM Account WHERE id IN : relatedCustomerIdSet OR id IN : relatedbusUnitAccountIdSet];
        
        System.debug('Izay: relatedCustomerList: ' + JSON.serializePretty(relatedCustomerList));
        
        // get related accounts                                    
        Map<Id, Account> relatedAccountMap = new Map<Id, Account>( [SELECT Id, ParentId, UNITY_Bill_To_Account__c,Residential__c FROM Account WHERE id IN : relatedAccountIdSet] );

        Map<Id, List<UNITY_Service_Contract__c>> accountServiceContractMap = new Map<Id, List<UNITY_Service_Contract__c>>();
        Map<Id, List<UNITY_Service_Contract__c>> customerServiceContractMap = new Map<Id, List<UNITY_Service_Contract__c>>();
        
        Map<Id, Id> parentAccount = new Map<Id, Id>();
        Map<Id, Id> billToAccount = new Map<Id, Id>();
        
        //set the customer's service contract map
        for (Account iter: relatedCustomerList){
            
            if (iter.Service_Contracts__r != null){
                accountServiceContractMap.put(iter.Id, iter.Service_Contracts__r);
                customerServiceContractMap.put(iter.Id, iter.Service_Contracts__r);
            }
        }
        
        //set the account parent and billTo maps
        for (Account iter: relatedAccountMap.values() ){
            
            if (iter.ParentId != null){
                parentAccount.put(iter.Id, iter.ParentId);
            }
            
            if (iter.UNITY_Bill_To_Account__c != null){
                billToAccount.put(iter.Id, iter.UNITY_Bill_To_Account__c);
            }
        }
        
        //search for a contract in customer account
        for (Case iter: caseList){
            
            List<UNITY_Service_Contract__c> customerServiceContracts = accountServiceContractMap.get(iter.UNITY_Customer__c);
            
            //3rd Party Scenario
            if (iter.UNITY_Customer__c != iter.AccountId){
                setCustomerServiceContract3rdParty(iter, accountServiceContractMap.get(iter.UNITY_Customer__c), iter.AccountId);
            }
            else if (setCustomerServiceContract(iter, customerServiceContracts)){
                
                //the customer contract was populated so we stop the searching in parent and billToAccount
                parentAccount.remove(iter.AccountId);
                billToAccount.remove(iter.AccountId);
            }    
        }
        
        //search for a contract in customer parent account or customer bill to account

        List<UNITY_Service_Contract__c> serviceContractList = [select id, UNITY_Account__c, UNITY_End_Customer__c, UNITY_Business_Unit__c from UNITY_Service_Contract__c
                                                                    where RecordTypeId =:UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE 
                                                               		and UNITY_IS_Active__c = true and (UNITY_Account__c in: billToAccount.values() 
                                                                                                  		or UNITY_Account__c in: parentAccount.values())];
            
        for (UNITY_Service_Contract__c iter: serviceContractList){
        
            List<UNITY_Service_Contract__c> relatedServiceContract = accountServiceContractMap.get(iter.UNITY_Account__c);
            
            if (relatedServiceContract == null){
                relatedServiceContract = new List<UNITY_Service_Contract__c>();
            }
            
            relatedServiceContract.add(iter);
            
            accountServiceContractMap.put(iter.UNITY_Account__c, relatedServiceContract);
        }
            
        for (Case iter: caseList){
            
            if (iter.UNITY_Customer_Service_Contract__c == null){
                
                Boolean serviceContractPopulated = false;
                
                Id parentAccountId = parentAccount.get(iter.AccountId);
                Id billToAccountId = billToAccount.get(iter.AccountId);
                
                //3rd Party Scenario
                if (iter.UNITY_Customer__c != iter.AccountId){
                    //End Customer = parentAccount
                    serviceContractPopulated = setCustomerServiceContract3rdParty(iter, customerServiceContractMap.get(iter.UNITY_Customer__c), parentAccountId);
                    if (!serviceContractPopulated){
                        //End Customer = billToAccountId
                        serviceContractPopulated = setCustomerServiceContract3rdParty(iter, customerServiceContractMap.get(iter.UNITY_Customer__c), billToAccountId);
                    }
                    if (!serviceContractPopulated){
                        //End Customer = null
                        setCustomerServiceContract3rdParty(iter, customerServiceContractMap.get(iter.UNITY_Customer__c), null);
                    }
                }
                else{
                    //search in parent customer account
                    if (parentAccountId != null){
                        serviceContractPopulated = setCustomerServiceContract(iter, accountServiceContractMap.get(parentAccountId));
                    }
                    
                    //search in billToAccount
                    if (billToAccountId != null && !serviceContractPopulated){
                        serviceContractPopulated = setCustomerServiceContract(iter, accountServiceContractMap.get(billToAccountId));
                    }
                }
				System.debug('Izay: serviceContractPopulated = '+serviceContractPopulated);
                System.debug('Izay: iter.UNITY_Business_Unit_Account__c = ' + iter.UNITY_Business_Unit_Account__c);
                System.debug('Izay: accountServiceContractMap.containsKey( iter.UNITY_Business_Unit_Account__c) = ' + accountServiceContractMap.containsKey( iter.UNITY_Business_Unit_Account__c));
                if ( !serviceContractPopulated && iter.UNITY_Business_Unit_Account__c != null && accountServiceContractMap.containsKey( iter.UNITY_Business_Unit_Account__c) ) {
                    System.debug('Izay: no sc, bu not null, and sc in map');
                    if ( iter.AccountId != null && relatedAccountMap.containsKey(iter.AccountId) && relatedAccountMap.get(iter.AccountId).Residential__c  ) {
                        System.debug('Izay: acctid != null, map contains acctid, and residential');
                        serviceContractPopulated = setCustomerServiceToBusinessUnitDefault(iter, accountServiceContractMap.get( iter.UNITY_Business_Unit_Account__c ), true );
                    }
                    if ( !serviceContractPopulated ) 
                        serviceContractPopulated = setCustomerServiceToBusinessUnitDefault( iter, accountServiceContractMap.get( iter.UNITY_Business_Unit_Account__c ), false );
                    //If there is still no SC
                    if ( !serviceContractPopulated ){
                        iter.addError('Customer should have an active Preventative Maintenance service contract.');
                    }
                }
            }
        }
    }
    
    public static Boolean setCustomerServiceContract3rdParty(Case caseRecord, List<UNITY_Service_Contract__c> serviceContractList, Id endCustomer){
        
        if (serviceContractList != null){
            
            for(UNITY_Service_Contract__c serviceContract : serviceContractList){
                
                if(serviceContract.UNITY_Business_Unit__c!=null){
                    
                    Set<String> delimitedBusinessUnit = new Set<String>(serviceContract.UNITY_Business_Unit__c.split(';'));
                    
                    System.debug('#serviceContract.UNITY_End_Customer__c '+serviceContract.UNITY_End_Customer__c);
                    System.debug('#endCustomer '+endCustomer);
                    
                    if(delimitedBusinessUnit.contains(caseRecord.UNITY_Business_Unit__c) && serviceContract.UNITY_End_Customer__c == endCustomer){
                        
                        caseRecord.UNITY_Customer_Service_Contract__c = serviceContract.Id;
                        
                        return true;
                        
                        break;
                    }        
                }
            }
            
            return false;                         
        }
        return false; 
    }
    
    public static Boolean setCustomerServiceContract(Case caseRecord, List<UNITY_Service_Contract__c> serviceContractList){
        
        if(serviceContractList != null){
                
            for(UNITY_Service_Contract__c serviceContract : serviceContractList){
                
                if(serviceContract.UNITY_Business_Unit__c!=null){
                    
                    Set<String> delimitedBusinessUnit = new Set<String>(serviceContract.UNITY_Business_Unit__c.split(';'));
                    
                    if(delimitedBusinessUnit.contains(caseRecord.UNITY_Business_Unit__c)){
                        
                        caseRecord.UNITY_Customer_Service_Contract__c = serviceContract.Id;
                        
                        return true;
                        
                        break;
                    }        
                }
            }
            
            return false;           
        }
        
        return false; 
    }
    
    private static Boolean setCustomerServiceToBusinessUnitDefault(Case caseRecord, List<UNITY_Service_Contract__c> serviceContractList, Boolean isResidential){
        System.debug('Izay: in setCustomerServiceToBusinessUnitDefault()');
        if ( serviceContractList != null ) {
            for (UNITY_Service_Contract__c serviceContract : serviceContractList) {
                if ( serviceContract.Default_Customer_Service_Contract__c && serviceContract.Residential__c == isResidential) {
                    caseRecord.UNITY_Customer_Service_Contract__c = serviceContract.Id;
                    return true;
                }
            }       
        }
        return false; 
    }

    /* Name  : setBusinessUnitAccountMap
     * Note  : populate map < BU picklist , BU account > , remember BU accounts are Miner Record Type */
    
	public static void setBusinessUnitAccountMap(){
        System.debug('>>> setBusinessUnitAccountMap()');
        List<String> relatedBusinessUnit = new List<String>();
        
        if (Trigger.isInsert){
            System.debug('>>> Insert');
            for (SObject iter: new_PM_Cases1){
                Case newCase = (Case)iter;
                System.debug('>>> case.UNITY_Business_Unit__c '+newCase.UNITY_Business_Unit__c);
                if (newCase.UNITY_Business_Unit__c != null && newCase.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
                    relatedBusinessUnit.add(((Case)iter).UNITY_Business_Unit__c);
                }
            }
        }else if (Trigger.isUpdate){
            System.debug('>>> Update '+relatedBusinessUnit);
            for (SObject iter: new_PM_Cases1){
                if (oldMap_PM_Cases1 == null)
                    continue;
                Case newCase = (Case)iter;
                Case oldCase = (Case)oldMap_PM_Cases1.get(iter.id);
                if((newCase.UNITY_Business_Unit__c != null)&&(newCase.UNITY_Business_Unit__c != oldCase.UNITY_Business_Unit__c) 
                   && newCase.RecordTypeId == UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE){
                    relatedBusinessUnit.add(((Case)iter).UNITY_Business_Unit__c);
                }
            }
        }
        
        System.debug('>>> relatedBusinessUnit '+relatedBusinessUnit);
        
        if(!relatedBusinessUnit.isEmpty()) {
            for (Account iter: [select Id, UNITY_Business_Unit__c from Account where UNITY_Business_Unit__c in:relatedBusinessUnit and RecordTypeId =: UNITY_Constants.ACCOUNT_MINER_RECORDTYPE]){
                businessUnitAccountMap.put(iter.UNITY_Business_Unit__c, iter.Id);
            }
            System.debug('CLAY: bu account map: ');
            System.debug(businessUnitAccountMap);
        }
        /*
        if (trigger.isUpdate){
            if (newMap_SR_Cases != null){
                List<WorkOrder> workOrderList = [select id, UNITY_Business_Unit_Account__c, CaseId from WorkOrder where CaseId in :newMap_PM_Cases.keyset()];
                
                for (WorkOrder iter: workOrderList){
                    Case oldCase = (Case)oldMap_PM_Cases.get(iter.CaseId);
                    Case newCase = (Case)newMap_PM_Cases.get(iter.CaseId);
                    // samuel update , add WO from cases If the UNITY_Business_Unit_Account__c has changed on the Case record
                    if(oldCase.UNITY_Business_Unit__c != newCase.UNITY_Business_Unit__c ){
                        if (caseWorkOrderMap.get(iter.CaseId) == null){
                            caseWorkOrderMap.put(iter.CaseId, new List<WorkOrder>());
                        }
                        caseWorkOrderMap.get(iter.CaseId).add(iter);
                    }
                }
            }
        }*/        
    }
   

    /* Name  : setBusinessUnitAccount
     * Param : Case				*/
	public static void setBusinessUnitAccount(Case currentCase){
        System.debug('CLAY: This is the setBusinessUnitAccount method. Our case BU:');
        System.debug(currentCase.UNITY_Business_Unit__c);
        boolean should_update_BU_account = false;
        if(Trigger.isInsert) should_update_BU_account = true;
        if(Trigger.isUpdate && oldMap_PM_Cases1 != null && oldMap_PM_Cases1.size() > 0 && (currentCase.UNITY_Business_Unit__c!=((Case)oldMap_PM_Cases1.get(currentCase.id)).UNITY_Business_Unit__c)) 
            should_update_BU_account = true;

        System.debug('Should we update the BU account? : ' + should_update_BU_account);
        System.debug('#currentCase '+currentCase.UNITY_Business_Unit_Account__c);
        System.debug('#businessUnitAccountMap '+businessUnitAccountMap);
        
        if(should_update_BU_account){
            if ((currentCase.UNITY_Business_Unit__c != null) && (currentCase.UNITY_Business_Unit__c != '') && (businessUnitAccountMap.get(currentCase.UNITY_Business_Unit__c) != null)){
                currentCase.UNITY_Business_Unit_Account__c = businessUnitAccountMap.get(currentCase.UNITY_Business_Unit__c);
            }else{
                currentCase.UNITY_Business_Unit_Account__c = null;
            }
        }
    }

    /*
    public void setBusinessUnitAccontUnitInWorkOrder(Case currentCase){
        
        if (caseWorkOrderMap.get(currentCase.Id) != null){
            
            for (WorkOrder iter: caseWorkOrderMap.get(currentCase.Id)){
                
                iter.UNITY_Business_Unit_Account__c = businessUnitAccountMap.get(currentCase.UNITY_Business_Unit__c);
                iter.UNITY_Business_Unit__c  = currentCase.UNITY_Business_Unit__c;
                if(!this.checkDupesWOToUpdate.contains(iter.id)){
                    workOrderToUpdate.add(iter);
                    this.checkDupesWOToUpdate.add(iter.id);
                }
            }
        }
    }*/
}