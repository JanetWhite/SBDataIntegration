trigger ProjectTrigger on Project__c (after update) {
    //Call the Billing Service callout logic here
    BillingCalloutService.callBillingService(Trigger.NewMap, Trigger.OldMap);
}