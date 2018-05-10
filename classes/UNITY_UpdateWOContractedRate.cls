public class UNITY_UpdateWOContractedRate  implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator([
              SELECT Id, UNITY_Vendor_Contract__r.Id, UNITY_Contracted_Rate__c, UNITY_Trade__c
                          FROM WorkOrder
                         WHERE UNITY_Contracted_Rate__c = null
                         AND Status != 'Canceled'
                         AND UNITY_Vendor_Contract__c != null
                         AND UNITY_Trade__c != null
                         AND RecordTypeId = '012310000011urpAAA'
             			 AND UNITY_Business_Unit__c in ('MNS','NSBS')
             			 AND CreatedDate >= 2017-07-01T00:00:00Z
             ]);
    }
    
    public void execute(Database.BatchableContext context, List<WorkOrder> scope) {
        Map<Id, Id> woContractMap = new Map<Id, Id>();
        for (WorkOrder wo: scope){
            woContractMap.put(wo.Id, wo.UNITY_Vendor_Contract__r.Id);
        }
        
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        Map<Id, UNITY_Service_Contract__c> vendorContractMap = new Map<Id,UNITY_Service_Contract__c> ([SELECT Id, UNITY_Default_Labor_Rate__c, Name, 
                                                                                                       (SELECT UNITY_Labor_Cost__c, UNITY_Trade__c,  UNITY_Trade__r.Name
                                                                                                        FROM UNITY_Service_Contract_Line_Items__r 
                                                                                                        WHERE RecordTypeId = :UNITY_Constants.SCLI_HOURLY_RATE_RECORDTYPE
                                                                                                       	ORDER BY LastModifiedDate desc
                                                                                                       )
                                                                                                       FROM UNITY_Service_Contract__c WHERE Id = :woContractMap.values()]);
        
        for (WorkOrder wo: scope){
            UNITY_Service_Contract__c vendorContract = vendorContractMap.get(wo.UNITY_Vendor_Contract__c);
            system.debug('@@@vendorContract'+vendorContract.Name);
            wo.UNITY_Contracted_Rate__c = vendorContract.UNITY_Default_Labor_Rate__c;
            if (vendorContract != null && vendorContract.UNITY_Service_Contract_Line_Items__r.size() > 0){
                system.debug('@@@unity trade:'+wo.UNITY_Trade__c);
                for (UNITY_Service_Contract_Line_Item__c scli: vendorContract.UNITY_Service_Contract_Line_Items__r){
                    system.debug('@@@applied rate scli'+scli);
                    if (wo.UNITY_Trade__c == scli.UNITY_Trade__c){
                        system.debug('@@@applied rate scli match'+scli);
                        wo.UNITY_Contracted_Rate__c = scli.UNITY_Labor_Cost__c;
                        break;
                    }
                }
            }
            woToUpdate.add(wo);
        }
        
        update woToUpdate;
			 
    }
    
     public void finish(Database.BatchableContext context) {
    }
 
}