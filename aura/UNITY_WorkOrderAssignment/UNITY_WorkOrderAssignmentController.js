({
	loadWorkOrders : function(component, event, helper) {         
       window.acceptBoxState = new Object();
       window.rejectBoxState = new Object();
       window.acceptDisabledState = new Object();
       window.rejectDisabledState = new Object();
       helper.refreshEveryMinute(component);
    },
    
      navigateToWorkOrder : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var workOrd = component.get("v.wrapperWOList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: workOrd.workOrder.Id,
                  detailName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+workOrd.Id+'/view'
        }
    },
        
      rejectCheckboxSelect: function(component, event, helper) {  
          var selectedRecValue = event.getSource().get("v.value");   
          var selectedRecText = event.getSource().get("v.text");  
          
         var name = event.getSource().get("v.name");      
         var rejectList = window.rejectBoxState;
         rejectList["'" + name +"'"] = selectedRecValue;
         window.rejectBoxState = rejectList;
         
         var rejectDisabledList = window.rejectDisabledState;
         var acceptDisabledList = window.acceptDisabledState;
         
         if (selectedRecValue){
       		rejectDisabledList["'" + name +"'"] = false;
       		acceptDisabledList["'" + name +"'"] = true;
         }
         else{
            rejectDisabledList["'" + name +"'"] = false;
            acceptDisabledList["'" + name +"'"] = false;
         }
                  
         window.rejectDisabledState = rejectDisabledList;
         window.acceptDisabledState = acceptDisabledList;
            
          var getrejectSelectedCount = component.get("v.rejectSelectedCount");   
              if (selectedRecValue == true) {
                  getrejectSelectedCount++;
              } else {
                 getrejectSelectedCount--;
              }      
           component.set("v.rejectSelectedCount", getrejectSelectedCount);
          
           var getAllacceptedId = component.find("boxAccepted");
           if ( selectedRecValue ){
                for (var i = 0; i < getAllacceptedId.length; i++) {
                  if (getAllacceptedId[i].get("v.text") == selectedRecText) {
                      getAllacceptedId[i].set("v.disabled", "true");
                  }
               }
           }
            if ( !selectedRecValue ){
                for (var i = 0; i < getAllacceptedId.length; i++) {
                  if (getAllacceptedId[i].get("v.text") == selectedRecText) {
                      getAllacceptedId[i].set("v.disabled", "false");
                  }
               }
           }
     },    
    
   acceptCheckboxSelect: function(component, event, helper) {
       var self = this;
      var workOrd = component.get("v.wrapperWOList")
      var selectedRecValue = event.getSource().get("v.value");
      var selectedRecText = event.getSource().get("v.text");       
       
      var name = event.getSource().get("v.name");      
      var acceptList = window.acceptBoxState;
      acceptList["'" + name +"'"] = selectedRecValue;
      window.acceptBoxState = acceptList;
       
      var acceptDisabledList = window.acceptDisabledState;
      var rejectDisabledList = window.rejectDisabledState;
       if (selectedRecValue){
       		acceptDisabledList["'" + name +"'"] = false;
       		rejectDisabledList["'" + name +"'"] = true;
       }
       else{
           acceptDisabledList["'" + name +"'"] = false;
       	   rejectDisabledList["'" + name +"'"] = false;
       }
           
       window.acceptDisabledState = acceptDisabledList;
       window.rejectDisabledState = rejectDisabledList;
     
      var getacceptSelectedCount = component.get("v.acceptSelectedCount");   
          if (selectedRecValue == true) {
              getacceptSelectedCount++;
          } else {
             getacceptSelectedCount--;
          }      
        component.set("v.acceptSelectedCount", getacceptSelectedCount);
       
       var getAllrejectedId = component.find("boxRejected");
     
       if ( selectedRecValue ){
            for (var i = 0; i < getAllrejectedId.length; i++) {
              if (getAllrejectedId[i].get("v.text") == selectedRecText) {
                  getAllrejectedId[i].set("v.disabled", "true");
              }
           }        
       }
        if ( !selectedRecValue ){
            for (var i = 0; i < getAllrejectedId.length; i++) {
              if (getAllrejectedId[i].get("v.text") == selectedRecText) {
                  getAllrejectedId[i].set("v.disabled", "false");
              }
           }
       }
     },
    
    
    updateSelected: function(component, event, helper) {        
      var updateAcceptedRejectedId = [];
      var getAllrejectedId = component.find("boxRejected");
      var getAllacceptedId = component.find("boxAccepted");
      var wos = component.get('v.wrapperWOList');
      var statusAccept ='ACCEPT';   //Accepted
      var statusReject ='REJECT';  //Rejected
       
          if (wos.length == 1){
            if ( wos[0].acceptChecked != undefined){
                if (wos[0].acceptChecked == true)  {
                    updateAcceptedRejectedId.push(wos[0].workOrder.WorkOrderNumber +',' +wos[0].workOrder.CaseId + ',' +wos[0].workOrder.UNITY_Vendor_PIN__c + ',' +wos[0].workOrder.UNITY_Case_Thread_Id__c +',' + statusAccept +',' + wos[0].workOrderID);                      
                }
            }
            if ( wos[0].rejectChecked != undefined){
                if (wos[0].rejectChecked == true)  {
                    updateAcceptedRejectedId.push(wos[0].workOrder.WorkOrderNumber +',' +wos[0].workOrder.CaseId + ',' +wos[0].workOrder.UNITY_Vendor_PIN__c + ',' +wos[0].workOrder.UNITY_Case_Thread_Id__c +',' + statusReject +',' + wos[0].workOrderID);                     
                }
            }
        }
        else{     
          for (var i = 0; i < getAllacceptedId.length; i++) {
              if (getAllacceptedId[i].get("v.value") == true) {
                   for (var j =0; j < wos.length; j++){                    
                       if ( getAllacceptedId[i].get("v.text") == wos[j].workOrder.WorkOrderNumber){                    
                            updateAcceptedRejectedId.push(getAllacceptedId[i].get("v.text") +',' +wos[j].workOrder.CaseId + ',' +wos[j].workOrder.UNITY_Vendor_PIN__c + ',' +wos[j].workOrder.UNITY_Case_Thread_Id__c +',' + statusAccept +',' + wos[j].workOrderID);                     
                            //updateAcceptedRejectedId.push(getAllacceptedId[i].get("v.text") +',' +wos[j].workOrder.CaseId + ',' +wos[j].workOrder.UNITY_Vendor_PIN__c + ',' +wos[j].workOrder.UNITY_Case_Thread_Id__c +',' + statusAccept +',' + wos[j].workOrderID+',' + wos[j].workOrder.ContactId);                     
                       }
                     }                   
                 }
            }
            
          for (var i = 0; i < getAllrejectedId.length; i++) {
              if (getAllrejectedId[i].get("v.value") == true) {
                   for (var j =0; j < wos.length; j++){          
                       if ( getAllrejectedId[i].get("v.text") == wos[j].workOrder.WorkOrderNumber){                        
                           updateAcceptedRejectedId.push(getAllrejectedId[i].get("v.text") +',' +wos[j].workOrder.CaseId + ',' +wos[j].workOrder.UNITY_Vendor_PIN__c + ',' +wos[j].workOrder.UNITY_Case_Thread_Id__c + ',' + statusReject +',' + wos[j].workOrderID);                         
                           //updateAcceptedRejectedId.push(getAllrejectedId[i].get("v.text") +',' +wos[j].workOrder.CaseId + ',' +wos[j].workOrder.UNITY_Vendor_PIN__c + ',' +wos[j].workOrder.UNITY_Case_Thread_Id__c + ',' + statusReject +',' + wos[j].workOrderID +',' + wos[j].workOrder.ContactId) ;     
                       }
                     }              
                }
           }  
        }
        console.log('>>>> updateAcceptedRejectedId >>>' + updateAcceptedRejectedId);
        helper.updateAcceptedRejectedWOHelper(component, event, updateAcceptedRejectedId);
     }, 
  
})