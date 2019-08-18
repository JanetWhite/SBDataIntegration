public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap){
        
        //Check if the status has changed to the required value:
        for(Project__c p : newMap.Values()){
            if(p.Status__c == 'Billable' && oldMap.get(p.Id).Status__c != p.Status__c){
                //do call out
                futureCallBillingService(p.Billable_Amount__c, p.ProjectRef__c);
            }
        }
    }
    
    @future(callout=true)
    public static void futureCallBillingService(decimal projbillAmount, String projectRef){
        
        ServiceCredentials__c credentials = ServiceCredentials__c.getInstance('BillingServiceCredential');
        system.debug(credentials);
        
        BillingServiceProxy.project project = new BillingServiceProxy.project();
        project.projectid = projectRef;
        project.billAmount = projbillAmount;
        project.username = credentials.Username__c;
        project.password = credentials.Password__c;

        BillingServiceProxy.InvoicesPortSoap11 bsp = new BillingServiceProxy.InvoicesPortSoap11();
        String results = bsp.billProject(project);
        system.debug(results);
        
       	Project__c proj = [Select Id, Status__c
                    From Project__c
                    Where ProjectRef__c = :projectRef];
        
        if(results != null && results.equalsIgnoreCase('OK')) {
                proj.Status__c = 'Billed';
                update proj;
            }
        
    }
        
}