/*------------------------------------------------------------
Name:           UNITY_CaseTrigger 
Author:         SFDC UNITY Team
Company:        Miner
Description:    This trigger call the UNITY processes on cases 
=====================================================
Changelog
=====================================================
Developer:      Izay Ramos
Description:    Added call to set business unit on case before any unity code executes
Date:           1/20/2016
=====================================================
------------------------------------------------------------*/
trigger UNITY_CaseTrigger on Case (before insert, after insert, before update, after update) {

    private static Set<Id> PMCaseSet = new Set<Id>{UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE,
                                    UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE};
    public static List<SObject> new_SR_Cases = UNITY_Utils.excludeRecordType(trigger.new, PMCaseSet );
    public static Map<Id, SObject> oldMap_SR_Cases = UNITY_Utils.excludeRecordType(Trigger.oldMap, PMCaseSet );
    public static Map<Id, SObject> newMap_SR_Cases = UNITY_Utils.excludeRecordType(Trigger.newMap, PMCaseSet );
    
    //Izay: Added to populate business unit before any unity process runs
    if(Trigger.isInsert && Trigger.isBefore){
        UNITY_CaseTriggerHandler_Miner.setCaseBusinessUnitFromUserBusinessUnit(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        //Clay: Added to handle work order agent matching to case.
        //send the case to the casetriggerhandlerminer
        UNITY_CaseTriggerHandler_Miner.updateAgentonWOs(newMap_SR_Cases, oldMap_SR_Cases );

    }

    Map<Id, Schema.RecordTypeInfo> defaultRecordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById().clone();
    defaultRecordTypeMap .remove(UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE);
    defaultRecordTypeMap .remove(UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE);

    //Handler that processes record types = PM and Program Case
    UNITY_TriggerFactory.createAndExecuteHandler(UNITYPM_CaseTriggerHandler_Miner.class, PMCaseSet);   

    //Handler for all other record types
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_CaseHandler.class, defaultRecordTypeMap.keySet() );
    UNITY_TriggerFactory.createAndExecuteHandler(UNITY_CaseTriggerHandler_Miner.class, defaultRecordTypeMap.keySet() );


    
}