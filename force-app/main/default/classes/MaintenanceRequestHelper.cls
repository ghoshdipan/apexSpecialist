public class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> caseList) {
        List<Case> caseListToIns = new List<Case>();
        Map<Id,Case> oldCaseList = new Map<Id,Case>(caseList);
        List<Case> closedList = [SELECT Id,
                                            Type,
                                            Vehicle__c,
                                            ProductId,
                                            Product__c,
                                            Origin,
                                            (SELECT Id,Equipment__c,Quantity__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r)
                                        FROM Case 
                                        WHERE Id IN:oldCaseList.keySet()
                                        AND Status='Closed'];
        Map<Id,List<Equipment_Maintenance_Item__c>> mainReqMap = new Map<Id,List<Equipment_Maintenance_Item__c>>();        
        Map<Id, Integer> equipmentMap = getDueDate(caseList);
        for(Case caseObj : closedList){
            if(caseObj.Type.equals('Routine Maintenance') || caseObj.Type.equals('Repair')){
                Case toInsert = new Case();
                toInsert.Vehicle__c=caseObj.Vehicle__c;
                toInsert.ProductId=caseObj.ProductId;
                toInsert.Product__c=caseObj.Product__c;
                toInsert.Type='Routine Maintenance';
                toInsert.Subject='Routine Maintenance';
                toInsert.Status='New';
                toInsert.ParentId=caseObj.Id;
                toInsert.Origin=caseObj.Origin;
                toInsert.Date_Reported__c=Date.today();
                toInsert.Date_Due__c=Date.today().addDays(equipmentMap.get(caseObj.Id));
                caseListToIns.add(toInsert);

                if(caseObj.Equipment_Maintenance_Items__r != null && !caseObj.Equipment_Maintenance_Items__r.isEmpty()){
                    mainReqMap.put(caseObj.Id, caseObj.Equipment_Maintenance_Items__r);
                }
            }
        }
        insert caseListToIns;
        manageRelatedLists(caseListToIns,mainReqMap);
    }

    public static void manageRelatedLists(List<Case> newCaseList, Map<Id,List<Equipment_Maintenance_Item__c>> mainReqMap){
        List<Equipment_Maintenance_Item__c> eqpMainList = new List<Equipment_Maintenance_Item__c>();
        for(Case newCase:newCaseList){
            for(Equipment_Maintenance_Item__c equipmentMItem : mainReqMap.get(newCase.ParentId)){
                Equipment_Maintenance_Item__c clonedEquipmentMItem = new Equipment_Maintenance_Item__c();
                clonedEquipmentMItem.Maintenance_Request__c = newCase.Id;
                clonedEquipmentMItem.Equipment__c = equipmentMItem.Equipment__c;
                clonedEquipmentMItem.Quantity__c = equipmentMItem.Quantity__c;
                eqpMainList.add(clonedEquipmentMItem);
            }
        }

        insert eqpMainList;
	}

    public static Map<Id,Integer> getDueDate(List<Case> caseList){
        Map<Id,Integer> equipmentMap = new Map<Id,Integer>();
        Map<Id, Case> caseMap = new Map<Id, Case> (caseList);        
        List<AggregateResult> aggregateList = [SELECT Maintenance_Request__c reqId,
                                                MIN(Equipment__r.Maintenance_Cycle__c) minDays
                                                FROM Equipment_Maintenance_Item__c 
                                                WHERE Maintenance_Request__c IN :caseMap.keySet() 
                                                GROUP BY Maintenance_Request__c];
        for(AggregateResult mainReq : aggregateList){
            Integer days=0;
            if(mainReq.get('minDays')!=null){
                days = Integer.valueOf(mainReq.get('minDays'));
            }
            equipmentMap.put((Id)mainReq.get('reqId'), days);
        }
        return equipmentMap;
    }
}