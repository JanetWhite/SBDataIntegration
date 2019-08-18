@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
    @TestSetup
    private Static Void testSetup(){
        //set up acc and opp
        Account acc = new Account(Name='test acc');
        insert acc;        
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Closed/Won', AccountId=acc.Id, closedate=date.today(), amount=500000);
        insert opp;
        ServiceCredentials__c credentials = new ServiceCredentials__c(name='BillingServiceCredential', Username__c ='testU', password__c='testP');
        insert credentials;
    }
    
    @istest
    private static void testSuccess(){
        
        Id oppId = [select Id from Opportunity where Name='Test Opp' limit 1].Id;
  		Project__c proj = new Project__c(Opportunity__c = oppId, Billable_Amount__c=500, ProjectRef__c='001', Status__c='Running');
        insert proj;
        
        Map<Id, Project__c> oldMap = new Map<Id, Project__c>();
        oldMap.put(proj.Id, proj);
        
        proj.Status__c = 'Billable';
        update proj;
        
        Map<Id, Project__c> newMap = new Map<Id, Project__c>();
        newMap.put(proj.Id, proj);
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        
        // Call the method that invokes a callout
        test.StartTest();
        BillingCalloutService.callBillingService(newMap, oldMap);
        test.stopTest();
        
        // Verify the result 
        proj = [select Status__c from Project__c where id =: proj.id];
        system.assertEquals(proj.Status__c,'Billed');
    }
    
    @istest
    private static void testFailure(){
        
        Id oppId = [select Id from Opportunity where Name='Test Opp' limit 1].Id;
  		Project__c proj = new Project__c(Opportunity__c = oppId, Billable_Amount__c=500, ProjectRef__c='001', Status__c='Running');
        insert proj;
        
        Map<Id, Project__c> oldMap = new Map<Id, Project__c>();
        oldMap.put(proj.Id, proj);
        
        proj.Status__c = 'Billable';
        update proj;
        
        Map<Id, Project__c> newMap = new Map<Id, Project__c>();
        newMap.put(proj.Id, proj);
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        
        // Call the method that invokes a callout
        test.StartTest();
        BillingCalloutService.callBillingService(newMap, oldMap);
        test.stopTest();
        
        // Verify the result 
        proj = [select Status__c from Project__c where id =: proj.id];
        system.debug(proj);
        system.assertEquals(proj.Status__c,'Billable');
    }
}