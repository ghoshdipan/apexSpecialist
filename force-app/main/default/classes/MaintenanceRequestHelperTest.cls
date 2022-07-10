@IsTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @TestSetup
    static void setup(){
        Vehicle__c vehicle = new Vehicle__c(
            Name = 'Honda City',
            Air_Conditioner__c = true,
            Awning__c = 'Manual'
        );
        insert vehicle;

        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2(
            Name = 'Brake Shoes',
            Cost__c = 213,
            Maintenance_Cycle__c = 90,
            Lifespan_Months__c = 180,
            Replacement_Part__c = true
        );
        Product2 prod2 = new Product2(
            Name = 'Engine Oil',
            Cost__c = 113,
            Maintenance_Cycle__c = 800,
            Lifespan_Months__c = 29,
            Replacement_Part__c = true
        );
        prodList.add(prod1);
        prodList.add(prod2);
        insert prodList;

        Case eqM = new Case(
            Product__c = 'GC3040',
            Vehicle__c = vehicle.Id,
            ProductId = prod1.Id,
            Type = 'Routine Maintenance',
            Status = 'Escalated',
            Origin = 'Web'
        );
        insert eqM;

        List<Equipment_Maintenance_Item__c> eqMItemList = new List<Equipment_Maintenance_Item__c>();
        Equipment_Maintenance_Item__c eqMItem1 = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = eqM.Id,
            Equipment__c = prod1.Id,
            Quantity__c = 3
        );
        Equipment_Maintenance_Item__c eqMItem2 = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = eqM.Id,
            Equipment__c = prod2.Id,
            Quantity__c = 4
        );
        eqMItemList.add(eqMItem1);
        eqMItemList.add(eqMItem2);
        insert eqMItemList;
    }

    @isTest
    static void testTestCase() {
        // Test data setup
        List<Case> caseList = [SELECT Id FROM Case WHERE Product__c = 'GC3040'];
        caseList[0].Status = 'Closed';
        

        // Actual test
        Test.startTest();
            update caseList;
        Test.stopTest();
            
        // Asserts
        List<Case> newCaseList = [SELECT Id FROM Case WHERE Product__c = 'GC3040' AND Status != 'Closed'];
        System.assertEquals(newCaseList.size(), 1, 'ERROR!');
        
        List<Equipment_Maintenance_Item__c> newEqMItemList = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c  !=:caseList[0].Id];
        System.assertEquals(newEqMItemList.size(), 2, 'ERROR!');
    }
}