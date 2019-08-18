@isTest
private class ProjectRESTServiceTest {
    
    @TestSetup
    private Static Void testSetup(){
        //set up acc and opp
        Account acc = new Account(Name='test acc');
        insert acc;        
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Closed/Won', AccountId=acc.Id, closedate=date.today(), amount=500000);
        insert opp;
    }
    @isTest
    private Static void testRestSuccess(){
     List<Opportunity> opps = [select id from opportunity limit 1];
     Id OpportunityId = opps[0].Id;   
     Date StartDate = date.today();
     Date EndDate = date.today();
     String result = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', OpportunityId, 'Billed', StartDate, EndDate, 500);
     system.debug('result =' + result);
        
    }
    @isTest
    private Static void testRestFail(){
     List<Opportunity> opps = [select id from opportunity limit 1];
     Id OpportunityId = opps[0].Id;   
     Date StartDate = date.today();
     Date EndDate = date.today();
     String result = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', OpportunityId, 'Billedd', StartDate, EndDate, 500);
     system.debug('result =' + result);
        
    }
}