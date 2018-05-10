public with sharing class UNITYPM_ServiceContractHandler extends UNITY_BaseHandler{
    

	public override void bulkBefore(List<SObject> newList_SC, List<SObject> oldList_SC, Map<Id,SObject> oldMap_SC, Map<Id,SObject> newMap_SC){
        system.debug('@@@UNITYPM_ServiceContractHandler');
        if (trigger.isInsert){
           Set<ID> accIDs = new Set <ID>();
            for (SObject obj: newList_SC){
              UNITY_Service_Contract__c srvCnt = (UNITY_Service_Contract__c)obj;
              
              srvCnt.UNITY_Miner_IVR_Required__c = true;
              srvCnt.UNITY_Customer_IVR_Required__c = true;
              
              if ( srvCnt.UNITY_IS_Active__c != false)
                   accIDs.add(srvCnt.UNITY_Account__c) ;
            }
            
          if ( accIDs.size() > 0) { 
            List<UNITY_Service_Contract__c> srvCntList =  [SELECT UNITY_Business_Unit__c , UNITY_Account__c, RecordType.Name, UNITY_IS_Active__c, UNITY_BU_MNS_SC_ID__c 
                    FROM UNITY_Service_Contract__c  
                         WHERE UNITY_Account__c IN :accIDs 
                            AND RecordType.Name = 'Preventative Maintenance' AND UNITY_IS_Active__c = true];
            if ( srvCntList.size() > 0){
               for (UNITY_Service_Contract__c srvCnt :srvCntList) {
                   string buMNS = srvCnt.UNITY_Account__c + srvCnt.RecordType.Name + srvCnt.UNITY_Business_Unit__c;
                   if ( buMNS == srvCnt.UNITY_BU_MNS_SC_ID__c ){
                    newList_SC[0].addError('You can not add a New Preventative Maintenance Service Contract. This Vendor Account contains this type of contract and it is Active.');
                   }
               }
            }
          }
        }
    }
}