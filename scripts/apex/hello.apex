List<Case> maintenanceRequestList =[SELECT Id,Status FROM Case WHERE Type='Routine Maintenance' LIMIT 5];
for(Case c:maintenanceRequestList){
    System.debug(c.Status);
    c.Type='Repair';
}
update maintenanceRequestList;

DELETE [SELECT Id FROM Case LIMIT 5];