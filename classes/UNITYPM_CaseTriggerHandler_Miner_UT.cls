@isTest
public class UNITYPM_CaseTriggerHandler_Miner_UT {
    @testSetup
    public static void testSetup(){
        
    }

    public testMethod static void createUpdateProgramCase(){
        List<Account> accts = new List<Account>();
        Account cust = TestDataProvider.getAccounts(1,'Customer', 'Customer')[0];
        cust.Account_Status__c = 'Active';
        cust.UNITY_Customer_Team__c = 'Team 1';
        cust.UNITY_MNS_Customer_Team__c = 'Team 1';
        cust.UNITY_Tier_Level__c = 'Tier 1';
        accts.add(cust);
        
        Account custSite = TestDataProvider.getAccounts(1,'Customer', 'Site/Location')[0];
        custSite.Account_Status__c = 'Active';
        custSite.UNITY_Customer_Team__c = 'Team 1';
        custSite.UNITY_MNS_Customer_Team__c = 'Team 1';
        custSite.UNITY_Tier_Level__c = 'Tier 1';
        accts.add(custSite);
        
		Account custSite2 = TestDataProvider.getAccounts(1,'Customer', 'Site/Location')[0];
        custSite2.Account_Status__c = 'Active';
        custSite2.UNITY_Customer_Team__c = 'Team 1';
        custSite2.UNITY_MNS_Customer_Team__c = 'Team 1';
        custSite2.UNITY_Tier_Level__c = 'Tier 1';
        accts.add(custSite2);
        

        Account buNSBS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];buNSBS.UNITY_Business_Unit__c = 'NSBS';accts.add(buNSBS);
        Account buMNS = TestDataProvider.getAccounts(1,'Miner','Business Unit')[0];buMNS.UNITY_Business_Unit__c = 'MNS';accts.add(buMNS);
        insert accts;
        
        
        List<UNITY_Service_Contract__c> scList = new List<UNITY_Service_Contract__c>();
        
        UNITY_Service_Contract__c testServiceContract1 = new UNITY_Service_Contract__c( UNITY_Account__c = cust.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract1);
        
        UNITY_Service_Contract__c testServiceContract2 = new UNITY_Service_Contract__c( UNITY_Account__c = custSite.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract2);
        
        UNITY_Service_Contract__c testServiceContract3 = new UNITY_Service_Contract__c( UNITY_Account__c = custSite2.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract3);

        UNITY_Service_Contract__c testServiceContract4 = new UNITY_Service_Contract__c( UNITY_Account__c = custSite.Id, UNITY_Margin__c = 10, 
        							UNITY_Invoicing_Method__c = 'Email', RecordTypeId = UNITY_Constants.SC_PREVENTATIVE_MAINTENANCE_RECORDTYPE,  UNITY_IS_Active__c = true,
        							UNITY_Business_Unit__c = 'MNS', UNITYPM_PMO_NTE__c = 500.00);

        scList.add(testServiceContract4);        

        insert scList;
                
        Case c = new Case();
        c.AccountId = cust.Id;
        c.UNITY_Customer__c = cust.Id;
        c.RecordTypeId = UNITY_Constants.CASE_PROGRAM_CASE_RECORDTYPE;
        c.Status = 'New';
        c.UNITY_Business_Unit__c = 'MNS';
        c.UNITY_Business_Unit_Account__c = buMNS.Id;
        c.UNITY_Skill_Broad__c = 'Glass';
		insert c;
        
        
        
        Case c2 = new Case();
        c2.AccountId = custSite.Id;
        c2.UNITY_Customer__c = custSite.Id;
        c2.UNITY_Business_Unit__c = 'MNS';
        c2.UNITY_Business_Unit_Account__c = buMNS.Id;
        c2.UNITY_Skill_Broad__c = 'Glass';
        c2.RecordTypeId = UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE;
        c2.ParentId = c.Id;
        c2.Status = 'New';
	    insert c2;
    
    
    	WorkOrder wo = [SELECT Id, UNITY_Business_Unit__c FROM WorkOrder WHERE CaseId = :c2.Id LIMIT 1];
    	system.assert(wo != null);

		Test.startTest();
		system.assert(c2.RecordTypeId == UNITY_Constants.CASE_PREVENTATIVE_MAINTENANCE_RECORDTYPE);    	

		UNITY_Constants.executionsPerTrigger.put('UNITYPM_CaseTriggerHandler_Miner',1);
		system.debug('@@@UNITYPM_CaseTriggerHandler_Miner beforeUpdate START');      
    	//update Case
    	c2.AccountId = custSite2.Id;
    	update c2;


    	wo = [SELECT Id, UNITY_Customer__c FROM WorkOrder WHERE CaseId = :c2.Id LIMIT 1];
    	SYSTEM.debug('@@@createUpdateProgramCase wo:'+wo);

		system.assert(wo.UNITY_Customer__c == custSite2.Id);    	


    	c2.Status = 'Cancelled';
    	c2.Reason = 'Customer Cancelled';
        update c2;
		//List<Case> cases = new List<Case>();
        //cases = [SELECT Id,UNITY_Skill_ID__c,UNITY_Skill_ID_1__c,UNITY_Skill_ID_2__c FROM Case];
        Test.stopTest();

    }
}