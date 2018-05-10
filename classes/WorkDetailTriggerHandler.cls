public class WorkDetailTriggerHandler {
    
    public static void before(List<SVMXC__Service_Order_Line__c> newList, Map<Id,SVMXC__Service_Order_Line__c> oldMap){
        if(Trigger.isInsert){
            handleLinesFromIpad(newList);
        }
    }
    
    public static void after(List<SVMXC__Service_Order_Line__c> newList, Map<Id,SVMXC__Service_Order_Line__c> oldMap){
        nolaTaxExempt(newList,oldMap);
        updateQuotedLaborWithActual(newList,oldMap);
    }

    public static void handleLinesFromIpad(List<SVMXC__Service_Order_Line__c> newList){
        Map<Id,List<SVMXC__Service_Order_Line__c>> woLinesMap = new Map<Id,List<SVMXC__Service_Order_Line__c>>();
        for(SVMXC__Service_Order_Line__c line :newList){
            if(line.Line_from_iPad__c){
                if(!woLinesMap.containsKey(line.SVMXC__Service_Order__c))
                    woLinesMap.put(line.SVMXC__Service_Order__c, new List<SVMXC__Service_Order_Line__c>());
                woLinesMap.get(line.SVMXC__Service_Order__c).add(line);
            }
         }
         if(!woLinesMap.keySet().isEmpty()){
            List<SVMXC__Service_Order__c> workOrders = [SELECT Id,Work_Order_Type__c FROM SVMXC__Service_Order__c WHERE Id IN :woLinesMap.keySet()];
            for(SVMXC__Service_Order__c wo :workOrders){
                if(wo.Work_Order_Type__c == 'Quoted'){
                    if(woLinesMap.containsKey(wo.Id)){
                        for(SVMXC__Service_Order_Line__c line :woLinesMap.get(wo.Id)){
                            line.SVMXC__Is_Billable__c = true;
                            //line.Work_Complete__c = true;
                            line.SVMXC__Line_Status__c = 'Open';
                        }
                    }
                }
            }
         }
    }

    public static void nolaTaxExempt(List<SVMXC__Service_Order_Line__c> newList, Map<Id,SVMXC__Service_Order_Line__c> oldMap){
        //Fetch the new orleans segment id
        String nolaSegId = '';
        List<Segment__c> nola = [SELECT Id FROM Segment__c WHERE Segment_Name__c = 'New Orleans' LIMIT 1];
        if(nola.size() > 0){
            nolaSegId  = nola[0].Id;
        }
        Set<Id> woids = new Set<Id>();
        for(SVMXC__Service_Order_Line__c line: newList){
            woids.add(line.SVMXC__Service_Order__c);
        }
        List<SVMXC__Service_Order_Line__c> detailLines = [SELECT Id,Name,SVMXC__Line_Type__c,SVMXC__Line_Status__c,SVMXC__Service_Order__c 
                                                         FROM SVMXC__Service_Order_Line__c
                                                         WHERE SVMXC__Service_Order__c IN :woids 
                                                         AND IsDeleted = False AND SVMXC__Line_Status__c != 'Canceled'];
        //Map to group detail lines by work order
        Map<Id,List<SVMXC__Service_Order_Line__c>> woMap = new Map<Id,List<SVMXC__Service_Order_Line__c>>();
        //For each line... add it to the woMap by the work order id
        for(SVMXC__Service_Order_Line__c line :detailLines){
            if(!woMap.containsKey(line.SVMXC__Service_Order__c)){
                List<SVMXC__Service_Order_Line__c> temp = new List<SVMXC__Service_Order_Line__c>();
                temp.add(line);
                woMap.put(line.SVMXC__Service_Order__c, temp);
            }else{
                woMap.get(line.SVMXC__Service_Order__c).add(line);
            }
        }
        //Fetch all work order to get the segment and field to be updated
        List<SVMXC__Service_Order__c> workOrders = [SELECT Id,Super_Center__c,Segment__c,SVMXC__Order_Type__c,Certificate__c FROM SVMXC__Service_Order__c WHERE Id IN :woMap.keySet()];
        List<SVMXC__Service_Order__c> toUpdate = new List<SVMXC__Service_Order__c>();
        //Now, iterate through all work orders found...
        for(SVMXC__Service_Order__c wo :workOrders){
            //Ensure that the work order is in the map
            if(woMap.containsKey(wo.Id)){
                //Check that the work order has a segment
                if(String.isNotBlank(wo.Segment__c)){
                    //If the segment on the work order is nola...
                    if(wo.Segment__c == nolaSegId){
                        //Iterate though the work detail lines to see if there is a parts line
                        //If there is a parts line make Certificate__c on the work order null
                        //Otherwise, set Certificate__c on the work order to 'EXEMPT - LABOR ONLY'
                        Boolean hasPart = false;
                        for(SVMXC__Service_Order_Line__c line :woMap.get(wo.Id)){
                            if(line.SVMXC__Line_Type__c == 'Parts' || line.SVMXC__Line_Type__c == 'Vendor Services'){
                                hasPart = true;
                                break;
                            }
                        }
                        if(hasPart){
                            wo.Certificate__c = null;
                        }else{
                            wo.Certificate__c = 'EXEMPT - LABOR ONLY';
                        }
                        toUpdate.add(wo);
                    }//End if NOLA
                }//End if Segment not blank
            }//End if woMap
        }//End for work orders
        try{
            update toUpdate;
        }catch(Exception e){
            Trigger.new[0].addError(' Could not set the Sales Tax Certificate. Contact the Help Desk for assistance with this problem.');
        }
    }

    public static void updateQuotedLaborWithActual(List<SVMXC__Service_Order_Line__c> newList, Map<Id,SVMXC__Service_Order_Line__c> oldMap){
        //Need to find Labor lines that are being created or updated via iPad
        Map<Id,SVMXC__Service_Order_Line__c> NotQuotedLines = new Map<Id,SVMXC__Service_Order_Line__c>();
        //Need to collect the workorder ids for the lines being created or updated
        Set<Id> woids = new Set<Id>();
         for(SVMXC__Service_Order_Line__c line :newList){
            if(line.SVMXC__Line_Type__c == 'Labor' && (line.Line_from_iPad__c || !line.Quoted__c)){
                NotQuotedLines.put(line.id,line);
                woids.add(line.SVMXC__Service_Order__c);
            }
         }
         if(!NotQuotedLines.keySet().isEmpty()){
            //Query the WOs to get the Work Order Type
            //Also query all other Labor lines for the same WO
            List<SVMXC__Service_Order__c> wos = [SELECT Id,Work_Order_Type__c from SVMXC__Service_Order__c WHERE Id IN: woids];
            List<SVMXC__Service_Order_Line__c> woLines = [SELECT Id,SVMXC__Service_Order__c,SVMXC__Line_Type__c,Quoted_Unit_Cost__c,Vendor_Cost_Per_Unit__c,SVMXC__Actual_Quantity2__c,Line_from_iPad__c,Quoted__c,SVMXC__Line_Status__c FROM SVMXC__Service_Order_Line__c WHERE Id NOT IN :NotQuotedLines.keyset() AND SVMXC__Service_Order__c IN :woids AND SVMXC__Line_Type__c = 'Labor' ORDER BY CreatedDate Desc];
            //Need to group all labor lines by work order.
            Map<Id,List<SVMXC__Service_Order_Line__c>> woLinesMap = new Map<Id,List<SVMXC__Service_Order_Line__c>>();
            for(SVMXC__Service_Order_Line__c line :woLines){
                if(!woLinesMap.containsKey(line.SVMXC__Service_Order__c))
                    woLinesMap.put(line.SVMXC__Service_Order__c, new List<SVMXC__Service_Order_Line__c>());
                woLinesMap.get(line.SVMXC__Service_Order__c).add(line);
            }
            for(SVMXC__Service_Order_Line__c line :NotQuotedLines.values()){
                if(!woLinesMap.containsKey(line.SVMXC__Service_Order__c))
                    woLinesMap.put(line.SVMXC__Service_Order__c, new List<SVMXC__Service_Order_Line__c>());
                woLinesMap.get(line.SVMXC__Service_Order__c).add(line);
            }
            //Now, need to iterate through the work orders. If the work order is "Quoted"...
            //need to add the cost and qty for all the labor lines from iPad. 
            //Then, need to calculate the cost per unit and update the quoted labor line.
            List<SVMXC__Service_Order_Line__c> linesToUpdate = new List<SVMXC__Service_Order_Line__c>();
            for(SVMXC__Service_Order__c wo :wos){
                if(wo.Work_Order_Type__c == 'Quoted'){
                    if(woLinesMap.containsKey(wo.Id)){
                        SVMXC__Service_Order_Line__c quotedLabor;
                        Decimal actualQty = 0;
                        Decimal totalCost = 0;
                        Decimal calcUnitCost = 0;
                        Integer noOfLabor = 0;
                        Decimal compTotalCost = 0;
                        Decimal compTotalQty = 0;
                        for(SVMXC__Service_Order_Line__c line :woLinesMap.get(wo.Id)){
                            if(line.Line_from_iPad__c || !line.Quoted__c){
                                totalCost += line.Vendor_Cost_Per_Unit__c != null ? line.Vendor_Cost_Per_Unit__c : 0;
                                actualQty += line.SVMXC__Actual_Quantity2__c != null ? line.SVMXC__Actual_Quantity2__c : 0;
                            	noOfLabor ++;
                            }else if(line.Quoted_Unit_Cost__c != null && line.SVMXC__Line_Status__c == 'Open'){
                                quotedLabor = line;
                            }else if(line.Quoted_Unit_Cost__c != null && line.SVMXC__Line_Status__c == 'Completed'){
                                compTotalCost += line.Vendor_Cost_Per_Unit__c != null ? line.Vendor_Cost_Per_Unit__c : 0;
                                compTotalQty += line.SVMXC__Actual_Quantity2__c != null ? line.SVMXC__Actual_Quantity2__c : 0;
                            }
                        }
                        if(actualQty > 0){
                            if(totalCost > 0){
                                calcUnitCost = (totalCost != 0 && noOfLabor != 0) ? (totalCost / noOfLabor) : 0;
                                calcUnitCost = calcUnitCost - compTotalCost;
                                actualQty = actualQty - compTotalQty;
                            }
                            if(quotedLabor != null){
                                quotedLabor.Vendor_Cost_Per_Unit__c = calcUnitCost > 0 ? calcUnitCost : quotedLabor.Vendor_Cost_Per_Unit__c;
                                quotedLabor.SVMXC__Actual_Quantity2__c = actualQty;
                                linesToUpdate.add(quotedLabor);
                            }
                        }
                    }
                }
            }
            if(!linesToUpdate.isEmpty()){
                try{
                    update linesToUpdate;
                }catch(Exception e){
                    Trigger.new[0].addError(e.getMessage());
                }
            }
         }
    }
}