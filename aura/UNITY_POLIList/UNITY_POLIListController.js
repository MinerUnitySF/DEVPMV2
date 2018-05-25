({
	myAction : function(component, event, helper) {
	var action = component.get("c.getOrderItemList");
        action.setParams({
	            "orderId": component.get("v.recordId")
	        });
        action.setCallback(this, function(data) {
        component.set("v.polis", data.getReturnValue());
        });
    $A.enqueueAction(action);

	},
    
    navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var poli = component.get("v.polis")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: poli.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+poli.Id+'/view'
        }
    }
    
})