/**
 * These bulk tests are used to compare the performance of the TDTM design using 
 * Custom Settings vs Custom Objects.
 */
@isTest
public with sharing class TDTM_ObjectPerf_Batch_TEST {

    public static testmethod void manyClassesOneRecordChange() {
    	//Define which classes (and in which order) should run when a change is made to
        //a record our test trigger is pointing to
        List<Trigger_Handler__c> handlers = new List<Trigger_Handler__c>();
        
        //Create some synchronous classes
        for(Integer i=0; i<100; i++) {
            handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'TDTM_Runnable_Impl', Load_Order__c = i, Object__c = 'Campaign', 
              Trigger_Action__c = 'BeforeInsert'));
        } 
        
        //Create some asynchronous classes
        for(Integer i=0; i<100; i++) {
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = true, 
              Class__c = 'TDTM_Runnable_Impl', Load_Order__c = i, Object__c = 'Campaign', 
              Trigger_Action__c = 'BeforeInsert')); 
        }
        
        insert handlers;
        
        //Make a change that makes our test trigger run
        Test.startTest();
        Long startTime = System.currentTimeMillis();
        insert new Campaign(Name='ObjectTest');
        Long endTime = System.currentTimeMillis();
        Long diff = endTime - startTime;
        System.debug(LoggingLevel.ERROR, '****manyClassesOneRecordChange - Using Objects took ' + diff + ' millis');
        Test.stopTest();
        
        //Verify that the class run - that is, that the database change that the class makes was 
        //performed
        List<Contact> contacts = [select FirstName, LastName from Contact];
        //Since we are using the alreadyCalled flag the class will only be called once. That's ok,
        //since we already tested performance without the flag.
        //System.assertEquals(200, contacts.size());
        System.assertEquals(1, contacts.size());
    }
    
    public static testmethod void manyRecordChangesOneClass() {
    	//Define which classes (and in which order) should run when a change is made to
        //a record our test trigger is pointing to
        List<Trigger_Handler__c> handlers = new List<Trigger_Handler__c>();
        
        //This one is synchronous
        handlers.add(new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'TDTM_Runnable_Impl', Load_Order__c = 1, Object__c = 'Campaign', 
              Trigger_Action__c = 'BeforeInsert')); 
        
        insert handlers;
        
        List<Campaign> campaigns = new List<Campaign>();
        for(Integer i=0; i<200; i++) {
        	campaigns.add(new Campaign(Name='ObjectTest' + i));
        }
        
        //Make a change that makes our test trigger run
        Test.startTest();
        Long startTime = System.currentTimeMillis();
        insert campaigns;
        Long endTime = System.currentTimeMillis();
        Long diff = endTime - startTime;
        System.debug(LoggingLevel.ERROR, '****manyRecordChangesOneClass - Using Objects took ' + diff + ' millis');
        Test.stopTest();
        
        //Verify that the class run
        List<Contact> contacts = [select FirstName, LastName from Contact];
        System.assertEquals(200, contacts.size());
    }
}