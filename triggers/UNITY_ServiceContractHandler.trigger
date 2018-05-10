trigger UNITY_ServiceContractHandler on UNITY_Service_Contract__c (before insert, before update, after delete, after insert, after undelete, 
after update, before delete) {
    //get all record types
    Map<Id, Schema.RecordTypeInfo> defaultRecordTypeMap = Schema.SObjectType.UNITY_Service_Contract__c.getRecordTypeInfosById().clone();
    defaultRecordTypeMap.remove(UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE);

    //define PM record type    
    private static Set<Id> PMRecordTypeSet = new Set<Id>{UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE};
    
    
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_ServiceContractHandler.class, defaultRecordTypeMap.keySet());
    UNITY_TriggerFactory.createAndExecuteHandler(UNITYPM_ServiceContractHandler.class, PMRecordTypeSet );

}