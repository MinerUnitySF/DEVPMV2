({
  displayToast : function(component, type, message) {
    var toastEvent = $A.get('e.force:showToast');
     
        toastEvent.setParams({
              title: 'Warning',
              message: message,             
              duration:'10000',  // 10 sec
              key: 'info_alt',
              type: type,
              mode: 'pester'
        });
        toastEvent.fire();     
  },
    displayErrorToast : function(component, type, message) {
    var toastEvent = $A.get('e.force:showToast');
     
        toastEvent.setParams({
              title: 'Error',
              message: message,      
              key: 'info_alt',
              type: type,
              mode: 'sticky'
        });
        toastEvent.fire();     
  }
})