public class UNITY_WorkOrderLineItemTriggerHandler extends UNITY_BaseHandler{

    private Set<Id>     countWOOnAssetIds = new Set<Id>();

    public override void bulkAfter(){

    }

    public override void afterUpdate(SObject oldSO , SObject newSO ){
        if (isFirstTriggerRun_AfterUpdate){
            WorkOrderLineItem newWOLI = (WorkOrderLineItem)newSO;
            WorkOrderLineItem oldWOLI = (WorkOrderLineItem)oldSO;
            if (newWoli.UNITY_PM_WOLI__c != true)
                this.checkAsset(newWOLI,oldWOLI);
        }
    }

    public override void afterInsert(SObject so){
        if (isFirstTriggerRun_AfterInsert){
            WorkOrderLineItem woli = (WorkOrderLineItem)so;
            if (woli.UNITY_PM_WOLI__c != true)
                this.checkAsset(woli);
        }
    }

    public override void beforeDelete(SObject so){
        WorkOrderLineItem woli = (WorkOrderLineItem)so;

        system.debug('@@@UNITY_WorkOrderLineItemTriggerHandler beforeDelete');
        //Check if WO is PM, do not allow delete
        //if (woli.UNITY_PM_WOLI__c == true)
        //    woli.addError('You cannot delete work order line items from a Preventative Maintenance Work Order');

    }

    public override void afterDelete(SObject so){
        if (isFirstTriggerRun_AfterDelete){
          WorkOrderLineItem woli = (WorkOrderLineItem)so;
          if (woli.UNITY_PM_WOLI__c != true)
            this.checkAsset(woli);
        }
    }


    public override void andFinally(){


       if(!this.countWOOnAssetIds.isEmpty() && !UNITY_Constants.isExecutingContext('UNITY_WorkOrderLineItemTriggerHandler.countWorkOrdersOnAsset'))
          if(!this.countWOOnAssetIds.isEmpty()) countWorkOrdersOnAsset(countWOOnAssetIds);

    }

   //private methods 
    private void checkAsset(WorkOrderLineItem woli){
        system.debug('//Clay - Entering checkAsset for WOLIs. Should avoid for PM WOLIs.');
        if((woli!=null) && (woli.AssetId!=null)) this.countWOOnAssetIds.add(woli.AssetId);
    }

    private void checkAsset(WorkOrderLineItem newWOLI, WorkOrderLineItem oldWOLI){

        Boolean changeAsset = (newWOLI.AssetId != oldWOLI.AssetId);

        if(changeAsset){
            if(newWOLI.AssetId != null)
              this.countWOOnAssetIds.add(newWOLI.AssetId);
            if(oldWOLI.AssetId != null)
                this.countWOOnAssetIds.add(oldWOLI.AssetId);
        }
    }

    @future
    private static void countWorkOrdersOnAsset(Set<id> assetIds){
        UNITY_Utils.countWorkOrdersOnAsset(assetIds, Asset.getSObjectType());
    }

    
   
    /**
    *** This variable and method are used to prevent triggers recursion on after insert/update
    */
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
     public static Boolean isFirstTriggerRun_AfterUpdate = true;
    public static Boolean runTriggerOnce_AfterUpdate(){
        if(isFirstTriggerRun_AfterUpdate){
            isFirstTriggerRun_AfterUpdate = false;
            return true;
        }else{
            return isFirstTriggerRun_AfterUpdate;
        }
    }

}