({
    doInit : function(component, event, helper){
        helper.getStateCodes(component);
    },
	sendMail : function(component, event, helper) {
        
		var name = component.get("v.customerName");
        var nameComponent = component.find("customerName");
        var companyName = component.get("v.companyName");
        var companyNameComponent = component.find("companyName");
        var city = component.get("v.city");
        var cityComponent = component.find("city");
        var state = component.find("state").get("v.value");   	
        var zip = component.get("v.zip");
        var zipComponent = component.find("zip");
        var phone = component.get("v.phone");
        var phoneComponent = component.find("phone");
        var email = component.get("v.email");
        var emailComponent = component.find("email");
        
        if (name == null)
            nameComponent.set("v.errors", [{message:"Required Field."}]);
        else
            nameComponent.set("v.errors", null);
        
        if (companyName == null)
            companyNameComponent.set("v.errors", [{message:"Required Field."}]);
        else
            companyNameComponent.set("v.errors", null);
        
        if (city == null)
            cityComponent.set("v.errors", [{message:"Required Field."}]);
        else
            cityComponent.set("v.errors", null);
        
        if (zip == null)
            zipComponent.set("v.errors", [{message:"Required Field."}]);
        else
            zipComponent.set("v.errors", null);
        
        if (phone == null)
            phoneComponent.set("v.errors", [{message:"Required Field."}]);
        else
            phoneComponent.set("v.errors", null);
        
        
        if (email == null)
            emailComponent.set("v.errors", [{message:"Required Field."}]);
        else{
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
            if (!email.match(regExpEmailformat))
                emailComponent.set("v.errors", [{message:"Enter a valid email."}]);
            else
            	emailComponent.set("v.errors", null);
        }
        
        if (name != null && companyName != null && city != null && zip != null && phone != null && email != null){
        	helper.sendEmailHelper(component, name, companyName, city, state, zip, phone, email);
        }
        
	},
    validateEmail: function(emailComponent) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        return emailComponent.match(regExpEmailformat);
    }, 
    openModal : function(component, event, helper) {
		component.set("v.isOpen", true);
	},
    cancel : function(component, event, helper) {
		component.set("v.isOpen", false);
	},
    closeMessage: function(component, event, helper) {
		component.set("v.emailStatus", false);
        component.set("v.customerName", '');
        component.set("v.companyName", '');
	},
    handleError: function(component, event){
        var errorsArr  = event.getParam("v.errors");
        for (var i = 0; i < errorsArr.length; i++) {
            console.log("error " + i + ": " + JSON.stringify(errorsArr[i]));
        }
    },
    handleClearError: function(component, event) {
        //clear errors if needed
    }

})