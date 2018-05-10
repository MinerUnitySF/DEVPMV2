/**
 * Created by mbesmonte on 5/3/2018.
 */

public with sharing class DocumentTriggerHandler extends UNITY_BaseHandler{

    public override void bulkAfter(){

        if (trigger.isInsert){
            //Check if there is an attachment

        }
    }
}