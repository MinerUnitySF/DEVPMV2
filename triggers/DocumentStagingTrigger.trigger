/**
 * Created by mbesmonte on 5/3/2018.
 */

trigger DocumentStagingTrigger on Document_Staging__c (after update) {
    system.debug('@@@DocumentStagingTrigger after update');
}