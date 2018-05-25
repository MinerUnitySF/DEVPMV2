({
    redirectToAccount: function(component, event, helper) {
        var loggedInUser;
        var state;
        var navEvt;
        
        var action = component.get("c.getLoggedInUser");
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === 'SUCCESS'){
                var loggedInUser = data.getReturnValue();
                if (loggedInUser === undefined || loggedInUser.Contact=== undefined || loggedInUser.Contact.AccountId === undefined){
                    var navEvent = $A.get("e.force:navigateToObjectHome");
                    navEvent.setParams({
                        "scope": "Account"
                    });
                    navEvent.fire();
                }
                else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": loggedInUser.Contact.AccountId,
                        "slideDevName": "detail"
                    });
					navEvt.fire();
                }
            }
            else{
                var navEvent = $A.get("e.force:navigateToObjectHome");
                navEvent.setParams({
                    "scope": "Account"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})