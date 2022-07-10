@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    public static String CRON_EXP = '0 0 0 * * ? 2022';
    // implement your mock callout test here
    @TestSetup
    static void setup(){

    }

    @isTest
    static void testTestCase() {
        // Test data setup
    
        // Actual test
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,new WarehouseSyncSchedule());
        Test.stopTest();
    
        // Asserts
        List<Product2> eqList = [SELECT Id FROM Product2];
        System.assert(eqList.size()>0, 'ERROR');
    }
}