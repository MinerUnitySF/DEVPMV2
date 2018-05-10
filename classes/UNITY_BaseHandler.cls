public virtual class UNITY_BaseHandler implements UNITY_ITrigger {
    
    public virtual void bulkBefore(){}
    public virtual void bulkBefore(List<SObject> newFilteredList, List<SObject> oldFilteredList, Map<Id,SObject> oldFilteredMap, Map<Id,SObject> newFilteredMap){}

    public virtual void bulkAfter(){}
    public virtual void bulkAfter(List<SObject> newFilteredList, List<SObject> oldFilteredList, Map<Id,SObject> oldFilteredMap, Map<Id,SObject> newFilteredMap){}
    
    public virtual void beforeInsert(SObject so){}
    public virtual void beforeInsert(SObject so, Id rt){}
    
    public virtual void beforeUpdate(SObject oldSo, SObject so){}
    
    public virtual void beforeDelete(SObject so){}
    
    public virtual void afterInsert(SObject  so){}
    
    public virtual void afterUpdate(SObject oldSo, SObject so){}
    
    public virtual void afterDelete(SObject so){}
    
    public virtual void andFinally(){}

}