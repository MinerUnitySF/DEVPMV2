public with sharing class UNITY_AssetTriggerHandler extends UNITY_BaseHandler {
   
    private Map< id, id> recordIdTemplateId = new Map< id, id>();

    public override void bulkAfter(){
               
        if (Trigger.isInsert || Trigger.isUpdate){
            //applyTemplates();
        }
        
        if (trigger.isUpdate){
            //calculateAccountAssetForUpdate(trigger.new, trigger.oldMap);
            if ( isFirstTriggerRun_AfterUpdate){
              calculateAccountAsset(trigger.new, trigger.oldMap);
            }
        }
        
        if(trigger.isDelete){
            if (isFirstTriggerRun_AfterDelete){
                //calculateAccountAssetForDelete(trigger.old);
                calculateAccountAsset(trigger.old, null);
            }
        }
        
        if(trigger.isInsert || trigger.isUndelete){
            if ( isFirstTriggerRun_AfterInsert){
               //calculateAccountAssetForInsert(trigger.new);
               calculateAccountAsset(trigger.new, null);
            }
        }
    }
    
    public override void bulkBefore(){
        
        if (trigger.isInsert){
            if (isFirstTriggerRun_BeforeInsert){
              UNITY_AutopopulateChildController.autopopulateFieldsIfApplicableBulkified(trigger.new, 'Asset');
            }
        }
    }

    public override void beforeUpdate(SObject oldSO, SObject newSO){
       if (isFirstTriggerRun_BeforeUpdate){
            Asset newAsset = (Asset)newSO;
            Asset oldAsset = (Asset)oldSO;
    
            this.populateLastYearDownServiceTime(newAsset,oldAsset);
            this.populateLastYearTotalCostOwnership(newAsset,oldAsset);
       }
    }

    private void populateLastYearDownServiceTime(Asset newAsset,Asset oldAsset){

        if(newAsset.AccountId == oldAsset.AccountId){
            if((newAsset.UNITY_YTD_Down_Time__c != oldAsset.UNITY_YTD_Down_Time__c)&&((newAsset.UNITY_YTD_Down_Time__c==0)||(newAsset.UNITY_YTD_Down_Time__c==null)))
                newAsset.UNITY_Last_Year_Down_Time__c = oldAsset.UNITY_YTD_Down_Time__c;

            if((newAsset.UNITY_YTD_Service_Time__c != oldAsset.UNITY_YTD_Service_Time__c)&&((newAsset.UNITY_YTD_Service_Time__c ==0)||(newAsset.UNITY_YTD_Service_Time__c==null)))
                newAsset.UNITY_Last_Year_Service_Time__c = oldAsset.UNITY_YTD_Service_Time__c;
        }else{
            newAsset.UNITY_YTD_Down_Time__c    = 0;
            newAsset.UNITY_YTD_Service_Time__c = 0;
            newAsset.UNITY_Last_Year_Down_Time__c    = 0;
            newAsset.UNITY_Last_Year_Service_Time__c = 0;
        }

    }

    private void populateLastYearTotalCostOwnership(Asset newAsset, Asset oldAsset){

        if(newAsset.AccountId == oldAsset.AccountId){
            if((newAsset.UNITY_YTD_Total_Cost_Ownership__c != oldAsset.UNITY_YTD_Total_Cost_Ownership__c)&&(newAsset.UNITY_YTD_Total_Cost_Ownership__c ==0))
                newAsset.UNITY_LY_Total_Cost_Ownership__c = oldAsset.UNITY_YTD_Total_Cost_Ownership__c;
        }else{
            newAsset.UNITY_LY_Total_Cost_Ownership__c  = 0;
            newAsset.UNITY_YTD_Total_Cost_Ownership__c = 0;
        }
    }

    /*
     * Name : calculateAccountAsset
     * Param 1 : List<Sobject> 
     * Param 2 : Map<Id, Sobject>
     * Note    : Update Account.SSVY_Total_Assets__c with the total of child assets 
     */
    private void calculateAccountAsset(List<Sobject> assetList, Map<Id, Sobject> assetMap){

        Set<Id> accountIdSet = new Set<Id>();

        if(trigger.isInsert || trigger.isUndelete || trigger.isDelete){

            for(SObject a : assetList){

                Asset asset = (Asset)a;
                if(asset.AccountId !=null)   accountIdSet.add(asset.AccountId);

            }// END FOR
        }if(trigger.isUpdate){

            for(SObject a : assetList){

                Asset asset    = (Asset)a;
                Asset oldAsset = (Asset)assetMap.get(asset.id);

                if(asset.AccountId != oldAsset.AccountId){
                    if(asset.AccountId    !=null) accountIdSet.add(asset.AccountId);
                    if(oldAsset.AccountId !=null) accountIdSet.add(oldAsset.AccountId);
                }// END IF
            }// END FOR
        }// END ELSE

        if(!accountIdSet.isEmpty()){
            List<Account> toUpdate = new List<Account>();
            List<AggregateResult> counter = [SELECT COUNT(id) numberOfAssets, AccountId FROM Asset WHERE AccountId IN :accountIdSet GROUP BY AccountId];

            Map<Id, Integer> accountIdToAssetCountMap = new Map<Id,Integer>();

            for(AggregateResult count : counter){
                if(count.get('AccountId') != null){
                    accountIdSet.remove((Id)count.get('AccountId'));
                    toUpdate.add(new Account(Id=(id)count.get('AccountId'), SSVY_Total_Assets__c = (Decimal)count.get('numberOfAssets')));
                }
            }

            if(!accountIdSet.isEmpty())
                for(id AccountId : accountIdSet){
                    toUpdate.add(new Account(Id=AccountId, SSVY_Total_Assets__c = 0) );
                }
            update toUpdate;
        }
    }
    /*
    public void applyTemplates(){
        
        List<Asset> assetWithTemplate = new List<Asset>();
        
        for (sObject iter: trigger.new){
            
            Asset assetRecord = (Asset)iter;
            
            if(assetRecord.UNITY_Template_Configuration__c  != null){
                recordIdTemplateId.put(assetRecord.id, assetRecord.UNITY_Template_Configuration__c );
                assetWithTemplate.add(assetRecord);
            }
        }
        
        UNITY_Utils.applyTemplates(recordIdTemplateId, assetWithTemplate, 'UNITY_Template_Configuration__c', 'Asset');             
    }*/

    /*
    private void calculateAccountAsset(List<Sobject> assetList, Map<Id, Sobject> assetMap){
        Set<Id> accountIdSet = new Set<Id>();
        for(SObject a : assetList){
            Asset asset = (Asset)a;
            accountIdSet.add(asset.AccountId);
        }
        if(assetMap != null){
            for(SObject a : assetMap.values()){
                Asset asset = (Asset)a;
                accountIdSet.add(asset.AccountId);
            }
        } 
        List<Account> accounts = [SELECT Id, SSVY_Total_Assets__c FROM Account WHERE Id IN: accountIdSet];
        List<Asset> assets = [SELECT Id, AccountId FROM Asset WHERE AccountId IN: accountIdSet];
        Map<Id, Integer> accountIdToAssetCountMap = new Map<Id,Integer>();
        for(Asset asset : assets){
            if(!accountIdToAssetCountMap.containsKey(asset.AccountId)){
                accountIdToAssetCountMap.put(asset.AccountId, 0);
            }
            accountIdToAssetCountMap.put(asset.AccountId, accountIdToAssetCountMap.get(asset.AccountId) + 1);
        }
        for(Account acc : accounts){
            if(accountIdToAssetCountMap.get(acc.Id) == null){
                acc.SSVY_Total_Assets__c = 0;
            } else {
                acc.SSVY_Total_Assets__c = accountIdToAssetCountMap.get(acc.Id);
            }
        }
        update accounts;
    }*/
    /*
    private void calculateAccountAssetForInsert(List<Sobject> newList){
        Map<Id, Integer> accountIdToAssetNumberMap = new Map<Id, Integer>();
        for(SObject a : newList){
            Asset asset = (Asset)a;
            if(!accountIdToAssetNumberMap.containsKey(asset.AccountId)){
                accountIdToAssetNumberMap.put(asset.AccountId, 0);
            }
            accountIdToAssetNumberMap.put(asset.AccountId, accountIdToAssetNumberMap.get(asset.AccountId) + 1);
            
        }
        List<Account> accounts =[SELECT Id, SSVY_Total_Assets__c FROM Account WHERE Id IN: accountIdToAssetNumberMap.keySet()];
       
        for(Account acc : accounts){
            Decimal currentCount = acc.SSVY_Total_Assets__c == null ? 0 : acc.SSVY_Total_Assets__c;
            acc.SSVY_Total_Assets__c = currentCount + accountIdToAssetNumberMap.get(acc.Id);
        }
        update accounts;
    }
    
    private void calculateAccountAssetForUpdate(List<Sobject> newList, Map<Id, Sobject> oldMap){
        Map<Id, Integer> accountIdToAssetNumberMap = new Map<Id, Integer>();
        for(SObject a : newList){
            Asset asset = (Asset)a;
            Asset oldAsset = (Asset)(oldMap.get(a.Id));
            if(oldAsset.AccountId != asset.AccountId){
                if(!accountIdToAssetNumberMap.containsKey(asset.AccountId)){
                    accountIdToAssetNumberMap.put(asset.AccountId, 0);
                }
                accountIdToAssetNumberMap.put(asset.AccountId, accountIdToAssetNumberMap.get(asset.AccountId) + 1);
                if(!accountIdToAssetNumberMap.containsKey(oldAsset.AccountId)){
                    accountIdToAssetNumberMap.put(oldAsset.AccountId, 0);
                }
                accountIdToAssetNumberMap.put(oldAsset.AccountId, accountIdToAssetNumberMap.get(oldAsset.AccountId) - 1);
            }
            
        }
        List<Account> accounts =[SELECT Id, SSVY_Total_Assets__c FROM Account WHERE Id IN: accountIdToAssetNumberMap.keySet()];
       
        for(Account acc : accounts){
            Decimal currentCount = acc.SSVY_Total_Assets__c == null ? 0 : acc.SSVY_Total_Assets__c;
            acc.SSVY_Total_Assets__c = currentCount + accountIdToAssetNumberMap.get(acc.Id);
        }
        update accounts;
    }
    
    private void calculateAccountAssetForDelete(List<Sobject> oldList){
        Map<Id, Integer> accountIdToAssetNumberMap = new Map<Id, Integer>();
        for(SObject a : oldList){
            Asset asset = (Asset)a;
            if(!accountIdToAssetNumberMap.containsKey(asset.AccountId)){
                accountIdToAssetNumberMap.put(asset.AccountId, 0);
            }
            accountIdToAssetNumberMap.put(asset.AccountId, accountIdToAssetNumberMap.get(asset.AccountId) + 1);
            
        }
        List<Account> accounts =[SELECT Id, SSVY_Total_Assets__c FROM Account WHERE Id IN: accountIdToAssetNumberMap.keySet()];
       
        for(Account acc : accounts){
            Decimal currentCount = acc.SSVY_Total_Assets__c == null ? 0 : acc.SSVY_Total_Assets__c;
            acc.SSVY_Total_Assets__c = currentCount - accountIdToAssetNumberMap.get(acc.Id);
        }
        update accounts;
    }
    */
    
     /**
    *** This variable and method are used to prevent triggers recursion on before insert/update
    */
    public static Boolean isFirstTriggerRun_BeforeInsert = true;
    public static Boolean runTriggerOnce_BeforeInsert(){
        if(isFirstTriggerRun_BeforeInsert){
            isFirstTriggerRun_BeforeInsert = false;
            return true;
        }else{
            return isFirstTriggerRun_BeforeInsert;
        }
    }
   
    public static Boolean isFirstTriggerRun_BeforeUpdate = true;
    public static Boolean runTriggerOnce_BeforeUpdate(){
        if(isFirstTriggerRun_BeforeUpdate){
            isFirstTriggerRun_BeforeUpdate = false;
            return true;
        }else{
            return isFirstTriggerRun_BeforeUpdate;
        }
    }
    /**
    *** This variable and method are used to prevent triggers recursion on after insert/update
    */
    public static Boolean isFirstTriggerRun_AfterUpdate = true;
    public static Boolean runTriggerOnce_AfterUpdate(){
        if(isFirstTriggerRun_AfterUpdate){
            isFirstTriggerRun_AfterUpdate = false;
            return true;
        }else{
            return isFirstTriggerRun_AfterUpdate;
        }
    }
   
    public static Boolean isFirstTriggerRun_AfterDelete = true;
    public static Boolean runTriggerOnce_AfterDelete(){
        if(isFirstTriggerRun_AfterDelete){
            isFirstTriggerRun_AfterDelete = false;
            return true;
        }else{
            return isFirstTriggerRun_AfterDelete;
        }
    }
    
    public static Boolean isFirstTriggerRun_AfterInsert = true;
    public static Boolean runTriggerOnce_AfterInsert(){
        if(isFirstTriggerRun_AfterInsert){
            isFirstTriggerRun_AfterInsert = false;
            return true;
        }else{
            return isFirstTriggerRun_AfterInsert;
        }
    }
}