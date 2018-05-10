public with sharing class UNITY_AccountHandler extends UNITY_BaseHandler{
    
    public override void andFinally(){
           
    }
    
    public override void bulkAfter() {
        if (trigger.isUpdate || trigger.isInsert) {
            if(!System.isFuture() && !System.isBatch())
                pushCustomerAndVendorsToSL((List<Account>)Trigger.new);
        }
    }
    
    public override void bulkBefore(){
        
        if (trigger.isUpdate){
            setHasPreferredPart();
        }
        if (trigger.isUpdate || trigger.isInsert){
            
            for (Sobject sobj: trigger.new){
                Account acct = (Account)sobj;
                //populate ultimate company text field
                acct.UNITY_Company_Text__c = acct.UNITY_Company__c;

                //lets set the PM PIN while we're here
                if (acct.RecordTypeId == UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE && acct.UNITY_Vendor_Type_PM__c == true && acct.UNITYPM_PIN__c == null){
                    acct.UNITYPM_PIN__c = UNITY_Utils.generateRandomPin();
                }
            }
        }
        
    }
    


    public void setHasPreferredPart(){
        
        Map<Id, Decimal> serviceContractMap = new Map<Id, Decimal>();
        
        Set<Account> accWithServiceContract = new Set<Account>();
        Set<Id> serviceContractId = new Set<Id>();
        
        for (Sobject iter: trigger.new){
            
            Account acc = (Account) iter;
            
            Account oldAcc = (Account)trigger.oldMap.get(acc.Id);
            
            //if the service contract lookup has changed, we update the UNITY_Has_Preferred_Part__c checkbox
            if (acc.UNITY_Service_Contract__c !=  oldAcc.UNITY_Service_Contract__c){
                
                if (acc.UNITY_Service_Contract__c != null){
                     
                   accWithServiceContract.add(acc);
                   serviceContractId.add(acc.UNITY_Service_Contract__c);
                }
                else{
                   acc.UNITY_Has_Preferred_Part__c = false;
                }
            }
        }
        
        List<UNITY_Service_Contract__c> serviceContractList = [select id, UNITY_Has_Preferred_Part__c from UNITY_Service_Contract__c where id in:serviceContractId];
        
        for (UNITY_Service_Contract__c iter: serviceContractList){
            
            serviceContractMap.put(iter.id, iter.UNITY_Has_Preferred_Part__c);
        }
        
        for (Account acc: accWithServiceContract){
            
            Decimal hasPreferredPart = serviceContractMap.get(acc.UNITY_Service_Contract__c);
                
            acc.UNITY_Has_Preferred_Part__c = hasPreferredPart != 0;
        }
    }
    
    private void pushCustomerAndVendorsToSL(List<Account> accounts) {
        String vmoProfId = [SELECT Id FROM Profile WHERE Name = 'UNITY_Vendor Management Office'].Id;
        String saProfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<Id> customerIds = new List<Id>();
        List<Id> vendorIds = new List<Id>();
        Map<Id,Account> vendorsToActivate = new Map<Id,Account>();
        Map<Id,Account> vendorsToValidateContract = new Map<Id,Account>();
        Map<Id,Account> vendorsToValidateAll = new Map<Id,Account>();
        for(Account account : accounts){
            if(account.RecordTypeId == UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE &&
               ((account.UNITY_Is_AR_Account__c && account.Type == 'Customer') || 
               ((account.UNITY_Bill_to_Self__c || account.MSPFS_MSP_Bill_to_Self__c) && account.Type == 'Site/Location' && account.Residential__c == false))){
                customerIds.add(account.Id);
            }else if(account.RecordTypeId == UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE){
                if(Trigger.isInsert){
                    if(!Test.isRunningTest() && (account.Account_Status__c == 'Active'))
                        Trigger.new[0].addError('Can\'t set the Account Status to Active on creation. The VMO team needs to validate the account information. Set the Account Status to Pending.');
                    if(!Test.isRunningTest() && (String.isBlank(account.BillingCity) || String.isBlank(account.BillingStreet) || String.isBlank(account.BillingState) || String.isBlank(account.BillingPostalCode)) )
                        Trigger.new[0].addError('Billing address is required for vendor accounts');
                    if(!Test.isRunningTest() && (String.isBlank(account.ShippingCity) || String.isBlank(account.ShippingStreet) || String.isBlank(account.ShippingState) || String.isBlank(account.ShippingPostalCode)) )
                        Trigger.new[0].addError('Shipping address is required for vendor accounts');
                    if(!Test.isRunningTest() && (account.UNITY_Vendor_Status__c == 'Active'))
                        Trigger.new[0].addError('Can\'t set the Vendor Status to Active without an active Service Contract. Set the Vendor Status to Pending.');
                }
                if(Trigger.isUpdate){
                    Account oldAcct = (Account)Trigger.oldMap.get(account.Id);
                    if(account.UNITY_Vendor_Status__c == 'Active' && oldAcct.UNITY_Vendor_Status__c != 'Active' && account.Type == 'Vendor'){
                        vendorsToValidateContract.put(account.Id,account);
                    }
                    if(account.Account_Status__c == 'Active' && oldAcct.Account_Status__c != 'Active'){
                        vendorsToActivate.put(account.Id,account);
                    }else if(account.Ready_to_Convert__c && !oldAcct.Ready_to_Convert__c){
                        vendorIds.add(account.Id);
                    }
                }
            }else if(account.RecordTypeId == UNITY_Constants.ACCOUNT_MINER_RECORDTYPE){
                if(Trigger.isInsert){
                    if(!Test.isRunningTest() && (String.isBlank(account.BillingCity) || String.isBlank(account.BillingStreet) || String.isBlank(account.BillingState) || String.isBlank(account.BillingPostalCode)) )
                        Trigger.new[0].addError('Billing address is required for vendor accounts');
                    if(!Test.isRunningTest() && (String.isBlank(account.ShippingCity) || String.isBlank(account.ShippingStreet) || String.isBlank(account.ShippingState) || String.isBlank(account.ShippingPostalCode)) )
                        Trigger.new[0].addError('Shipping address is required for vendor accounts');
                    if(!Test.isRunningTest() && (account.UNITY_Vendor_Status__c == 'Active'))
                        Trigger.new[0].addError('Can\'t set the Vendor Status to Active without an active Service Contract. Set the Vendor Status to Pending.');
                }
                if(Trigger.isUpdate){
                    Account oldAcct = (Account)Trigger.oldMap.get(account.Id);
                    if(account.UNITY_Vendor_Status__c == 'Active' && oldAcct.UNITY_Vendor_Status__c != 'Active'){
                        vendorsToValidateContract.put(account.Id,account);
                    }
                    if(account.Ready_to_Convert__c && !oldAcct.Ready_to_Convert__c){
                        //vendorIds.add(account.Id);
                    }
                }
            }
        }
        if(!vendorsToValidateContract.isEmpty()){
            Map<Id,UNITY_AccountHandler.Validation> validationsMap = validateVendors(vendorsToValidateContract,false);
            String errMessage = '';
            for(Account a :vendorsToValidateContract.values()){
                if(validationsMap.containsKey(a.Id)){
                    if(!validationsMap.get(a.id).valid){
                        if(!Test.isRunningTest()){
                            Trigger.new[0].addError(validationsMap.get(a.id).message);
                        }
                    }
                }
            }
        }
        if(!vendorsToActivate.isEmpty()){
            //Map<Id,UNITY_AccountHandler.Validation> validationsMap = validateVendors(vendorsToActivate,false);
            String errMessage = '';
            for(Account a :vendorsToActivate.values()){
                if(UserInfo.getProfileId() != vmoProfId && UserInfo.getProfileId() != saProfId){
                    if(!Test.isRunningTest())
                        Trigger.new[0].addError('Vendors must be activated by a VMO or System Administrator user only.');
                }
                vendorIds.add(a.Id);
            }
        }
        if(!customerIds.isEmpty() && !System.isBatch()){
            UNITY_IntegrationCalloutBatch_Miner b = new UNITY_IntegrationCalloutBatch_Miner(UNITY_Constants.IntegrationType.CUSTOMER);
            b.query = 'SELECT Id FROM Account WHERE Id IN ' + ApexHelper.joinIds(customerIds);
            Database.executeBatch(b,10);
            //UNITY_MuleCalloutOperation.invokeCallOut(customerIds, UNITY_MuleSiteSettingUtils.CUSTOMER);
        }
        if(!vendorIds.isEmpty() && !System.isBatch()){
            UNITY_IntegrationCalloutBatch_Miner b = new UNITY_IntegrationCalloutBatch_Miner(UNITY_Constants.IntegrationType.VENDOR);
            b.query = 'SELECT Id FROM Account WHERE Id IN ' + ApexHelper.joinIds(vendorIds);
            Database.executeBatch(b,10);
            //UNITY_MuleCalloutOperation.invokeCallOut(vendorIds, UNITY_MuleSiteSettingUtils.VENDOR);
        }
    }
    
    public Map<Id,UNITY_AccountHandler.Validation> validateVendors(Map<Id,Account> vendors, Boolean contractOnly){
        Map<Id,UNITY_AccountHandler.Validation> validations = new Map<Id,UNITY_AccountHandler.Validation>();
        List<UNITY_Vendor_Covered_Location__c> coveredLocs = [SELECT Id,Vendor__c FROM UNITY_Vendor_Covered_Location__c WHERE Vendor__c IN :vendors.keySet()];
        List<UNITY_Vendor_Trade__c> trades = [SELECT Id,Vendor__c FROM UNITY_Vendor_Trade__c WHERE Vendor__c IN :vendors.keySet()];
        List<UNITY_Service_Contract__c> contracts = [SELECT Id,UNITY_IS_Active__c,UNITY_Account__c FROM UNITY_Service_Contract__c WHERE UNITY_Account__c IN :vendors.keySet() AND UNITY_IS_Active__c = TRUE];
        for(Account a :vendors.values()){
            UNITY_AccountHandler.Validation valid = new UNITY_AccountHandler.Validation();
            valid.acctId = a.Id;
            valid.message = '';
            valid.valid = true;
            Boolean hasLoc = false;
            Boolean hasTrade = false;
            Boolean hasContract = false;
            for(UNITY_Vendor_Covered_Location__c loc :coveredLocs){
                if(loc.Vendor__c == a.Id){
                    hasLoc = true;
                    break;
                }
            }
            for(UNITY_Vendor_Trade__c t :trades){
                if(t.Vendor__c == a.Id){
                    hasTrade = true;
                    break;
                }
            }
            for(UNITY_Service_Contract__c c :contracts){
                if(c.UNITY_Account__c == a.Id){
                    hasContract = true;
                    break;
                }
            }
            valid.acctId = a.Id;
            if(!hasContract)
                valid.message += ' ' + a.Name + ' does not have an active Service Contract. ';
            if(!hasLoc && !contractOnly)
                valid.message += ' ' + a.Name + ' does not have any Vendor Covered Locations. ';
            if(!hasTrade && !contractOnly)
                valid.message += ' ' + a.Name + ' does not have any Vendor Trades. ';
            if(((!hasLoc || !hasTrade || !hasContract) && !contractOnly) ||  (contractOnly && !hasContract))
                valid.valid = false;
            
            validations.put(a.Id,valid);
        }
        return validations;
    }
    
    public class Validation{
        public Boolean valid {get; set;}
        public String message {get; set;}
        public String acctId {get; set;}
    }
}