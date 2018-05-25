({    
    loadDocTypes: function(component, event, helper) {
        var action = component.get("c.getDocumentTypes");
        
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === 'SUCCESS'){
                component.set("v.docTypes", data.getReturnValue());
                window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our default value
                        component.find("docSelection").set("v.value", data.getReturnValue()[0]);
                    }));
            }
        });
        $A.enqueueAction(action);
    },
    downloadPDF: function(component, event, helper){
        var recordId = component.get("v.recordId");
        var documentType = component.find("docSelection").get("v.value");
        var siteURL = '';
        console.log(recordId);
        console.log(documentType);
        
        var action = component.get("c.getURL");
        action.setCallback(this, function(data) {
            var state = data.getState();
            if (state === 'SUCCESS'){
                siteURL = data.getReturnValue();
                console.log(siteURL);
            }
        });
        $A.enqueueAction(action);
        
        // Generating Pdf  through VisualForce Page
        window.setTimeout(
            $A.getCallback(function() {
                // visualforce page URL 
                window.open(siteURL + "/apex/UNITY_BarcodeCoverPage?Id="+recordId+"&docType="+documentType, '_blank', 'fullscreen=yes');
            }), 1000
        );
        
    }
})