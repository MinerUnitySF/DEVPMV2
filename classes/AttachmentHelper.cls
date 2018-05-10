/**This is a helper class for attachments
** @programer: Izay Ramos-Irizarry
** @version: 2.0
** @date: 6/17/2015
*/
public without sharing class AttachmentHelper {
    public static Boolean doNotRunAgain = false;
    
    
    /** This method manages service reports attached to work orders **/
    public static void manageServiceReport(List<Attachment> newList){
        List<Attachment> serviceReps = new List<Attachment>();//List to hold service report attachments
        //List of emails to send out
        List<Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>(); 
        Set<String> emailSet = new Set<String>();//Set to hold email address in work orders
        Map<String, Contact> contactMap = new Map<String, Contact>();//Map of contacts by email address
        Set<Id> woIDs = new Set<Id>();//Set to hold work order ids
        //Iterate throughh attachments to find service reports
        System.debug('============= Atachment count: ' + newList.size());
        for (Attachment a : newList){
            //If the attachment parent is a work order and the name contains Service_Report and it is a pdf...
            //EDIT: And also does NOT contain 'Comprehensive'
            if (a.ParentId.getSobjectType() == SVMXC__Service_Order__c.SobjectType && String.isNotBlank(a.Name)){
                System.debug('============= Atachment name: ' + a.Name);
                if(a.Name.contains('Service_Report') && a.Name.contains('.pdf')){
                    woIDs.add(a.ParentId);//Add the ParentId to the woIDs set
                    serviceReps.add(a);//Add the attachment to the serviceReps list
                }
            }
        }//End for
        System.debug('============= Service Report count: ' + serviceReps.size());
        //If service reports were found attached to work orders...
        if(woIDs.size() > 0){
            //Query the work orders and work detail lines in a map
            Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>([Select Id,Name,Email_Service_Report__c,Send_Service_Report_to_Customer__c,SVMXC__Service_Group__r.Company_Legal_Name__c,
                SVMXC__Service_Group__r.SVMXC__Street__c,SVMXC__Service_Group__r.SVMXC__City__c,SVMXC__Service_Group__r.SVMXC__State__c,SVMXC__Service_Group__r.SVMXC__Zip__c,SVMXC__Service_Group__r.SVMXC__Phone__c,
                SVMXC__Service_Group__r.SVMXC__Email__c,Location__r.Name,Location__r.SVMXC__Street__c,Location__r.SVMXC__City__c,Location__r.SVMXC__State__c,Location__r.SVMXC__Zip__c,SVMXC__Contact__r.Name,
                SVMXC__Contact__r.Phone,SVMXC__Contact__r.Email,Service_Report_Received__c,SVMXC__Scheduled_Date_Time__c,
                (SELECT Id,Service_Report__c,Service_Report_Line__c FROM SVMXC__Service_Order_Line__r WHERE Service_Report_Line__c = 'Queued'),
                (SELECT Id,Service_Report__c,Report_Status__c FROM Job_History__r WHERE Report_Status__c = 'Queued')
                FROM SVMXC__Service_Order__c WHERE Id IN :woIDs]);
            System.debug('============= Work Orders count: ' + woMap.keySet().size());
            //For each work order... 
            for (SVMXC__Service_Order__c wo : woMap.Values()){
                if (String.isNotBlank(wo.Email_Service_Report__c)){
                    //Add the email address on the work order to the emailSet
                    emailSet.add(wo.Email_Service_Report__c);
                }
            }
            //List to hold contact records for the emails in the emailSet
            List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email IN :emailSet];
            //Put the returned contacts in the contactMap by contact email
            if (contactList.size() > 0){
                for (Contact co : contactList){
                    contactMap.put(co.Email, co);
                }
            }
            //List of work orders to update w/ Service report received
            List<SVMXC__Service_Order__c> woToUpdate = new List<SVMXC__Service_Order__c>();
            List<Service_Report__c> servRepsRecords = new List<Service_Report__c>();
            //Now need to buld the email for each service report attachment
            //For each service report...
            for (Attachment a : serviceReps) {
                System.debug('============= Attachment to put in message: ' + a.Name);
                //If the woMap has the attachment ParentId as a key...
                if(woMap.containsKey(a.ParentId)){
                    System.debug('============= Work Order Map has Attachment Parent Id: ' + a.ParentId);
                    //Get the work order from the map
                    SVMXC__Service_Order__c wo = woMap.get(a.ParentId);
                    //Reset the flags on the work order
                    wo.Service_Report_Received__c = true;
                    //Add the work order to the list to update
                    woToUpdate.add(wo);
                    //Create the service report record for it...
                    Service_Report__c sr = new Service_Report__c();
                    sr.Work_Order__c = wo.Id;
                    DateTime dt = wo.SVMXC__Scheduled_Date_Time__c;
                    if(dt != null){
                        sr.Date__c = dt.date();
                    }else{
                        sr.Date__c = Date.today();
                    }
                    sr.PDF_Link__c = 'https://c.na15.content.force.com/servlet/servlet.FileDownload?file='+a.Id;
                    servRepsRecords.add(sr);
                    //Create the attachment for the email message
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setFileName(a.Name);
                    emailAttachment.setBody(a.Body);
                    System.debug('============= Created Email Attchment...');
                    //Construct the email message
                    String emailBody = '<body style="font-family: Arial,Helvetica Neue,Helvetica,sans-serif;font-size: 12px;"><div>'+
                        '<h3 style="font-family: Arial,Helvetica Neue,Helvetica,sans-serif;font-size: 14px;font-style: normal;font-variant: normal;font-weight: bold;line-height: 15.4px;">' + wo.SVMXC__Service_Group__r.Company_Legal_Name__c + '</h3>' +
                        '<p>' + wo.SVMXC__Service_Group__r.SVMXC__Street__c +
                        '<br/><span>' + wo.SVMXC__Service_Group__r.SVMXC__City__c + ', ' + wo.SVMXC__Service_Group__r.SVMXC__State__c + ' ' + wo.SVMXC__Service_Group__r.SVMXC__Zip__c + '</span>' +
                        '<br/><span><strong>Phone:</strong> ' + wo.SVMXC__Service_Group__r.SVMXC__Phone__c + '</span>' +
                        '<br/><span>' + wo.SVMXC__Service_Group__r.SVMXC__Email__c + '</span></p>' +
                        '</div><br/>';
                    System.debug(emailBody);
                    emailBody += '<table cellpadding="5" cellspacing="0" style="width:500px;font-size:13px;border:1px solid #ccc;border-collapse:collapsed;">' +
                        '<tr>' +
                        '<th>Customer</th>' +
                        '<td style="white-space: nowrap;"><span>' + wo.Location__r.Name + '</span></td>' +
                        '<th>Date</th>' +
                        '<td><span>' + Date.today().format() + '</span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<th>Address</th>' +
                        '<td style="white-space: nowrap;">' +
                        '<span>' + wo.Location__r.SVMXC__Street__c +
                        '<br />' +
                        wo.Location__r.SVMXC__City__c + ', ' + wo.Location__r.SVMXC__State__c + ' ' + wo.Location__r.SVMXC__Zip__c + '</span>' +
                        '</td>' +
                        '<th>Job #</th>' + 
                        '<td style="white-space: nowrap;"><span>' + wo.Name + '</span></td>' +
                        '</tr>' +
                        '<tr>' +
                        '<th>Contact</th>' +
                        '<td style="white-space: nowrap;"><span>' + wo.SVMXC__Contact__r.Name + '</span></td>' +
                        '</tr>' +
                        '<tr>' + 
                        '<th>Phone</th>' + 
                        '<td style="white-space: nowrap;">' + 
                        '<span>' + wo.SVMXC__Contact__r.Phone +  '       <strong>&nbsp;E-Mail:&nbsp;</strong>' + wo.SVMXC__Contact__r.Email + '</span>' +
                        '</td>' +
                        '</tr>' +
                        '</table>';
                    emailBody += '<br/><h3 style="font-family: Arial,Helvetica Neue,Helvetica,sans-serif;font-size: 14px;font-style: normal;font-variant: normal;font-weight: bold;line-height: 15.4px;">Thank you for your business!</h3>';
                    emailBody += '<p><em>DO NOT REPLY TO THIS EMAIL, please send replies to <a href="mailto:' + wo.SVMXC__Service_Group__r.SVMXC__Email__c + '">' + wo.SVMXC__Service_Group__r.SVMXC__Email__c + '</a></em></p></body>';
                    System.debug('============= Created Email Body...');
                    //If the work order has an email address...
                    if(String.isNotBlank(wo.Email_Service_Report__c)  && !(a.Name.contains('Comprehensive'))){
                        //Get the email from the work order
                        String email = wo.Email_Service_Report__c;
                        System.debug('============= Email on the work order to send to: ' + email);
                        System.debug('============= Creating message for customer...');
                        //Create message for customer
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setOrgWideEmailAddressId(Label.Org_Wide_Email_Address_Record);
                        message.setSaveAsActivity(false);
                        message.setWhatId(a.ParentId);
                        message.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                        message.setSubject('Job # ' + wo.Name + ' Service Report');
                        if(contactMap.containsKey(email)){
                            System.debug('============= Customer is in contacts map: ' + contactMap.get(email).Id);
                            message.setTargetObjectId(contactMap.get(email).Id);
                        }else{
                            System.debug('============= Customer is NOT in contacts map: ' + email);
                            message.setToAddresses(new String[] {email});
                        }
                        message.setHTMLBody(emailBody);
                        messagesList.add(message);
                    }
                    //Create Message for user
                    System.debug('============= Creating message for user...');
                    Messaging.SingleEmailMessage uMsg = new Messaging.SingleEmailMessage();
                    uMsg.setOrgWideEmailAddressId(Label.Org_Wide_Email_Address_Record);
                    uMsg.setSaveAsActivity(false);
                    uMsg.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                    uMsg.setSubject('Job # ' + wo.Name + ' Service Report');
                    uMsg.setTargetObjectId(UserInfo.getUserId());
                    uMsg.setHTMLBody(emailBody);
                    messagesList.add(uMsg);
                    //Send Message to Team
                    System.debug('============= Creating message for team...');
                    Messaging.SingleEmailMessage uMsg_IT = new Messaging.SingleEmailMessage();
                    uMsg_IT.setOrgWideEmailAddressId(Label.Org_Wide_Email_Address_Record);
                    uMsg_IT.setSaveAsActivity(false);
                    uMsg_IT.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                    uMsg_IT.setSubject('Job # ' + wo.Name + ' Service Report');
                    uMsg_IT.setToAddresses(new String[] {'jp@tfsglobal.com'});
                    uMsg_IT.setHTMLBody(emailBody);
                    messagesList.add(uMsg_IT);
                }
            }
            System.debug('============= Number of messages (emails) to send: ' + messagesList.size());
            //If email message were created...
            if(messagesList.size() > 0){
                //Exception handling
                try{
                    //Send the emailMessages
                    System.debug('============= Sending emails...');
                    Messaging.sendEmail(messagesList);
                    //Update the work orders...
                    if(woToUpdate.size() > 0){
                        update woToUpdate;
                    }
                    //If there are service report records to create...
                    if(servRepsRecords.size() > 0){
                        //Map to place all existing service reports by the work order id 
                        Map<Id,List<Service_Report__c>> srMap = new Map<Id,List<Service_Report__c>>();
                        //Final list of service reports to insert
                        List<Service_Report__c> finalSrvReps = new List<Service_Report__c>();
                        //List of service reports to update
                        List<Service_Report__c> toUpdateSrvReps = new List<Service_Report__c>();
                        //List of work order detail lines to update with the service report 
                        List<SVMXC__Service_Order_Line__c> wodlToUpdate = new List<SVMXC__Service_Order_Line__c>();
                        List<Work_Performed__c> jobNotesToUpdate = new List<Work_Performed__c>();
                        //Fetch all the service reports for the work orders in the transaction... Done to prevent duplication
                        List<Service_Report__c> reps = [SELECT Id,Work_Order__c,Date__c FROM Service_Report__c WHERE Work_Order__c IN :woMap.keySet()];
                        //If there are exisiting servivce report records for the work orders in the transaction...
                        if(reps.size() > 0){
                            //Put each service report in the srMap by the work order id
                            for(Service_Report__c sr :reps){
                                if(!srMap.containsKey(sr.WOrk_Order__c)){
                                    List<Service_Report__c> temp = new List<Service_Report__c>();
                                    temp.add(sr);
                                    srMap.put(sr.Work_Order__c,temp);
                                }else{
                                    srMap.get(sr.Work_Order__c).add(sr);
                                }
                            }
                        }
                        //For each service report created in this transaction...
                        for(Service_Report__c sr :servRepsRecords){
                            ////////////////////////////////////////////////////////////////////////////////////////
                            // Need to find out if there is an exisintg service report record similar to this one //
                            ////////////////////////////////////////////////////////////////////////////////////////
                            Boolean found = false;//Denotes if a similar service report was found
                            //If this wotrk order id is in the srMap...
                            if(srMap.containsKey(sr.Work_Order__c)){
                                //Iterate through all existing service reports for this work order id
                                for(Service_Report__c srInMap : srMap.get(sr.Work_Order__c)){
                                    //If this service report has the same date as the exisintg service report...
                                    if(sr.Date__c == srInMap.Date__c){
                                        found = true;//Set found to true
                                        //If the work order is in the woMap...
                                        if(woMap.containsKey(sr.Work_Order__c)){
                                            //For each service order line on this work order that are... Queued and has no Service Report...
                                            for(SVMXC__Service_Order_Line__c wodl :woMap.get(sr.Work_Order__c).SVMXC__Service_Order_Line__r){
                                                wodl.Service_Report__c = srInMap.Id;//Set the service report on the work order detail line
                                                wodl.Service_Report_Line__c = 'Reported';//Change the status to reported
                                                wodlToUpdate.add(wodl);//Add the line to the list of work order details to update
                                            }//End for
                                            for(Work_Performed__c jn :woMap.get(sr.Work_Order__c).Job_History__r){
                                                jn.Service_Report__c = srInMap.Id;
                                                jn.Report_Status__c = 'Reported';
                                                jobNotesToUpdate.add(jn);
                                            }
                                        }//End if
                                        srInMap.PDF_Link__c = sr.PDF_Link__c;//Set the existing service report link to the new one
                                        toUpdateSrvReps.add(srInMap);//Add the exisintg service report to be updated
                                    }//End if sr date
                                }//End for existing sr
                            }//End if srMap
                            //If an exisiting service report is not found...
                            if(!found){
                                finalSrvReps.add(sr);//Add the service report to the final list to inser
                            }//End if not found
                        }//End for service reports
                        //If need to insert new service report records...
                        if(finalSrvReps.size() > 0){
                            insert finalSrvReps;//Insert the service report records...
                            ////////////////////////////////////////////////
                            // Need to update the work order detail lines //
                            ////////////////////////////////////////////////
                            //For each service report record inserted...
                            for(Service_Report__c sr: finalSrvReps){
                                if(woMap.containsKey(sr.Work_Order__c)){
                                    //For each service order line on this work order that are... Queued and no Service Report...
                                    for(SVMXC__Service_Order_Line__c wodl :woMap.get(sr.Work_Order__c).SVMXC__Service_Order_Line__r){
                                        wodl.Service_Report__c = sr.Id;//Set the service report on the work order detail line
                                        wodlToUpdate.add(wodl);//Add the line to the list of work order details to update
                                        wodl.Service_Report_Line__c = 'Reported';
                                    }//End for
                                    for(Work_Performed__c jn :woMap.get(sr.Work_Order__c).Job_History__r){
                                        jn.Service_Report__c = sr.Id;
                                        jn.Report_Status__c = 'Reported';
                                        jobNotesToUpdate.add(jn);
                                    }
                                }//End if
                            }//End for
                        }//End if final list
                        //If there are work detail lines to update...
                        if(wodlToUpdate.size() > 0){
                            update wodlToUpdate;//Update the work detail lines
                        }//End if
                        if(jobNotesToUpdate.size() > 0){
                            update jobNotesToUpdate;
                        }
                        //If there are existing service reports to update
                        if(toUpdateSrvReps.size() > 0){
                            update toUpdateSrvReps;//Update exisiting service reports
                        }//End if 
                    }//End if service report records
                //Handle exceptions
                }catch(Exception e){
                    System.debug('============== Error: ' + e.getMessage());
                }//End try catch
            }//end if messages
        }//End if woIds
    }//End method
    
    /** splitting  attachments for document stging   **/     
    
    public static void uploadDocumentstaingAttachments(List<Attachment> newList){
         Map<ID, List<Attachment>> attListForParentMap = new Map<ID, List<Attachment>>();
        for (Attachment att: newList){
            String sobjectType = att.ParentId.getSObjectType().getDescribe().getName();
            if (sobjectType != 'Document_Staging__c')
                continue;

             if(attListForParentMap.containsKey(att.ParentId)) {
                 List<Attachment> attList = attListForParentMap.get(att.ParentId);
                 attList.add(att);
                 attListForParentMap.put(att.ParentId, attList);
              } else {
                  attListForParentMap.put(att.ParentId, new List<Attachment> { att });
            }
          }
         
          Map<ID, Document_Staging__c> docStagingMap = new  Map<ID, Document_Staging__c>([SELECT ID,Incoming_Email_Address__c,Document_Source__c, Email_Subject__c,Status__c from Document_Staging__c WHERE ID IN:attListForParentMap.keySet()]);
         
          List<Document_Staging__c> newDocStagingList = new List<Document_Staging__c>();
         
           
          for (ID parentID: attListForParentMap.keySet()){
              List<Attachment>attList = attListForParentMap.get(parentID); 
              Document_Staging__c docStg = docStagingMap.get(parentID);
                
              if (attList.size() > 1){
                for (Integer i=1; i<attList.size(); i++){
                   Document_Staging__c newDocStaging = new Document_Staging__c(Incoming_Email_Address__c = docStg.Incoming_Email_Address__c, Email_Subject__c =docStg.Email_Subject__c,Document_Source__c = docStg.Document_Source__c, Status__c =docStg.Status__c );
                   newDocStagingList.add(newDocStaging);  
                }
               
                if ( newDocStagingList.size()>0)
                     insert newDocStagingList;
                 
                for (Attachment att: attList){
                   for (Integer i = (newDocStagingList.size()-1) ; i>= 0 ; i--){
                          ID pID = newDocStagingList[i].ID;
                          att.ParentId = pID;
                          newDocStagingList.remove(i);
                          break;
                     }
                  
                 }
             }
          }
    }

    /** upload attachments to DocParser */
    public static void prepareFileUploadToDocParser(List<Attachment> attachmentList){

        //Check if attachment is related to Document Staging
        Map<Id, Attachment> attachmentForDocStagingMap = new Map<Id, Attachment>();
        Set<Id> docStagingIds = new Set<Id>();

        system.debug('@@@prepareFileUploadToDocParser attachmentList:'+attachmentList);

        for (Attachment a: attachmentList){
            String sobjectType = a.ParentId.getSObjectType().getDescribe().getName();
            if (sobjectType == 'Document_Staging__c'){
                attachmentForDocStagingMap.put(a.Id, a);
                docStagingIds.add(a.ParentId);
            }
        }

        //Fetch document staging records
        Map<Id, Document_Staging__c> docStagingMap = new Map<Id, Document_Staging__c>([SELECT Id, Status__c
                                                    FROM Document_Staging__c
                                                    WHERE Status__c = 'New'
                                                    AND DocParser_Id__c = null
                                                    AND Id = :docStagingIds]);


        for (Attachment a: attachmentForDocStagingMap.values()){
            Document_Staging__c ds = docStagingMap.get(a.ParentId);
            if (ds != null)
                UNITY_DocParserUtility.UploadDocumentToDocParserF(ds.Id);
        }

    }
}