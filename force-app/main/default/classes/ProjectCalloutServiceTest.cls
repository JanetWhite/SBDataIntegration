@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here
 
    	@testSetup
    static void testData(){
        
        //set up acc and opp
        Account acc = new Account(Name='test acc');
        insert acc;        
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Closed/Won', AccountId=acc.Id, closedate=date.today(), amount=500000);
        insert opp;
        ServiceTokens__c st = new ServiceTokens__c(name='ProjectServiceToken', Token__c = 'TestToken');
        insert st;
    }
    
        @isTest static void testSuccess() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        
        List<Opportunity> opps = [select id from opportunity limit 1];
        List<Id> oppIds = new List<ID>();
        oppIds.add(opps[0].Id);
            system.debug('oppIds' + oppIds);
        // Call method to test.
        test.StartTest();
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        test.StopTest();
        
        Opportunity opp = [select id, stagename from opportunity where id =: oppids[0]];
            
        System.assertEquals(opp.StageName, 'Submitted Project');
    }
    
    @isTest static void testFail() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        
        List<Opportunity> opps = [select id from opportunity limit 1];
        List<Id> oppIds = new List<ID>();
        oppIds.add(opps[0].Id);
        // Call method to test.
        test.StartTest();
        ProjectCalloutService.postOpportunityToPMS(oppIds);
        test.StopTest();
        
        Opportunity opp = [select id, stagename from opportunity where id =: oppids[0]];
            
        System.assertEquals(opp.StageName, 'Resubmit Project');
    }
}