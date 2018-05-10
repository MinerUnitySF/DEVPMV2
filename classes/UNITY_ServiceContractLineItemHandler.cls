/*
 * @programer: Samuel Astol
 * @date:      11/17/2015
 *
 *    -----------------------------------------------------------------------------
 *    Developer                    Date                Description
 *    -----------------------------------------------------------------------------
 *    Samuel Astol                 11/19/2015          For Sprint1 US328, update UNITY_Has_Preferred_Part__c on Account =
 *                                                     UNITY_Service_Contract_Line_Item_c.UNITY_Service_Contract__r.Account.UNITY_Has_Preferred_Part__c.
 *                                                     UNITY_Has_Preferred_Part__c is true if at least one
 *                                                     UNITY_Service_Contract_Line_Item_c has (UNITY_Is_Preferred_Part__c = true) and it will be false
 *                                                     if all UNITY_Service_Contract_Line_Item_c have (UNITY_Is_Preferred_Part__c = false).
 *                                                     Considerate UNITY_Service_Contract_Line_Item_c with record type FLEET_TO_ACCOUNT and DISTRIBUTOR_TO_FLEET.
 *
 *   
 */
public with sharing class UNITY_ServiceContractLineItemHandler implements UNITY_ITrigger{

    //  < account id , value of UNITY_Has_Preferred_Part__c field  on Account related to (SCLI --> Service Contract  --> Account) >
    private Map< id , boolean >  isAccountPreferredPart  = new Map< id , boolean >();
    //  Service contract map related to SCLI types FLEET_TO_ACCOUNT and DISTRIBUTOR_TO_FLEET
    private Map< id, UNITY_Service_Contract__c  >  serviceContractsMap  = new Map< id , UNITY_Service_Contract__c >();
    // service contract line item ids , only  FLEET_TO_ACCOUNT and DISTRIBUTOR_TO_FLEET record type
    private Set<id> serviceContractLIIds  = new Set<id>();
    
    // key : vendor id  + trade id
    // value : rate price
    private Map<String,Map<String,double>> vendorTrade_requestTypeRate  = new Map<String,Map<String,double>>();
    private Map<id,UNITY_Service_Contract_Line_Item__c> scliId_hourlyRate  = new Map<id,UNITY_Service_Contract_Line_Item__c>();
    private Set<id> vendorPricesToUpdate  = new Set<id>();
    
    public void bulkBefore(){}
    public void bulkAfter(){
    // aux set for query related Service contract US328
        Set<id> serviceContractIds  = new Set<id>();
        Set<id> aux_scliHourlyRateIDs   = new Set<id>();
        list<UNITY_Service_Contract_Line_Item__c> aux_scliHourlyRate = new list<UNITY_Service_Contract_Line_Item__c>();
         
        for (SObject so : Trigger.new){

            UNITY_Service_Contract_Line_Item__c  onSCLI = (UNITY_Service_Contract_Line_Item__c ) so;

/*
            if((onSCLI.RecordTypeId == UNITY_Constants.SCLI_FLEET_TO_ACCOUNT_RECORDTYPE) || (onSCLI.RecordTypeId == UNITY_Constants.SCLI_DISTRIBUTOR_TO_FLEET_RECORDTYPE)){

                serviceContractIds.add(onSCLI.UNITY_Service_Contract__c);
                serviceContractLIIds.add(onSCLI.Id);

            }
 */           
            // check for hourly rate record type, that way we are going to check for price update for vendor trade 
            if(onSCLI.RecordTypeId == UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE){
               aux_scliHourlyRateIDs.add(onSCLI.id);
            }

        }
        
        serviceContractsMap = new Map<id, UNITY_Service_Contract__c>([SELECT id, 
                                                                                UNITY_Account__c, 
                                                                                (   SELECT id FROM UNITY_Service_Contract_Line_Items__r 
                                                                                    WHERE UNITY_Is_Preferred_Part__c = true AND 
                                                                                        id NOT IN :Trigger.newMap.keySet()  AND 
                                                                                        (   (RecordTypeId = :UNITY_Constants.SCLI_FLEET_TO_ACCOUNT_RECORDTYPE) OR
                                                                                            (RecordTypeId = :UNITY_Constants.SCLI_DISTRIBUTOR_TO_FLEET_RECORDTYPE) )
                                                                                ) 
                                                                          FROM UNITY_Service_Contract__c  
                                                                          WHERE id IN :serviceContractIds AND 
                                                                                UNITY_Account__c != null AND 
                                                                                UNITY_IS_Active__c = true ]);
        
        // query SCLI with parent SC details 
        scliId_hourlyRate = new Map<id,UNITY_Service_Contract_Line_Item__c>([SELECT id, 
                                                                                   UNITY_Labor_Cost__c, 
                                                                                   UNITY_Trade__c , 
                                                                                   UNITY_Service_Contract__r.UNITY_Account__c ,
                                                                                   UNITY_Service_Contract__r.UNITY_Default_Labor_Rate__c ,
                                                                                   UNITY_Service_Contract__r.RecordTypeId,
                                                                                   UNITY_Service_Contract__r.RecordType.Name
                                                                             FROM  UNITY_Service_Contract_Line_Item__c
                                                                             WHERE id IN :aux_scliHourlyRateIDs AND
                                                                                   UNITY_Service_Contract__r.UNITY_IS_Active__c = true AND 
                                                                                   UNITY_Service_Contract__r.UNITY_Account_Record_Type__c = 'Vendor']);
        

    }
    
    public void bulkBefore(List<SObject> newList_SCLI, List<SObject> oldList_SCLI, Map<Id,SObject> oldMap_SCLI, Map<Id,SObject> newMap_SCLI){}

    public void bulkAfter(List<SObject> newList_SCLI, List<SObject> oldList_SCLI, Map<Id,SObject> oldMap_SCLI, Map<Id,SObject> newMap_SCLI){   
        
    }

    public void beforeInsert(SObject so){}

    public void beforeUpdate(SObject oldSo, SObject so){}

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject  so){

        UNITY_Service_Contract_Line_Item__c  onSCLI = (UNITY_Service_Contract_Line_Item__c ) so;
/*
        if(serviceContractLIIds.contains(onSCLI.Id) && serviceContractsMap.get(onSCLI.UNITY_Service_Contract__c) != null ){

            id onAccountId = serviceContractsMap.get(onSCLI.UNITY_Service_Contract__c).UNITY_Account__c;

            if((isAccountPreferredPart.get(onAccountId) == null) && onSCLI.UNITY_Is_Preferred_Part__c){

                isAccountPreferredPart.put(onAccountId, true);

            }
        }
        */
        verifyVendorPrice(onSCLI,null);

    }

    public void afterUpdate(SObject oldSo, SObject so){

        UNITY_Service_Contract_Line_Item__c  oldSCLI = (UNITY_Service_Contract_Line_Item__c ) oldSo;
        UNITY_Service_Contract_Line_Item__c  newSCLI = (UNITY_Service_Contract_Line_Item__c ) so;
        /*
        if(serviceContractLIIds.contains(newSCLI.Id) && serviceContractsMap.get(newSCLI.UNITY_Service_Contract__c) != null ){

            if( newSCLI.UNITY_Is_Preferred_Part__c  && (newSCLI.UNITY_Is_Preferred_Part__c != oldSCLI.UNITY_Is_Preferred_Part__c)){

                id onAccountId = serviceContractsMap.get(newSCLI.UNITY_Service_Contract__c).UNITY_Account__c;

                isAccountPreferredPart.put(onAccountId, true);

            }

            if(!newSCLI.UNITY_Is_Preferred_Part__c && (newSCLI.UNITY_Is_Preferred_Part__c != oldSCLI.UNITY_Is_Preferred_Part__c)){

                id onAccountId = serviceContractsMap.get(newSCLI.UNITY_Service_Contract__c).UNITY_Account__c;

                boolean atLeastOneTrueRecord = ( serviceContractsMap.get(newSCLI.UNITY_Service_Contract__c).UNITY_Service_Contract_Line_Items__r.size() > 0 ) ;
                
                if(!atLeastOneTrueRecord && (isAccountPreferredPart.get(onAccountId) == null) ){
                    
                    isAccountPreferredPart.put(onAccountId, false);
                    
                }
            }
        }
        */
        verifyVendorPrice(newSCLI,oldSCLI);
        
    }

    public void afterDelete(SObject so){}

    public void andFinally(){
        
        if ((trigger.isUpdate || trigger.isInsert) && trigger.isAfter){
            updateHasPreferredPartOnAccounts(isAccountPreferredPart);
            updateVendorPrices();
        }
    }
	
    private void verifyVendorPrice(UNITY_Service_Contract_Line_Item__c newSCLI, UNITY_Service_Contract_Line_Item__c oldSCLI){

        boolean noOldValue = (oldSCLI == null )? true : false;
        
       if( (noOldValue || (newSCLI.UNITY_Labor_Cost__c != oldSCLI.UNITY_Labor_Cost__c)) && (scliId_hourlyRate.get(newSCLI.id) != null)){
                
               UNITY_Service_Contract_Line_Item__c scli = scliId_hourlyRate.get(newSCLI.id);
                
               if(vendorTrade_requestTypeRate.get(scli.UNITY_Service_Contract__r.UNITY_Account__c+'-'+scli.UNITY_Trade__c) == null)
                    vendorTrade_requestTypeRate.put(scli.UNITY_Service_Contract__r.UNITY_Account__c+'-'+scli.UNITY_Trade__c , new Map<String,double>());
            
               vendorTrade_requestTypeRate.get(scli.UNITY_Service_Contract__r.UNITY_Account__c+'-'+scli.UNITY_Trade__c).put(
                    UNITY_Constants.WO_RECORDTYPE_ABBR.get(scli.UNITY_Service_Contract__r.RecordType.Name),
                    ((newSCLI.UNITY_Labor_Cost__c==null)? scli.UNITY_Service_Contract__r.UNITY_Default_Labor_Rate__c: newSCLI.UNITY_Labor_Cost__c));
                
               vendorPricesToUpdate.add(scli.UNITY_Service_Contract__r.UNITY_Account__c);
                
        } 
    }
    
    /*
     * @programer   Samuel Astol
     * @date        11/18/2015
     * @description Update the Accounts.UNITY_Has_Preferred_Part__c
     * @param       Map < id account to update , field value to update on UNITY_Has_Preferred_Part__c>
     * @return      void
     *
     */
    private void updateHasPreferredPartOnAccounts(Map<id,boolean>isAccountPreferredPart){

        if(isAccountPreferredPart.size()>0){
            list<Account> accounts =  new list<Account>();
            for( id accountId :isAccountPreferredPart.keySet()){
                Account onAccount = new Account();
                onAccount.id = accountId;
                onAccount.UNITY_Has_Preferred_Part__c = isAccountPreferredPart.get(accountId);
                accounts.add(onAccount);
            }
            update accounts;
        }
    }

	/*
     * @programer   Samuel Astol
     * @date        
     * @description 
     * @param       
     * @return      void
     *
     */
     private void updateVendorPrices(){
         
 		 List<UNITY_Vendor_Trade__c> aux_vendorsTrades = new List<UNITY_Vendor_Trade__c>();
         List<UNITY_Vendor_Trade__c> aux_update_vendorsTrades = new List<UNITY_Vendor_Trade__c>();
         system.debug('## vendorPricesToUpdate '+vendorPricesToUpdate);
         system.debug('## vendorTrade_requestTypeRate '+vendorTrade_requestTypeRate);
         if(vendorPricesToUpdate.size() > 0){
             
             aux_vendorsTrades = [SELECT id, name,Vendor__c, Trade__c, Price_PM__c, Price_SR__c, Price_SS__c, Score_Project__c  
                                  FROM UNITY_Vendor_Trade__c
                                  WHERE Vendor__c IN :vendorPricesToUpdate];
             
             if(aux_vendorsTrades.size() > 0){
                 
                 String vendorTradeKey = '';
                 for(UNITY_Vendor_Trade__c onVTrade :aux_vendorsTrades){
                     
                     vendorTradeKey = onVTrade.Vendor__c+'-'+onVTrade.Trade__c;
                     
                     if(vendorTrade_requestTypeRate.get(vendorTradeKey)!=null){
                         for(String onAbbr :vendorTrade_requestTypeRate.get(vendorTradeKey).keySet()){
                             
                             if(onAbbr == 'SR') onVTrade.Price_SR__c = vendorTrade_requestTypeRate.get(vendorTradeKey).get(onAbbr) ; 
                             if(onAbbr == 'SS') onVTrade.Price_SS__c = vendorTrade_requestTypeRate.get(vendorTradeKey).get(onAbbr) ; 
                             if(onAbbr == 'Project') onVTrade.Price_Project__c = vendorTrade_requestTypeRate.get(vendorTradeKey).get(onAbbr) ; 
                             if(onAbbr == 'PM') onVTrade.Price_PM__c = vendorTrade_requestTypeRate.get(vendorTradeKey).get(onAbbr) ; 
                             
                         }
                         aux_update_vendorsTrades.add(onVTrade);
                     }
                 }
                 
                 update aux_update_vendorsTrades;
             }
             
         }
        
     }


}