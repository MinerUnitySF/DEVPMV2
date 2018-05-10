/*
 *   @programer:    Rodrigo Birriel
 *   @description:  handle the user trigger.
 *   @date:         12/15/2015            
 */
public class UNITY_UserTriggerHandler extends UNITY_BaseHandler {
    
    public override void bulkAfter() {
        try {
            handleUserSkillVendorsFlow();
            // just for testing enabling for update
            if(Trigger.isInsert) {
                createManualSharing();   
                  
               //added 
               List<Id> accountIds = new List<Id>();
                for(User user : (List<User>)Trigger.new) {
                    if(user.AccountId != null && user.IsPortalEnabled == true) {
                        accountIds.add(user.AccountId);
                    }
                }
               if (accountIds.size()> 0)
                  userCustomerPortalAccount(accountIds);
                  
            }
        } catch(Exception ex) {
            for(User user : (List<User>)Trigger.new) {
                user.addError(ex.getMessage());
            }
        }
        
    }
    
     @future
    private static void userCustomerPortalAccount(List<ID> accountIds){
         List<Account> accUpdate = new List<Account>();
         
         for (Account acc: [SELECT Id, IsCustomerPortal, UNITY_Has_Community_Member__c FROM Account  WHERE Id IN :accountIds] ){
                System.debug('#### acc.UNITY_Has_Community_Member__c  ####' + acc.UNITY_Has_Community_Member__c);
                acc.UNITY_Has_Community_Member__c = acc.IsCustomerPortal;
                accUpdate.add(acc);
         }
        
          System.debug('#### accUpdate ####' + accUpdate);
          
         if (accUpdate.size()> 0)
            update accUpdate;
    }
    
    private void handleUserSkillVendorsFlow() {
        If(Trigger.isInsert) {
            List<Id> accountIds = new List<Id>();
            // retrieve the partner technician vendor record
            Profile partnerTechnicianVendor = [SELECT Id FROM Profile 
                                                       WHERE Name =:UNITY_Constants.PROFILE_PARTNER_TECHNICIAN_VENDOR_NAME]; 
            
            // discard the users who are not technician vendor. 
            List<User> usersAsTechnicianVendor = new List<User>();
            for(User user : (List<User>)Trigger.new) {
                
                if(user.AccountId != null && user.ProfileId == partnerTechnicianVendor.Id) {
                    accountIds.add(user.AccountId);
                    usersAsTechnicianVendor.add(user);
                }
            }
            System.debug('usersAsTechnicianVendor :'+usersAsTechnicianVendor);
            if(!usersAsTechnicianVendor.isEmpty()) {
                List<Id> skillIds = new List<Id>();
                List<Id> userIds = new List<Id>();
                List<FSO__SkillUser__c> skillUsers = new List<FSO__SkillUser__c>();
                // iterate over the vendor trade associated to the user,
                // to create and add the skill for each user.
                // exclude Miner Region Office accounts (based on record type MINER or the new Boolean field)
                for(UNITY_Vendor_Trade__c vendorTrade : [SELECT Id,Vendor__c,Trade__c FROM UNITY_Vendor_Trade__c 
                                                        WHERE Vendor__c IN (SELECT Id FROM Account 
                                                                            WHERE Id IN :accountIds AND 
                                                                            RecordTypeId != : UNITY_Constants.ACCOUNT_MINER_RECORDTYPE )]) {
                    for(User user: usersAsTechnicianVendor) {
                        if(user.AccountId == vendorTrade.Vendor__c) {
                            skillIds.add(vendorTrade.Trade__c);
                            userIds.add(user.Id);
                        }
                    }             
                }
                System.debug('skillUsers :'+usersAsTechnicianVendor);
                //both list should have the same size (skillIds,userIds)
                if(!skillIds.isEmpty()) {
                    UNITY_UserTriggerHandler.createSkillUsersOnfuture(skillIds,userIds);
                }   
            }
        }
    }
    
    // prevent MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have 
    // updated a non-setup object (or vice versa): FSO__SkillUser__c, original object: User.
    @future
    private static void createSkillUsersOnfuture(List<Id> skillIds,List<Id> userIds) {
        List<FSO__SkillUser__c> skillUsers = new List<FSO__SkillUser__c>();
        for(Integer i=0; i<skillIds.size(); i++){
            skillUsers.add(new FSO__SkillUser__c(FSO__User__c=userIds.get(i),
                                                FSO__Skill__c=skillIds.get(i)));
        }
        insert skillUsers;
    } 
    
    // Update manual sharing with workorders related to the user.Contact.Account.
    private void createManualSharing() {
        
        Profile unityCustomer = [SELECT Id FROM Profile 
                                 WHERE Name = 'UNITY_Customer'];
        System.debug(' ---> users :'+Trigger.new);
        if(unityCustomer != null) {
            List<SObject> sobjects = new List<SObject>();
            List<Id> userOrGroupIds = new List<Id>();
            
            //retrieve the users associated to the accounts
            System.debug(' ---> users :'+Trigger.new);
            Map<Id,List<Id>> accountIdUserIdMap = new Map<Id,List<Id>>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> oldAccountIds = new Set<Id>();
            for(User user : (List<User>)Trigger.new) {
                if(user.AccountId != null && user.ProfileId == unityCustomer.Id) {
                    if(accountIdUserIdMap.get(user.AccountId) == null) {
                        accountIdUserIdMap.put(user.AccountId, new List<Id>());
                    }
                    accountIdUserIdMap.get(user.AccountId).add(user.Id);   
                }
            }
            System.debug(' ---> accountIdUserIdMap :'+accountIdUserIdMap);
            if(accountIdUserIdMap.size() > 0){
                System.debug(' ---> workorders :'+[SELECT Id, AccountId FROM WorkOrder]);
                for(WorkOrder workorder : [SELECT Id, AccountId FROM WorkOrder 
                                           WHERE AccountId IN:accountIdUserIdMap.keySet()]) {
                    for(Id userId : accountIdUserIdMap.get(workorder.AccountId)) {
                        userOrGroupIds.add(userId);
                        sobjects.add(workorder);
                    } 
                }
                             
               System.debug('creating manual sharing'+sobjects+userOrGroupIds);
               UNITY_SharingUtil.manualShareCreateReadOnlyBulk(sobjects,userOrGroupIds,WorkOrderShare.SObjectType);
            }   
        }

    }
    
}