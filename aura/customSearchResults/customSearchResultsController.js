({
  init: function(component, event, helper) {
    var idsJson = sessionStorage.getItem('customSearch--recordIds'); 
    if (!$A.util.isUndefinedOrNull(idsJson)) {
      var ids = JSON.parse(idsJson);
      var accountList = [];
      var caseList = [];
      var attachmentList = [];
      console.log(ids.length);
      for (var i=0; i < ids.length; i++){
          if (ids[i].CaseNumber){
            caseList.push(ids[i]);
          }
          else{
            if (ids[i].UNITY_Type__c) 
              attachmentList.push(ids[i]);
      		else
              accountList.push(ids[i]);
          }
      }
      
      component.set('v.recordIds', ids);
      component.set('v.accountList', accountList);
      component.set('v.caseList', caseList);
	  component.set('v.attachmentList', attachmentList);
        
      console.log(accountList);
      console.log(caseList);
      sessionStorage.removeItem('customSearch--recordIds'); 
    }
  },
    navigateToAccount : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var rec = component.get("v.accountList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: rec.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+attachment.Id+'/view'
        }
    },
    navigateToCase : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var rec = component.get("v.caseList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: rec.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+attachment.Id+'/view'
        }
    },
    navigateToAttachment : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var rec = component.get("v.attachmentList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: rec.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+attachment.Id+'/view'
        }
    }          
})