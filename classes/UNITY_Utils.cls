/*
 *   @programer:    Samuel Astol
 *   @description:  Common static methods.
 *   @date:         11/17/2015
 */
public class UNITY_Utils {

    private static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    public static id getRecordType(Schema.SObjectType objectType , String recordTypeName){


        return ( ( objectType != null
                  && objectType.getDescribe()  != null
                  && objectType.getDescribe().getRecordTypeInfosByName() != null
                  && objectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName) != null )?
                     objectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId():null );

    }

    public static SObject includedInRecordType(SObject record, Set<Id> recordTypeList){
		if (record == null)
            return record;

        String recordTypeID = (String)record.get('RecordTypeId');
        if (recordTypeList.contains(recordTypeID))
			return record;
        else
        	return null;
    }
    public static SObject excludedInRecordType(SObject record, Set<Id> recordTypeList){
        if (record == null)
            return record;
        
        String recordTypeID = (String)record.get('RecordTypeId');
        if (!recordTypeList.contains(recordTypeID))
			return record;
        else
            return null;
	}
    
    public static List<SObject> includeRecordType(List<SObject> records, Set<Id> recordTypeList){
        List<SObject> resultInclude = new List<SObject>();
        
		if (records == null || records.size() == 0)
            return records;
                    
        for (SObject so: records){
            String recordTypeID = (String)so.get('RecordTypeId');

           if (recordTypeList.contains(recordTypeID))
				resultInclude.add(so);
        }
        return resultInclude;
    }
    public static List<SObject> excludeRecordType(List<SObject> records, Set<Id> recordTypeList){
        List<SObject> resultExclude = new List<SObject>();
        
        if (records == null || records.size() == 0)
            return records;
        
        for (SObject so: records){
            String recordTypeID = (String)so.get('RecordTypeId');
           if (!recordTypeList.contains(recordTypeID))
				resultExclude.add(so);
        }
        return resultExclude;
    }
    
    public static Map<Id, SObject> includeRecordType(Map<Id, SObject> recordMap, Set<Id> recordTypeList){
        Map<Id, SObject> resultInclude = new Map<Id, SObject>();
        
        if (recordMap == null || recordMap.size() == 0)
            return recordMap;
        
        for (SObject so: recordMap.values()){
            String recordTypeID = (String)so.get('RecordTypeId');

           if (recordTypeList.contains(recordTypeID))
				resultInclude.put(so.Id, so);
        }
        return resultInclude;
    }
    public static Map<Id, SObject> excludeRecordType(Map<Id, SObject> recordMap, Set<Id> recordTypeList){
        Map<Id, SObject> resultExclude = new Map<Id, SObject>();
        
        if (recordMap == null || recordMap.size() == 0)
            return recordMap;
        
        for (SObject so: recordMap.values()){
            String recordTypeID = (String)so.get('RecordTypeId');
           if (!recordTypeList.contains(recordTypeID))
				resultExclude.put(so.Id, so);
        }
        return resultExclude;
    }
    

    /*
     *   @programer   : Samuel Astol
     *   @date        : 12/09/2015
     *   @description : example -> ' field1, field2, field3 ' 
     *   @param 1     : List<String> list of fields 
     *   @return      : String
     */
    public static String getQueryFields(List<String> fields){

        String returnString = '';
        //discard the duplicated one
        fields = new List<String>(new Set<String>(fields));
        for( Integer i = 0 ; i < fields.size(); i++ ){

            returnString += fields.get(i);
            if( i < (fields.size() - 1) ){
                returnString += ', ';
            }

        }

        return returnString;

    }
    
    public static List<String> joiningByFieldList(List<SObject> sobjects,String fieldName) {
        List<String> fieldList = new List<String>();
        for(SObject obj : sobjects){
            fieldList.add((String)obj.get(fieldName));
        }
        return fieldList;
    }
    
    public static List<String> joiningByIdList(List<SObject> sobjects) {
        return joiningByFieldList(sobjects,'Id');
    }
    
    /*
     *   @programer:    Samuel Astol
     *   @date:         12/09/2015
     *   @description:  METHOD TO BE REMOVED SOON 
     *   @name:         getVendorsSpecific
     *
     */
    public static  List<UNITY_wrapperVendorByTrade> getVendorsSpecific(id sobjectId , boolean justVendorAssignments ){
        
        String locationKey = null ;
        String trade       = null ; 
        Id customerId      = null ;
        
        boolean isFromWO      = false;
        boolean isFromAccount = false;
        
        WorkOrder  aux_wo  = null ;
        Account            aux_acc = null ;
        
        list<UNITY_Vendor_Assignment__c> assignments = new list<UNITY_Vendor_Assignment__c>() ; 
        
           
        // list to return
        List<UNITY_wrapperVendorByTrade> vendors = new List<UNITY_wrapperVendorByTrade>();
        
        return vendors;
    }
    
    
    /*
     *   @programer:    Samuel Astol
     *   @date:         12/09/2015
     *   @description:  check if an object has the field 
     *   @name:         hasSObjectField
     *
     */
    public static boolean hasSObjectField(String fieldName, SObject so){
      return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName);
    }

    public static string getSObjectTypeName(SObject so) {
        return so.getSObjectType().getDescribe().name;
    }

    public static Schema.SObjectType getSObjectType(String sObjectTypeName) {
        return globalDescribe.get(sObjectTypeName);
    }
    
    /*
     *   @programer:    Samuel Astol
     *   @description:  get the location key =  [ shippingCountryCode first 2 characters ] + [ ShippingPostalCode first 3 characters ]
     *   @date:         12/09/2015
     *   @name:         getLocationKey
     *   @param1:       <string> shipping Country Code 
     *   @param2:       <string> Shipping Postal Code
     *   @return:       <string> example  --> 'OH'-'123'
     */
    public static String getLocationKey(String shippingCountryCode, String ShippingPostalCode){

        String locationKey = '';

        if( (shippingCountryCode != null) && (ShippingPostalCode != null) ){

                locationKey = shippingCountryCode.substring(0,2).trim() +'-'+ShippingPostalCode.substring(0, 3).trim();

        }

        return locationKey;
    }

    public static DateTime getDateTime(){
        return  DateTime.now(); 
    } 
    
    public static integer getDayOfTheWeek(){
        date myDate          = Date.today();
        date weekStart       = myDate.toStartofWeek();
        integer dayOfTheWeek = weekStart.daysBetween(myDate);
        return  dayOfTheWeek;
    } 
    
    public static void applyTemplates(Map<Id, Id> recordIdTemplateId, List<SObject> sObjectsWithTemplate, String templateLookupField, String sObjectName){
        
        if (!sObjectsWithTemplate.isEmpty()){
            System.debug('#recordIdTemplateId '+recordIdTemplateId);
            
            //get hierarchy data         
            Map<Id,UNITY_Template_Configuration__c> templateConfigMap = new Map<Id,UNITY_Template_Configuration__c>([select id, Name, UNITY_Applicable_Template__c, UNITY_Node_Type__c, UNITY_Node_Value__c, UNITY_Part_Lookup__c, UNITY_Target_Object__c, UNITY_Target_Object_Record_Type__c from UNITY_Template_Configuration__c where id in:recordIdTemplateId.values()]);        
            
            Map<Id, List<UNITY_MultiLevelHierarchyUtility.HierarchyNode>> hierarchyMap = new Map<Id, List<UNITY_MultiLevelHierarchyUtility.HierarchyNode>>();
            
            List<UNITY_MultiLevelHierarchyUtility.HierarchyNode> nodes = UNITY_MultiLevelHierarchyUtility.getHierarchiesOptimized(templateConfigMap.keySet()).values();
            
            /* Start - Price Book Related code */
            //map <orderId, priceBook>
            Map<Id, Id> orderPriceBookMap = new Map<Id, Id>();
            poppulateOrderPriceBookMap(orderPriceBookMap, sObjectsWithTemplate, sObjectName);
            Map<String, PricebookEntry> priceBookEntryMap = priceBookRelatedWithTemplate(orderPriceBookMap, sObjectsWithTemplate, sObjectName, nodes);        
            
            UNITY_MultiLevelHierarchyUtility.priceBookMap = orderPriceBookMap;
            UNITY_MultiLevelHierarchyUtility.priceBookEntryMap = priceBookEntryMap;
            /* End - Price Book Related code */
            
            for (UNITY_MultiLevelHierarchyUtility.HierarchyNode currentNode : nodes){
                
                System.debug('#UNITY_MultiLevelHierarchyUtility.getHierarchiesOptimized->currentNode '+currentNode);
                
                Id templateId = currentNode.node.UNITY_Template_Parent__c;
                
                if (hierarchyMap.get(templateId) == null){
                    hierarchyMap.put(templateId, new List<UNITY_MultiLevelHierarchyUtility.HierarchyNode>());
                }
                hierarchyMap.get(templateId).add(currentNode);
            }
            
            //create sobject hierarchy
            List<sObject> sObjectsToBeCreated = new List<sObject>();
            
            for (sObject record: sObjectsWithTemplate){
                
                List<UNITY_MultiLevelHierarchyUtility.HierarchyNode> childs = hierarchyMap.get((Id)record.get(templateLookupField));            
                
                for(UNITY_MultiLevelHierarchyUtility.HierarchyNode node: childs){
                    
                    System.debug('#child node '+node);
                
                    sObjectsToBeCreated.addAll(UNITY_MultiLevelHierarchyUtility.traverseChildren(node, sObjectName, record.Id, null));
                }
            } 
            
            //clear template field
            List<SObject> sObjectsToUpdate = new List<SObject>();
            
            for (SObject iter: sObjectsWithTemplate){
                
                sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();
                sObj.put('Id',iter.Id);
                sObj.put(templateLookupField, null);
                
                //added to populate product field if present (asset)
                if (recordIdTemplateId.get(iter.Id) != null){
                    Id templateId = recordIdTemplateId.get(iter.Id);
                    
                    if (templateConfigMap.get(templateId).UNITY_Part_Lookup__c != null){
                        sObj.put('Product2Id', templateConfigMap.get(templateId).UNITY_Part_Lookup__c);
                    }
                }   
                
                sObjectsToUpdate.add(sObj);
                
            }
            
            update sObjectsToUpdate;
            
            System.debug('#sObjectsToBeCreated '+sObjectsToBeCreated);
            List<Database.SaveResult> resultList = Database.insert(sObjectsToBeCreated);
        }
    }
    
    public static void poppulateOrderPriceBookMap(Map<Id, Id> orderPriceBookMap, List<SObject> records, String sObjectName){

        if (sObjectName == 'Order'){
            
            for (SObject record: records){
                
                Order orderRecord = (Order)record;
                orderPriceBookMap.put(orderRecord.Id, orderRecord.Pricebook2Id);
            }
        }
    }
    
    public static void populateProductList(List<Id> productList, List<UNITY_MultiLevelHierarchyUtility.HierarchyNode> nodes, Id parentId){
        
        for(UNITY_MultiLevelHierarchyUtility.HierarchyNode node: nodes){
            
            if (parentId == null){
                parentId = node.node.UNITY_Template_Parent__c;
            }
            
            Id productId  = node.node.UNITY_Part_Lookup__c;
            
            productList.add(productId);
            
            populateProductList(productList, node.children, parentId);
        }
    }
    
    //returns Map<PriceBookId+ProductId. PriceBookEntryId>
    public static Map<String, PricebookEntry> priceBookRelatedWithTemplate(Map<Id, Id> orderPriceBookMap, List<SObject> sObjectsWithTemplate, String sObjectName, List<UNITY_MultiLevelHierarchyUtility.HierarchyNode> templateNodes){
        
        Map<String, PricebookEntry> result = new Map<String, PricebookEntry> ();
        
        //map <templateId, List<productId>>
        List<Id> productList = new List<Id>();
        
        populateProductList(productList, templateNodes, null);
        
        Id standardPriceBookId = UNITY_Constants.getStandardPriceBookId();
        
        List<PricebookEntry> priceBookEntryList = [select id, UnitPrice, Product2Id, Pricebook2Id from PricebookEntry where Product2Id in:productList and (Pricebook2Id in:orderPriceBookMap.values() or Pricebook2Id =:standardPriceBookId)];
        
        
        for (PricebookEntry entry: priceBookEntryList){
            
            result.put((String)entry.Pricebook2Id+(String)entry.Product2Id, entry);
        }
        
        return result;
    }
    
    /*
     *  Generate a random four digit ping.
     */
    public static String generateRandomPin() {
        return String.valueOf(Math.random()).right(4);
    }
    
    public static SObject createObject(SObjectType objectT , Map<String,Object> fields ) {
        
        SObject obj = objectT.newSObject();
        if(fields!=null){
            for(String field :fields.keySet()){
                if((field!=null) &&(objectT.getDescribe().fields.getMap().get(field) != null)){
                    obj.put(field.toLowerCase(),fields.get(field));
                }
            } 
        }
        return obj;
    }
    
    public static DateTimeZone getDateTime(DateTime onDateTime ,  String f, String tzId) {
        
        String   timeZoneId = ((tzId==null)?'America/Chicago':tzId);
        String   format   = ((f==null)?'MM/dd/YYYY hh:mm a':f);
        onDateTime   = ((onDateTime==null)?DateTime.now():onDateTime);
        String   tofullFormat = '';
        String   toDate = '';
        String   toTime = '';
        String   toHH = '';
        String   toMM = '';
        
        toDate       = onDateTime.format('MM/dd/YYYY', timeZoneId);
        toHH         = onDateTime.format('HH', timeZoneId);
        toMM         = onDateTime.format('mm', timeZoneId);
        toTime       = onDateTime.format('hh:mm a', timeZoneId);
        tofullFormat = onDateTime.format(format, timeZoneId);
        
        TimeZone tzone = TimeZone.getTimeZone(timeZoneId);
        Integer offsetGMT = tzone.getOffset(onDateTime);
        Integer offsetHours = offsetGMT/3600000;
        
        DateTimeZone toReturn = new DateTimeZone();
        toReturn.formatTime = toTime;
        toReturn.formatDate = toDate;
        toReturn.format = tofullFormat;
        toReturn.HH = integer.valueOf(toHH);
        toReturn.MM = integer.valueOf(toMM);
        toReturn.displayname = tzone.getDisplayName();
        toReturn.timeZoneId  = timeZoneId;
        toReturn.localDatetime = onDateTime.addHours(offsetHours);
        toReturn.offsetHour = offsetHours;
            
        return toReturn;
    }
    
    public static Map<String,DateTimeZone> getDateTime( Map<String,DateTime> dates,  String f, String tzId) {
        
        Map<String,DateTimeZone> toReturn = new Map<String,DateTimeZone>();
        
        for(String key :dates.keySet()){
            toReturn.put(key, getDateTime(dates.get(key), f, tzId));
        }
        return toReturn;
    }
    
    
    
    public static Map<String,Object> toMap(Object obj) {
        // Serialize our Object into JSON
        String s = JSON.serialize(obj);
        // Deserialize it back into a key/value map
        return (Map<String,Object>) JSON.deserializeUntyped(s);
    }
        
    public class DateTimeZone{
        public String format{get;set;}
        public String formatDate{get;set;}
        public String formatTime{get;set;}
        public String displayname{get;set;} 
        public String timeZoneId{get;set;}
        public Integer HH{get;set;}
        public Integer MM{get;set;}
        public Datetime localDatetime{get;set;}
        public Integer offsetHour{get;set;}
    } 
    
    /*
     * Name    : getAccounts
     * Param   : List< WO id>
     * Return  : Map<id,WorkOrder>
     * 
     */
    public static Map<id,WorkOrder> getWorkOrders(list<String> workOrdersId){
        
        Map<id,WorkOrder> toReturn = new Map<id,WorkOrder>([SELECT id, 
                                                                   Priority,
                                                                   AccountId,
                                                                   RecordTypeId,
                                                                   UNITY_Trade__c, 
                                                                   RecordType.Name,
                                                                   UNITY_Customer__c,
                                                                   UNITY_Trade__r.Name, 
                                                                   UNITY_Customer_Margin__c,
                                                                   Account.ShippingPostalCode, 
                                                                   Account.ShippingCountryCode,
                                                                   UNITY_Customer_Service_Contract_Price__c
                                                            FROM   WorkOrder
                                                            WHERE  id IN :workOrdersId ]);
        return toReturn;
    }
    
    /*
     * Name    : getAccounts
     * Param   : List< account id>
     * Return  : Map<id,Account>
     * 
     */
    public static Map<id,Account> getAccounts(List<id> accountsId){
        
        Map<id,Account> accounts  = new Map<id,Account>([SELECT id, Name, Phone ,  
                                                                UNITY_Dispatcher__c, 
                                                                Account_Email__c, 
                                                                ShippingPostalCode, 
                                                                ShippingCountryCode,
                                                                UNITY_Preferred_Vendor__c,
                                                                UNITY_Vendor_Type_PM__c, 
                                                                UNITY_Vendor_Type_Project__c,
                                                                UNITY_Vendor_Type_SR__c, 
                                                                UNITY_Vendor_Type_SS__c,
                                                                UNITY_Vendor_Status__c  ,
                                                                UNITY_Sunday_Start_Time__c   , UNITY_Sunday_End_Time__c,
                                                                UNITY_Monday_Start_Time__c   , UNITY_Monday_End_Time__c,
                                                                UNITY_Tuesday_Start_Time__c  , UNITY_Tuesday_End_Time__c,
                                                                UNITY_Wednesday_Start_Time__c, UNITY_Wednesday_End_Time__c,
                                                                UNITY_Thursday_Start_Time__c , UNITY_Thursday_End_Time__c, 
                                                                UNITY_Friday_Start_Time__c   , UNITY_Friday_End_Time__c  , 
                                                                UNITY_Saturday_Start_Time__c , UNITY_Saturday_End_Time__c,
                                                                UNITY_TimeZoneSidKey__c ,
                                                                UNITY_Miner_Regional_Office__c ,
                                                                UNITY_Hours_of_Operation_Summary__c,
                                                                UNITY_Do_Not_Use__c
                                                         FROM    Account
                                                         WHERE   id IN :accountsId AND (Account.ShippingCountryCode IN :UNITY_Constants.allowVendorCountries)]);
        return accounts;
    } 

    /*
     * Name    : insertJobLog
     * Param   : string sJobName, string sEvent, string sMessage, optional enum enumSeverity
     * Return  : null;
     * 
     */
    public static void insertJobLog(UNITY_Constants.JOB_LOG_SEVERITY eSeverity, string sJobName, string sEvent, string sMessage){
        UNITY_Job_Log__c log = new UNITY_Job_Log__c();
        log.Job_Name__c = sJobName;
        log.Event__c = sEvent;
        log.Message__c = sMessage;

        if (eSeverity == UNITY_Constants.JOB_LOG_SEVERITY.INFO)
            log.Severity__c = 'INTO';
        else if (eSeverity == UNITY_Constants.JOB_LOG_SEVERITY.WARNING)
            log.Severity__c = 'WARNING';
        else if (eSeverity == UNITY_Constants.JOB_LOG_SEVERITY.ERROR)
            log.Severity__c = 'ERROR';
        else
            log.Severity__c = 'INTO';

        insert log;   
    }
    
    private static Map<Id, Asset> getAssetForCounter(Set<id> assetIds){
      Map<Id, Asset> toReturn = new Map<Id, Asset>();

      if((assetIds!=null) && !assetIds.isEmpty())
          toReturn =  new Map<Id, Asset>([SELECT Id,
                                                SSVY_Open_Work_Orders__c,
                                                SSVY_Total_of_Work_Orders__c,
                                                (SELECT Id, WorkOrderId, WorkOrder.Status, UNITY_Work_Order_Closed__c FROM WorkOrderLineItems)
                                        FROM    Asset
                                        WHERE   Id IN :assetIds]);

      return toReturn;
    }

    public static void countWorkOrdersOnAsset(Set<id> recordsId, SObjectType SOType){

      system.debug('>>> countWorkOrdersOnAsset > recordsId '+recordsId);
      Set<Id>        aux_openWO   = new Set<Id>();
      Set<Id>        aux_totalWO  = new Set<Id>();
      Set<Id>        aux_assetIds = new Set<Id>();
      Map<Id, Asset> assetMap     = new Map<Id, Asset>();
      Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>();


        if((recordsId!=null) && !recordsId.isEmpty()){

            if(SOType == WorkOrder.getSObjectType()){
                woliMap = new Map<Id, WorkOrderLineItem>([SELECT Id, AssetId FROM WorkOrderLineItem WHERE WorkOrderId IN :recordsId]);
                for(WorkOrderLineItem woli :woliMap.values()){
                    aux_assetIds.add(woli.AssetId);
                }
                assetMap = getAssetForCounter(aux_assetIds);
            }else if(SOType == Asset.getSObjectType()){
                assetMap = getAssetForCounter(recordsId);
            }



            for(Asset onAsset :assetMap.values()){

                aux_openWO  = new Set<Id>();
                aux_totalWO = new Set<Id>();

                if(onAsset.WorkOrderLineItems.isEmpty()){
                    onAsset.SSVY_Open_Work_Orders__c     = 0;
                    onAsset.SSVY_Total_of_Work_Orders__c = 0;
                }else{
                  for(WorkOrderLineItem woli :onAsset.WorkOrderLineItems){
                      aux_totalWO.add(woli.WorkOrderId);
                      if(!woli.UNITY_Work_Order_Closed__c)
                        aux_openWO.add(woli.WorkOrderId);
                  }
                  onAsset.SSVY_Open_Work_Orders__c     = aux_openWO.size();
                  onAsset.SSVY_Total_of_Work_Orders__c = aux_totalWO.size();
                }
            }
            update assetMap.values();
        }

    }

}