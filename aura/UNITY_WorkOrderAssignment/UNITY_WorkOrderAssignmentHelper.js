({	
    updateAcceptedRejectedWOHelper: function(component, event, updateAcceptedRejectedId) {
         var action = component.get('c.updateWorkOrdersStatusBySendingEmail');
         console.log('calling updateAcceptedWOHelper' + updateAcceptedRejectedId);         
         action.setParams({
               "workOrdersIDs": updateAcceptedRejectedId       
              });
          action.setCallback(this, function(response) {        
           var state = response.getState();
            if (state === "SUCCESS") { 
              var woID = response.getReturnValue();          
              this.refreshWOAfterUpdate (component, woID);
               component.set("v.workOrdersUpdatedCount", updateAcceptedRejectedId.length);
               window.acceptBoxState = new Object();
               window.rejectBoxState = new Object();
              }
            if ( state ==='ERROR'){
               var errors = response.getError();
               this.displayErrorToast(component, 'Error', ' Retrieve Work Orders Pending Acceptance. Please refresh the page.');  
            }
          });
          $A.enqueueAction(action);
       },   
    
    refreshWOAfterUpdate: function(component, woID){
       var refereshedWorkOrders = [];
       var action = component.get('c.initMethod');
       action.setCallback(this, function(response){
       var state = response.getState();  
           if (state === "SUCCESS"){
               var workOrder = response.getReturnValue(); 
               if (workOrder != null){
                  for (var i = 0; i < workOrder.length; i++) { 
                     var wo = workOrder[i].workOrderID;
                      if ( woID.length > 0){
                         var index  = woID.indexOf(wo); 
                          if ( index == -1){
                            refereshedWorkOrders.push(workOrder[i]);  
                          }
                      }
                  }
                  component.set('v.wrapperWOList', refereshedWorkOrders);  
                  component.set("v.acceptSelectedCount", 0); 
                  component.set("v.rejectSelectedCount", 0);                 
               } 
           }
           if ( state ==='ERROR'){
               var errors = response.getError();
               this.displayErrorToast(component, 'Error', 'Error to get Work Orders Pending Acceptance. Please refresh the page.');  
            }           
       });
         $A.enqueueAction(action);
    },
    
    refreshEveryMinute:  function(component){
       var that = this;  
       var acceptCount = 0;
       var rejectCount = 0;
       var action = component.get('c.initMethod');
       action.setCallback(this, function(response){
       var state = response.getState();       
         if (state === "SUCCESS") {     
              var workOrders = response.getReturnValue(); 
               if (workOrders != null){                 
                   var acceptList = window.acceptBoxState;
                  // acceptCount = Object.keys(acceptList).length;                   
                   var rejectList = window.rejectBoxState;
                   //rejectCount = Object.keys(rejectList).length;  
                   
                   var acceptList = window.acceptBoxState;
                   var rejectList = window.rejectBoxState;
                   
				   var rejectDisabledList = window.rejectDisabledState;
                   var acceptDisabledList = window.acceptDisabledState;
                   
                   if ( Object.keys(acceptList).length == 1){
                       var v = Object.values(acceptList);
                       if ( v[0] == true)
                           acceptCount = 1;
                   }
                   else{
                       for (var i=0; i < Object.keys(acceptList).length; i++){
                           if (acceptList["'"+i+"'"] == true) 
                               acceptCount++;                         
                       }
                   }
                   if ( Object.keys(rejectList).length == 1){
                       var v = Object.values(rejectList);
                       if ( v[0] == true)
                           rejectCount = 1;
                   }
                   else{
                       for (var i=0; i < Object.keys(rejectList).length; i++){
                           if (rejectList["'"+i+"'"]  == true) 
                               rejectCount++; 
                       }
                   }
                  
                   for (var i=0; i < workOrders.length; i++){
                       workOrders[i].acceptChecked = acceptList["'"+i+"'"];               
                       workOrders[i].rejectDisabled = rejectDisabledList["'"+i+"'"];                      
                       workOrders[i].rejectChecked = rejectList["'"+i+"'"];                      
                       workOrders[i].acceptDisabled = acceptDisabledList["'"+i+"'"];                      
                   }              
                   component.set('v.wrapperWOList', workOrders);  
                   component.set("v.acceptSelectedCount", acceptCount); 
                   component.set("v.rejectSelectedCount", rejectCount);
                   component.set("v.workOrdersUpdatedCount", 0);                   
               }
            }
         if ( state ==='ERROR'){
               var errors = response.getError();
               this.displayErrorToast(component, '', 'Error to get Work Orders Pending Acceptance. Please refresh the page.');  
            }    
       });    
      $A.enqueueAction(action);
       
        window.setTimeout(
            $A.getCallback(function() {    
                console.log('calling');
               that.refreshEveryMinute(component);              
           }), 60000 //180000
        );  
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
    },   
})