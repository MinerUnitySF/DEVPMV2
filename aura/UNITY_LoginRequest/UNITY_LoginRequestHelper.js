({
    getStateCodes : function(component){
        component.set('v.states', ['AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','PR','RI','SC','SD','TN','TX','UT','VT','VI','VA','WA','WV','WI','WY']);
    },
    
    sendEmailHelper : function(component, name, companyName, city, state, zip, phone, email) {
        var action = component.get("c.sendLoginRequestEmail");
        action.setParams({
            'name': name,
            'companyName': companyName,
            'city':city,
            'state':state,
            'zip':zip,
            'phone':phone,
            'email':email           
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.emailStatus", true);
                component.set("v.isOpen", false);
            }
 
        });
        $A.enqueueAction(action);
	}
})