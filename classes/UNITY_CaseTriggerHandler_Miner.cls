/**This class serves as a trigger handler for cases and CTI integration purposes
 * @programmer: Izay Ramos-Irizarry
 * @date: 2/19/2016
 * @version: 0.1
 */
public class UNITY_CaseTriggerHandler_Miner extends UNITY_BaseHandler{
    
    public override void bulkBefore(List<SObject> newList_Case, List<SObject> oldList_Case, Map<Id,SObject> oldMap_Case, Map<Id,SObject> newMap_Case){
        
            if(trigger.isInsert){
                UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_Case,null,'Case',true);


                /////////////////////////////////////
                //Build out a list of Service Channel Cases to pass into other methods:
                List<Case> ScCases = new List<Case>();
                List<String> ScTrades = new List<String>();
                for (SObject obj : newList_Case){
                    //cast our trigger list into cases
                    Case nc = (Case)obj;
                    if(nc.UNITY_Source_System__c == 'Service Channel' && nc.UNITY_Portal_Source__c == 'Service Channel' && nc.Origin == 'Web Portal'){
                        //need to add checking for origin
                        //add this case to SCcases
                        //now we should check if this subscriber ID is set to activated. If not, we don't add it to the list?                        
                        //custom method to check if case should be created
                        checkSubIdActive(nc);
                        ScCases.add(nc);
                        if (nc.UNITY_Service_Channel_Trade__c != null){ ScTrades.add(nc.UNITY_Service_Channel_Trade__c);}
                        

                                                
                    }
                }
                //If we have Service Channel Cases - send them to our method for mapping
                if(ScCases.size() > 0){
                    system.debug('CLAY: ScCases we found:' + ScCases.size());
                    UNITY_CaseTriggerHandler_Miner.MapSCCaseValues(ScCases, ScTrades);
                    UNITY_CaseHandler.setBusinessUnitAccountMap();
                    //System.debug('CLAY: trying to figure out what is in the bu account map:' );
                    //System.debug(businessUnitAccountMap);
                    for (Case c : ScCases){
                        //set our BU account
                        UNITY_CaseHandler.setBusinessUnitAccount(c);
                        //System.debug('CLAY: Our case: ' + JSON.serializePretty(c));
                        //now let's change the status to dispatch confirmed. We could do this via custom setting.
                        c.UNITY_Service_Channel_Status__c = 'DISPATCH_CONFIRMED';
                        System.debug('CLAY: ' + c.UNITY_Service_Channel_Status__c);
                    }
                }

            }
            if(trigger.isUpdate){
                UNITY_TimeInput_Ctlr.verifyDateTimeChanged(newList_Case,
                                                           oldMap_Case,
                                                           'Case',true);
                //CLAY: Need to update work order check-in right here
                /////////////////////////////////////
                //Build out a list of Service Channel Cases to pass into other methods:
                List<Case> ScCases = new List<Case>();
                Map<Id,Case> oldCases = new Map<Id,Case>();
                for (SObject obj : newList_Case){
                    //cast our trigger list into cases
                    Case nc = (Case)obj;
                    if(nc.UNITY_Source_System__c == 'Service Channel' && nc.UNITY_Portal_Source__c == 'Service Channel'){
                        //need to add checking for origin
                        //add this case to SCcases
                        ScCases.add(nc);                    
                    }     
                }
                //convert our sobject map to a case map
                for (SObject obj : oldMap_Case.values()){
                    Case oc = (Case)obj;
                    if(oc.UNITY_Source_System__c == 'Service Channel' && oc.UNITY_Portal_Source__c == 'Service Channel'){
                        oldCases.put(oc.Id,oc);
                    }
                }
                //update work orders with the new check in
                
                updateWOCheckin(ScCases, oldCases);




            }//End if trigger.isUpdate
            if(runTriggerOnce_Before()){
                UNITY_CaseTriggerHandler_Miner.setSkillIds(newList_Case,
                                                           oldMap_Case);
            }
        //}
    }


    /**
    *updateWOCheckin
    *Used to search for and find current/active WO and stamps check in/out
    *CLay: Updated with more conditions - 2/16
    **/
   public static void updateWOCheckin (List<Case> ScCases, Map<Id,Case> oldCases){
        //our payload
        List<WorkOrder> updatedWos = new List<WorkOrder>();
        //our type for service channel time conversion:
        String type = 'Service Channel';
        //map of cases where the time has changed
        Map<Id,Case> checkedCases = new Map<Id, Case>();

        //first we check for changed check in or outs. We need to combine this map so that we only have to query WOs once.
        for (Case c : ScCases){
            if(c.UNITY_Service_Channel_Current_Check_In__c != oldCases.get(c.Id).UNITY_Service_Channel_Current_Check_In__c || c.UNITY_Service_Channel_Current_Check_Out__c != oldCases.get(c.Id).UNITY_Service_Channel_Current_Check_Out__c)
                checkedCases.put(c.Id, c);
            

        }
        //look for any work orders with a CaseId in the keyset
        //This is our one query
        List<WorkOrder> checkedWos = new List<WorkOrder>();
        if ( checkedCases.size() > 0){
                checkedWos = [SELECT Id, CaseId, UNITY_Check_In_Date_Cust__c, UNITY_Check_Out_Date_Cust__c, StartDate, EndDate, FSO__Check_In_Date__c, FSO__Completed_Date__c, RecordType.Name, UNITY_Check_In_Source__c, UNITY_Check_Out_Source__c
                                                FROM WorkOrder WHERE CaseId IN :checkedCases.keySet() AND RecordTypeId = :UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE AND Status != 'Canceled' AND Status != 'Completed'];
        
                Map<Id, List<WorkOrder>> caseToWo = new Map<Id, List<WorkOrder>>();
        
                for (WorkOrder wo: checkedWos){
                    List<WorkOrder> temp = new List<WorkOrder>();
                    if (!caseToWo.containsKey(wo.CaseId)){
                        temp.add(wo);
                        caseToWo.put(wo.CaseId, temp);
                    }else{
                        temp = caseToWo.get(wo.CaseId);
                        temp.add(wo);
                        caseToWo.put(wo.CaseId, temp);
                    }
                }
        
                for (Id cId : checkedCases.keySet()){
                    //if there is only one service request work order
                    //System.debug('<>< CLAY: Work order SC Check in/Out time stamp: Found case:' + cId);
                    //System.debug('<>< CLAY: case work order list size' + caseToWo.get(cId).size());
                    //System.debug('<>< CLAY: first work order in list: ' + caseToWo.get(cId)[0].Id);
                    if (caseToWo.get(cId).size() == 1){
                        System.debug('<>< CLAY: Work order we are going to check in/out' + caseToWo.get(cId)[0].Id);
                        Datetime checkIn;
                        Datetime checkOut;
                        //grab the case from the map
                        Case currentCase = checkedCases.get(cId);
                        WorkOrder wo = casetoWo.get(cId)[0];
                        //Split the check in vs check out logic
                        //if the check in has changed from the old case do the check in
                        if (currentCase.UNITY_Service_Channel_Current_Check_In__c != oldCases.get(cId).UNITY_Service_Channel_Current_Check_In__c){
                            checkIn = (currentCase.UNITY_Service_Channel_Current_Check_In__c != null) ? UNITY_TimeInput_Ctlr.convertDateTime(currentCase.UNITY_Service_Channel_Current_Check_In__c, currentCase.UNITY_Account_Time_Zone__c, type) : null;
                            if(wo.FSO__Check_In_Date__c != checkIn && checkIn != null){
                                wo.FSO__Check_In_Date__c = checkIn;
                                wo.UNITY_Check_In_Source__c = 'Service Channel';
                                updatedWos.add(wo);
                            }
                        }
                        //if the checkout changed do the check out
                        if (currentCase.UNITY_Service_Channel_Current_Check_Out__c != oldCases.get(cId).UNITY_Service_Channel_Current_Check_Out__c) {
                            checkOut = (currentCase.UNITY_Service_Channel_Current_Check_Out__c != null) ? UNITY_TimeInput_Ctlr.convertDateTime(currentCase.UNITY_Service_Channel_Current_Check_Out__c, currentCase.UNITY_Account_Time_Zone__c, type) : null;
                            if(wo.FSO__Completed_Date__c != checkOut && checkOut != null){
                                wo.FSO__Completed_Date__c = checkOut;
                                wo.UNITY_Check_Out_Source__c = 'Service Channel';
                                updatedWos.add(wo);
                            }      
                        }
        
                        //if the timestamp values are filled, we need to convert them and save them
                        //checkIn = (currentCase.UNITY_Service_Channel_Current_Check_In__c != null) ? UNITY_TimeInput_Ctlr.convertDateTime(currentCase.UNITY_Service_Channel_Current_Check_In__c, currentCase.UNITY_Account_Time_Zone__c, type) : null;
                        //checkOut = (currentCase.UNITY_Service_Channel_Current_Check_Out__c != null) ? UNITY_TimeInput_Ctlr.convertDateTime(currentCase.UNITY_Service_Channel_Current_Check_Out__c, currentCase.UNITY_Account_Time_Zone__c, type) : null;
                        
                        //if the check in or check values are different from what is on the work order, we need to update the work order
                        //NOTE: This won't overwrite if an agent has modified the date on the work order manually, because these cases are only ones that had it changed via SC
        
                        /**if(wo.FSO__Check_In_Date__c != checkIn && checkIn != null){
                            wo.FSO__Check_In_Date__c = checkIn;
                            updatedWos.add(wo);
                        }
                        if(wo.FSO__Completed_Date__c != checkOut && checkOut != null){
                            wo.FSO__Completed_Date__c = checkOut;
                            updatedWos.add(wo);
                        }                
        
                        **/
                    }
                }
         }
        //we need to loop through the work orders and get the case check in/out, if it has changed, 
        //we need to convert it and populate it
        if (updatedWos.size() > 0){                                    
            //now we do a try/catch to update these work orders
            try {
                update updatedWos;   
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }else{
            System.debug('CLAY: No work orders to update with check in or out');
        }       

    }
    /**
    * MapScCaseValues()
    * Used to populate Case values from field and trade mappings
    * @param: ScCases = List<Case> : List of cases passed in to find values for - type casted it into Case
    * Custom Setting:
    * UNITY_SC_to_Case_Field_Mapping__c
    * Object Reference:
    * UNITY_Service_Channel_Trade_Mapping__c
    **/
    public static void MapSCCaseValues(List<Case> ScCases, List<String> ScTrades){
        //build out our trade map:
        Map<String, Map<String, UNITY_Service_Channel_Trade_Mapping__c>> tradeMap = new Map<String, Map<String, UNITY_Service_Channel_Trade_Mapping__c>>();
        
        for (UNITY_Service_Channel_Trade_Mapping__c trade : [Select Id, UNITY_Miner_Skill_Broad__c, UNITY_Miner_Skill_Group__c, UNITY_Miner_Skill_Type__c, UNITY_Miner_Skill_SubType__c, UNITY_Customer_Subscriber_ID__c, UNITY_Service_Channel_Trade__c 
                                                             from UNITY_Service_Channel_Trade_Mapping__c where UNITY_Service_Channel_Trade__c IN :ScTrades])
        {
            Map<String, UNITY_Service_Channel_Trade_Mapping__c> temptradeMap = new Map<String, UNITY_Service_Channel_Trade_Mapping__c>();
            temptradeMap.put(trade.UNITY_Service_Channel_Trade__c, trade);    
            //our map will have subscriber ID to trade to mapping
            //build out our default settings if we have them
            if(trade.UNITY_Customer_Subscriber_ID__c == null){
                if(!tradeMap.containsKey('Default')){
                    tradeMap.put('Default', tempTradeMap);
                }else{
                    //we have default settings, do we have this trade?
                    if(!tradeMap.get('Default').containsKey(trade.UNITY_Service_Channel_Trade__c)){
                        //if not add it
                        tradeMap.put('Default', tempTradeMap);
                    }
                }    
            }else{
                //this trade setting is subscriber specific
                if(!tradeMap.containsKey(trade.UNITY_Customer_Subscriber_ID__c)){
                    tradeMap.put(trade.UNITY_Customer_Subscriber_ID__c, tempTradeMap);
                }else{
                    //we have trade mapping for this subscriber, do we have this trade?
                    if(!tradeMap.get(trade.UNITY_Customer_Subscriber_ID__c).containsKey(trade.UNITY_Service_Channel_Trade__c)){
                        //if not add it
                        tradeMap.put(trade.UNITY_Customer_Subscriber_ID__c, tempTradeMap);
                    }
                }

            }
            //if(!temptradeMap.containsKey(trade.UNITY_Service_Channel_Trade__c))
            //    temptradeMap.put(trade.UNITY_Service_Channel_Trade__c, trade);
        }
        System.debug('We are in the Service channel case mapping');
        System.debug('tradeMap' + tradeMap);
        //pull all of the custom setting mappings:
        List<UNITY_SC_to_Case_Field_Mapping__c> SC_Case_Map_List = UNITY_SC_to_Case_Field_Mapping__c.getAll().values();
        //build out a map of sub Id to a list of UNITY_SC
        Map<string, LIST<UNITY_SC_to_Case_Field_Mapping__c>> subToValues = new Map<string, LIST<UNITY_SC_to_Case_Field_Mapping__c>>();

        
        //This map will have keys based on unique subscribers to the settings that go with them 
        //TODO: potentially will need to also add by provider

 for(UNITY_SC_to_Case_Field_Mapping__c setting : SC_Case_Map_List) {
    String scMapKey = (setting.CustomerId_Subscriber__c == null ? 'Default' : setting.CustomerId_Subscriber__c);
           scMapKey += (setting.Category__c == null ? '-Any' : '-' + setting.Category__c);
            //our temporary list for creating the mapping placeholder
            List<UNITY_SC_to_Case_Field_Mapping__c> tempList = new List<UNITY_SC_to_Case_Field_Mapping__c>();
            if(!subToValues.containsKey(scMapKey)){
              tempList.add(setting);
              subToValues.put(scMapKey, tempList);
            }else{
              subToValues.get(scMapKey).add(setting);
            }
        }
        //get our default settings:
       List<UNITY_SC_to_Case_Field_Mapping__c> defaultSettings = subToValues.get('Default-Any');


//system.debug(JSON.serializePretty(defaultSettings, false));



        //loop through Sobjects
        for (Case c : ScCases){
            //These shouldnt be blank on any Service Channel case
            String caseMapKey = c.UNITY_Subscriber_ID__c + '-' + c.UNITY_Service_Channel_Category__c;
            System.debug('//Clay ==Looping through Cases== : ' + caseMapKey );
            //empty lists (init everytime)
            List<UNITY_SC_to_Case_Field_Mapping__c> defSubSettings = new List<UNITY_SC_to_Case_Field_Mapping__c>();
            List<UNITY_SC_to_Case_Field_Mapping__c> defCatSettings = new List<UNITY_SC_to_Case_Field_Mapping__c>();
            List<UNITY_SC_to_Case_Field_Mapping__c> catSubSettings = new List<UNITY_SC_to_Case_Field_Mapping__c>();
            
            //lets find our list of settings:
            if(subToValues.containsKey(caseMapKey)) //caseMapKey example = 200512549-MAINTENANCE
                catSubSettings = subToValues.get(caseMapKey); 
            if(subToValues.containsKey(c.UNITY_Subscriber_ID__c)) //settings without a category
                defSubSettings = subToValues.get(c.UNITY_Subscriber_ID__c);
            if(subToValues.containsKey('Default-' + c.UNITY_Service_Channel_Category__c)) //settings without a sub
                defCatSettings = subToValues.get('Default-' + c.UNITY_Service_Channel_Category__c);
            

            //Loop through the default settings first, this way we set all of our baselines and then do the subscriber specific
            for (UNITY_SC_to_Case_Field_Mapping__c def : defaultSettings){
                if(def.SourceValue__c == c.get(def.SCField__c)) {
                    //this means this setting SourceValue matches the case's value in the corresponding Service Channel field
                    //We can now set the matched value to the targetfields it maps to
                    c.put(def.TargetField__c, def.Value__c);           
                }
            }

            //our default category settings:
            if (defCatSettings.size() > 0){
                for (UNITY_SC_to_Case_Field_Mapping__c mapVal : defCatSettings){
                        if (mapVal.SourceValue__c != null){ //source field has a value - lets check to see if it matches our case source field
                            if(mapVal.SourceValue__c == c.get(mapVal.SCField__c)) {                      
                                c.put(mapVal.TargetField__c, mapVal.Value__c);
                                system.debug('//Clay - found Default Subscriber + Category setting: ' + mapVal.TargetField__c + ' = ' + mapVal.Value__c);           
                            }               
                        }else{ //no source field to match, just a default setting for this category
                                c.put(mapVal.TargetField__c, mapVal.Value__c);
                                system.debug('//Clay - found Default Category setting (no source field): ' + mapVal.TargetField__c + ' = ' + mapVal.Value__c);
                        }
                }

            }
            //our default subscriber settings:
            if (defSubSettings.size() > 0){
                for (UNITY_SC_to_Case_Field_Mapping__c mapVal : defSubSettings){                    
                    if(mapVal.SourceValue__c != null){
                        if(mapVal.SourceValue__c == c.get(mapVal.SCField__c)) {                      
                            c.put(mapVal.TargetField__c, mapVal.Value__c);           
                        }        
                    }else{
                        c.put(mapVal.TargetField__c, mapVal.Value__c);
                    }
                }

            }
            //our most specific settings:
            if (catSubSettings.size() > 0){
                for (UNITY_SC_to_Case_Field_Mapping__c mapVal : catSubSettings){
                    if (mapVal.SourceValue__c != null){ //source field has a value - lets check to see if it matches our case source field
                        if(mapVal.SourceValue__c == c.get(mapVal.SCField__c)) {                      
                            c.put(mapVal.TargetField__c, mapVal.Value__c); 
                            system.debug('//Clay - found Default Subscriber + Category setting: ' + mapVal.TargetField__c + ' = ' + mapVal.Value__c);                    
                        }               
                    }else{ //no source field to match, just a default setting for this category
                            c.put(mapVal.TargetField__c, mapVal.Value__c);
                            system.debug('//Clay - found Default Subscriber + Category setting (no source field): ' + mapVal.TargetField__c + ' = ' + mapVal.Value__c);
                    }   
                }
            }

            ////////////////////////////////////////////////////////
            //Let's set the trade on this case now. 
            //get the trade mapping per subscriber Id first:
            if(tradeMap.containsKey(c.UNITY_Subscriber_ID__c)){
                //get the broad, group, type, and subtype based on subscriber id
                c.UNITY_Skill_Broad__c = tradeMap.get(c.UNITY_Subscriber_ID__c).get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Broad__c;
                c.UNITY_Skill_Group__c = tradeMap.get(c.UNITY_Subscriber_ID__c).get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Group__c;
                c.UNITY_Skill_Type__c = tradeMap.get(c.UNITY_Subscriber_ID__c).get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Type__c;
                c.UNITY_Skill_SubType__c = tradeMap.get(c.UNITY_Subscriber_ID__c).get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_SubType__c;
            }else{
                //look for this trade in the default settings
                if(tradeMap.containsKey('Default') && tradeMap.get('Default').containsKey(c.UNITY_Service_Channel_Trade__c)){
                //get the broad, group, type, and subtype based on default settings
                c.UNITY_Skill_Broad__c = tradeMap.get('Default').get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Broad__c;
                c.UNITY_Skill_Group__c = tradeMap.get('Default').get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Group__c;
                c.UNITY_Skill_Type__c = tradeMap.get('Default').get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_Type__c;
                c.UNITY_Skill_SubType__c = tradeMap.get('Default').get(c.UNITY_Service_Channel_Trade__c).UNITY_Miner_Skill_SubType__c;  

                } else{
                    system.debug('CLAY: No trade mappings found for this Service Channel case! = ' + c.UNITY_Service_Channel_Trade__c);
                }
            }

            //need to set this to true so the assignment rule will fire
            //TODO: we need to determine why they are all going to UNITY-Catch all
            c.UNITY_Fire_Assignment_Rule__c = true;

            //System.debug('CLAY: Lets see if all of our service channel case mapping stuck:');
            //System.debug(JSON.serializePretty(c));
        }



    }
    ///////////////////////////////
    //UpdateAgentonWOs - 
    //updates the agent on the case and returns the void
    //
    ///////////////////////////////
    public static void updateAgentonWOs(Map<Id, SObject> newSObject, Map<Id, SObject> oldSObject){
        //UNITYPM replaced typecasting by converting collection manually
        Map<Id, Case> newCaseM = new  Map<Id, Case>();
        Map<Id, Case> oldCasesM =new  Map<Id, Case>();
        
        for(SObject sObj :  newSObject.values()){
            Case c = (Case)sObj;
            newCaseM.put(c.Id, c);
        }
        
        for(SObject sObj :  oldSObject.values()){
            Case c = (Case)sObj;
            oldCasesM.put(c.Id, c);
        }
        
        //the set of ids we will query wos against
        Set<Id> cids = new Set<Id>();
        List<WorkOrder> changedWos = new List<WorkOrder>();
        //loop through our newCase map and scoop up cases where owner has changed to user and update work orders that are not canceled 
        for (Case c : newCaseM.values()){
            //if the case owner has changed and equals a user add it to the list of cases to query for
            if(c.OwnerId != oldCasesM.get(c.Id).OwnerId && ((String)c.OwnerId).startsWith('005') && c.status != 'Cancelled')
                cids.add(c.Id);
        }

        //if we have some case ids lets query for some work orders
        if(cids.size() > 0){
            System.debug ('><>Clay: We have some cases where owner has changed - time to find the work orders underneath them');
            changedWos = [Select Id, CaseId, UNITY_Agent__c 
                            FROM WorkOrder WHERE Status != 'Canceled' AND CaseId IN :cids ];
            //did we find some wos?
            if (changedWos.size() > 0 ){
                //oh wo is me. 
                for(WorkOrder w :changedWos){
                    //this is kind of redundant. But i like to be REALLY sure. 
                    if (w.UNITY_Agent__c != newCaseM.get(w.CaseId).OwnerId)
                        w.Unity_Agent__c = newCaseM.get(w.CaseId).OwnerId;
                }

                try {
                    //lets update these work orders
                    update changedWos;
                    
                } catch(Exception e) {
                    System.debug('><>Clay: Whoops. Something broke: '+e.getMessage());
                }

            }

        }

    }
    ///////////////////////////////
    //our custom exception class
    public class subNotActiveException extends Exception {}

    //method to check this Service Channel case against active subscribers in our custom setting list
    public static void checkSubIdActive(Case c){
        //search for this case subscriber in the custom setting
        if (c.UNITY_Subscriber_ID__c != null){
            UNITY_SC_Activated_Subs__c scSub = new UNITY_SC_Activated_Subs__c();
            //check if the sub id is in the custom setting
            if (UNITY_SC_Activated_Subs__c.getInstance(c.UNITY_Subscriber_ID__c) != null){
                scSub = UNITY_SC_Activated_Subs__c.getInstance(c.UNITY_Subscriber_ID__c);
                if(scSub.Active__c){
                    //customer has been found and is active.
                    System.Debug('CLAY: SC Customer Sub was found and is active:');                
                    return;
                }else{
                    //not active
                    throw new subNotActiveException('This subscriber Id '+c.UNITY_Subscriber_ID__c+' has not had Service Channel'+ 
                                                    ' integration activated yet. Custom Setting: Unity SC Activated Subs');       
                }
            }else{ 
            //customer sub not found
            throw new subNotActiveException('This subscriber Id '+c.UNITY_Subscriber_ID__c+' was not found in'+ 
                                                    'Custom Setting: Unity SC Activated Subs'); 
            }
                
        }
        
    }

    /**This method handles updates the case with the incontact skill ids
     * @param: newList - List<Case> : The list of cases being created or updated
     * @param: oldMap - Map<Id,Case> : The map of cases before the update
     */
    public static void setSkillIds(List<SObject> newList, Map<Id,SObject> oldMap){
        Set<Id> aids = new Set<Id>();//Set of account ids
        //get the account id for each case
        for(SObject s :newList){
            Case c = (Case)s;
            if(String.isNotBlank(c.UNITY_Customer__c) && (String.isBlank(c.UNITY_Skill_ID__c) || String.isBlank(c.UNITY_Skill_ID_1__c) || String.isBlank(c.UNITY_Skill_ID_2__c) || String.isBlank(c.UNITY_VM_Skill_ID__c))){
                aids.add(c.UNITY_Customer__c);//get the customer id
            }
        }//End for cases
        if(aids.size() > 0){
            //Need to get the correct customer team based in the case BU
            //map to hold all customers by id
            //First Need to do some setup... 
            //Get the values from trhe Custom Setting for the field to look at from the account
            Map<String,UNITY_BU_Team_Field_Map__c> fieldsMap = UNITY_BU_Team_Field_Map__c.getAll();
            //Now buil a query using those fields to get the needed values
            String mergeFields = ',';
            String myAids = ApexHelper.joinIds(aids);
            for(UNITY_BU_Team_Field_Map__c fMap :fieldsMap.values()){
                mergeFields += fMap.UNITY_Field_API_Name__c + ',';
            }
            mergeFields = mergeFields.removeEnd(',');
            if(mergeFields.indexOf('UNITY_Customer_Team__c') == -1){
                mergeFields += ',UNITY_Customer_Team__c';
            }
            String query = 'SELECT Id, UNITY_Tier_Level__c' + mergeFields;
            
            query += ' FROM Account WHERE Id IN ' + myAids;
            System.debug('##### query: ' + query);
            try{
                //Get the accounts and put them in the acctMap
                List<Account> accts = Database.query(query);
                Map<Id,Account> acctMap = new Map<Id,Account>();
                for(Account a :accts){
                    acctMap.put(a.Id,a);
                }
                Map<Id,List<String>> skillsMap = new Map<Id,List<String>>();//Map of skills by case id
                Set<String> sList = new Set<String>();//Set of skills
                //For each case... get the skills that apply to the case
                for(SObject s :newList){
                    Case c = (Case)s;
                    if(String.isNotBlank(c.UNITY_Customer__c)){
                        if(acctMap.containsKey(c.UNITY_Customer__c)){
                            //Need to get the appropriate customer team field for the BU in the case
                            String fname = '';
                            if(fieldsMap.containsKey(c.UNITY_Business_Unit__c)){
                                fname = fieldsMap.get(c.UNITY_Business_Unit__c).UNITY_Field_API_Name__c;
                            }else{
                                fname = 'UNITY_Customer_Team__c';
                            }
                            //Need to get the team value from the account
                            String custTeam = (String)acctMap.get(c.UNITY_Customer__c).get(fname);
                            //Now, create the string for the incontact skill name
                            UNITY_CTI_Values_Map__c cBroad = UNITY_CTI_Values_Map__c.getInstance(c.UNITY_Skill_Broad__c);
                            UNITY_CTI_Values_Map__c aTier = UNITY_CTI_Values_Map__c.getInstance(acctMap.get(c.UNITY_Customer__c).UNITY_Tier_Level__c);
                            UNITY_CTI_Values_Map__c aTeam = UNITY_CTI_Values_Map__c.getInstance(custTeam);
                            String bu = c.UNITY_Business_Unit__c;
                            String b = (cBroad != null && String.isNotBlank(cBroad.InContact_Value__c)) ? cBroad.InContact_Value__c : c.UNITY_Skill_Broad__c;
                            String t = (aTier != null && String.isNotBlank(aTier.InContact_Value__c)) ? aTier.InContact_Value__c : acctMap.get(c.UNITY_Customer__c).UNITY_Tier_Level__c;
                            String tm = (aTeam != null && String.isNotBlank(aTeam.InContact_Value__c)) ? aTeam.InContact_Value__c : custTeam;
                            String skill = bu + '-' + t + '-' + tm + '-' + b;
                            String skill_1 = bu + '-'+ t + '-' + tm;
                            String skill_2 = bu + '-'+ t;
                            String skill_VM = bu + '-'+ t + '-' + tm + '-VM';
                            List<String> skls = new List<String>();
                            skls.add(skill);
                            skls.add(skill_1);
                            skls.add(skill_2);
                            skls.add(skill_VM);
                            skillsMap.put(c.id,skls);
                            sList.addAll(skls);
                        }
                    }
                }
                if(sList.size() > 0){
                    //get all the skills for the set
                    List<CTI_Skill_ID_Map__c> ctiSId = [SELECT Id,Name,InContact_ID__c FROM CTI_Skill_ID_Map__c WHERE Name IN :sList];
                    Map<String,String> skillIdMap = new Map<String,String>();
                    //Iterate through all mappings and put in map by label
                    for(CTI_Skill_ID_Map__c ctiId: ctiSId){
                        skillIdMap.put(ctiId.Name,ctiId.InContact_ID__c);
                    }
                    //Now, loop trough each case and populate the in-contact id for each skill
                    for(SObject s :newList){
                        Case c = (Case)s;
                        Integer index = 0;
                        if(skillsMap.containsKey(c.Id)){
                            for(String sk:skillsMap.get(c.Id)){
                                if(skillIdMap.containsKey(sk)){
                                    if(index == 0){
                                        c.UNITY_Skill_ID__c = skillIdMap.get(sk);
                                    }else if(index == 1){
                                        c.UNITY_Skill_ID_1__c = skillIdMap.get(sk);
                                    }else if(index == 2){
                                        c.UNITY_Skill_ID_2__c = skillIdMap.get(sk);
                                    }else{
                                        c.UNITY_VM_Skill_ID__c = skillIdMap.get(sk);
                                    }//End if index
                                }//End if skillId
                                index++;
                            }//End for skills
                        }//End if skillsmap
                    }//End for case            
                }//End if sList
            }catch(Exception e){
                System.debug('##### Error: ' + e.getMessage());
            }
        }//End if aids
    }//End before

    /**
     * Logic that sets default case business unit based on the current running user's business unit.
     * @param: List<sObject>
     * @return: void
     */
    public static void setCaseBusinessUnitFromUserBusinessUnit(List<SObject> newList) {
        if(!Test.isRunningTest()){
            User user = [SELECT Business_Unit__c,UNITY_Segment__c FROM User WHERE Id =: UserInfo.getUserId()];

            if(String.isNotBlank(user.Business_Unit__c) && String.isNotBlank(user.UNITY_Segment__c)){
                String bu = '';
                if(user.UNITY_Segment__c != 'MNS' && user.UNITY_Segment__c != 'NSBS' && user.UNITY_Segment__c != 'Craft')
                    bu = 'MSP '+user.UNITY_Segment__c;
                else
                    bu = user.UNITY_Segment__c;
                for(sObject c : newList) {
                    c.put('UNITY_Business_Unit__c', bu);
                }
            }
        }
    }

    /**
    *** This variable and method are used to prevent triggers recursion on before insert/update
    */
    public static Boolean isFirstTriggerRun_Before = true;
    public static Boolean runTriggerOnce_Before(){
        if(isFirstTriggerRun_Before){
            isFirstTriggerRun_Before = false;
            return true;
        }else{
            return isFirstTriggerRun_Before;
        }
    }
    /**
    *** This variable and method are used to prevent triggers recursion on afterinsert/update
    */
    public static Boolean isFirstTriggerRun_After = true;
    public static Boolean runTriggerOnce_After(){
        if(isFirstTriggerRun_After){
            isFirstTriggerRun_After = false;
            return true;
        }else{
            return isFirstTriggerRun_After;
        }
    }
}