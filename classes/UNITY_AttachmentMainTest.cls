/*------------------------------------------------------------
Name:          UNITY_AttachmentMainTest
Author:        Krishna Kameneni
Company:       Miner
Description:   This class contains unit tests for validating the behavior of trigger UNITY_AttachmentMain
History:
01/27/2016     Krishna Kameneni(Perficient)    Added/Modified comments
                                                 ,Indentation 
                                                 Added test method
------------------------------------------------------------*/
@isTest

private class UNITY_AttachmentMainTest{
    static testMethod void testUpdateAttachmentCompliant(){
        System.Test.startTest();
       // List<Account> accounts = UNITY_TestDataFactory.createAccounts(2);
        List<Account> accounts = new List<Account>();
        for(Integer index=0; index<2; index++) {
            //Account account = createAccount('Name'+index);
            String aa = Account.UNITY_Customer_Team__c.getDescribe().getPicklistValues().get(0).getValue();
            Account acc = new Account(Name='Name'+index);
            acc.BillingStateCode = 'NY';
            //account.UNITY_Customer_Team__c = aa;
            acc.Type ='Customer';
            acc.RecordTypeId = UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE;
            acc.UNITY_TimeZoneSidKey__c = 'America/Chicago';
            acc.BillingCity = 'billingCity'+index;
            acc.BillingStateCode = 'NY';
            acc.BillingStreet = '123 Fake St.';
            acc.BillingPostalCode = '123456';
            acc.UNITY_SSN__c = '222-22-2222';
            acc.Account_Status__c = 'Active';
            accounts.add(acc);
        }
        insert accounts;
        //List<Contact> contacts = UNITY_TestDataFactory.createContacts(2,accounts.get(0).Id);
        List<Contact> contacts = new List<Contact>();
        for(Integer index=0; index<2; index++) {
            Contact contact = new Contact(FirstName='FirstName'+index,
                                          LastName='LastName'+index,
                                          AccountId= accounts.get(0).Id,
                                          Email='email@home'+index+'.com');
            contacts.add(contact);
        }
        insert contacts;
        //List<Case> cases = UNITY_TestDataFactory.createCases(2,accounts.get(0).Id,accounts.get(1).Id,contacts.get(0).Id,UNITY_Constants.CASE_SERVICE_REQUEST_RECORDTYPE);
        List<Case> cases = new List<Case>();
        for(Integer index=0; index<2 ;index++) {
            Case acase = new Case();
            acase.AccountId = accounts.get(0).Id;
            //acase.UNITY_Customer__c = customerId;
            acase.ContactId = contacts.get(0).Id;
            acase.Status = 'Verified';
            cases.add(acase);
        }
        
        List<UNITY_Service_Contract__c> serviceContracts = UNITY_TestDataFactory.createServiceContracts(1, accounts[0].Id);
        
        insert cases;
        //List<WorkOrder> workOrders = UNITY_TestDataFactory.createWorkOrders(2,cases.get(0).Id, accounts[0].Id, UNITY_Constants.WO_SERVICE_REQUEST_RECORDTYPE);
         List<WorkOrder> workOrders = new List<WorkOrder>();
         for(Integer index=0; index<2; index++) {
            WorkOrder workOrder = new WorkOrder();
            workOrder.Subject = 'Subject-'+index;
            workOrder.CaseId = cases.get(0).Id;
            if(accounts[0].Id != NULL) {
                workOrder.UNITY_Customer__c = accounts[0].Id;  
            }
            workOrder.UNITY_Customer_PIN__c = UNITY_Utils.generateRandomPin();
            workOrder.UNITY_Vendor_PIN__c = UNITY_Utils.generateRandomPin();
            workOrder.UNITY_Vendor_Status__c = UNITY_Constants.WO_STATUS_ASSIGNED;
            workOrder.UNITY_Customer_Service_Contract__c = serviceContracts[0].Id;
            workOrders.add(workOrder);
        }
        insert workOrders;
        UNITY_Service_Contract__c serviceContract =new UNITY_Service_Contract__c();
        serviceContract.UNITY_Required_Documentation__c = 'Copy of Supplier Parts;Customer Required Sign Off';
        serviceContract.UNITY_Account__c=accounts.get(0).Id;
        insert serviceContract;
        WorkOrder wo =workOrders.get(0);
        wo.UNITY_Customer_Service_Contract__c =serviceContract.Id; 
        update wo;
        //WorkOrder wo1 =[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id='a4O180000008YV0EAM' LIMIT 1];
        UNITY_Attachment__c attachment1 = new UNITY_Attachment__c();
        attachment1.Work_Order__c =wo.Id;
        attachment1.UNITY_Type__c ='Copy of Supplier Parts';
        insert attachment1;
        WorkOrder updatedWorkOrder =[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id = :wo.id];
        System.assertEquals(false, updatedWorkOrder.UNITY_Attachment_Compliant__c);
        /*UNITY_Attachment__c attachment2 = new UNITY_Attachment__c();
        attachment2.Work_Order__c =wo.Id;
        attachment2.UNITY_Type__c ='Copy of Vendor Invoices';
        insert attachment2;
        WorkOrder updatedWorkOrder1 =[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id = :wo.id];
        System.assertEquals(false, updatedWorkOrder1.UNITY_Attachment_Compliant__c);
        attachment1.UNITY_Type__c ='Customer Required Sign Off';*/
        update attachment1;
        //WorkOrder updatedWorkOrder2 =[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id = :wo.id];
        //System.assertEquals(false, updatedWorkOrder2.UNITY_Attachment_Compliant__c);
        //attachment1.UNITY_Type__c ='Copy of Supplier Parts';
        //update attachment1;
        //WorkOrder updatedWorkOrder3 =[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id = :wo.id];
       // System.assertEquals(true, updatedWorkOrder3.UNITY_Attachment_Compliant__c);
        
        delete attachment1;
        //WorkOrder updatedWorkOrder4=[SELECT UNITY_Attachment_Compliant__c FROM WorkOrder WHERE id = :wo.id];
       // System.assertEquals(false, updatedWorkOrder4.UNITY_Attachment_Compliant__c);
        
        System.Test.stopTest();
    }
   
    private static void createuser(Contact c){        
        User admin = TestDataProvider.getUser('Tim', 'System_Admin', 'System Administrator');
        system.runAs(admin){
			Profile p = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
            system.debug('@@@p:'+p);

            User user = new User();
            user.ProfileID = p.id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = 'test@adfadf.com';   
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = c.Id;
            insert user;
        }
    }
    
    static testMethod void testShareAttachmentToVendor(){
        
	    System.Test.startTest();
        RecordType srRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Service_Request' AND SObjectType = 'Case'];

        //Create Accounts - customer and vendor
        Map<String,Object> accountFields = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;  
        accountFields.put('Type','Site/Location' );
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE );
        accountFields.put('Account_Status__c', 'Active' );
        
        List<Account> accountList = new List<Account>();
        
        Account acc = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accountList.add(acc);
        
        Account customer = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accountList.add(customer);
        
        Account vendorAccount = new Account();
        vendorAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_VENDOR_RECORDTYPE;
        vendorAccount.Name = 'Test Vendor Account';
        vendorAccount.Type = 'Site/Location';
        vendorAccount.BillingCity = 'Brooklyn';
        vendorAccount.BillingStateCode = 'NY';
        vendorAccount.BillingStreet = '123 Fake St.';
        vendorAccount.BillingPostalCode = '123456';
        vendorAccount.Account_Status__c = 'Active';
        accountList.add(vendorAccount);
        insert accountList;

        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.Email='test@test.com';
        c.AccountId = vendorAccount.Id;
        insert c;
        
        createuser(c);     
        
        Case caseRecord = new Case();
        caseRecord.Status = 'Verified';
        caseRecord.RecordTypeId = srRT.Id;
        caseRecord.UNITY_Customer__c = customer.Id;
        caseRecord.ContactId = c.Id;
        caseRecord.UNITY_Business_Unit__c = 'MNS';
        insert caseRecord;
        
        UNITY_Service_Contract__c vendorContract = new UNITY_Service_Contract__c();
        vendorContract.UNITY_Account__c = vendorAccount.Id;
        vendorContract.UNITY_Trip_Charge__c = 10;
        vendorContract.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
        vendorContract.UNITY_Default_Labor_Rate__c = 75;
        vendorContract.UNITY_Invoicing_Increments__c = 'Next ¼ hr';
        vendorContract.UNITY_Business_Unit__c = 'MNS';
        vendorContract.UNITY_IS_Active__c = true;
        vendorContract.RecordTypeId = UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE;
        insert vendorContract;
        
        WorkOrder wo = new WorkOrder();
        wo.UNITY_Customer__c = customer.Id;
        wo.Status = 'New';
        wo.AccountId = acc.Id;
        wo.UNITY_Assigned_Vendor__c = vendorAccount.Id;
        wo.CaseId = caseRecord.Id;
        wo.Subject='Test';
        wo.UNITY_Work_Window_Begin__c = Datetime.now();
        wo.UNITY_Accepted_Vendor__c = vendorAccount.Id;
        wo.UNITY_Vendor_Status__c = 'Accepted';
        wo.UNITY_Vendor_Contract__c = vendorContract.Id;
        wo.UNITY_Customer_Service_Contract__c = vendorContract.Id;        
        insert wo;
        
        
        UNITY_Attachment__c attachment1 = new UNITY_Attachment__c();
        attachment1.Work_Order__c =wo.Id;
        attachment1.UNITY_Type__c ='Completed Survey';
        insert attachment1;
        
        List<UNITY_Attachment__Share> s = [SELECT Id, ParentID, UserOrGroupID FROM UNITY_Attachment__Share WHERE RowCause = :Schema.UNITY_Attachment__Share.RowCause.Vendor_Community__c];
        System.debug('@@@Share:'+s);
        System.assert(s.size() > 0);
        List<Group> groupList = [SELECT Id, RelatedID FROM Group WHERE Id = :s[0].UserOrGroupID];
		System.debug('@@@groupList:'+groupList);        
        List<UserRole> ur = [SELECT Id, PortalAccountId FROM UserRole WHERE Id = :groupList[0].RelatedID];
        System.debug('@@@ur:'+ur);        
        Account acct = [select name from account where id = :ur[0].PortalAccountId];
        system.debug('@@@acct:'+acct);
        
        
        UNITY_AttachmentUtilities.unShareAttachmentToVendor(new List<UNITY_Attachment__c> {attachment1});
        System.Test.stopTest();
    }   
    
    static testMethod void testPopulateCustomerUltimateParentText(){
		System.Test.startTest();
        
        RecordType srRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'UNITY_Service_Request' AND SObjectType = 'Case'];

        //Create Accounts - customer and vendor
        Map<String,Object> accountFields = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;  
        accountFields.put('Type','Site/Location' );
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE );
        accountFields.put('Account_Status__c', 'Active' );
        
        List<Account> accountList = new List<Account>();
        
        Account acc = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accountList.add(acc);
        
        Account customer = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        accountList.add(customer);
        
        Account vendorAccount = new Account();
        vendorAccount.RecordTypeId  = UNITY_Constants.ACCOUNT_MINER_RECORDTYPE;
        vendorAccount.Name = 'Test Vendor Account';
        vendorAccount.Type = 'Site/Location';
        vendorAccount.BillingCity = 'Brooklyn';
        vendorAccount.BillingStateCode = 'NY';
        vendorAccount.BillingStreet = '123 Fake St.';
        vendorAccount.BillingPostalCode = '123456';
        vendorAccount.Account_Status__c = 'Active';
        accountList.add(vendorAccount);
        insert accountList;

        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.Email='test@test.com';
        c.AccountId = vendorAccount.Id;
        insert c;
        
        createuser(c);     
        
        Case caseRecord = new Case();
        caseRecord.Status = 'Verified';
        caseRecord.RecordTypeId = srRT.Id;
        caseRecord.UNITY_Customer__c = customer.Id;
        caseRecord.ContactId = c.Id;
        caseRecord.UNITY_Business_Unit__c = 'MNS';
        insert caseRecord;
        
        UNITY_Service_Contract__c vendorContract = new UNITY_Service_Contract__c();
        vendorContract.UNITY_Account__c = vendorAccount.Id;
        vendorContract.UNITY_Trip_Charge__c = 10;
        vendorContract.UNITY_Trip_Charge_Type__c = 'Hourly Rate';
        vendorContract.UNITY_Default_Labor_Rate__c = 75;
        vendorContract.UNITY_Invoicing_Increments__c = 'Next ¼ hr';
        vendorContract.UNITY_Business_Unit__c = 'MNS';
        vendorContract.UNITY_IS_Active__c = true;
        vendorContract.RecordTypeId = UNITY_Constants.SC_SERVICE_REQUEST_RECORDTYPE;
        insert vendorContract;
        
        WorkOrder wo = new WorkOrder();
        wo.UNITY_Customer__c = customer.Id;
        wo.Status = 'New';
        wo.AccountId = acc.Id;
        wo.UNITY_Assigned_Vendor__c = vendorAccount.Id;
        wo.CaseId = caseRecord.Id;
        wo.Subject='Test';
        wo.UNITY_Work_Window_Begin__c = Datetime.now();
        wo.UNITY_Accepted_Vendor__c = vendorAccount.Id;
        wo.UNITY_Vendor_Status__c = 'Accepted';
        wo.UNITY_Vendor_Contract__c = vendorContract.Id;
        wo.UNITY_Customer_Service_Contract__c = vendorContract.Id;        
        insert wo;
        
        
        UNITY_Attachment__c attachment1 = new UNITY_Attachment__c();
        attachment1.Work_Order__c =wo.Id;
        attachment1.UNITY_Type__c ='Copy of Supplier Parts';
        insert attachment1;
        
        wo = [SELECT UNITY_Customer__r.UNITY_Company__c FROM WorkOrder WHERE Id = :wo.Id];
        system.debug('@@@wo:'+wo.UNITY_Customer__r.UNITY_Company__c);
        
		attachment1 = [SELECT Customer_Ultimate_Parent_Text__c FROM UNITY_Attachment__c WHERE Id = :attachment1.Id];
        system.debug('@@@attachment1:'+attachment1.Customer_Ultimate_Parent_Text__c);
        
        System.assertEquals(wo.UNITY_Customer__r.UNITY_Company__c, attachment1.Customer_Ultimate_Parent_Text__c);
          
    }
}