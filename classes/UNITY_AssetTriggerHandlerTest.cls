@isTest
public class UNITY_AssetTriggerHandlerTest{

    public static testMethod void runTest(){

        Map<String,Object> accountFields               = UNITY_TestDataFactory.MOCKUP_ACCOUNT_FIELDS;  


        //Account acc = new Account(Name = 'Test', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
        accountFields.put('Type','Site/Location' );
        accountFields.put('RecordTypeId', UNITY_Constants.ACCOUNT_CUSTOMER_RECORDTYPE );
        Account acc =  (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        insert acc;
        
        //Account acc2 = new Account(Name = 'Test2', Type= 'Site/Location', BillingCity = 'City', BillingStateCode = 'CA', BillingPostalCode = '12345', BillingCountry = 'US', BillingStreet = 'Street', Account_Email__c = 'test2@test.com');
        Account acc2 = (Account) UNITY_TestDataFactory.createObject(1, Account.getSObjectType(), accountFields).get(0);
        insert acc2;
        
        Asset asset = new Asset(Name = 'Test', AccountId = acc.Id);
        insert asset;
        
        acc = [SELECT SSVY_Total_Assets__c FROM Account WHERE Id =: acc.Id];
        system.assertEquals(1, acc.SSVY_Total_Assets__c);
        
        asset.AccountId = acc2.Id;
        update asset;
        
        acc = [SELECT SSVY_Total_Assets__c FROM Account WHERE Id =: acc.Id];
        system.assertEquals(0, acc.SSVY_Total_Assets__c);
        acc2 = [SELECT SSVY_Total_Assets__c FROM Account WHERE Id =: acc2.Id];
        system.assertEquals(1, acc2.SSVY_Total_Assets__c);
        
        delete asset;
        acc2 = [SELECT SSVY_Total_Assets__c FROM Account WHERE Id =: acc2.Id];
        system.assertEquals(0, acc2.SSVY_Total_Assets__c);

		UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterUpdate = true;        
        UNITY_AssetTriggerHandler.runTriggerOnce_BeforeInsert();
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterUpdate = false;        
        UNITY_AssetTriggerHandler.runTriggerOnce_BeforeInsert();
        
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterInsert = true;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterInsert();
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterInsert = false;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterInsert();
        
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterDelete = true;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterDelete();
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterDelete = false;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterDelete();
        
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterUpdate = true;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterUpdate();
        UNITY_AssetTriggerHandler.isFirstTriggerRun_AfterUpdate = false;
        UNITY_AssetTriggerHandler.runTriggerOnce_AfterUpdate();
        
        UNITY_AssetTriggerHandler.isFirstTriggerRun_BeforeUpdate = true;
        UNITY_AssetTriggerHandler.runTriggerOnce_BeforeUpdate();
        UNITY_AssetTriggerHandler.isFirstTriggerRun_BeforeUpdate = false;
        UNITY_AssetTriggerHandler.runTriggerOnce_BeforeUpdate();
            
    }
}