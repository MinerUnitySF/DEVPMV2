({
    generateNewDocumentStagingRecord : function(component, event, helper) {
        var action = component.get("c.generateNewDocumentStaging");
        component.set("v.isFirstPage", false);
        action.setCallback(this, function (data){
            var state = data.getState();
            var docStagingId = data.getReturnValue();
            if (state === 'SUCCESS' && docStagingId != undefined){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": docStagingId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
            else{
                //If there is an error, navigate back to Account
                var navEvent = $A.get("e.force:navigateToObjectHome");
                navEvent.setParams({
                    "scope": "Account"
                });
                navEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    setFirstPage : function(component, event, helper) {
        component.set("v.isFirstPage", true);
    },
    
    getStagingItems: function(component, event, helper){
        var action = component.get("c.getDocumentStagingList");
        action.setCallback(this, function(data) {
            console.log( data.getReturnValue());
            component.set("v.stagingList", data.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})