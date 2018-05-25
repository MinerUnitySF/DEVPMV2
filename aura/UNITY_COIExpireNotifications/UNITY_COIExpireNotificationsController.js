({
	loadMessages : function(component, event, helper) {  
		var action = component.get('c.getExpiredInsurances');        
        
        action.setCallback(this, function(response) {  
            var state = response.getState();             
           
           if ( state ==='ERROR'){
                var errors = response.getError();
                 helper.displayErrorToast(component, 'Error', 'Error to get Insurance expiration notifications. Please refresh the page.');                  
            }
           if (state === "SUCCESS") { 
              var notificationData = response.getReturnValue();
              component.set("v.notifications", notificationData); 
               if ( notificationData != ''){                 
                    helper.displayToast(component, 'Error', 'Insurance expiration notifications.');                  
               }
             }
          });
      $A.enqueueAction(action);
	},
})