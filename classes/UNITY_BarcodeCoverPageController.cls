public class UNITY_BarcodeCoverPageController {

    
    public WorkOrder wo {get;set;}
    public Id recordId {
        get{
            return (Id)strRecordId;
        }
        set;}
    public String strRecordId {get;
        set{            
            strRecordId = value;
        }
    }
    public String objType {
        get{
            return recordID.getSObjectType().getDescribe().getName();
        }
        set;
    }
    public String documentCode {
        get{
            Document_Type_Code_Mapping__mdt dtc = [SELECT Type_Code__c, Type__c FROM Document_Type_Code_Mapping__mdt WHERE Type__c=:documentType LIMIT 1];
            if (dtc != null)
                return dtc.Type_Code__c;
            return null;
        }
        set;
    }
    public String documentType {get;set;}
    public string objIdentifier{
        get{
            if (objType == 'WorkOrder'){
                wo = [SELECT WorkOrderNumber FROM WorkOrder WHERE ID = :recordId];
                return wo.WorkOrderNumber;
            }
            return null;
        }
        set;}
    
    public UNITY_BarcodeCoverPageController(){
        
    }
}