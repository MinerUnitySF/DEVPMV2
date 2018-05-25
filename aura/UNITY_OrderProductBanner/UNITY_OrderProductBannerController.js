({
	myAction : function(component, event, helper) {
		var action = component.get("c.getOrderItem");
        action.setParams({
	            "recordId": component.get("v.recordId")
	        });
        action.setCallback(this, function(data) {
        	component.set("v.Item", data.getReturnValue());
        });
    	$A.enqueueAction(action);
	}
})