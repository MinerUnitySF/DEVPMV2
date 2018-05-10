public class UNITY_AuraLoginRequestController {
    
    @AuraEnabled
    public static boolean sendLoginRequestEmail(String name, String companyName, String city, String state, String zip, String phone, String email){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        if (Label.UNITY_Community_Request_Login_Email_Recipient != null){
            
            User u = [SELECT Name FROM User WHERE Id = :Label.UNITY_Community_Request_Login_Email_Recipient];
            String recipientName = u != null ? u.Name : '';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);            
            mail.setTargetObjectId(Label.UNITY_Community_Request_Login_Email_Recipient);
            mail.setSubject('Login ID Request for Service Provider Community');
            String mailBody = '<html><body><h3>Hi '+ u.Name +', </h3><br/><h4>Please create a Service Provider login for: </h4><br/> <table> <tr><td>Name</td><td><b>' + name + '</b></td></tr><tr><td>Company Name</td><td><b>' + companyName + '</b></td></tr><tr><td>City</td><td><b>' + city + '</b></td></tr><tr><td>State</td><td><b>' + state + '</b></td></tr><tr><td>Zip Code</td><td><b>' + zip +'</b></td></tr><tr><td>Contact Number</td><td><b>' + phone + '</b></td></tr><tr><td>Contact Email</td><td><b>' + email +'</b></td></tr></table></body></html>';
            mail.setHtmlBody(mailBody); 
            mailList.add(mail);
            
            Messaging.SendEmailResult[] sendEmailResult = Messaging.sendEmail(mailList);  
            
            return sendEmailResult[0].isSuccess();
        }
        else
            return false;
    }
}