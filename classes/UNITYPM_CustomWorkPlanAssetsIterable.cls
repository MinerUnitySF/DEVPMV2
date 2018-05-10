global class  UNITYPM_CustomWorkPlanAssetsIterable implements Iterator<list<UNITYPM_WorkPlanAssetsWrapper>>
{ 
  list < UNITYPM_WorkPlanAssetsWrapper > InnerList {get;set;} // Holds all the values
        list < UNITYPM_WorkPlanAssetsWrapper > ListRequested {get;set;} // Holds the value to be displayed on the Page
        Integer i {get;set;}
        public Integer setPageSize {get;set;}
        
     
        public UNITYPM_CustomWorkPlanAssetsIterable(List < UNITYPM_WorkPlanAssetsWrapper > lstAccWr)
        {
            InnerList = new list < UNITYPM_WorkPlanAssetsWrapper > ();
            ListRequested = new list < UNITYPM_WorkPlanAssetsWrapper > ();
            InnerList = lstAccWr;
            setPageSize = 10;
            i = 0;
        }
        
        global boolean hasNext()
        {
            if (i >= InnerList.size())
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        
        global boolean hasPrevious()
        {
            if (i <= setPageSize)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        
     global list < UNITYPM_WorkPlanAssetsWrapper > next()
      {
        ListRequested = new list < UNITYPM_WorkPlanAssetsWrapper > ();
        integer startNumber;
        integer size = InnerList.size();
        
            if (hasNext())
            {
                if (size <= (i + setPageSize))
                {
                    startNumber = i;
                    i = size;
                }
                else
                {
                    i = (i + setPageSize);
                    startNumber = (i - setPageSize);
               }
                for (integer start = startNumber; start < i; start++)
                {
                     ListRequested.add(InnerList[start]);
                }
            }
           
        return ListRequested;
        }
        
        global list < UNITYPM_WorkPlanAssetsWrapper > previous()
        {
        ListRequested = new list < UNITYPM_WorkPlanAssetsWrapper > ();
        integer size = InnerList.size();
        if (i == size)
        {
            if (math.mod(size, setPageSize) > 0)
            {
                i = size - math.mod(size, setPageSize);
            }
            else
            {
                i = (size - setPageSize);
            }
        }
        else
        {
            i = (i - setPageSize);
        }
        
        for (integer start = (i - setPageSize); start < i; ++start) {
            ListRequested.add(InnerList[start]);
        }
        return ListRequested;
        }
        
    }