global class UNITY_ScheduleFixWOManualShareFix implements Schedulable
{
    global void execute(SchedulableContext sc)    {
        
        UNITY_FixWorkOrderManualSharing fixWOShare = new UNITY_FixWorkOrderManualSharing ();
        Integer batchSize = 30;
        database.executebatch(fixWOShare,30);
    }
   
}