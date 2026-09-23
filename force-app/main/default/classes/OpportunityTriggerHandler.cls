public with sharing class OpportunityTriggerHandler {

    public static void afterUpdate(
        List<Opportunity> newOpportunities,
        Map<Id, Opportunity> oldMap
    ) {

        Set<Id> accountIds = new Set<Id>();

        for (Opportunity newOpp : newOpportunities) {

            Opportunity oldOpp = oldMap.get(newOpp.Id);

            Boolean relevantChange =
                newOpp.StageName != oldOpp.StageName ||
                newOpp.CloseDate != oldOpp.CloseDate ||
                newOpp.AccountId != oldOpp.AccountId ||
                newOpp.Amount != oldOpp.Amount ||
                newOpp.Financial_Rate__c != oldOpp.Financial_Rate__c;

            if (relevantChange) {

                if (oldOpp.AccountId != null) {
                    accountIds.add(oldOpp.AccountId);
                }

                if (newOpp.AccountId != null) {
                    accountIds.add(newOpp.AccountId);
                }
            }
        }

        CustomerPurchaseService.recalculate(accountIds);
    }


    public static void afterInsert(List<Opportunity> newOpportunities) {

        Set<Id> accountIds = new Set<Id>();

        for (Opportunity opp : newOpportunities) {

            if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        CustomerPurchaseService.recalculate(accountIds);
    }


    public static void afterDelete(List<Opportunity> oldOpportunities) {

        Set<Id> accountIds = new Set<Id>();

        for (Opportunity opp : oldOpportunities) {

            if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        CustomerPurchaseService.recalculate(accountIds);
    }

    public static void afterUndelete(List<Opportunity> restoredOpportunities) {

    Set<Id> accountIds = new Set<Id>();

    for (Opportunity opp : restoredOpportunities) {

        if (opp.StageName == 'Closed Won' && opp.AccountId != null) {
            accountIds.add(opp.AccountId);
        }
    }

    CustomerPurchaseService.recalculate(accountIds);
}

}