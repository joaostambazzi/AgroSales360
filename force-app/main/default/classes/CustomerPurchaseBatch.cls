public without sharing class CustomerPurchaseBatch
    implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {

        return Database.getQueryLocator([
            SELECT Id
            FROM Account
        ]);
    }

    public void execute(
        Database.BatchableContext context,
        List<SObject> scope
    ) {

        Set<Id> accountIds = new Set<Id>();

        for (SObject record : scope) {
            accountIds.add(record.Id);
        }

        CustomerPurchaseService.recalculate(accountIds);
    }

    public void finish(Database.BatchableContext context) {

    }
}