@RestResource(urlMapping='/project/*')
global with Sharing class ProjectRESTService {
    //Implement service logic here
    
    @HttpPost
    global Static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, String Status, Date StartDate, Date EndDate, Double Amount) {
        	
        	Project__c thisProj = new Project__c();
        	//Check for existing project
        	List<Project__c> pList = [select id from Project__c where ProjectRef__c =: ProjectRef order by createdDate desc limit 1];
        	if(!pList.isEmpty()){
            	thisProj = pList[0];
        	}
            
        	//set savepoint before any data operations
            Savepoint sp = Database.setSavepoint();
            try{
                //updtate project 
            thisProj.ProjectRef__c= ProjectRef ;
            thisProj.Name= ProjectName;
            thisProj.Opportunity__c= OpportunityId;
            thisProj.Status__c= Status;
            thisProj.Start_Date__c= StartDate;
            thisProj.End_Date__c= EndDate;
            thisProj.Billable_Amount__c=Amount;
        
            //Get related opp
            Opportunity opp = [Select Id from Opportunity where id =: thisProj.Opportunity__c];
        
                upsert thisProj ProjectRef__c;
                opp.DeliveryInstallationStatus__c = 'In Progress';
            	update opp;
            }catch(DMLException e){
                system.debug('error' + e.getMessage());
                Database.Rollback(sp);
                return e.getMessage();
            }
            
            return 'OK';
            
    }   
    
}