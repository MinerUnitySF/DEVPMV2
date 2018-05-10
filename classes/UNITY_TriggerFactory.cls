/*
 *   @programer:    Samuel Astol
 *   @description:  Used to instantiate and execute Trigger Handlers associated with sObjects.
 *   @date:         11/17/2015            
 */
public with sharing class UNITY_TriggerFactory {
    
    /**
     * Public static method to create and execute a trigger handler
     * @arguments:   Type t - Type of handler to instatiate
     */
    public static void createAndExecuteHandler(Type t){
        // Get a handler appropriate to the object being processed
        UNITY_ITrigger handler = getHandler(t);
        // Execute the handler to fulfil the trigger
        if(!UNITY_Constants.isExecutingTooMany(t.toString())) {
            execute(handler);   
        }
    }
    
    /**
     * Private static method to control the execution of the handler
     * @arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(UNITY_ITrigger handler){
        // Before Trigger
        if (Trigger.isBefore){
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            if (Trigger.isDelete){
                // Iterate through the records to be deleted passing them to the handler.
                for (SObject so : Trigger.old){
                    handler.beforeDelete(so);
                }
            } else if (Trigger.isInsert) {
                // Iterate through the records to be inserted passing them to the handler.
                for (SObject so : Trigger.new){
                    handler.beforeInsert(so);
                }
            } else if (Trigger.isUpdate) {
                // Iterate through the records to be updated passing them to the handler.
                for (SObject so : Trigger.old){
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        } else { // After Trigger
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            if (Trigger.isDelete){
                // Iterate through the records deleted passing them to the handler.
                for (SObject so : Trigger.old){
                    handler.afterDelete(so);
                }
            } else if (Trigger.isInsert){
                // Iterate through the records inserted passing them to the handler.
                for (SObject so : Trigger.new){
                    handler.afterInsert(so);
                }
            } else if (Trigger.isUpdate){
            //UNITY_CaseUtilities.onAfterUpdate(null,Trigger.New);

                // Iterate through the records updated passing them to the handler.
                for (SObject so : Trigger.old){
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        // Perform any post processing
        handler.andFinally();
    }

///////////////////////////////////////////////////////////////////////
//Same methods with set of recordtype id overload
///////////////////////////////////////////////////////////////////////
    //CLAY: TEST OF OVERLOAD create and execute handler with Recordtype filter
    public static void createAndExecuteHandler(Type t, Set<Id> rtSet){
        // Get a handler appropriate to the object being processed and pass
        UNITY_ITrigger handler = getHandler(t, rtSet);
        // Execute the handler to fulfil the trigger
        if(!UNITY_Constants.isExecutingTooMany(t.toString())) {
            execute(handler, rtSet);   
        }
    }

    /**
     *
     * Private static method to control the execution of the handler
     * @arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(UNITY_ITrigger handler, Set<Id> rtSet){
        List<SObject> newFilteredList = UNITY_Utils.includeRecordType(trigger.new, rtSet);
        List<SObject> oldFilteredList = UNITY_Utils.includeRecordType(trigger.old, rtSet);
        Map<Id, SObject> oldFilteredMap = UNITY_Utils.includeRecordType(Trigger.oldMap, rtSet);
        Map<Id, SObject> newFilteredMap = UNITY_Utils.includeRecordType(Trigger.newMap, rtSet);

        // Before Trigger
        if (Trigger.isBefore){
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore(newFilteredList, oldFilteredList, oldFilteredMap, newFilteredMap);
            if (Trigger.isDelete){
                // Iterate through the records to be deleted passing them to the handler.
                for (SObject so : oldFilteredList){
                    handler.beforeDelete(so);
                }
            } else if (Trigger.isInsert) {
                // Iterate through the records to be inserted passing them to the handler.
                for (SObject so : newFilteredList){
					handler.beforeInsert(so);
                }
            } else if (Trigger.isUpdate) {
                // Iterate through the records to be updated passing them to the handler.
                for (SObject so : oldFilteredList){
                    handler.beforeUpdate(so, newFilteredMap.get(so.Id));
                }
            }
        } else { // After Trigger
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter(newFilteredList, oldFilteredList, oldFilteredMap, newFilteredMap);
            if (Trigger.isDelete){
                // Iterate through the records deleted passing them to the handler.
                for (SObject so : oldFilteredList){
                    handler.afterDelete(so);
                }
            } else if (Trigger.isInsert){
                // Iterate through the records inserted passing them to the handler.
                for (SObject so : newFilteredList){
                    handler.afterInsert(so);
                }
            } else if (Trigger.isUpdate){
                // Iterate through the records updated passing them to the handler.
                for (SObject so : oldFilteredList){
                    handler.afterUpdate(so, newFilteredMap.get(so.Id));
                }
            }
        }
        // Perform any post processing
        handler.andFinally();
    }



    
    /**
     * Private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     * @arguments:   Type t - Class of handler to instatiate
     * @returns:     UNITY_ITrigger - A trigger handler if one exists or null.
     */
    private static UNITY_ITrigger getHandler(Type t){
        // Instantiate the type
        Object o = t.newInstance();
        return o instanceOf UNITY_ITrigger ? (UNITY_ITrigger) o : null;
    }
    /**
     * Clay: Duplicated to provide a different 'path' when we pass a set of recordtype IDs
     * Private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     * @arguments:   Type t - Class of handler to instatiate
     * @returns:     UNITY_ITrigger - A trigger handler if one exists or null.
     */
    private static UNITY_ITrigger getHandler(Type t, Set<Id> rtSet){
        // Instantiate the type
        Object o = t.newInstance();
        return o instanceOf UNITY_ITrigger ? (UNITY_ITrigger) o : null;
    }

    //
}