public with sharing class WarehouseSyncSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc){

        ID jobID = System.enqueueJob(new WarehouseCalloutService());
    }
}