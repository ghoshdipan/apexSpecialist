public with sharing class WarehouseCalloutService implements Queueable{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public void execute(QueueableContext qc){
        callout();
    }
    
    @future(callout = true)
    public static void callout(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Parse the JSON response
        if(response.getStatusCode() == 200) {
            List<Object> result = (List<Object>) JSON.deserializeUntyped(response.getBody());
            if(result != null){
                List<Product2> eqList = insertEquipments(result);
                insert eqList;
            }
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
    }

    public static List<Product2> insertEquipments(List<Object> result){
        List<Product2> eqList = new List<Product2>();
        for(Object obj : result){
            Map<String,Object> currMap = (Map<String,Object>) obj;
            Product2 equipment = new Product2(
                Replacement_Part__c = true,
                Name = String.valueOf(currMap.get('name')),
                Cost__c = Decimal.valueOf(String.valueOf(currMap.get('cost'))),
                Current_Inventory__c = Integer.valueOf(String.valueOf(currMap.get('quantity'))),
                Lifespan_Months__c = Integer.valueOf(String.valueOf(currMap.get('lifespan'))),
                Maintenance_Cycle__c = Integer.valueOf(String.valueOf(currMap.get('maintenanceperiod'))),
                Warehouse_SKU__c = String.valueOf(currMap.get('sku'))
            );
            eqList.add(equipment);
        }
        return eqList;
    }
}