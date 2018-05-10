/**
 * Created by mbesmonte on 5/9/2018.
 */

public with sharing class UNITY_DocParseBatchScheduler implements Schedulable{

    public Integer batchSize {get; set;}

    public UNITY_DocParseBatchScheduler(){
    }

    public UNITY_DocParseBatchScheduler(Integer bSize){
        batchSize = bSize;
    }

    public void execute(SchedulableContext sc){
        UNITY_DocParserBatch batchClass = new UNITY_DocParserBatch();

        Integer size = (batchSize == null || batchSize == 0) ? 1 : batchSize;
        Database.executeBatch(batchClass, size);

    }


}