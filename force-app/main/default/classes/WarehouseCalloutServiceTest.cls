@IsTest
class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @TestSetup
    static void setup(){

    }

    @isTest
    static void testTestCase() {    
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        // Actual test
        Test.startTest();
        WarehouseCalloutService calloutClass = new WarehouseCalloutService();
        calloutClass.execute(null);
        Test.stopTest();
    
        // Asserts
        List<Product2> eqList = [SELECT Id FROM Product2];
        System.assert(eqList.size()>0, 'ERROR');
    }
}