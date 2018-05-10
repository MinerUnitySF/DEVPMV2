public with sharing class UNITY_ServiceContractHandler extends UNITY_BaseHandler{
    
    public List<Account> accountWithDeletedServiceContract = new List<Account>();
    
    private Set<id> getPricesFromSC = new Set<id>();
    
    private Set<Id> scToBeDeleted   = new Set<Id>();
    
    Map<Id, Decimal> serviceContractNewValue = new Map<Id, Decimal>();
    
    public override void bulkBefore(List<SObject> newList_SC, List<SObject> oldList_SC, Map<Id,SObject> oldMap_SC, Map<Id,SObject> newMap_SC){}
    
    public override void bulkAfter(List<SObject> newList_SC, List<SObject> oldList_SC, Map<Id,SObject> oldMap_SC, Map<Id,SObject> newMap_SC){
        
        if (!trigger.isDelete){
            
            //if UNITY_Has_Preferred_Part__c field has changed, update account
            for (SObject iter: newList_SC){
                //UNITY_Service_Contract__c oldSC = (UNITY_Service_Contract__c) iter;
                UNITY_Service_Contract__c newSC = (UNITY_Service_Contract__c) newMap_SC.get(iter.Id);
            }
        }
    }
    
    public override void afterInsert(SObject  so){
        UNITY_Service_Contract__c newSC = (UNITY_Service_Contract__c) so;
        if( newSC.UNITY_IS_Active__c && (newSC.UNITY_Account_Record_Type__c =='Vendor')) getPricesFromSC.add(newSC.id);
    }
    
    public override void afterUpdate(SObject oldSo, SObject so){
        UNITY_Service_Contract__c oldSC = (UNITY_Service_Contract__c) oldSo;
        UNITY_Service_Contract__c newSC = (UNITY_Service_Contract__c) so;
        
        if (oldSC.UNITY_Has_Preferred_Part__c != newSC.UNITY_Has_Preferred_Part__c)serviceContractNewValue.put(newSC.Id, newSC.UNITY_Has_Preferred_Part__c);
        
        if( newSC.UNITY_IS_Active__c && (newSC.UNITY_Account_Record_Type__c =='Vendor') && (oldSC.UNITY_IS_Active__c!= newSC.UNITY_IS_Active__c) ){
                  
            getPricesFromSC.add(newSC.id);
        }
        
    }
    
    public override void afterDelete(SObject so){
        
        UNITY_Service_Contract__c oldSC = (UNITY_Service_Contract__c) so;
        
         scToBeDeleted.add(oldSC.Id);
        
    }
    
    public override void andFinally(){
                
        /*for (Account acc: accountWithDeletedServiceContract){
                
            acc.UNITY_Has_Preferred_Part__c = false;
        }
        
        List<Account> accountsToUpdate = [select id, UNITY_Service_Contract__c, UNITY_Has_Preferred_Part__c from Account where UNITY_Service_Contract__c in: serviceContractNewValue.keySet()];
        
        for (Account acc: accountsToUpdate){
            
            acc.UNITY_Has_Preferred_Part__c = serviceContractNewValue.get(acc.UNITY_Service_Contract__c) != 0;
        }
        
        accountsToUpdate.addAll(accountWithDeletedServiceContract);
        update accountsToUpdate;*/
        preferredPartHandler();
        
        updateVendorPrices();
        
    }
    
    private void preferredPartHandler(){
        
        List<Account> accountsToUpdate = new List<Account> ();
        
        if(Trigger.isDelete && (scToBeDeleted.size()>0)){
            
            accountsToUpdate = [select id, UNITY_Has_Preferred_Part__c, UNITY_Service_Contract__c from Account where id in :scToBeDeleted];
                
            for (Account acc: accountWithDeletedServiceContract){
                    
                acc.UNITY_Has_Preferred_Part__c = false;
        	}
        }
        
        if(Trigger.isUpdate && (serviceContractNewValue.size()>0)){
            
             accountsToUpdate = [select id, UNITY_Service_Contract__c, UNITY_Has_Preferred_Part__c from Account where UNITY_Service_Contract__c in: serviceContractNewValue.keySet()];
            
            for (Account acc: accountsToUpdate){
                
                acc.UNITY_Has_Preferred_Part__c = serviceContractNewValue.get(acc.UNITY_Service_Contract__c) != 0;
            }
        }
        
        if(accountsToUpdate.size()>0)update accountsToUpdate;
		
        
    }
    
    private void updateVendorPrices(){
         
 		 List<UNITY_Vendor_Trade__c> aux_vendorsTrades = new List<UNITY_Vendor_Trade__c>();
         List<UNITY_Vendor_Trade__c> aux_update_vendorsTrades = new List<UNITY_Vendor_Trade__c>();
         List<UNITY_Service_Contract__c> aux_sc = new List<UNITY_Service_Contract__c>();
         Set<id> vendorPricesToUpdate = new Set<id>();
         Map<String,Map<String,double>> vendorTrade_requestTypeRate  = new Map<String,Map<String,double>>();
         Map<String,Map<String,double>> vendor_requestTypeRate = new  Map<String,Map<String,double>>();
  
         if(getPricesFromSC.size() > 0){
             
             aux_sc = [SELECT id, 
                              UNITY_Account__c ,
                              UNITY_Default_Labor_Rate__c ,
                              RecordTypeId,
                              RecordType.Name,
                              (SELECT ID, UNITY_Labor_Cost__c, UNITY_Trade__c 
                               FROM UNITY_Service_Contract_Line_Items__r  //AND UNITY_Labor_Cost__c <> null
                               WHERE RecordTypeId = :UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE  )
                       FROM UNITY_Service_Contract__c
                       WHERE id IN :getPricesFromSC];
             
             for(UNITY_Service_Contract__c sc :aux_sc){
                 
                 if(sc.UNITY_Service_Contract_Line_Items__r.size()>0){
                     
                     for(UNITY_Service_Contract_Line_Item__c scli :sc.UNITY_Service_Contract_Line_Items__r){
                         
                         //UNITY_Service_Contract_Line_Item__c  scli = sc.UNITY_Service_Contract_Line_Items__r.get(0);
                     
                         if(vendorTrade_requestTypeRate.get(sc.UNITY_Account__c+'-'+scli.UNITY_Trade__c) == null)
                            vendorTrade_requestTypeRate.put(sc.UNITY_Account__c+'-'+scli.UNITY_Trade__c , new Map<String,double>());
                    
                         vendorTrade_requestTypeRate.get(sc.UNITY_Account__c+'-'+scli.UNITY_Trade__c).put(
                            UNITY_Constants.WO_RECORDTYPE_ABBR.get(sc.RecordType.Name),
                            ((scli.UNITY_Labor_Cost__c==null)? sc.UNITY_Default_Labor_Rate__c: scli.UNITY_Labor_Cost__c));
                         
                         
                     }
                    // vendorPricesToUpdate.add(sc.UNITY_Account__c);
                 }else{
                     
                     if(vendor_requestTypeRate.get(sc.UNITY_Account__c) == null)
                         vendor_requestTypeRate.put(sc.UNITY_Account__c, new Map<String,double>());
                    
                     vendor_requestTypeRate.get(sc.UNITY_Account__c).put(
                         UNITY_Constants.WO_RECORDTYPE_ABBR.get(sc.RecordType.Name),
                          ((sc.UNITY_Default_Labor_Rate__c==null)? null: sc.UNITY_Default_Labor_Rate__c));
                     
                 }
                 vendorPricesToUpdate.add(sc.UNITY_Account__c);
                 
             }
             //UNITY_TestDataFactory.testLog('#### sam '+vendorTrade_requestTypeRate.keySet().size()); 
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
                     }else if(vendor_requestTypeRate.get(onVTrade.Vendor__c) !=null){
                         
                         for(String onAbbr :vendor_requestTypeRate.get(onVTrade.Vendor__c).keySet()){
                             if(onAbbr == 'SR') onVTrade.Price_SR__c = vendor_requestTypeRate.get(onVTrade.Vendor__c).get(onAbbr) ; 
                             if(onAbbr == 'SS') onVTrade.Price_SS__c = vendor_requestTypeRate.get(onVTrade.Vendor__c).get(onAbbr) ; 
                             if(onAbbr == 'Project') onVTrade.Price_Project__c = vendor_requestTypeRate.get(onVTrade.Vendor__c).get(onAbbr) ; 
                             if(onAbbr == 'PM') onVTrade.Price_PM__c = vendor_requestTypeRate.get(onVTrade.Vendor__c).get(onAbbr) ; 
                         }
                         aux_update_vendorsTrades.add(onVTrade);
                     }
                 }
                 
                 update aux_update_vendorsTrades;
             }
             
         }
        
     }
    
}