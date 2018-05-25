({
    search : function(component, event, helper) {
        if (event.getParams().keyCode == 13){
			helper.goSearch(component, event);
        }
    },
    handleClick : function(component, event, helper) {
        helper.goSearch(component, event);
    }
    
})