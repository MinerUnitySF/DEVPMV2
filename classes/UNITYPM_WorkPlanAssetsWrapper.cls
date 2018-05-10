global class UNITYPM_WorkPlanAssetsWrapper implements Comparable {
     public boolean selected { get; set;}
      public Asset  asset {get; set;}
      public  List<SelectOption> wplist {get; set;}
      public Integer numberOfRow {get; set;} 
      public String SelectedOption { get; set; }
      public String wpName { get; set; }
      public String wpID { get; set; }
      public string workOrderID {get;set;}
      
      public static String compareField {get; set;}
      public static String sortOrder {get; set;}
     
      public UNITYPM_WorkPlanAssetsWrapper (Asset asset,  List<SelectOption> wplist, Integer rowCounter, Boolean selected){
          this.selected = selected;
          this.asset = asset;
          this.wplist = wplist;
          this.numberOfRow = rowCounter;
      } 
       public UNITYPM_WorkPlanAssetsWrapper (Asset asset,  List<SelectOption> wplist, Integer rowCounter, Boolean selected, String workOrderID){
          this.selected = selected;
          this.asset = asset;
          this.wplist = wplist;
          this.numberOfRow = rowCounter;
          this.workOrderID = workOrderID;
      } 
      
       public UNITYPM_WorkPlanAssetsWrapper (Asset asset,  String wpName, string wpID, Integer rowCounter, Boolean selected){
          this.selected = selected;
          this.asset = asset;
          this.wpName = wpName;
          this.wpID = wpID;
          this.numberOfRow = rowCounter;
      } 
      
       public UNITYPM_WorkPlanAssetsWrapper (Asset asset, Integer rowCounter, Boolean selected){
          this.selected = selected;
          this.asset = asset;
          this.numberOfRow = rowCounter;
      } 
      
 
      public Integer compareTo(Object vRec) {
        UNITYPM_WorkPlanAssetsWrapper recToCompare = (UNITYPM_WorkPlanAssetsWrapper) vRec;
       
        if (compareField == 'selected' ){
            if ( recToCompare.selected == true){
                return sortOrder.equals('asc') ? 1 : 0;   
            }
            else{
             
              return  sortOrder.equals('asc') ? 0 : 1;  
            }
        }
        else if ((String) asset.get(compareField) > (String) recToCompare.asset.get(compareField)) {
            return sortOrder.equals('asc') ? 1 : 0;
         } else {
            return sortOrder.equals('asc') ? 0 : 1;
        }
        
    }
}