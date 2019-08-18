Public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod (label='Post Opportunity To PMS' Description='Callout')
	Public static void postOpportunityToPMS(List<Id> oppIds){
        
        Opportunity opp = [select id,  Name, Account.Name, closedate, amount from Opportunity where id =: oppIds[0]];
        system.debug('opp = ' + opp);
        ID JobID = System.enqueueJob(new QueueablePMSCall(opp));
        
       }
    
    public class QueueablePMSCall implements System.Queueable ,  Database.AllowsCallouts{
        
        private String jsonString;
        private Opportunity opp;
        
        public QueueablePMSCall(Opportunity oppToUpdate){
        	this.opp = oppToUpdate;	
            system.debug('opp = ' + opp);
            //Convert to json 
            JSONGenerator gen = JSON.createGenerator(false);
            
                gen.writeStartObject();
                gen.writeStringField('opportunityId', opp.Id);
                gen.writeStringField('opportunityName', opp.Name);
                gen.writeStringField('accountName', opp.Account.Name);
                gen.writeDateField('closeDate', opp.closedate);
                gen.writeNumberField('amount', opp.amount);
                gen.writeEndObject();
            jsonString = gen.getAsString();
            system.debug(jsonString);	
            
        }
        
        public void execute(System.QueueableContext context){
            //get Token
              	ServiceTokens__c st = ServiceTokens__c.getValues('ProjectServiceToken');
            	system.debug('token = ' + st.Token__c);
            
            //setup new httpRequest
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ProjectService/');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('token', st.Token__c);
            req.setBody(jsonString);
            
            //Setup new http call
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            if (res.getStatusCode() == 201) {
            	opp.StageName = 'Submitted Project';
            }else{
                opp.StageName = 'Resubmit Project';
            }
            
            update opp;
           }
      
    	}
    }