@isTest
public class UNITY_AuraLoginRequestController_UT {

    public static testMethod void sendTestEmail(){
        Integer expectedLimits = 0;
        Integer actualLimits = Limits.getEmailInvocations();
        System.debug('@@@UNITY_AuraLoginRequestController_UT actualLimits:'+actualLimits);
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');

        boolean isSuccess = UNITY_AuraLoginRequestController.sendLoginRequestEmail('John Doe', '123 Company', 'aliso', 'ca', '92656', '9495551234', 'dklfj@kdljf.com');
        system.assert(isSuccess, true);
        
        expectedLimits = 1;
        actualLimits = Limits.getEmailInvocations();
        System.debug('@@@UNITY_AuraLoginRequestController_UT actualLimits:'+actualLimits);
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');
    }
}