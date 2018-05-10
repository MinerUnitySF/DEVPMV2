public with sharing class UNITY_CaseHandler implements UNITY_ITrigger {
    
    private static Map<String,id> mapAccounts = new Map<String,id>();
    
    private Map< id, id> recordIdTemplateId = new Map< id, id>();
    private List<Case> caseWithTemplate;
    
    private List<Id> scCaseIdStatusChangedList = new List<Id>();
    private List<Id> scCaseIdNewCommentList = new List<Id>();
    
    private Map< id, SObject > parentCases;

    private Map<Id,Account>caseIdAccountMapForUpdateCaseOwner = new Map<Id,Account>();
    private Map<Id,Account>idAccountMapForUpdateCaseOwner;
    private Map<String,Id>nameQueueIdMap = new Map<String,Id>();

    private Set< id > needParentData = new Set< id >();
    
    // key   : BU String 
    // value : BU Account Id 
    public static Map<String, Id> businessUnitAccountMap = new Map<String, Id>();
    
    public static Map<Id, List<WorkOrder>> caseWorkOrderMap = new Map<Id, List<WorkOrder>>();
    
    private List<WorkOrder> workOrderToUpdate = new List<WorkOrder>();
    
    private Map<Id,UNITY_Service_Contract__c> caseCustomerSCMap = new Map<Id,UNITY_Service_Contract__c>();
    
    private Set<id> checkDupesWOToUpdate = new Set<id>();

    private Set<id> closedCases = new Set<id>();
    
    private Map<Id, Id> parentAccountMap = new Map<Id, Id>();
    
    private List<Case> casesToSetSC = new List<Case>();

    private Set<Id> caseIdsToFireAR = new Set<Id>();
    
    private static Set<Id> excludeRTSet = new Set<Id>{UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
								       UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE};
    public static List<SObject> newList_Case1 = UNITY_Utils.excludeRecordType(trigger.new, excludeRTSet);
    public static Map<Id, SObject> oldMap_Case1 = UNITY_Utils.excludeRecordType(Trigger.oldMap, excludeRTSet);
    public static Map<Id, SObject> newMap_Case1 = UNITY_Utils.excludeRecordType(Trigger.newMap, excludeRTSet);
    
    public void bulkBefore(){}
    public void bulkAfter(){}
    public void bulkBefore(List<SObject> newList_Case, List<SObject> oldList_Case, Map<Id,SObject> oldMap_Case, Map<Id,SObject> newMap_Case){
        System.debug('//Clay - inside the standard bulkBefore :( ');
        Set<String> locSet            = new Set<String>();
        Set<String> subscriberIDSet   = new Set<String>();
        // capture parent case
        Set<String> captureParentCase = new Set<String>();
        
        // set businessUnitAccountMap 
        setBusinessUnitAccountMap();

        //setCaseCustomerSCMap();

        if (Trigger.isInsert){
            setAccountIfNull();
            UNITY_AutopopulateChildController.autopopulateFieldsIfApplicableBulkified(newList_Case, 'Case');
        }
        
        if (Trigger.isUpdate){
            Map<Id,Case> oldMap = new Map<Id, Case>();
            for (SObject so: oldMap_Case.values()){
                Case c = (Case)so;
                oldMap.put(c.id, c);
            }
                
            setCaseIdAccountMapForUpdateCaseOwner(oldMap,(List<Case>)newList_Case);
            //if (nameQueueIdMap == NULL) 
            setNameQueueIdMap();
        }
        
        Case currentCase;
        // Collecting sets of UNITY_LOC attribute and UNITY_Subscriber_ID value from Case.
        for(SObject currentObject : newList_Case) {
            currentCase = (Case) currentObject;
                
            // capture parent case 
            if( (currentCase.ParentId != null) && (currentCase.RecordTypeId  == UNITY_Constants.CASE_PROJECT_PHASE_RECORDTYPE) ){
               captureParentCase.add(currentCase.ParentId); 
               needParentData.add(currentCase.id);
            }
            
            // both attributes should not be both nulls.
            if(currentCase.UNITY_LOC__c != NULL && currentCase.UNITY_Subscriber_ID__c != NULL) {
                locSet.add(currentCase.UNITY_LOC__c);
                subscriberIDSet.add(currentCase.UNITY_Subscriber_ID__c);
            }
        }
        
        
        Account currentAccount;
        // list of accounts with acceptance criteria when UNITY_LOC and UNITY_Subscriber_ID are each one
        // in its corresponding set.
        if(!subscriberIDSet.isEmpty()) {
            //System.debug('==========CLAY: our subscriberIDSet : ' + subscriberIDSet.size());
            //System.debug('==========CLAY: ' + subscriberIDSet);
            //System.debug('==========CLAY: the locSet: ' + locSet.size());
            //System.debug('==========CLAY: ' + locSet);
            //WHY do we query for an SObject with an Account query?            
            for(SObject currentObject :[SELECT id, UNITY_LOC__c, UNITY_Subscriber_ID__c
                                            FROM Account 
                                            WHERE UNITY_LOC__c IN :locSet AND
                                                  UNITY_Subscriber_ID__c IN :subscriberIDSet]){ 
                currentAccount = (Account) currentObject;
                
                // use a combined key, joining UNITY_LOC and UNITY_Subscriber_ID                                          
                mapAccounts.put(currentAccount.UNITY_LOC__c + currentAccount.UNITY_Subscriber_ID__c, currentAccount.id);
            }
            //if(mapAccounts.size() > 0)
                //System.debug('CLAY: We just built a map of accounts using the LOC and subscriber as a key:' + mapAccounts);
        }
        
        if( captureParentCase.size() > 0 ){
            String query =  'SELECT id, '+UNITY_Utils.getQueryFields(UNITY_Constants.CASE_CAPTURE_PARENT_FIELDS)+' FROM Case WHERE id IN :captureParentCase';
            parentCases  =  new Map< id, SObject  >(Database.query(query));
        }
    }

    public void bulkAfter(List<SObject> newList_Case, List<SObject> oldList_Case, Map<Id,SObject> oldMap_Case, Map<Id,SObject> newMap_Case){
        system.debug('>>>>>> CASE HANDLER  BEFORE Limits.getQueries() '+Limits.getQueries());
        if (Trigger.isUpdate || Trigger.isInsert){
            applyTemplates();
        }
    }
    
    public void beforeInsert(SObject so){
        
        //UNITYPM check for record type
        Case currentCase = (Case) so;
        
        if (currentCase.Origin.contains('Email')){
            if(Currentcase.UNITY_Customer__c == null ) Currentcase.UNITY_Customer__c = CurrentCase.AccountId;
																														   
        }
        
		
		  
																			
								
													
													   
																						
			 
									
																				  
				  
																			   
			 
		 
		  
		
        casesToSetSC.add((Case)so);
        System.debug('~~~Clay: The case subject coming across before we insert = ' + currentCase.Subject);

        populateCustomer(currentCase);
        //CLAY: 
        setBusinessUnitAccount(currentCase);
        // check if we need to set data from the parent Case
        if(needParentData.contains(currentCase.Id)){
            
            for(String field :UNITY_Constants.CASE_CAPTURE_PARENT_FIELDS ){
                 currentCase.put(field,parentCases.get(currentCase.ParentId).get(field) );
            } 
        }
			
											  
				 
																						
																																		  


							  
																									   
																 
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        System.Debug('>>> beforeUpdate');

        //UNITYPM check for record type
        Case currentCase = (Case)so;
        Case oldCase = (Case) oldSo;
        
        //System.debug('CLAY: Before update: '+JSON.serializePretty(currentCase));

        System.Debug('>>> CurrentBU'+currentCase.UNITY_Business_Unit__c);
        System.Debug('>>> OldCaseBU'+oldCase.UNITY_Business_Unit__c);

				 
		  
			
																			   
																					 
							
											 
																														   

		 
		  

        // 6/9/2016 Refactor updateCaseOwner Trigger Contdition
        if(((String)currentCase.OwnerId).startsWith('00G') && currentCase.UNITY_Business_Unit__c != NULL && ((oldCase.OwnerId != currentCase.OwnerID) || (oldCase.UNITY_Business_Unit__c != currentCase.UNITY_Business_Unit__c)))
        {
            if (caseIdAccountMapForUpdateCaseOwner != NULL && !caseIdAccountMapForUpdateCaseOwner.isEmpty() && 
                nameQueueIdMap != NULL && !nameQueueIdMap.isEmpty() )
                updateCaseOwner(oldCase,currentCase,caseIdAccountMapForUpdateCaseOwner.get(currentCase.id));
        }

        if (currentCase.UNITY_Customer_Service_Contract__c == null || (currentCase.UNITY_Customer__c != oldCase.UNITY_Customer__c)){
            casesToSetSC.add((Case)currentCase);
        }
        

		  
																													  
		
																			
								
													
													   
																						
			 
									
																				  
				  
																			   
			 
		 

				 
			
													
																													
															   
																										   
															 
																													   
																								   
																					   
									  
							 
						   
					 

				 
			 
							
									 
		   
			 
        // -- need to do it in the update too for email to case flow (busniess unit is set after the case is inserted)
        setBusinessUnitAccount(currentCase);
															
			 
    }
    
    public void beforeDelete(SObject so){}
    
    public void afterInsert(SObject  so){
        //UNITYPM check for record type
        Case currentCase = (Case)so;
        
        // collection sc case service request with status changed
        if(currentCase.RecordTypeId == UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE &&
           currentCase.UNITY_Portal_Source__c == UNITY_Constants.CASE_PORTAL_SOURCE_SERVICE_CHANNEL){
               //Only cases with service channel portal source and service requets type.
               
               //need to fire assignment rule on this SC case. why are we only doing this on update right now?
               //if this case is a service channel, we are going to add it to the set of Ids going to run the assignment rule method
               caseIdsToFireAR.add(currentCase.Id);
               System.debug('--CLAY: We inserted a service channel case with status: ' + currentCase.UNITY_Service_Channel_Status__c);
               //filtering out cases that are 'OPEN'. This will prevent the auto callout on creation. WHY even do this?
               if(currentCase.UNITY_Service_Channel_Status__c  != null && currentCase.Unity_Service_Channel_Status__c != 'OPEN') {
                   scCaseIdStatusChangedList.add(currentCase.Id);
                   System.debug('==========CLAY: We just added this case to a list of SCCaseIdStatusChanged because this status is: ' + currentCase.UNITY_Service_Channel_Status__c);
               }
															 
																																 
																
				  
           }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        //UNITYPM check for record type
        Case currentCase = (Case) so;
        Case oldCase = (Case) oldSo;
        
        if(currentCase.RecordTypeId == UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE && 
           currentCase.UNITY_Portal_Source__c == UNITY_Constants.CASE_PORTAL_SOURCE_SERVICE_CHANNEL &&
           oldCase.UNITY_Service_Channel_Status__c  != currentCase.UNITY_Service_Channel_Status__c) {
               //only gets here if the case was service channel and the status changed
                System.debug('--CLAY: This case had a status change and should be sent to mule callout');
               //need to allow a couple of changes to status directly in case, without a work order.
               //this will fire on updates from SC is the problem. We need to exclude if the check-in/out have changed? Yeah. 
																																				   
               if(oldCase.UNITY_Service_Channel_Status__c  != currentCase.UNITY_Service_Channel_Status__c && currentCase.Unity_Service_Channel_Status__c != 'OPEN') {
                    System.debug('CLAY: Old case status has changed. Adding to the list for the callout');
                   scCaseIdStatusChangedList.add(currentCase.Id);
                }

                           
           } else if(currentCase.RecordTypeId == UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE && 
           currentCase.UNITY_Portal_Source__c == UNITY_Constants.CASE_PORTAL_SOURCE_SERVICE_CHANNEL){
                //only gets here if the case is service channel
                if(oldCase.UNITY_Integration_Case_Note__c != currentCase.UNITY_Integration_Case_Note__c && currentCase.UNITY_Integration_Case_Note__c != null){
                    //only gets here if the case notes are not what they were!
                    system.debug('CLAY: afterUpdate we added notes to this case to go back to SC:');
                    system.debug(currentCase.UNITY_Integration_Case_Note__c);
                    scCaseIdNewCommentList.add(currentCase.Id);
                }

                //now we check if the scheduled date field has changed:
                //CLAY: We are going to add it to the scCaseIdStatusChangedList
                //will this duplicate the callout if it is allready on the list?
                if (oldCase.UNITY_ServiceChannel_Scheduled_Date_Time__c != currentCase.UNITY_ServiceChannel_Scheduled_Date_Time__c){
                    scCaseIdStatusChangedList.add(currentCase.Id);
                }

           }
        this.checkClosedCase(currentCase,oldCase);

        if (currentCase.UNITY_Fire_Assignment_Rule__c == true && oldCase.UNITY_Fire_Assignment_Rule__c == false){
            caseIdsToFireAR.add(currentCase.Id);
        }
    }
    
    public void afterDelete(SObject so){}
    
    public void andFinally(){
        
        for (sObject iter: newList_Case1){
            
            Case caseRecord = (Case)iter;
            //system.debug('##### owner '+caseRecord.OwnerId);
        }
        
        // DO NOT Propogate the BU to the work order related
        //update workOrderToUpdate;
        
        if (trigger.isInsert && trigger.isBefore){
            System.debug('#Case list before insert: '+newList_Case1.size());
        }
        else if (trigger.isInsert && trigger.isAfter){
            System.debug('#Case list after insert: '+newList_Case1.size());
        }
        else if (trigger.isUpdate && trigger.isBefore){
            System.debug('#Case list before update: '+newList_Case1.size());
        }
        else if (trigger.isUpdate && trigger.isAfter){
            System.debug('#Case list after update: '+newList_Case1.size());
            if((this.closedCases!=null)&&!this.closedCases.isEmpty())processAssets(this.closedCases);
        }
        
        if (!casesToSetSC.isEmpty()){
            UNITY_CaseHandlerHelper.popoulateServiceContract(casesToSetSC);
        }
        
        if (!caseIdsToFireAR.isEmpty()){
            UNITY_CaseUtilities.fireAssignmentRule(caseIdsToFireAR);
        }

        if (trigger.isBefore){
            populateNTE();
        }
        
        // pushing the sc case service request with status or notes changed to Mulesoft 
        //CLAY: Callout to SC only if the case status changed or if there is a new comment
        System.debug('CaseHandler ===========Clay: AndFinally - we are calling UNITY_MuleCalloutOperation/UNITY_MuleSiteSettingUtils against cases with status change or new comments:' + scCaseIdStatusChangedList.size() + ' / ' + scCaseIdNewCommentList.size());
        //System.debug('CLAY: scCaseIdStatusChangedList: ' + scCaseIdStatusChangedList);
        //System.debug('CLAY: scCaseIdNewCommentList : ' + scCaseIdNewCommentList);
        UNITY_MuleCalloutOperation.invokeCallOut(scCaseIdStatusChangedList, 
                                                 UNITY_MuleSiteSettingUtils.CASE1);
        UNITY_MuleCalloutOperation.invokeCallOut(scCaseIdNewCommentList, 
                                                 UNITY_MuleSiteSettingUtils.CASE_COMMENT);
        
        system.debug('>>>>>> CASE HANDLER F Limits.getQueries() '+Limits.getQueries());
    }
    

    private void checkClosedCase(Case newCase, Case oldCase) {
        if((newCase.Status != oldCase.Status) && (newCase.Status=='Closed') && !newCase.UNITY_Service_Data_Processed__c){
            this.closedCases.add(newCase.Id);
        }
    }

    @Future
    private static void processAssets(Set<Id> caseIds) {
        UNITY_AssetAvailability.calculateAvailability(caseIds);
    }
//CLAY:This method is what populates customer on the case - 
//I modified to also clone value into account
    private void populateCustomer(Case currentCase) {
        if(currentCase.UNITY_Customer__c == NULL){
            currentCase.UNITY_Customer__c = mapAccounts.get(currentCase.UNITY_LOC__c + currentCase.UNITY_Subscriber_ID__c);
            //System.debug('==============CLAY: We just set the case to this customer ' + currentCase.Unity_Customer__c);
            //CLAY: If the current case was created via service channel, we can safely assume we can populate the account the same as the customer? 
            if (currentCase.UNITY_Source_System__c != NULL){
                if(currentCase.UNITY_Source_System__c == 'Service Channel'){
                    //if this is a service channel case, set the account the same as the customer.
                    //System.debug('CLAY: Setting case Account/site location to same ID as customer');
                    currentCase.AccountId = currentCase.UNITY_Customer__c;
                }
            }
        }
    }
    
    public void applyTemplates(){
        
        for (sObject iter: newList_Case1){
            
            Case caseRecord = (Case)iter;
            
            caseWithTemplate = new List<Case>();
            
            if(caseRecord.UNITY_Template_Configuration__c  != null ){
                recordIdTemplateId.put(caseRecord.id, caseRecord.UNITY_Template_Configuration__c );
                caseWithTemplate.add(caseRecord);
            }
        }
        //UNITYPM Mod: Added if to check if there are records to process
        if (caseWithTemplate != null && caseWithTemplate.size() > 0)
        	UNITY_Utils.applyTemplates(recordIdTemplateId, caseWithTemplate, 'UNITY_Template_Configuration__c', 'Case');
    }

    /*
     * Name  : setBusinessUnitAccountMap
     * Note  : populate map < BU picklist , BU account > , remember BU accounts are Miner Record Type 
     */
    public static void setBusinessUnitAccountMap(){
        System.debug('>>> setBusinessUnitAccountMap()');
        List<String> relatedBusinessUnit = new List<String>();
        //check for new_SR_cases
        if (newList_Case1.size() > 0){
            if (Trigger.isInsert){
                System.debug('>>> Insert');
                for (SObject iter: newList_Case1){
                    Case newCase = (Case)iter;
                    //System.debug('CLAY: This is our case:');
                    //System.debug(newCase);
                    System.debug('>>> case.UNITY_Business_Unit__c '+newCase.UNITY_Business_Unit__c);
                    if (newCase.UNITY_Business_Unit__c != null){
                        relatedBusinessUnit.add(((Case)iter).UNITY_Business_Unit__c);
                    }
                }
            }else if (Trigger.isUpdate){
                System.debug('>>> Update '+relatedBusinessUnit);

                for (SObject iter: newList_Case1){
                    Case newCase = (Case)iter;
                    if(oldMap_Case1 != null){
                        Case oldCase = (Case)oldMap_Case1.get(iter.id);
                        //System.debug('>>> case.UNITY_Business_Unit__c '+newCase.UNITY_Business_Unit__c);
                        if((newCase.UNITY_Business_Unit__c != null)&&(newCase.UNITY_Business_Unit__c != oldCase.UNITY_Business_Unit__c)){
                            relatedBusinessUnit.add(((Case)iter).UNITY_Business_Unit__c);
                        }
                    }
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
        
        if (trigger.isUpdate){
            if (newMap_Case1 != null){
                List<WorkOrder> workOrderList = [select id, UNITY_Business_Unit_Account__c, CaseId from WorkOrder where CaseId in :newMap_Case1.keyset()];
                
                for (WorkOrder iter: workOrderList){
                    Case oldCase = (Case)oldMap_Case1.get(iter.CaseId);
                    Case newCase = (Case)newMap_Case1.get(iter.CaseId);
                    // samuel update , add WO from cases If the UNITY_Business_Unit_Account__c has changed on the Case record
                    if(oldCase.UNITY_Business_Unit__c != newCase.UNITY_Business_Unit__c ){
                        if (caseWorkOrderMap.get(iter.CaseId) == null){
                            caseWorkOrderMap.put(iter.CaseId, new List<WorkOrder>());
                        }
                        caseWorkOrderMap.get(iter.CaseId).add(iter);
                    }
																
                }
            }
        }        
    }
    
    /*
     * Name  : setBusinessUnitAccount
     * Param : Case
     */
    public static void setBusinessUnitAccount(Case currentCase){
        System.debug('CLAY: This is the setBusinessUnitAccount method. Our case BU:');
        //System.debug(JSON.serializePretty(currentCase));
        System.debug(currentCase.UNITY_Business_Unit__c);
        boolean should_update_BU_account = false;
        if(Trigger.isInsert) should_update_BU_account = true;
        //UNITYPM added null checking
        if(Trigger.isUpdate && oldMap_Case1 != null && oldMap_Case1.size() > 0 && (currentCase.UNITY_Business_Unit__c!=((Case)oldMap_Case1.get(currentCase.id)).UNITY_Business_Unit__c)) 
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
        
        //System.debug('#currentCase after update BU '+currentCase.UNITY_Business_Unit_Account__c);
    }
    
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
    }
    
    public void populateNTE(){
        
        List<Case> casesWithoutNTE = new List<Case>();
        
        for (SObject iter: newList_Case1){
            
            Case caseRecord = (Case)iter;
            
            if (caseRecord.UNITY_Trade__c != null && caseRecord.UNITY_NTE_Threshold__c == null && caseRecord.UNITY_Customer_Service_Contract__c != null){
                casesWithoutNTE.add(caseRecord);
            }
            /*if (caseRecord.UNITY_NTE_Threshold__c == null){
                casesWithoutNTE.add(caseRecord);
            }*/
        }
        
        if (!casesWithoutNTE.isEmpty()){
            UNITY_CaseHandlerHelper.populateNTEFromServiceContract(casesWithoutNTE);
        }    
    }
    Public void setCaseIdAccountMapForUpdateCaseOwner(Map<Id,Case> oldCasesMap, List<Case>casesList){
    try{
            Set<Id>businessUnitIds=new Set<Id>();
            for(case currentCase : casesList){
                
                setBusinessUnitAccount(currentCase);
                
                case oldCase = oldCasesMap.get(currentCase.Id);
                if(((String)currentCase.OwnerId).startsWith('00G') && currentCase.UNITY_Business_Unit__c != NULL && 
                   ((oldCase.OwnerId != currentCase.OwnerID) || (oldCase.UNITY_Business_Unit__c != currentCase.UNITY_Business_Unit__c))) 
                {
                     businessUnitIds.add(currentCase.UNITY_Business_Unit_Account__c);
                }

            }
            System.debug('Business Unit###'+ businessUnitIds);
            if (businessUnitIds.size() > 0){
                List<Account>businessUnits = [SELECT Id,UNITY_TimeZoneSidKey__c,
                                              UNITY_Agent_Work_Day__c,
                                              UNITY_Agent_Work_Hour_Start_Time__c,
                                              UNITY_Agent_Work_Hour_End_Time__c,
                                              UNITY_Off_Hour_Queue__c
                                              FROM Account
                                              WHERE Id IN : businessUnitIds];
                Set<String> offHourQueueNames =new Set<String>();
                for(Account bu:businessUnits){
                    offHourQueueNames.add(bu.UNITY_Off_Hour_Queue__c);
                }
                idAccountMapForUpdateCaseOwner=new Map<Id,Account>(businessUnits);
                    for(Case c : casesList){
                caseIdAccountMapForUpdateCaseOwner.put(c.Id,idAccountMapForUpdateCaseOwner.get(c.UNITY_Business_Unit_Account__c));
                }
             }
    }catch(Exception e){System.Debug('********in setCaseIdAccountMapForUpdateCaseOwner');}
}

public void setNameQueueIdMap(){
    try{
        Set<String> offHourQueueNames =new Set<String>();
        if(caseIdAccountMapForUpdateCaseOwner.size() > 0) {
            for(Account bu:caseIdAccountMapForUpdateCaseOwner.values()){
                offHourQueueNames.add(bu.UNITY_Off_Hour_Queue__c);
            }
            
            if(offHourQueueNames.size() > 0) {
                List<Group> Queues = [SELECT Id,DeveloperName
                                  FROM Group 
                                  WHERE Type = 'Queue'
                                  AND DeveloperName IN :offHourQueueNames];
                for(Group q : Queues){
                    nameQueueIdMap.put(q.DeveloperName,q.Id); 
                }    
            }    
        } 
    }catch(Exception e){System.Debug('***********in setNameQueueIdMap:'+e);}

}

public void updateCaseOwner(Case oldCase,Case newCase,Account bu){
    if (oldCase.OwnerId != newCase.OwnerID || oldCase.UNITY_Business_Unit__c != newCase.UNITY_Business_Unit__c ) 
    {
        try{
            String caseModifiedDayOfWeek = newCase.SystemModstamp.format('EEEE')!=NULL?newCase.SystemModstamp.format('EEEE'): DateTime.now().format('EEEE');
            if(!bu.UNITY_Agent_Work_Day__c.contains(caseModifiedDayOfWeek)){
            //if(!(oldCase.OwnerId == nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c) && 
                              //newCase.OwnerId != nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c)))
                            if ((nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c))!=null)
                                newCase.OwnerId = nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c);
                    

            }else{
            Integer agentStartHour = Integer.valueOf(bu.UNITY_Agent_Work_Hour_Start_Time__c.substring(0,bu.UNITY_Agent_Work_Hour_Start_Time__c.indexOfChar(58)));
                            Integer agentStartMinute = Integer.valueOf(bu.UNITY_Agent_Work_Hour_Start_Time__c.indexOfChar(58)+1);
                            Time agentStartTime =Time.newInstance(agentStartHour,agentStartMinute,0,0);
                            Integer agentEndHour = Integer.valueOf(bu.UNITY_Agent_Work_Hour_End_Time__c.substring(0,bu.UNITY_Agent_Work_Hour_End_Time__c.indexOfChar(58)));
                            Integer agentEndMinute = Integer.valueOf(bu.UNITY_Agent_Work_Hour_End_Time__c.substring(bu.UNITY_Agent_Work_Hour_End_Time__c.indexOfChar(58)+1));
                            Time agentEndTime =Time.newInstance(agentEndHour,agentEndMinute,0,0);
                            UNITY_Utils.DateTimeZone tz =UNITY_Utils.getDateTime(newCase.SystemModstamp,null,bu.UNITY_TimeZoneSidKey__c);
                            Integer caseLastModifiedHour =tz.HH;
                            Integer caseLastModifiedMinute =tz.MM;
                            Time caseLastModifiedTime = Time.newInstance(caseLastModifiedHour,caseLastModifiedMinute,0,0);
                            System.Debug('caseLastModifiedHour:'+caseLastModifiedTime);
                            System.Debug('agent start time:'+agentStartTime);
                            System.Debug('agent End time:'+agentEndTime);
                            if(caseLastModifiedTime<agentStartTime || caseLastModifiedTime>agentEndTime){
                                  //if(!(oldCase.OwnerId == nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c) && 
                              //newCase.OwnerId != nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c)))
                                if ((nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c))!=null)
                                    newCase.OwnerId = nameQueueIdMap.get(bu.UNITY_Off_Hour_Queue__c);
                            }
            }
        }catch(Exception e){
                System.Debug('Error while changing case owner:'+e);
        }
    }  
}
    public void setAccountIfNull(){
        
        Set<Id> relatedContactIdSet = new Set<Id>();
        
        for (SObject iter: newList_Case1){
            
            Case caseRecord = (Case)iter;
            
            if (caseRecord.contactId != null){
                relatedContactIdSet.add(caseRecord.contactId);
            }
        }
        if(!relatedContactIdSet.isEmpty()) {
            List<Contact> contactList = [select id, AccountId from Contact where id in:relatedContactIdSet];
            
            Map<Id, Id> contactAccountMap = new Map<Id, Id>();
            
            for (Contact iter: contactList){
                
                contactAccountMap.put(iter.id, iter.AccountId);
            }
            
             for (SObject iter: newList_Case1){
                
                Case caseRecord = (Case)iter;
                
                if (caseRecord.contactId != null && caseRecord.accountId == null){
                    caseRecord.accountId = contactAccountMap.get(caseRecord.contactId);
                }
            } 
        }
        
    }
}