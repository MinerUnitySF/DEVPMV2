({
	myAction : function(component, event, helper) {
	var action = component.get("c.getAttachmentWrapper");
        action.setParams({
	            "recordId": component.get("v.recordId")
	        });
        action.setCallback(this, function(data) {
        component.set("v.attachmentWrapper", data.getReturnValue());
        });
    $A.enqueueAction(action);

	},
    
    navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var attachment = component.get("v.attachmentWrapper.attachmentList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: attachment.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+attachment.Id+'/view'
        }
    },
    
    navigateToWorkOrder : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var attachment = component.get("v.attachmentWrapper.attachmentList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: attachment.Work_Order__r.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+attachment.Id+'/view'
        }
    },
    
})